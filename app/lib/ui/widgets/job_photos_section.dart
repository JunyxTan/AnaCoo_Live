import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/database.dart';
import '../../l10n/app_strings.dart';
import '../../providers/providers.dart';
import 'common.dart';

/// Cloth / garment photo strip for a saved job.
class JobPhotosSection extends ConsumerWidget {
  const JobPhotosSection({super.key, required this.jobId});

  final int jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final photos = ref.watch(jobPhotosProvider(jobId)).value ?? const <JobPhoto>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          strings.clothPhotos,
          count: photos.isEmpty ? null : photos.length,
          icon: Icons.photo_library_outlined,
          trailing: IconButton(
            tooltip: strings.addPhoto,
            onPressed: () => unawaited(_addPhoto(context, ref, strings)),
            icon: const Icon(Icons.add_a_photo_outlined),
          ),
        ),
        if (photos.isEmpty)
          EmptyState(
            message: strings.noClothPhotos,
            icon: Icons.checkroom_outlined,
          )
        else
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final photo = photos[index];
                return _PhotoThumb(
                  photo: photo,
                  deleteTooltip: strings.delete,
                  onOpen: () => unawaited(_openPhoto(context, ref, photo)),
                  onDelete: () =>
                      unawaited(_deletePhoto(context, ref, strings, photo)),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _addPhoto(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
  ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(strings.takePhoto),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(strings.choosePhoto),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (picked == null || !context.mounted) return;

    await ref.read(jobRepositoryProvider).addClothPhoto(
          jobId,
          File(picked.path),
        );
  }

  Future<void> _deletePhoto(
    BuildContext context,
    WidgetRef ref,
    AppStrings strings,
    JobPhoto photo,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(strings.deletePhotoConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(jobRepositoryProvider).deleteClothPhoto(photo);
  }

  Future<void> _openPhoto(
    BuildContext context,
    WidgetRef ref,
    JobPhoto photo,
  ) async {
    final file =
        await ref.read(clothPhotoStoreProvider).absoluteFile(photo.relativePath);
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: InteractiveViewer(
          child: Image.file(file, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _PhotoThumb extends ConsumerWidget {
  const _PhotoThumb({
    required this.photo,
    required this.deleteTooltip,
    required this.onOpen,
    required this.onDelete,
  });

  final JobPhoto photo;
  final String deleteTooltip;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return FutureBuilder<File>(
      future: ref.read(clothPhotoStoreProvider).absoluteFile(photo.relativePath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        return Stack(
          children: [
            Material(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: file == null ? null : onOpen,
                child: SizedBox(
                  width: 112,
                  height: 112,
                  child: file == null
                      ? const Center(child: CircularProgressIndicator())
                      : Image.file(file, fit: BoxFit.cover),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                shape: const CircleBorder(),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints.tightFor(width: 32, height: 32),
                  padding: EdgeInsets.zero,
                  tooltip: deleteTooltip,
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
