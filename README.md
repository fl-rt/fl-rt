# fl-rt

fl-rt is an experimental Flutter embedder written in Dart.

## Installation

Currently, fl-rt heavily depends on local dependencies, so you need to clone this repo and install fl-rt from there:

```bash
git clone https://github.com/fl-rt/fl-rt
cd fl-rt/tool
pub global activate -s path .
```

## App setup

Navigate to your app and run

```bash
fl-rt init
```

and add `fl_rt_embedder` as a `dev_dependency` to your app like this:

```yaml
dev_dependencies:
  fl_rt_embedder:
    path: ../embedder
```

You need to adjust the path accordingly to your fl-rt local installation (this one is for the example app).

## Example

This repo contains an example app at `example/`.  
To run it use `fl-rt run` and to build it use `fl-rt build`.

## Development

You can also run and build the example app using

```bash
dart ../tool/bin/tool.dart run
dart ../tool/bin/tool.dart build
```

## Status

Somewhere is an issue with memory management, so the application always crashes with a SEGFAULT.