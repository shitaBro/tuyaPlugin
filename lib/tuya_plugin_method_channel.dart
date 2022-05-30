import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'tuya_plugin_platform_interface.dart';

/// An implementation of [TuyaPluginPlatform] that uses method channels.
class MethodChannelTuyaPlugin extends TuyaPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tuya_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
