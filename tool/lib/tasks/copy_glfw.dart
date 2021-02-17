import 'dart:io';

import 'package:path/path.dart' as path;

import '../fl_rt.dart';

class CopyGLFWTask implements Task {
  @override
  String name = 'CopyGLFWTask';

  @override
  Future run([dynamic args]) async {
    final buildInfo = args as BuildInfo;
    final cacheDirPath =
        path.join(getCacheDir(), 'glfw', buildInfo.targetOS.name);
    final buildDir = getBuildDir(buildInfo);
    File(path.join(cacheDirPath, glfwOutputFiles[buildInfo.targetOS]))
        .copySync(path.join(buildDir, glfwOutputFiles[buildInfo.targetOS]));
  }
}
