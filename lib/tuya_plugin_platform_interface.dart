import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'tuya_plugin_method_channel.dart';

abstract class TuyaPluginPlatform extends PlatformInterface {
  /// Constructs a TuyaPluginPlatform.
  TuyaPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static TuyaPluginPlatform _instance = MethodChannelTuyaPlugin();

  /// The default instance of [TuyaPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelTuyaPlugin].
  static TuyaPluginPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TuyaPluginPlatform] when
  /// they register themselves.
  static set instance(TuyaPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
