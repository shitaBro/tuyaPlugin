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
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  startWithKeySercert(
      {required String key, required String appSercert}) async {
    Map? dic = await methodChannel.invokeMethod<Map>(
        "startWithKeySercert", {"key": key, "secret": appSercert});

  }

  @override
  Future<Map<String,dynamic>?> loginOrRegisterAccount({required String countryCode,uid,password}) async{
    Map? dic = await methodChannel.invokeMapMethod("loginOrRegisterAccount",{"countryCode":countryCode,"uid":uid,"password":password});
    return dic?.cast<String,dynamic>();
  }
  @override
  Future<List<String>?> searchWifi() async{
    List<String>? arr = await  methodChannel.invokeListMethod("searchWifi");
    return arr;
  }
  @override
  Future<Map<String,dynamic>?> startConfigBLEWifiDeviceWith({required String UUID,productId,ssid,password, required int homeId}) async{
    Map? dic = await methodChannel.invokeMethod<Map>("startConfigBLEWifiDeviceWith",{"UUID":UUID,"password":password,"productId":productId,"ssid":ssid,"homeId":homeId});
    return dic?.cast<String,dynamic>();
  }
  @override
  Future<bool> removeDevice() async{
    bool resu = await methodChannel.invokeMethod("removeDevice");
    return resu;
  }
  @override
  Future<bool> resetFactory() async{
    bool resu = await methodChannel.invokeMethod("resetFactory");
    return resu;
  }
  @override
  Future<bool> sendCommand(Map map) async{
    bool resu = await methodChannel.invokeMethod("sendCommand",map);
    return resu;
  }

}
