import 'dart:io';

import 'package:path/path.dart' as path;

import '../fl_rt.dart';

class FlutterBundleTask implements Task {
  @override
  String name = 'FlutterBundleTask';

  @override
  Future run([dynamic args]) async {
    final buildInfo = args as BuildInfo;
    await Process.start(
      'flutter',
      [
        'build',
        'bundle',
        '--target=${buildInfo.targetFile}',
        if (buildInfo.buildMode != BuildMode.debug) ...[
          '--no-track-widget-creation',
        ],
        //if (buildInfo.buildMode == BuildMode.debug) '--debug',
        //if (buildInfo.buildMode == BuildMode.release) '--release',
        //if (buildInfo.buildMode == BuildMode.profile) '--profile',
      ],
    ).then(handleCommandOutput);
    final assetsDir =
        Directory(path.join(getBuildDir(buildInfo), 'flutter_assets'));
    if (!assetsDir.existsSync()) {
      assetsDir.createSync(recursive: true);
    }
    Directory(path.join('build', 'flutter_assets')).copySync(assetsDir);
    File(path.join(assetsDir.path, '.last_build_id')).deleteSync();
    File(path.join(assetsDir.path, 'NOTICES')).deleteSync();
  }
}

extension DirectoryCopy on Directory {
  void copySync(Directory destination) {
    _copyDirectory(this, destination);
  }

  void _copyDirectory(Directory source, Directory destination) {
    for (final entity in source.listSync()) {
      if (entity is Directory) {
        final newDirectory = Directory(
            path.join(destination.absolute.path, path.basename(entity.path)))
          ..createSync();
        _copyDirectory(entity.absolute, newDirectory);
      } else if (entity is File) {
        entity
            .copySync(path.join(destination.path, path.basename(entity.path)));
      }
    }
  }
}
