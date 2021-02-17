import 'dart:async';
import 'dart:io';

import 'package:common/common.dart';
import 'package:path/path.dart' as path;

export 'package:common/common.dart';

export 'tasks/binary.dart';
export 'tasks/binary.dart';
export 'tasks/collect_build_info.dart';
export 'tasks/copy_engine.dart';
export 'tasks/copy_glfw.dart';
export 'tasks/download_engine.dart';
export 'tasks/download_glfw.dart';
export 'tasks/flutter_aot.dart';
export 'tasks/flutter_bundle.dart';
export 'tasks/init.dart';
export 'tasks/run.dart';
export 'tasks/verify_in_project.dart';

const String kInit = 'init';
const String kRun = 'run';
const String kBuild = 'build';
const String kSkipFlutterBundle = 'skip-flutter-bundle';
const String kSkipFlutterAOT = 'skip-flutter-aot';
const String kSkipBinary = 'skip-binary';
const String kSkipDownloadEngine = 'skip-download-engine';
const String kSkipDownloadGLFW = 'skip-download-glfw';
const String kTarget = 'target';
const String kDebug = 'debug';
const String kRelease = 'release';
const String kProfile = 'profile';
const String kHelp = 'help';

class BuildInfo {
  BuildInfo({
    required this.projectName,
    required this.targetFile,
    required this.targetOS,
    required this.buildMode,
    required this.flutterChannel,
    required this.flutterEngineVersion,
    required this.flutterRoot,
  });

  final String projectName;

  final String targetFile;

  final OS targetOS;

  final BuildMode buildMode;

  final String flutterChannel;

  final String flutterEngineVersion;

  final String flutterRoot;
}

enum BuildMode {
  debug,
  release,
  profile,
}

extension BuildModeName on BuildMode {
  String get name {
    switch (this) {
      case BuildMode.debug:
        return 'debug';
      case BuildMode.release:
        return 'release';
      case BuildMode.profile:
        return 'profile';
    }
  }

  String get artifactName {
    switch (this) {
      case BuildMode.debug:
        return 'debug_unopt';
      case BuildMode.release:
        return 'release';
      case BuildMode.profile:
        return 'profile';
    }
  }
}

abstract class Task {
  Task(this.name);

  final String name;

  Future<dynamic> run([dynamic args]);
}

String getBuildDir(BuildInfo buildInfo) => path.absolute(path.join(
      'build',
      'fl-rt',
      '${buildInfo.targetOS.name}-${buildInfo.buildMode.name}',
    ));

String getExecutableFileName(BuildInfo buildInfo) =>
    '${buildInfo.projectName}${buildInfo.targetOS == OS.windows ? '.exe' : ''}';

String? getUserHomeDir() =>
    Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];

// This is hardcoded and ugly, but for now it's enough
String getCacheDir() => path.join(getUserHomeDir()!, '.cache', 'fl-rt');

List<String> getEngineFiles(BuildInfo buildInfo) {
  switch (buildInfo.targetOS) {
    case OS.linux:
      return ['libflutter_engine.so'];
    case OS.darwin:
      return ['libflutter_engine.dylib'];
    case OS.windows:
      if (buildInfo.buildMode == BuildMode.debug) {
        return ['flutter_engine.dll'];
      } else {
        return [
          'flutter_engine.dll',
          'flutter_engine.exp',
          'flutter_engine.lib',
          'flutter_engine.pdb',
        ];
      }
  }
}

Future<ProcessResult> handleCommandOutput(Process process) {
  final completer = Completer<ProcessResult>();
  try {
    stdout.addStream(process.stdout);
    stderr.addStream(process.stderr);
    // ignore: empty_catches
  } on Exception {}
  process.exitCode.then((exitCode) {
    if (exitCode != 0) {
      exit(exitCode);
    }
    completer.complete(ProcessResult(pid, exitCode, '', ''));
  });
  return completer.future;
}
