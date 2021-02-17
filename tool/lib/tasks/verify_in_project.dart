import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

import '../fl_rt.dart';

class VerifyInProjectTask implements Task {
  @override
  String name = 'VerifyInProjectTask';

  @override
  Future run([dynamic args]) async {
    final isInit = args as bool;
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      print('Failed to find pubspec.yaml in current directory');
      exit(1);
    }
    final pubspec = loadYaml(await pubspecFile.readAsString());
    if (pubspec['dependencies'] == null) {
      print('Failed to find dependencies key in pubspec.yaml');
      exit(1);
    }
    if (pubspec['dependencies']['flutter'] == null) {
      print('Failed to find dependencies.flutter key in pubspec.yaml');
      print('This project is probably not a flutter project');
      exit(1);
    }
    if (!isInit && !File(path.join('bin', 'fl_rt.dart')).existsSync()) {
      print('Failed to find bin/fl_rt.dart. Please run "fl-rt init" first');
      exit(1);
    }
  }
}
