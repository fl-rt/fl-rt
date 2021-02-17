import 'dart:ffi' as ffi;

import 'generated.dart';

// ignore_for_file: non_constant_identifier_names

class FlutterRendererConfig extends ffi.Struct {
  @ffi.Int32()
  external int type;

  external FlutterOpenGLRendererConfig open_gl;
}

class FlutterEngineAOTDataSource extends ffi.Struct {
  @ffi.Int32()
  external int type;

  external ffi.Pointer<ffi.Int8> elf_path;
}
