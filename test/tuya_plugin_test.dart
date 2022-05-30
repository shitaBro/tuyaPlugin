import 'package:flutter_test/flutter_test.dart';
import 'package:tuya_plugin/tuya_plugin.dart';
import 'package:tuya_plugin/tuya_plugin_platform_interface.dart';
import 'package:tuya_plugin/tuya_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTuyaPluginPlatform 
    with MockPlatformInterfaceMixin
    implements TuyaPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final TuyaPluginPlatform initialPlatform = TuyaPluginPlatform.instance;

  test('$MethodChannelTuyaPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTuyaPlugin>());
  });

  test('getPlatformVersion', () async {
    TuyaPlugin tuyaPlugin = TuyaPlugin();
    MockTuyaPluginPlatform fakePlatform = MockTuyaPluginPlatform();
    TuyaPluginPlatform.instance = fakePlatform;
  
    expect(await tuyaPlugin.getPlatformVersion(), '42');
  });
}
