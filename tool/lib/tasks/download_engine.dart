import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

import '../fl_rt.dart';

class DownloadEngineTask implements Task {
  @override
  String name = 'DownloadEngineTask';

  @override
  Future run([dynamic args]) async {
    final buildInfo = args as BuildInfo;
    final cacheDirPath = path.join(getCacheDir(), 'engine',
        '${buildInfo.targetOS.name}-${buildInfo.buildMode.artifactName}');
    final versionFile = File(path.join(cacheDirPath, 'version'));
    String? currentVersion;
    if (versionFile.existsSync()) {
      currentVersion = versionFile.readAsStringSync();
    }
    if (currentVersion != buildInfo.flutterEngineVersion) {
      print(
          'Updating ${buildInfo.targetOS.name}-${buildInfo.buildMode.artifactName} engine to ${buildInfo.flutterEngineVersion}...');
      final engineZip = File(path.join(cacheDirPath, 'engine.zip'));
      if (Directory(cacheDirPath).existsSync()) {
        Directory(cacheDirPath).deleteSync(recursive: true);
      }
      Directory(cacheDirPath).createSync(recursive: true);
      final url =
          'https://github.com/flutter-rs/engine-builds/releases/download/f-${buildInfo.flutterEngineVersion}/${buildInfo.targetOS.name}_x64-host_${buildInfo.buildMode.artifactName}.zip';
      await HttpClient()
          .getUrl(Uri.parse(url))
          .then((request) => request.close())
          .then((response) => response.pipe(engineZip.openWrite()))
          .catchError((error) {
        print(error);
        exit(1);
      });
      final archive = ZipDecoder().decodeBytes(engineZip.readAsBytesSync());
      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File(path.join(cacheDirPath, filename))
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory(path.join(cacheDirPath, filename))
              .createSync(recursive: true);
        }
      }
      if (Platform.isLinux || Platform.isMacOS) {
        final result = await Process.run('chmod', [
          '+x',
          path.join(cacheDirPath, 'dart'),
          path.join(cacheDirPath, 'gen_snapshot'),
        ]);
        if (result.exitCode != 0) {
          print(result.stdout);
          print(result.stderr);
          exit(result.exitCode);
        }
      }
      if (Platform.isLinux && buildInfo.buildMode != BuildMode.debug) {
        final result = await Process.run('strip', [
          '-s',
          path.join(cacheDirPath, getEngineFiles(buildInfo)[0]),
        ]);
        if (result.exitCode != 0) {
          print(result.stdout);
          print(result.stderr);
          exit(result.exitCode);
        }
      }
      versionFile.writeAsStringSync(buildInfo.flutterEngineVersion);
    }
  }
}
