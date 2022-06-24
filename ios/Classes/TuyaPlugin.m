#import "TuyaPlugin.h"
#import <TuyaSmartHomeKit/TuyaSmartKit.h>
#import "NSDictionary+json.h"
#import "BlueToothManagerDelegate.h"
#import <NetWorkExtension/NetWorkExtension.h>
#import "TuYaPluginDeviceDelegate.h"
#import "PluginLocationStatusManager.h"
#define WeakSelf __weak typeof(self) weakSelf = self;

@interface TuyaPlugin()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@property (nonatomic,strong) NSArray * boolKeys;
@end
@implementation TuyaPlugin {
    FlutterEventSink _eventSink;
    long long _homeId;
    TuyaSmartDevice* _device;
    CLLocationManager *_locationManager;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"tuya_plugin"
            binaryMessenger:[registrar messenger]];
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"tuya_event" binaryMessenger:[registrar messenger]];
  TuyaPlugin* instance = [[TuyaPlugin alloc] init];
    instance.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
    [eventChannel setStreamHandler:instance];
    

}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }else if ([call.method isEqualToString:@"startWithKeySercert"]) {
      [self handleInitSdkCall:call reslut:result];
  } else if ([call.method isEqualToString:@"loginOrRegisterAccount"]){
      [self loginOrRegisterAccount:call result:result];
  }else if ([call.method isEqualToString:@"searchWifi"]) {
      [self searchWifi:call result:result];
  }else if ([call.method isEqualToString:@"startConfigBLEWifiDeviceWith"]) {
      [self startConfigBLEWifiDeviceWith:call result:result];
  }else if ([call.method isEqualToString:@"removeDevice"]) {
      [self removeDevice:call result:result];
  }else if ([call.method isEqualToString:@"resetFactory"]) {
      [self resetFactory:call result:result];
  }else if ([call.method isEqualToString:@"sendCommand"]) {
      [self sendCommand:call result:result];
  }else if ([call.method isEqualToString:@"startSearchDevice"]) {
      [self startSearchDevice];
  }else if ([call.method isEqualToString:@"connectDeviceWithId"]) {
      [self connectDeviceWithId:call result:result];
  }
  else  {
    result(FlutterMethodNotImplemented);
  }
}
- (void)handleInitSdkCall:(FlutterMethodCall*)call reslut:(FlutterResult) result {
    NSString *key = [call.arguments jsonString:@"key"];
    NSString *sercert = [call.arguments jsonString:@"secret"];
    self.boolKeys = [call.arguments jsonArray:@"boolKeys"];
    [[TuyaSmartSDK sharedInstance] startWithAppKey:key secretKey:sercert];
    [TuyaSmartBLEManager sharedInstance].delegate = [BlueToothManagerDelegate sharedInstance];
    [BlueToothManagerDelegate sharedInstance].modelBlock = ^(TYBLEAdvModel * _Nonnull mo) {
        [_channel invokeMethod:@"ScanResult" arguments:@{@"homeId":@(_homeId),@"uuid":mo.uuid,@"productId":mo.productId,@"mac":mo.mac,@"isActive":@(mo.isActive),@"bleType":@(mo.bleType),@"isSupport5G":@(mo.isSupport5G),@"isProuductKey":@(mo.isProuductKey),@"bleProtocolV":@(mo.bleProtocolV),@"isQRCodeDevice":@(mo.isQRCodeDevice),@"isSupportMultiUserShare":@(mo.isSupportMultiUserShare)}];
    };
    
}
- (void)loginOrRegisterAccount:(FlutterMethodCall*)call result:(FlutterResult) result {
    NSString * countryCode = [call.arguments jsonString:@"countryCode"];
    NSString * uid = [call.arguments jsonString:@"uid"];
    NSString *password = [call.arguments jsonString:@"password"];
    WeakSelf
    __strong typeof(weakSelf) strongSelf = weakSelf;
    [[TuyaSmartUser sharedInstance]loginOrRegisterWithCountryCode:countryCode uid:uid password:password createHome:true success:^(id succe) {
        NSLog(@"tuya login success:%@",succe);
        
        [[TuyaSmartHomeManager   new]getHomeListWithSuccess:^(NSArray<TuyaSmartHomeModel *> *homes) {
            NSLog(@"涂鸦 homes:%@",homes);
            if (homes.count > 0) {
                
                self->_homeId = homes.firstObject.homeId;
                TuyaSmartHome *home = [TuyaSmartHome homeWithHomeId:self->_homeId];
                [home getHomeDetailWithSuccess:^(TuyaSmartHomeModel *homeModel) {
                   
                    NSLog(@"devices :%@，devid:%@",home.deviceList,home.deviceList.firstObject.devId);
                    NSMutableDictionary * sdic = @{@"homeId":@(self->_homeId)}.mutableCopy;
                    NSMutableArray* devices = @[].mutableCopy;
                    if ( home.deviceList.count > 0) {
                        NSMutableDictionary * dic = @{}.mutableCopy;
                        for (TuyaSmartDeviceModel * dev in home.deviceList) {
                            dic[@"productId"] = dev.productId;
                            dic[@"uuid"] = dev.uuid;
                            dic[@"mac"] = dev.mac;
                            dic[@"devId"] = dev.devId;
                            [devices addObject:dic];
                        }
                        sdic[@"devices"] = devices;
                    }else {
                        
                    }
                    result(sdic);
                    
                } failure:^(NSError *error) {
                    NSLog(@"get home info error:%@",error);
                }];
                
                
                
            }else {
//                result(@{@"status":@(false),@"msg":@"noHome"});
            }
                } failure:^(NSError *error) {
//                    result(@{@"status":@(false),@"msg":error.description});
                }];
        } failure:^(NSError *error) {
            NSLog(@"tuya homes erros:%@",error);
//            result(@{@"status":@(false),@"msg":error.description});
        }];
}
- (void)startSearchDevice {
    [BlueToothManagerDelegate sharedInstance].blepowerBlock = ^(BOOL powerOn) {
        
    };
    
    [[TuyaSmartBLEManager sharedInstance]startListening:true];
}
- (void)connectDeviceWithId:(FlutterMethodCall*)call result:(FlutterResult) result {
    NSString * devid = [call.arguments jsonString:@"devId"];
    NSLog(@"connect dev id:%@",devid);
    _device = [TuyaSmartDevice deviceWithDeviceId:devid];
    if (_device != nil) {
        result(@(true));
    }else {
        result(@(false));
    }
    
}

