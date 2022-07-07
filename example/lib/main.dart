import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:tuya_plugin/tuya_dev_model.dart';
import 'package:tuya_plugin/tuya_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final _tuyaPlugin = TuyaPlugin.instance;
  TuyaDevModel? _devModel;
  TextEditingController _accountController = TextEditingController(text: "470227667246649344");
  TextEditingController _pswController = TextEditingController(text: "111111");
  String? _ssid;
  bool? _mainOn;
  bool? warnOn;
  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      _tuyaPlugin.startWithKeySercert(key: "df7j7egd344xggr9r589", appSercert: "vapxperxgcdst9cdshjth8tq9xjuxy53",
          boolKeys: ["1","5","6","101","102"]);
    }else {
      _tuyaPlugin.startWithKeySercert(key: "ax83aapssgwp9p83pmqv",
          appSercert: "44wethtvje5xnv4dyeratvts8d9tng8e", boolKeys: ["1","5","6","101","102"]);
    }
    
    _tuyaPlugin.scanResult.stream.listen((event) {
      log("model:${event}");
      _devModel = event;
    });
    _tuyaPlugin.dpResult.listen((value) {
      log("dp changed:${value}");
    });

  }
  void getStatus() async {
    var main = await _tuyaPlugin.getPushStatus();
    log("mainOn:${_mainOn}");
    var warn = await _tuyaPlugin.getPushStatusByType(0);
    setState((){
      _mainOn = main;
      warnOn = warn;
    });

  }


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: ListView(
          children: [
            TextField(decoration: InputDecoration(
              hintText: "inout account"
            ),controller: _accountController,),
            TextField(controller: _pswController,decoration: InputDecoration(
                hintText: "inout account"
            )),
            Container(child: TextButton(child: Text("扫描设备"),onPressed: () async{
               _tuyaPlugin.startSearchDevice();

            },),),
            Container(child: TextButton(child: Text("选择网络"),onPressed: () async{
            _ssid = await _tuyaPlugin.searchWifi();

            },),),
            Container(
              child: Row(
                children: <Widget>[
                  Text("总推送"),
                  Switch(value: _mainOn ?? false, onChanged: (on) async{
                    var suc = await _tuyaPlugin.setPushStatus(on ? 1:0);
                    log("set main success:${suc}");
                  }),
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Text("告警"),
                  Switch(value: warnOn ?? false, onChanged: (on) async{
                    var suc = await _tuyaPlugin.setPushStatusByType(0,on ? 1:0);
                    log("set warn success:${suc}");
                  }),
                ],
              ),
            ),
            Container(
              child: TextButton(child: Text("开始配网"),onPressed: () {
                if (_ssid?.isNotEmpty == true) {
                  log("ssid:${_ssid}");
                  _tuyaPlugin.startConfigBLEWifiDeviceWith(UUID: _devModel?.uuid ?? "", homeId: _devModel?.homeId ?? 0,productId:
                      _devModel?.productId ?? "",ssid: _ssid! ,password: "88888888",bleType: _devModel?.bleType,address:
                      _devModel?.address,mac: _devModel?.mac);
                }
              },),
            ),
            Container(
              child: TextButton(child: Text("普通模式"),onPressed: (){
                _tuyaPlugin.sendCommand({"2":"normal"});
              },),
            ),
            Container(
              child: TextButton(child: Text("智能模式"),onPressed: (){
                _tuyaPlugin.sendCommand({"2":"smart"});
              },),
            ),
            Container(
              child: TextButton(child: Text("开"),onPressed: (){
                _tuyaPlugin.sendCommand({"1":true});
              },),
            ),
            Container(
              child: TextButton(child: Text("关"),onPressed: (){
                _tuyaPlugin.sendCommand({"1":false});
              },),
            ),
            Container(
              child: TextButton(child: Text("暂停出水"),onPressed: (){
                _tuyaPlugin.sendCommand({"101":false});
              },),
            ),
             Container(
              child: TextButton(child: Text("开始出水"),onPressed: (){
                _tuyaPlugin.sendCommand({"101":true});
              },),
            ),
            Container(
              child: TextButton(child: Text("重置设备"),onPressed: (){
                _tuyaPlugin.resetFactory();
              },),
            )
          ],
        ),
        floatingActionButton: TextButton(child: Text("初始化登录"),onPressed: () async{

          var dic = await _tuyaPlugin.loginOrRegisterAccount(countryCode: "86",uid: _accountController.text,password: _pswController.text);
          log("login Success：${dic}");
          int homeid = dic!["homeId"];
          List<Object?> arr = dic?["devices"];
          if (arr.isNotEmpty) {

            Map mdic = json.decode(json.encode(arr?.first));

            var connect = await _tuyaPlugin.connectDeviceWithId(mdic["devId"]);
            log("connected:${connect}");
            getStatus();
          }


        },),
      ),
    );
  }
}
