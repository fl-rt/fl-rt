import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

import '../fl_rt.dart';

class CollectBuildInfoTask implements Task {
  @override
  String name = 'CollectBuildInfoTask';

  @override
  Future run([dynamic args]) async {
    final buildDebug = args[0] as bool;
    final buildRelease = args[1] as bool;
    final buildProfile = args[2] as bool;
    final defaultBuildMode = args[3] as BuildMode;
    final targetFile = args[4] as String;
    int flagCount = 0;
    if (buildDebug) {
      flagCount++;
    }
    if (buildRelease) {
      flagCount++;
    }
    if (buildProfile) {
      flagCount++;
    }
    if (flagCount > 1) {
      print('Only provide on of --$kDebug, --$kRelease, --$kProfile');
      exit(1);
    }
    late BuildMode buildMode;
    if (flagCount == 0) {
      buildMode = defaultBuildMode;
    }
    if (buildDebug) {
      buildMode = BuildMode.debug;
    }
    if (buildRelease) {
      buildMode = BuildMode.release;
    }
    if (buildProfile) {
      buildMode = BuildMode.profile;
    }

    final pubspecFile = File('pubspec.yaml');
    final pubspec = loadYaml(await pubspecFile.readAsString()) as YamlMap;

    final result = await Process.run(
      'flutter',
      [
        '--version',
        '--machine',
      ],
    );
    if (result.exitCode != 0) {
      print(result.stdout);
      print(result.stderr);
      exit(result.exitCode);
    }
    final flutterVersionJson =
        json.decode(result.stdout as String) as Map<String, dynamic>;
    return BuildInfo(
      projectName: pubspec['name'] as String,
      targetFile: targetFile,
      targetOS: osFromString(args[5] as String),
      buildMode: buildMode,
      flutterChannel: flutterVersionJson['channel'] as String,
      flutterEngineVersion: flutterVersionJson['engineRevision'] as String,
      flutterRoot: flutterVersionJson['flutterRoot'] as String,
    );
  }
}
