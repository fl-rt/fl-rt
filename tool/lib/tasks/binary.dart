import 'dart:io';

import 'package:path/path.dart' as path;

import '../fl_rt.dart';

class BinaryTask implements Task {
  @override
  String name = 'BinaryTask';

  @override
  Future run([dynamic args]) async {
    final buildInfo = args as BuildInfo;
    final buildDirPath = getBuildDir(buildInfo);
    if (!Directory(buildDirPath).existsSync()) {
      Directory(buildDirPath).createSync(recursive: true);
    }
    final dart2nativeExecutable = path.normalize(path.join(
      buildInfo.flutterRoot,
      'bin',
      'cache',
      'dart-sdk',
      'bin',
      'dart2native',
    ));
    await Process.start(
      dart2nativeExecutable,
      [
        path.join('bin', 'fl_rt.dart'),
        '--output=${path.join(getBuildDir(buildInfo), getExecutableFileName(buildInfo))}',
        '--define=$kProjectName=${buildInfo.projectName}',
        '--save-debugging-info=${path.join(getBuildDir(buildInfo), '${buildInfo.projectName}.debug')}',
      ],
    ).then(handleCommandOutput);
  }
}
