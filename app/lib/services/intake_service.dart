import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../data/database.dart';
import '../domain/parser/appointment_request_parser.dart';
import '../domain/parser/text_cleaner.dart';

/// Where a piece of text arrived from. The import screen shows it, so a badly
/// parsed message can be traced back to how it got in.
enum IntakeSource { clipboard, shareSheet, manual }

class IntakeCandidate {
  const IntakeCandidate({
    required this.rawText,
    required this.source,
    this.parsed,
  });

  final String rawText;
  final IntakeSource source;

  /// Null when the text did not parse — the caller opens the manual form with
  /// [rawText] dropped into notes rather than showing an error.
  final ParsedRequest? parsed;

  bool get didParse => parsed != null;

  String get fingerprint => fingerprintOf(rawText);
}

/// The three ways a WhatsApp message gets into the app.
///
/// 1. The "Paste appointment" button reads the clipboard on demand.
/// 2. Android's share target and the iOS share extension push text in.
/// 3. On resume, the clipboard is checked once and a dismissible banner is
///    offered — never a silent background read, and never an automatic import.
class IntakeService {
  IntakeService(this.db);

  final AppDatabase db;

  final StreamController<IntakeCandidate> _shared =
      StreamController<IntakeCandidate>.broadcast();
  StreamSubscription<List<SharedMediaFile>>? _shareSubscription;

  /// Fingerprints declined during this run, so the banner does not nag about
  /// the same message twice before the app is restarted.
  final Set<String> _dismissed = {};

  Stream<IntakeCandidate> get sharedText => _shared.stream;

  Future<void> start() async {
    if (kIsWeb) return;
    // Text shared while the app was already running.
    _shareSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen(_onShared);
    // Text that launched the app.
    final initial = await ReceiveSharingIntent.instance.getInitialMedia();
    if (initial.isNotEmpty) {
      _onShared(initial);
      ReceiveSharingIntent.instance.reset();
    }
  }

  void _onShared(List<SharedMediaFile> media) {
    final text = media
        .where((m) => m.type == SharedMediaType.text || m.type == SharedMediaType.url)
        .map((m) => m.path)
        .where((value) => value.trim().isNotEmpty)
        .join('\n')
        .trim();
    if (text.isEmpty) return;
    _shared.add(
      IntakeCandidate(
        rawText: text,
        source: IntakeSource.shareSheet,
        parsed: parseAppointmentRequest(text),
      ),
    );
  }

  /// Reads the clipboard because the tailor asked for it. On iOS this triggers
  /// the system paste prompt, which is exactly the intended behaviour.
  Future<IntakeCandidate?> readClipboard({
    IntakeSource source = IntakeSource.clipboard,
  }) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text == null || text.isEmpty) return null;
    return IntakeCandidate(
      rawText: text,
      source: source,
      parsed: parseAppointmentRequest(text),
    );
  }

  /// On-resume check for the "Appointment request detected" banner.
  ///
  /// Returns a candidate only when the clipboard holds something that actually
  /// parses and has not already been imported or dismissed. Anything else
  /// returns null, so the banner never appears over ordinary copied text.
  Future<IntakeCandidate?> pollClipboardForBanner() async {
    final candidate = await readClipboard();
    if (candidate == null || !candidate.didParse) return null;
    if (_dismissed.contains(candidate.fingerprint)) return null;
    if (await db.isMessageImported(candidate.fingerprint)) return null;
    return candidate;
  }

  void dismiss(IntakeCandidate candidate) =>
      _dismissed.add(candidate.fingerprint);

  Future<void> markImported(IntakeCandidate candidate) =>
      db.markMessageImported(candidate.fingerprint);

  Future<void> dispose() async {
    await _shareSubscription?.cancel();
    await _shared.close();
  }
}
