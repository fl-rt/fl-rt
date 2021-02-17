import 'dart:io';

import 'package:path/path.dart' as path;

import '../fl_rt.dart';

class CopyEngineTask implements Task {
  @override
  String name = 'CopyEngineTask';

  @override
  Future run([dynamic args]) async {
    final buildInfo = args as BuildInfo;
    final cacheDirPath = path.join(getCacheDir(), 'engine',
        '${buildInfo.targetOS.name}-${buildInfo.buildMode.artifactName}');
    final buildDir = getBuildDir(buildInfo);
    for (final artifact in getEngineFiles(buildInfo)..add('icudtl.dat')) {
      File(path.join(cacheDirPath, artifact))
          .copySync(path.join(buildDir, artifact));
    }
  }
}
