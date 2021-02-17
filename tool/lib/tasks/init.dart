import 'dart:io';

import 'package:path/path.dart' as path;

import '../fl_rt.dart';

class InitTask implements Task {
  @override
  String name = 'InitTask';

  @override
  Future run([dynamic args]) async {
    final binDirPath = path.absolute('bin');
    if (!Directory(binDirPath).existsSync()) {
      Directory(binDirPath).createSync(recursive: true);
    }
    final mainFile = File(path.join(binDirPath, 'fl_rt.dart'));
    if (mainFile.existsSync()) {
      print('bin/fl_rt.dart already exists.');
      exit(1);
    }
    mainFile.writeAsStringSync('''
import 'package:fl_rt_embedder/fl_rt_embedder.dart';

void main() {
  Application().run();
}
''');
  }
}
