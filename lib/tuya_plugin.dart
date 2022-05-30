
import 'tuya_plugin_platform_interface.dart';

class TuyaPlugin {
  Future<String?> getPlatformVersion() {
    return TuyaPluginPlatform.instance.getPlatformVersion();
  }
}
