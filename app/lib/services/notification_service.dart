import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../domain/notification_plan.dart';

/// What the OS is currently willing to let the app do. Surfaced verbatim in
/// Settings — if reminders will be inexact, the tailor is told so plainly
/// rather than finding out by missing a drop-off.
class NotificationCapabilities {
  const NotificationCapabilities({
    required this.notificationsAllowed,
    required this.exactAlarmsAllowed,
    required this.maxPending,
  });

  final bool notificationsAllowed;

  /// Android 12+ `SCHEDULE_EXACT_ALARM`. Always true on iOS, which has no
  /// equivalent restriction.
  final bool exactAlarmsAllowed;

  /// iOS refuses to hold more than 64 pending notifications per app.
  final int maxPending;

  static const NotificationCapabilities unknown = NotificationCapabilities(
    notificationsAllowed: false,
    exactAlarmsAllowed: false,
    maxPending: 60,
  );
}

/// The narrow surface `NotificationScheduler` needs.
///
/// Extracted so the scheduler can be tested against an in-memory double — the
/// zero-orphan guarantee is exactly the kind of thing that must be provable
/// without a device attached.
abstract class NotificationSink {
  Future<NotificationCapabilities> capabilities();

  Future<void> schedule({
    required int id,
    required PlannedNotification notification,
    required bool useExactAlarms,
  });

  Future<void> cancel(int id);

  Future<void> cancelAll();
}

/// Thin wrapper over `flutter_local_notifications`.
///
/// Deliberately dumb: it schedules and cancels what it is told to, and knows
/// nothing about jobs or appointments. All the deciding happens in
/// `planNotifications` and `NotificationScheduler`.
class NotificationService implements NotificationSink {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String reminderChannelId = 'anacoo_reminders';
  static const String agendaChannelId = 'anacoo_agenda';
  static const String nudgeChannelId = 'anacoo_nudges';

  bool _initialised = false;

  /// Set by the tap handler installed in [initialize].
  void Function(String payload)? onNotificationTapped;

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> initialize() async {
    if (_initialised || !isSupported) return;
    _initialised = true;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      // Permission is requested on the first schedule, not at cold start, so
      // the prompt lands with context instead of on a blank first launch.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) onNotificationTapped?.call(payload);
      },
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          reminderChannelId,
          'Appointment reminders',
          description: 'Ahead-of-time reminders for drop-offs and collections.',
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          agendaChannelId,
          'Daily agenda',
          description: 'A morning summary of the day ahead.',
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          nudgeChannelId,
          'Overdue nudges',
          description: 'Collections past their date and orders waiting for pickup.',
        ),
      );
    }
  }

  /// Asks for whatever the platform needs. Safe to call repeatedly — both
  /// platforms no-op once the user has answered.
  Future<NotificationCapabilities> requestPermissions() async {
    if (!isSupported) return NotificationCapabilities.unknown;
    await initialize();

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission() ?? false;
      final exact = await android?.canScheduleExactNotifications() ?? false;
      return NotificationCapabilities(
        notificationsAllowed: granted,
        exactAlarmsAllowed: exact,
        maxPending: 400,
      );
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final granted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
    return NotificationCapabilities(
      notificationsAllowed: granted,
      exactAlarmsAllowed: true,
      maxPending: 60,
    );
  }

  /// Reads current capability without prompting.
  @override
  Future<NotificationCapabilities> capabilities() async {
    if (!isSupported) return NotificationCapabilities.unknown;
    await initialize();
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return NotificationCapabilities(
        notificationsAllowed: await android?.areNotificationsEnabled() ?? false,
        exactAlarmsAllowed: await android?.canScheduleExactNotifications() ?? false,
        maxPending: 400,
      );
    }
    return const NotificationCapabilities(
      notificationsAllowed: true,
      exactAlarmsAllowed: true,
      maxPending: 60,
    );
  }

  /// Opens the Android "Alarms & reminders" screen so the tailor can grant
  /// exact alarms after the fact.
  Future<void> requestExactAlarmPermission() async {
    if (!isSupported || !Platform.isAndroid) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  @override
  Future<void> schedule({
    required int id,
    required PlannedNotification notification,
    required bool useExactAlarms,
  }) async {
    if (!isSupported) return;
    await initialize();
    await _plugin.zonedSchedule(
      id: id,
      title: notification.title,
      body: notification.body,
      scheduledDate: notification.fireAt,
      payload: notification.payload,
      // Inexact is the graceful fallback when SCHEDULE_EXACT_ALARM is denied:
      // a reminder that lands a few minutes late still beats none at all.
      androidScheduleMode: useExactAlarms
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: _detailsFor(notification.kind),
    );
  }

  @override
  Future<void> cancel(int id) async {
    if (!isSupported) return;
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    if (!isSupported) return;
    await _plugin.cancelAll();
  }

  Future<List<PendingNotificationRequest>> pending() async {
    if (!isSupported) return const [];
    return _plugin.pendingNotificationRequests();
  }

  /// The payload of the notification that launched the app, if any.
  Future<String?> launchPayload() async {
    if (!isSupported) return null;
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }

  NotificationDetails _detailsFor(NotificationKind kind) {
    final (channelId, channelName, importance) = switch (kind) {
      NotificationKind.reminder =>
        (reminderChannelId, 'Appointment reminders', Importance.high),
      NotificationKind.agenda =>
        (agendaChannelId, 'Daily agenda', Importance.defaultImportance),
      NotificationKind.overdueCollection ||
      NotificationKind.readyNudge =>
        (nudgeChannelId, 'Overdue nudges', Importance.defaultImportance),
    };
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: importance,
        priority: importance == Importance.high
            ? Priority.high
            : Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
