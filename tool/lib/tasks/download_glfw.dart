import 'dart:io';

import 'package:path/path.dart' as path;

import '../fl_rt.dart';

class DownloadGLFWTask implements Task {
  @override
  String name = 'DownloadGLFWTask';

  final String _glfwVersion = '3.3.2';
  final Map<OS, String> _glfwInputFiles = {
    OS.linux: 'libglfw.so.3.3',
    OS.darwin: 'libglfw.3.3.dylib',
    OS.windows: 'glfw3.dll',
  };

  @override
  Future run([dynamic args]) async {
    final buildInfo = args as BuildInfo;
    final cacheDirPath =
        path.join(getCacheDir(), 'glfw', buildInfo.targetOS.name);
    final versionFile = File(path.join(cacheDirPath, 'version'));
    String? currentVersion;
    if (versionFile.existsSync()) {
      currentVersion = versionFile.readAsStringSync();
    }
    if (currentVersion != _glfwVersion) {
      print('Updating ${buildInfo.targetOS.name} GLFW to $_glfwVersion...');
      final glfwFile =
          File(path.join(cacheDirPath, glfwOutputFiles[buildInfo.targetOS]));
      if (Directory(cacheDirPath).existsSync()) {
        Directory(cacheDirPath).deleteSync(recursive: true);
      }
      Directory(cacheDirPath).createSync(recursive: true);
      final url =
          'https://github.com/fl-rt/glfw-build/releases/download/$_glfwVersion/${_glfwInputFiles[buildInfo.targetOS]}';
      await HttpClient()
          .getUrl(Uri.parse(url))
          .then((request) => request.close())
          .then((response) => response.pipe(glfwFile.openWrite()));
      if (Platform.isLinux) {
        final result = await Process.run('strip', [
          '-s',
          glfwFile.path,
        ]);
        if (result.exitCode != 0) {
          print(result.stdout);
          print(result.stderr);
          exit(result.exitCode);
        }
      }
      versionFile.writeAsStringSync(_glfwVersion);
    }
  }
}
