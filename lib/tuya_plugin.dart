
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
  PublishSubject<Map> _dpResult = PublishSubject();
  PublishSubject<Map> get dpResult => _dpResult;
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
        
        break ;
      case "DpUpdate":
        print("收到dp更新回调----${call.arguments}");
        _dpResult.add(call.arguments);
        break;
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
  Future<Map<String,dynamic>?> startConfigBLEWifiDeviceWith({required String
  UUID,productId,ssid,password, required int homeId,int? bleType,String?
  address,mac}) async{
    Map<String,dynamic> data =  {"UUID":UUID,"password":password,"productId":
    productId,"ssid":ssid,"homeId":homeId};
    if (bleType != null && address?.isNotEmpty == true) {
      data["bleType"] = bleType;
      data["address"] = address!;
      data["mac"] = mac ?? "";
    }
    Map? dic = await _methodChannel.invokeMethod<Map>
      ("startConfigBLEWifiDeviceWith",data);
    return dic?.cast<String,dynamic>();
  }
  void startSearchDevice() {
    _methodChannel.invokeMethod("startSearchDevice");
  }
  Future<bool> connectDeviceWithId(String devId) async{
    var resu = await _methodChannel.invokeMethod("connectDeviceWithId",
        {"devId":devId});
    return resu == 1 || resu == true;
  }
  @override
  Future<bool> removeDevice() async{
    var  resu = await _methodChannel.invokeMethod("removeDevice") ;
    return resu == 1 || resu == true;
  }
  @override
  Future<bool> resetFactory() async{
    var resu = await _methodChannel.invokeMethod("resetFactory") ;
    return resu == 1 || resu == true;
  }
  @override
  Future<bool> sendCommand(Map map) async{

    log("command str ${map}");
    var resu = await _methodChannel.invokeMethod("sendCommand",map);
    return resu == 1 || resu == true;
  }
  Future<bool> getPushStatus() async {
    var resu = await _methodChannel.invokeMethod("getPushStatus");
    return resu == 1 || resu == true;
  }
  Future<bool> getPushStatusByType(int type) async {
    var resu = await _methodChannel.invokeMethod("getPushStatusByType",{"type":type});
    return resu == 1 || resu == true;
  }
  Future<bool> setPushStatus(int isOpen) async {
    var resu = await _methodChannel.invokeMethod("setPushStatus",
        {"isOpen":isOpen});
    return resu == 1 || resu == true;
  }
  Future<bool> setPushStatusByType(int type,int isOpen) async {
    var resu = await _methodChannel.invokeMethod("setPushStatusByType",{"type":type,"isOpen":isOpen});
    return resu == 1 || resu == true;
  }
  Future<bool> getOfflineReminderStatus() async {
    var resu = await _methodChannel.invokeMethod("getOfflineReminderStatus");
    return resu == 1 || resu == true;
  }
  Future<bool> setOfflineReminderStatus(int isOn) async {
    var resu = await _methodChannel.invokeMethod("setOfflineReminderStatus",{"isOn":isOn});
    return resu == 1 || resu == true;
  }
  Future removeIosAccessToken() async {
    await _methodChannel.invokeMethod("removeIosAccessToken");
  }
  Future setAlias(String alias) async {
    await _methodChannel.invokeMethod("setAlias",{"alias":alias});
  }

}