- (void)searchWifi:(FlutterMethodCall*)call result:(FlutterResult) result {
    [[PluginLocationStatusManager sharedInstance] startRequestLocationStatus:^(CLAuthorizationStatus status) {
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
            [TuyaSmartActivator getSSID:^(NSString *str) {
                NSLog(@"current wifi ssid:%@",str);
                result(str);
            } failure:^(NSError *error) {
                NSLog(@"get ssid error:%@",error.description);
                
            }];
        }else if (status == kCLAuthorizationStatusDenied) {
            NSLog(@"请开启定位权限");
            
        }
    }];
    
//    NSMutableArray *arr = @[].mutableCopy;
//    dispatch_queue_t queue = dispatch_queue_create("com.leopardpan.HotspotHelper", 0);
//        [NEHotspotHelper registerWithOptions:nil queue:queue handler: ^(NEHotspotHelperCommand * cmd) {
//            //kNEHotspotHelperCommandTypeFilterScanList：表示扫描到 Wifi 列表信息。
//            if(cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList) {
//                //NEHotspotNetwork 里有如下信息：SSID：Wifi 名称；BSSID：站点的 MAC 地址；signalStrength： Wifi信号强度，该值在0.0-1.0之间；secure：网络是否安全 (不需要密码的 Wifi，该值为 false)；autoJoined： 设备是否自动连接该 Wifi，目前测试自动连接以前连过的 Wifi 的也为 false ；justJoined：网络是否刚刚加入；chosenHelper：HotspotHelper是否为网络的所选助手
//                for (NEHotspotNetwork* network  in cmd.networkList) {
//                    NSLog(@"+++++%@",network.SSID);
//
//                    [arr addObject:network.SSID];
//                }
//                result(arr);
//            }
//        }];
}
- (void)startConfigBLEWifiDeviceWith:(FlutterMethodCall*)call result:(FlutterResult) result {
    NSDictionary *dic = call.arguments;
    [TuyaSmartBLEWifiActivator sharedInstance].bleWifiDelegate = [BlueToothManagerDelegate sharedInstance];
    __block NSString * devId;
    WeakSelf
    __strong typeof(weakSelf) strongSelf = weakSelf;
    [BlueToothManagerDelegate sharedInstance].configDeviceWifiSuccess = ^(BOOL isSuccess,NSString * _Nonnull devid) {
        devId = devid;
        result(@{@"status":@(isSuccess),@"msg":isSuccess ? @"配网成功":@"配网失败",@"devId":devid});
        strongSelf->_device = [TuyaSmartDevice deviceWithDeviceId:devId];
        [strongSelf->_device setOfflineReminderStatus:true success:^(BOOL result) {
            NSLog(@"设置离线告警成功:%hhd",result);
                } failure:^(NSError *error) {
                    NSLog(@"设置离线告警错误：%@",error.description);
                }];
        strongSelf->_device.delegate = [TuYaPluginDeviceDelegate sharedInstance];
    };
    [[TuyaSmartBLEWifiActivator sharedInstance] startConfigBLEWifiDeviceWithUUID:[dic jsonString:@"UUID"] homeId:[dic jsonLongLong:@"homeId"] productId:[dic jsonString:@"productId"] ssid:[dic jsonString:@"ssid"] password:[dic jsonString:@"password"] timeout:100 success:^{
        NSLog(@"start config method done");
//        result(@{@"status":@true,@"msg":@"配网成功"});
        
       
        } failure:^{
            NSLog(@"配网失败了");
            result(@{@"status":@false,@"msg":@"配网失败"});
        }];
}
- (void)removeDevice:(FlutterMethodCall*)call result:(FlutterResult)result {
    [_device remove:^{
        NSLog(@"device Remove success");
        result(@(true));
        } failure:^(NSError *error) {
            NSLog(@"device Remove error");
            result(@(false));
        }];
}
- (void)resetFactory:(FlutterMethodCall*)call result:(FlutterResult)result {
    [_device resetFactory:^{
        NSLog(@"device reset success");
        result(@(true));
        } failure:^(NSError *error) {
            NSLog(@"device reset false");
            result(@(false));
        }];
}
- (void)sendCommand:(FlutterMethodCall*)call result:(FlutterResult) result {
    NSLog(@"commands:%@",call.arguments);
    NSDictionary *dic = [self handleCommandDic:call.arguments];
    [_device publishDps:dic success:^{
        NSLog(@"send command success");
        result(@(true));
        } failure:^(NSError *error) {
            NSLog(@"send command error:%@",error.description);
            result(@(false));
        }];
}
- (NSMutableDictionary *)handleCommandDic:(NSDictionary*)dic {
    NSMutableDictionary * mdic = [[NSMutableDictionary alloc]init];
    NSString * command = dic.allKeys.firstObject;
    if ([self.boolKeys containsObject:command]) {
        [mdic setValue:@([dic jsonBool:command]) forKey:command];
    }else {
        mdic[command] = dic[command];
    }
    
    NSLog(@"command change dicc:%@",mdic);
    return mdic;
}


- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    return nil;
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"location fail:%@",error);
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"location author Status:%d",status);
}

@end
