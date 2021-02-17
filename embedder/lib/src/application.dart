import 'dart:ffi';
import 'dart:io';

import 'package:common/common.dart';
import 'package:ffi/ffi.dart';
import 'package:fl_rt_bindings/fl_rt_bindings.dart' as bindings;
import 'package:glfw_dart/glfw3.dart';
import 'package:path/path.dart' as path;

import 'config.dart';
import 'details.dart';
import 'engine.dart';

class Application {
  Application({
    this.config = const Config(),
    Details? details,
  }) : _details = details;

  Config config;

  late Pointer<GLFWwindow> window;

  late Pointer<GLFWwindow> resourceWindow;

  final Details? _details;

  late bindings.FlutterEmbedderBindings bindingsInstance;

  void run() {
    final details = Details.merge(Details.fromEnvironment(), _details);
    final executableDir = path.dirname(Platform.script.path);
    config = Config(
      flutterAssetsPath: config.flutterAssetsPath ??
          path.join(executableDir, 'flutter_assets'),
      icuDataPath: config.flutterAssetsPath ??
          path.join(executableDir, 'flutter_assets'),
      elfSnapshotPath:
          config.elfSnapshotPath ?? path.join(executableDir, 'libapp.so'),
      vmArguments: config.vmArguments ?? [],
      windowInitialDimensions: config.windowInitialDimensions ??
          WindowDimensions(
            width: 800,
            height: 600,
          ),
      windowMode: config.windowMode ?? WindowMode.windowModeDefault,
      windowAlwaysOnTop: config.windowAlwaysOnTop ?? false,
      windowTransparent: config.windowTransparent ?? false,
    );

    bindingsInstance = bindings.FlutterEmbedderBindings(
      DynamicLibrary.open(
        path.join(
          executableDir,
          'libflutter_engine.so',
        ),
      ),
    );
    glfw = Glfw(
      customPath: path.join(executableDir, glfwOutputFiles[osFromPlatform()]),
    );
    if (glfw.init() != GLFW_TRUE) {
      exit(-1);
    }

    Pointer<GLFWmonitor> monitor = nullptr.cast();
    switch (config.windowMode!) {
      case WindowMode.windowModeDefault:
        // Nothing
        break;
      case WindowMode.windowModeMaximize:
        glfw.windowHint(GLFW_MAXIMIZED, GLFW_TRUE);
        break;
      case WindowMode.windowModeBorderlessMaximize:
        glfw.windowHint(GLFW_MAXIMIZED, GLFW_TRUE);
        glfw.windowHint(GLFW_DECORATED, GLFW_FALSE);
        break;
      case WindowMode.windowModeBorderless:
        glfw.windowHint(GLFW_DECORATED, GLFW_FALSE);
        break;
      case WindowMode.windowModeBorderlessFullscreen:
        monitor = glfw.getPrimaryMonitor();
        final mode = glfw.getVideoMode(monitor).ref;
        config.windowInitialDimensions!.width = mode.width;
        config.windowInitialDimensions!.height = mode.height;
        glfw.windowHint(GLFW_RED_BITS, mode.redBits);
        glfw.windowHint(GLFW_GREEN_BITS, mode.greenBits);
        glfw.windowHint(GLFW_BLUE_BITS, mode.blueBits);
        glfw.windowHint(GLFW_REFRESH_RATE, mode.refreshRate);
        break;
    }

    glfw.postEmptyEvent();
    if (config.windowInitialLocation != null) {
      glfw.windowHint(GLFW_VISIBLE, GLFW_FALSE);
    }
    // GLFW_SCALE_TO_MONITOR
    // https://github.com/glfw/glfw/blob/1ed1489831e32337c13fbcbac2c2562ac4163bd3/include/GLFW/glfw3.h#L1060
    glfw.windowHint(0x0002200C, GLFW_TRUE);
    if (config.windowAlwaysOnTop!) {
      glfw.windowHint(GLFW_FLOATING, GLFW_TRUE);
    }
    if (config.windowTransparent!) {
      // GLFW_TRANSPARENT_FRAMEBUFFER
      // https://github.com/glfw/glfw/blob/1ed1489831e32337c13fbcbac2c2562ac4163bd3/include/GLFW/glfw3.h#L885
      glfw.windowHint(0x0002000A, GLFW_TRUE);
    }
    if (Platform.isLinux) {
      glfw.windowHint(GLFW_CONTEXT_CREATION_API, GLFW_EGL_CONTEXT_API);
    }

    window = glfw.createWindow(
      config.windowInitialDimensions!.width,
      config.windowInitialDimensions!.height,
      details.projectName.toNativeUtf8(),
      monitor,
      nullptr,
    );
    if (window == nullptr) {
      glfw.terminate();
      exit(-1);
    }
    glfw.defaultWindowHints();
    if (config.windowInitialLocation != null) {
      glfw.setWindowPos(
        window,
        config.windowInitialLocation!.xPos,
        config.windowInitialLocation!.yPos,
      );
      glfw.showWindow(window);
    }
    _createResourceWindow();

    if (config.windowIconProvider != null) {
      // TODO: Implement window icon
    }

    glfw.setWindowTitle(window, details.projectName.toNativeUtf8());

    if (config.windowDimensionLimits != null) {
      glfw.setWindowSizeLimits(
        window,
        config.windowDimensionLimits!.minWidth,
        config.windowDimensionLimits!.minHeight,
        config.windowDimensionLimits!.maxWidth,
        config.windowDimensionLimits!.maxHeight,
      );
    }

    FlutterEngine.assetsPath = config.flutterAssetsPath!;
    FlutterEngine.icuDataPath = config.icuDataPath!;
    FlutterEngine.elfSnapshotPath = config.elfSnapshotPath!;
    FlutterEngine.window = window;
    FlutterEngine.resourceWindow = resourceWindow;
    FlutterEngine.run(
      config.vmArguments!,
      bindingsInstance,
    );

    while (glfw.windowShouldClose(window) == GLFW_FALSE) {
      glfw.waitEventsTimeout(1);
    }
    FlutterEngine.shutdown(bindingsInstance);
    glfw.destroyWindow(resourceWindow);
    glfw.destroyWindow(window);
    glfw.terminate();
  }

  void _createResourceWindow() {
    glfw.windowHint(GLFW_DECORATED, GLFW_FALSE);
    glfw.windowHint(GLFW_VISIBLE, GLFW_FALSE);
    if (Platform.isLinux) {
      glfw.windowHint(GLFW_CONTEXT_CREATION_API, GLFW_EGL_CONTEXT_API);
    }
    resourceWindow = glfw.createWindow(
      1,
      1,
      ''.toNativeUtf8(),
      nullptr,
      window,
    );
    glfw.defaultWindowHints();
  }
}
