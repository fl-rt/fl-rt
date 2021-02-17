import 'dart:io';

import 'package:path/path.dart' as path;

import '../fl_rt.dart';

class RunTask implements Task {
  @override
  String name = 'RunTask';

  @override
  Future run([dynamic args]) async {
    final buildInfo = args as BuildInfo;
    final executablePath =
        path.join(getBuildDir(buildInfo), getExecutableFileName(buildInfo));
    await Process.start(executablePath, []).then(handleCommandOutput);
  }
}
