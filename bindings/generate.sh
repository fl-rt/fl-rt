#!/usr/bin/env bash
set -ex

curl https://raw.githubusercontent.com/flutter/engine/master/shell/platform/embedder/embedder.h -o embedder.h

pub run ffigen

# Manual bindings because of unions
sed -i "s/class FlutterRendererConfig /class _FlutterRendererConfig /g" lib/generated.dart
sed -i "s/class FlutterEngineAOTDataSource /class _FlutterEngineAOTDataSource /g" lib/generated.dart

# Some fixes for the code
sed -i "s/ ? /SpaceQuestionMarkSpace/g" lib/generated.dart
sed -i "s/\? / /g" lib/generated.dart
sed -i "s/SpaceQuestionMarkSpace/ \? /g" lib/generated.dart
sed -i -z "s/\?\n/\n/g" lib/generated.dart

sed -i "s/_dart_FlutterEngineCreateAOTData _FlutterEngineCreateAOTData;/_dart_FlutterEngineCreateAOTData\? _FlutterEngineCreateAOTData;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineCollectAOTData _FlutterEngineCollectAOTData;/_dart_FlutterEngineCollectAOTData\? _FlutterEngineCollectAOTData;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineRun _FlutterEngineRun;/_dart_FlutterEngineRun\? _FlutterEngineRun;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineShutdown _FlutterEngineShutdown;/_dart_FlutterEngineShutdown\? _FlutterEngineShutdown;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineInitialize _FlutterEngineInitialize;/_dart_FlutterEngineInitialize\? _FlutterEngineInitialize;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineDeinitialize _FlutterEngineDeinitialize;/_dart_FlutterEngineDeinitialize\? _FlutterEngineDeinitialize;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineRunInitialized _FlutterEngineRunInitialized;/_dart_FlutterEngineRunInitialized\? _FlutterEngineRunInitialized;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEngineSendWindowMetricsEvent\n      _FlutterEngineSendWindowMetricsEvent;/_dart_FlutterEngineSendWindowMetricsEvent\?\n      _FlutterEngineSendWindowMetricsEvent;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineSendPointerEvent _FlutterEngineSendPointerEvent;/_dart_FlutterEngineSendPointerEvent\? _FlutterEngineSendPointerEvent;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineSendKeyEvent _FlutterEngineSendKeyEvent;/_dart_FlutterEngineSendKeyEvent\? _FlutterEngineSendKeyEvent;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineSendPlatformMessage _FlutterEngineSendPlatformMessage;/_dart_FlutterEngineSendPlatformMessage\? _FlutterEngineSendPlatformMessage;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterPlatformMessageCreateResponseHandle\n      _FlutterPlatformMessageCreateResponseHandle;/_dart_FlutterPlatformMessageCreateResponseHandle\?\n      _FlutterPlatformMessageCreateResponseHandle;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterPlatformMessageReleaseResponseHandle\n      _FlutterPlatformMessageReleaseResponseHandle;/_dart_FlutterPlatformMessageReleaseResponseHandle\?\n      _FlutterPlatformMessageReleaseResponseHandle;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEngineSendPlatformMessageResponse\n      _FlutterEngineSendPlatformMessageResponse;/_dart_FlutterEngineSendPlatformMessageResponse\?\n      _FlutterEngineSendPlatformMessageResponse;/g" lib/generated.dart
sed -i -z "s/_dart___FlutterEngineFlushPendingTasksNow\n      ___FlutterEngineFlushPendingTasksNow;/_dart___FlutterEngineFlushPendingTasksNow\?\n      ___FlutterEngineFlushPendingTasksNow;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEngineRegisterExternalTexture\n      _FlutterEngineRegisterExternalTexture;/_dart_FlutterEngineRegisterExternalTexture\?\n      _FlutterEngineRegisterExternalTexture;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEngineUnregisterExternalTexture\n      _FlutterEngineUnregisterExternalTexture;/_dart_FlutterEngineUnregisterExternalTexture\?\n      _FlutterEngineUnregisterExternalTexture;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEngineMarkExternalTextureFrameAvailable\n      _FlutterEngineMarkExternalTextureFrameAvailable;/_dart_FlutterEngineMarkExternalTextureFrameAvailable\?\n      _FlutterEngineMarkExternalTextureFrameAvailable;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEngineUpdateSemanticsEnabled\n      _FlutterEngineUpdateSemanticsEnabled;/_dart_FlutterEngineUpdateSemanticsEnabled\?\n      _FlutterEngineUpdateSemanticsEnabled;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEngineUpdateAccessibilityFeatures\n      _FlutterEngineUpdateAccessibilityFeatures;/_dart_FlutterEngineUpdateAccessibilityFeatures\?\n      _FlutterEngineUpdateAccessibilityFeatures;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEngineDispatchSemanticsAction\n      _FlutterEngineDispatchSemanticsAction;/_dart_FlutterEngineDispatchSemanticsAction\?\n      _FlutterEngineDispatchSemanticsAction;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineOnVsync _FlutterEngineOnVsync;/_dart_FlutterEngineOnVsync\? _FlutterEngineOnVsync;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineReloadSystemFonts _FlutterEngineReloadSystemFonts;/_dart_FlutterEngineReloadSystemFonts\? _FlutterEngineReloadSystemFonts;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEngineTraceEventDurationBegin\n      _FlutterEngineTraceEventDurationBegin;/_dart_FlutterEngineTraceEventDurationBegin\?\n      _FlutterEngineTraceEventDurationBegin;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineTraceEventDurationEnd _FlutterEngineTraceEventDurationEnd;/_dart_FlutterEngineTraceEventDurationEnd\? _FlutterEngineTraceEventDurationEnd;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineTraceEventInstant _FlutterEngineTraceEventInstant;/_dart_FlutterEngineTraceEventInstant\? _FlutterEngineTraceEventInstant;/g" lib/generated.dart
sed -i "s/_dart_FlutterEnginePostRenderThreadTask _FlutterEnginePostRenderThreadTask;/_dart_FlutterEnginePostRenderThreadTask\? _FlutterEnginePostRenderThreadTask;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineGetCurrentTime _FlutterEngineGetCurrentTime;/_dart_FlutterEngineGetCurrentTime\? _FlutterEngineGetCurrentTime;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineRunTask _FlutterEngineRunTask;/_dart_FlutterEngineRunTask\? _FlutterEngineRunTask;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineUpdateLocales _FlutterEngineUpdateLocales;/_dart_FlutterEngineUpdateLocales\? _FlutterEngineUpdateLocales;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEngineRunsAOTCompiledDartCode\n      _FlutterEngineRunsAOTCompiledDartCode;/_dart_FlutterEngineRunsAOTCompiledDartCode\?\n      _FlutterEngineRunsAOTCompiledDartCode;/g" lib/generated.dart
sed -i "s/_dart_FlutterEnginePostDartObject _FlutterEnginePostDartObject;/_dart_FlutterEnginePostDartObject\? _FlutterEnginePostDartObject;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEngineNotifyLowMemoryWarning\n      _FlutterEngineNotifyLowMemoryWarning;/_dart_FlutterEngineNotifyLowMemoryWarning\?\n      _FlutterEngineNotifyLowMemoryWarning;/g" lib/generated.dart
sed -i -z "s/_dart_FlutterEnginePostCallbackOnAllNativeThreads\n      _FlutterEnginePostCallbackOnAllNativeThreads;/_dart_FlutterEnginePostCallbackOnAllNativeThreads\?\n      _FlutterEnginePostCallbackOnAllNativeThreads;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineNotifyDisplayUpdate _FlutterEngineNotifyDisplayUpdate;/_dart_FlutterEngineNotifyDisplayUpdate\? _FlutterEngineNotifyDisplayUpdate;/g" lib/generated.dart
sed -i "s/_dart_FlutterEngineGetProcAddresses _FlutterEngineGetProcAddresses;/_dart_FlutterEngineGetProcAddresses\? _FlutterEngineGetProcAddresses;/g" lib/generated.dart

sed -i "1s;^;import 'manual.dart'\;\n;" lib/generated.dart
