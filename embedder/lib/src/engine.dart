import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:fl_rt_bindings/fl_rt_bindings.dart' as bindings;
import 'package:glfw_dart/glfw3.dart';
import 'package:glfw_dart/glfw_dart.dart';
import 'package:path/path.dart' as path;

class FlutterEngine {
  static Pointer<bindings.FlutterEngine>? engine =
      malloc<Int8>(sizeOf<Pointer<bindings.FlutterEngine>>())
          .cast<bindings.FlutterEngine>();

  static late String assetsPath;

  static late String icuDataPath;

  static late String elfSnapshotPath;

  static late Pointer<bindings.FlutterEngineAOTData> aotData;

  static late Pointer<GLFWwindow> window;

  static late Pointer<GLFWwindow> resourceWindow;

  static void platformMessage(
      Pointer<bindings.FlutterPlatformMessage> message, Pointer<Void> data) {
    print('platform message');
    print(message.ref.channel.cast<Utf8>().toDartString());
    print(message.ref.message.cast<Utf8>().toDartString());
  }

  static int makeCurrent(Pointer<Void> data) {
    print('makeCurrent');
    glfw.makeContextCurrent(window);
    return 1;
  }

  static int makeResourceCurrent(Pointer<Void> data) {
    print('makeResourceCurrent');
    glfw.makeContextCurrent(resourceWindow);
    return 1;
  }

  static int clearCurrent(Pointer<Void> data) {
    print('clearCurrent');
    glfw.makeContextCurrent(nullptr);
    return 1;
  }

  static int present(Pointer<Void> data) {
    print('present');
    glfw.swapBuffers(window);
    return 1;
  }

  static int fboCallback(Pointer<Void> data) {
    print('fboCallback');
    return 0;
  }

  static Pointer<Void> glProcResolver(Pointer<Void> data, Pointer<Int8> name) {
    print('glProcResolver');
    print(name.cast<Utf8>().toDartString());
    return calloc<Void>();
  }

  static void run(
    List<String> vmArguments,
    bindings.FlutterEmbedderBindings bindingsInstance,
  ) {
    vmArguments.insert(0, path.basename(Platform.resolvedExecutable));
    final Pointer<Int8> a =
        malloc<Int8>(vmArguments.length * sizeOf<Pointer<Uint8>>());
    for (var i = 0; i < vmArguments.length; i++) {
      a.elementAt(i).value = vmArguments[i].toNativeUtf8().cast<Int8>().value;
    }
    final args = calloc<bindings.FlutterProjectArgs>();
    args.ref
      ..struct_size = sizeOf<bindings.FlutterProjectArgs>()
      ..assets_path = assetsPath.toNativeUtf8().cast<Int8>()
      ..icu_data_path = icuDataPath.toNativeUtf8().cast<Int8>()
      ..command_line_argv = (calloc<Pointer<Int8>>()..value = a)
      ..command_line_argc = vmArguments.length
      ..shutdown_dart_vm_when_done = 1
      ..main_path__unused__ = nullptr.cast()
      ..packages_path__unused__ = nullptr.cast()
      ..aot_data = nullptr.cast()
      ..isolate_snapshot_data = nullptr.cast()
      ..isolate_snapshot_data_size = 0
      ..isolate_snapshot_instructions = nullptr.cast()
      ..isolate_snapshot_instructions_size = 0
      ..vm_snapshot_data = nullptr.cast()
      ..vm_snapshot_data_size = 0
      ..vm_snapshot_instructions = nullptr.cast()
      ..vm_snapshot_instructions_size = 0
      ..custom_task_runners = nullptr.cast()
      ..vsync_callback = nullptr.cast()
      ..custom_dart_entrypoint = nullptr.cast()
      ..root_isolate_create_callback = nullptr
      ..platform_message_callback = Pointer.fromFunction(platformMessage);

    if (bindingsInstance.FlutterEngineRunsAOTCompiledDartCode()) {
      final dataIn = calloc<bindings.FlutterEngineAOTDataSource>();
      dataIn.ref
        ..type = bindings.FlutterEngineAOTDataSourceType
            .kFlutterEngineAOTDataSourceTypeElfPath
        ..elf_path = elfSnapshotPath.toNativeUtf8().cast<Int8>();
      aotData = malloc<Int8>(sizeOf<Pointer<bindings.FlutterEngineAOTData>>())
          .cast<bindings.FlutterEngineAOTData>();
      final result = bindingsInstance.FlutterEngineCreateAOTData(dataIn,
          (calloc<Pointer<bindings.FlutterEngineAOTData>>()..value = aotData));
      if (result != bindings.FlutterEngineResult.kSuccess) {
        exit(1);
      }
      args.ref.aot_data = aotData;
    }

    final Pointer<bindings.FlutterRendererConfig> config =
        calloc<bindings.FlutterRendererConfig>();
    final bindings.FlutterOpenGLRendererConfig rendererConfig =
        bindings.FlutterOpenGLRendererConfig()
          ..struct_size = sizeOf<bindings.FlutterOpenGLRendererConfig>()
          ..make_current =
              Pointer.fromFunction<bindings.BoolCallback>(makeCurrent, 1)
          ..make_resource_current = Pointer.fromFunction<bindings.BoolCallback>(
              makeResourceCurrent, 1)
          ..clear_current =
              Pointer.fromFunction<bindings.BoolCallback>(clearCurrent, 1)
          ..present = Pointer.fromFunction<bindings.BoolCallback>(present, 1)
          ..present_with_info = nullptr
          ..fbo_callback =
              Pointer.fromFunction<bindings.UIntCallback>(fboCallback, 0)
          ..fbo_with_frame_info_callback = nullptr
          ..gl_proc_resolver =
              Pointer.fromFunction<bindings.ProcResolver>(glProcResolver);
    config.ref.type = bindings.FlutterRendererType.kOpenGL;
    config.ref.open_gl = rendererConfig;

    final result = bindingsInstance.FlutterEngineRun(
      bindings.FLUTTER_ENGINE_VERSION,
      config,
      args,
      nullptr,
      calloc<Pointer<bindings.FlutterEngine>>()..value = engine!,
    );
    print(result);
    if (result != bindings.FlutterEngineResult.kSuccess || engine == null) {
      print('Failed to run engine');
      exit(1);
    }
  }

  static void shutdown(bindings.FlutterEmbedderBindings bindingsInstance) {
    int result = bindingsInstance.FlutterEngineShutdown(engine!);
    if (result != bindings.FlutterEngineResult.kSuccess) {
      exit(1);
    }
    if (bindingsInstance.FlutterEngineRunsAOTCompiledDartCode()) {
      result = bindingsInstance.FlutterEngineCollectAOTData(aotData);
      if (result != bindings.FlutterEngineResult.kSuccess) {
        exit(1);
      }
    }
  }
}
