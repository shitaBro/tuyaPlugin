
import 'package:tuya_plugin/tuya_dev_model.dart';

import 'tuya_plugin_platform_interface.dart';

class TuyaPlugin {
  Future<String?> getPlatformVersion() {
    return TuyaPluginPlatform.instance.getPlatformVersion();
  }
  startWithKeySercert(
      {required String key, required String appSercert})  {

    TuyaPluginPlatform.instance.startWithKeySercert(key: key, appSercert: appSercert);
  }

  Future<List<String>?> searchWifi() {
    return TuyaPluginPlatform.instance.searchWifi();
  }
  Future<TuyaDevModel?> loginOrRegisterAccount({required String countryCode,required String uid,required String password}) {
    return TuyaPluginPlatform.instance.loginOrRegisterAccount(countryCode: countryCode,uid: uid,password: password);
  }

  Future<Map<String,dynamic>?> startConfigBLEWifiDeviceWith({required String UUID,productId,ssid,password, required int homeId}) {
    return TuyaPluginPlatform.instance.startConfigBLEWifiDeviceWith(UUID: UUID, homeId: homeId,productId: productId,ssid: ssid,password: password);
  }

  Future<bool> removeDevice() {
    return TuyaPluginPlatform.instance.removeDevice();
  }

  Future<bool> resetFactory() {
    return TuyaPluginPlatform.instance.resetFactory();
  }

  Future<bool> sendCommand(Map map) {
    return TuyaPluginPlatform.instance.sendCommand(map);
  }

}
