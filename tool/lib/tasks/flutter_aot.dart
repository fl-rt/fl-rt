import 'dart:io';

import 'package:path/path.dart' as path;

import '../fl_rt.dart';

class FlutterAOTTask implements Task {
  @override
  String name = 'FlutterAOTTask';

  @override
  Future run([dynamic args]) async {
    final buildInfo = args as BuildInfo;
    final buildDir = getBuildDir(buildInfo);
    final cacheDirPath = path.join(getCacheDir(), 'engine',
        '${buildInfo.targetOS.name}-${buildInfo.buildMode.artifactName}');
    for (final file in [
      'isolate_snapshot_data',
      'vm_snapshot_data',
      'kernel_blob.bin',
    ]) {
      File(path.join(buildDir, 'flutter_assets', file)).deleteSync();
    }
    final dart =
        path.join(cacheDirPath, 'dart${Platform.isWindows ? '.exe' : ''}');
    final frontendServerSnapshot =
        path.join(cacheDirPath, 'gen', 'frontend_server.dart.snapshot');
    final flutterPatchedSdk = path.join(cacheDirPath, 'flutter_patched_sdk');
    final kernelSnapshot = path.join(buildDir, 'kernel_snapshot.dill');
    final genSnapshot = path.join(
        cacheDirPath, 'gen_snapshot${Platform.isWindows ? '.exe' : ''}');
    final elfSnapshot = path.join(getBuildDir(buildInfo), 'libapp.so');
    await Process.start(
      dart,
      [
        frontendServerSnapshot,
        '--sdk-root=$flutterPatchedSdk',
        '--output-dill=$kernelSnapshot',
        '--target=flutter',
        '--aot',
        '--tfa',
        '-Ddart.vm.product=true',
        '--packages=.packages',
        buildInfo.targetFile,
      ],
    ).then(handleCommandOutput);
    await Process.start(
      genSnapshot,
      [
        '--elf=$elfSnapshot',
        '--no-causal-async-stacks',
        '--lazy-async-stacks',
        '--deterministic',
        '--snapshot_kind=app-aot-elf',
        if (buildInfo.buildMode == BuildMode.release) '--strip',
        kernelSnapshot,
      ],
    ).then(handleCommandOutput);
    File(kernelSnapshot).deleteSync();
  }
}
