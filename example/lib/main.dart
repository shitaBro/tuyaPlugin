import 'dart:developer';

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
  TextEditingController _accountController = TextEditingController(text: "a");
  TextEditingController _pswController = TextEditingController(text: "b");
  @override
  void initState() {
    super.initState();

    _tuyaPlugin.startWithKeySercert(key: "df7j7egd344xggr9r589", appSercert: "vapxperxgcdst9cdshjth8tq9xjuxy53",
    boolKeys: ["1","5","6","101","102"]);
    _tuyaPlugin.scanResult.stream.listen((event) {
      log("mo:${event}");
      _devModel = event;
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
            Container(child: TextButton(child: Text("选择网络"),onPressed: () async{
            String? ssid = await _tuyaPlugin.searchWifi();
            if (ssid?.isNotEmpty == true) {
              _tuyaPlugin.startConfigBLEWifiDeviceWith(UUID: _devModel?.uuid ?? "", homeId: _devModel?.homeId ?? 0,productId: _devModel?.productId ?? "",ssid: ssid! ,password: "88888888");
            }
            },),),
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
              child: TextButton(child: Text("暂停"),onPressed: (){
                _tuyaPlugin.sendCommand({"101":1});
              },),
            ),
             Container(
              child: TextButton(child: Text("开始出水"),onPressed: (){
                _tuyaPlugin.sendCommand({"101":0});
              },),
            )
          ],
        ),
        floatingActionButton: TextButton(child: Text("初始化登录"),onPressed: () async{

          var dic = await _tuyaPlugin.loginOrRegisterAccount(countryCode: "86",uid: _accountController.text,password: _pswController.text);



        },),
      ),
    );
  }
}
