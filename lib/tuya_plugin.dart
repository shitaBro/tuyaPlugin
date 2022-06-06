
import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:tuya_plugin/tuya_dev_model.dart';
import 'package:rxdart/rxdart.dart';


class TuyaPlugin {
  final _methodChannel = const MethodChannel('tuya_plugin');

  TuyaPlugin._(){
    _methodChannel.setMethodCallHandler(_platformCallHandler);
  }
  static TuyaPlugin _instance = new TuyaPlugin._();
  static TuyaPlugin get instance => _instance;
  PublishSubject<TuyaDevModel> _scanResult = PublishSubject<TuyaDevModel>();
  PublishSubject<TuyaDevModel> get scanResult => _scanResult;
  Future<Map<String,dynamic>?> loginOrRegisterAccount({required String countryCode,required String uid,required String password}) async{
    Map? dic = await _methodChannel.invokeMapMethod<String,dynamic>("loginOrRegisterAccount",{"countryCode":countryCode,"uid":uid,"password":password});
    log("loginOrRegister :${dic}");

    return dic?.cast<String,dynamic>();
  }
  Future<dynamic> _platformCallHandler(MethodCall call) async {
    switch (call.method) {
      case "ScanResult":
        print('收到原生回调 ---- ${call.arguments}');
        _scanResult.add(TuyaDevModel.fromJson(call.arguments.cast<String,dynamic>()));
        print("add signal success:${_scanResult}");
        
        return ;
        
    }
  }


 ///初始化方法
  /// *[boolKeys] 值需要转换成bool的指令
  void startWithKeySercert(
      {required String key, required String appSercert, required List<String> boolKeys}) async {

    log("key:${key},sercert:${appSercert}");
    Map? dic = await _methodChannel.invokeMethod<Map>(
        "startWithKeySercert", {"key": key, "secret": appSercert,'boolKeys':boolKeys});

  }


  Future<String?> searchWifi() async{
    String ssid = await  _methodChannel.invokeMethod("searchWifi");
    return ssid;
  }
  @override
  Future<Map<String,dynamic>?> startConfigBLEWifiDeviceWith({required String UUID,productId,ssid,password, required int homeId}) async{
    Map? dic = await _methodChannel.invokeMethod<Map>("startConfigBLEWifiDeviceWith",{"UUID":UUID,"password":password,"productId":productId,"ssid":ssid,"homeId":homeId});
    return dic?.cast<String,dynamic>();
  }
  @override
  Future<bool> removeDevice() async{
    bool resu = await _methodChannel.invokeMethod("removeDevice");
    return resu;
  }
  @override
  Future<bool> resetFactory() async{
    bool resu = await _methodChannel.invokeMethod("resetFactory");
    return resu;
  }
  @override
  Future<bool> sendCommand(Map map) async{

    int? resu = await _methodChannel.invokeMethod("sendCommand",map);
    return resu == 1;
  }

}
