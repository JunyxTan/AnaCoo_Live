import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies cloth photos into app-private storage and resolves them later.
///
/// Paths stored in the database are relative to [root], so tests can inject a
/// temporary directory without touching the real documents folder.
class ClothPhotoStore {
  ClothPhotoStore({Directory? root}) : _rootOverride = root;

  final Directory? _rootOverride;
  Directory? _cachedRoot;

  Future<Directory> get root async {
    final override = _rootOverride;
    if (override != null) return override;
    if (_cachedRoot != null) return _cachedRoot!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'cloth_photos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return _cachedRoot = dir;
  }

  Future<File> absoluteFile(String relativePath) async {
    final base = await root;
    return File(p.join(base.path, relativePath));
  }

  /// Copies [source] into `cloth_photos/{jobId}/{stamp}.ext` and returns the
  /// relative path to persist.
  Future<String> importPhoto({
    required int jobId,
    required File source,
  }) async {
    final base = await root;
    final jobDir = Directory(p.join(base.path, '$jobId'));
    if (!await jobDir.exists()) {
      await jobDir.create(recursive: true);
    }
    final ext = _extensionOf(source.path);
    final name =
        '${DateTime.now().toUtc().millisecondsSinceEpoch}_${Random().nextInt(1 << 20)}$ext';
    final relative = p.join('$jobId', name);
    final destination = File(p.join(base.path, relative));
    await source.copy(destination.path);
    return relative;
  }

  Future<void> deletePhoto(String relativePath) async {
    final file = await absoluteFile(relativePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteAllForJob(int jobId) async {
    final base = await root;
    final jobDir = Directory(p.join(base.path, '$jobId'));
    if (await jobDir.exists()) {
      await jobDir.delete(recursive: true);
    }
  }

  String _extensionOf(String path) {
    final ext = p.extension(path).toLowerCase();
    if (ext == '.png' || ext == '.webp' || ext == '.heic' || ext == '.jpeg') {
      return ext == '.jpeg' ? '.jpg' : ext;
    }
    return '.jpg';
  }
}
