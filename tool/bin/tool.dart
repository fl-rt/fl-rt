import 'dart:io';

import 'package:args/args.dart';
import 'package:fl_rt/fl_rt.dart';

Future main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag(
      kHelp,
      help: 'Displays this help message',
      negatable: false,
    );
  final run = addBuildFlags(parser.addCommand(kRun));
  final build = addBuildFlags(parser.addCommand(kBuild));
  parser.addCommand(kInit);
  ArgResults results = parser.parse(args);
  if (results.arguments.isEmpty || results[kHelp] as bool) {
    print(parser.usage);
    exit(1);
  }
  final isRun = results.arguments[0] == kRun;
  final isBuild = results.arguments[0] == kBuild;
  final isInit = results.arguments[0] == kInit;
  await VerifyInProjectTask().run(isInit);
  if (isInit) {
    await InitTask().run();
  } else if (isRun || isBuild) {
    results = isRun ? run.parse(args.sublist(1)) : build.parse(args.sublist(1));
    final buildInfo = await CollectBuildInfoTask().run([
      results[kDebug],
      results[kRelease],
      results[kProfile],
      if (isRun) BuildMode.debug else BuildMode.release,
      results[kTarget],
      Platform.operatingSystem,
    ]) as BuildInfo;
    if (!(results[kSkipDownloadEngine] as bool)) {
      await DownloadEngineTask().run(buildInfo);
    }
    if (!(results[kSkipDownloadGLFW] as bool)) {
      await DownloadGLFWTask().run(buildInfo);
    }
    if (!(results[kSkipFlutterBundle] as bool)) {
      await FlutterBundleTask().run(buildInfo);
    }
    if (buildInfo.buildMode != BuildMode.debug &&
        !(results[kSkipFlutterAOT] as bool)) {
      await FlutterAOTTask().run(buildInfo);
    }
    if (!(results[kSkipBinary] as bool)) {
      await BinaryTask().run(buildInfo);
    }
    await CopyEngineTask().run(buildInfo);
    await CopyGLFWTask().run(buildInfo);
    if (isRun) {
      await RunTask().run(buildInfo);
    }
  }
}

ArgParser addBuildFlags(ArgParser command) => command
  ..addFlag(
    kDebug,
    help: 'Build app for debug mode',
  )
  ..addFlag(
    kRelease,
    help: 'Build app for release mode',
  )
  ..addFlag(
    kProfile,
    help: 'Build app for profile mode',
  )
  ..addFlag(
    kSkipFlutterBundle,
    help: 'Skip building the flutter bundle',
  )
  ..addFlag(
    kSkipFlutterAOT,
    help: 'Skip building the flutter AOT snapshot',
  )
  ..addFlag(
    kSkipBinary,
    help: 'Skip building the binary',
  )
  ..addFlag(
    kSkipDownloadEngine,
    help: 'Skip downloading the engine',
  )
  ..addFlag(
    kSkipDownloadGLFW,
    help: 'Skip downloading GLFW',
  )
  ..addOption(
    kTarget,
    help: 'Target file of the app',
    defaultsTo: 'lib/main.dart',
  );
