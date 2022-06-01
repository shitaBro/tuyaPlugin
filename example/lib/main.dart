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
  String _platformVersion = 'Unknown';
  final _tuyaPlugin = TuyaPlugin();
  TuyaDevModel? _devModel;
  TextEditingController _accountController = TextEditingController();
  TextEditingController _pswController = TextEditingController();
  @override
  void initState() {
    super.initState();
    initPlatformState();
    _tuyaPlugin.startWithKeySercert(key: "df7j7egd344xggr9r589", appSercert: "vapxperxgcdst9cdshjth8tq9xjuxy53");

  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _tuyaPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
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
            TextField(controller: _pswController,),
            Container(child: TextButton(child: Text("选择网络"),onPressed: () async{
            List<String>? wifis = await _tuyaPlugin.searchWifi();
            if ((wifis?.length ?? 0) > 0) {
              showModalBottomSheet(context: context, builder: (context) {
                return ListView.builder(itemBuilder: (context,index) {
                  return ListTile(title: Text(wifis![index]),onTap: (){
                    _tuyaPlugin.startConfigBLEWifiDeviceWith(UUID: _devModel?.uuid ?? "", homeId: _devModel?.homeId ?? 0,productId: _devModel?.productId ?? "",ssid: wifis![index] ,password: "88888888");
                  },);
                });
              });
            }
            },),)
          ],
        ),
        floatingActionButton: TextButton(child: Text("初始化登录"),onPressed: () async{

          _devModel = await _tuyaPlugin.loginOrRegisterAccount(countryCode: "86",uid: _accountController.text,password: _pswController.text);
          log("devmo:${_devModel?.productId ?? ""},mac:${_devModel?.mac ?? ""}");

        },),
      ),
    );
  }
}
