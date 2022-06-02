//
//  BlueToothManagerDelegate.m
//  tuya_plugin
//
//  Created by Mac on 2022/5/30.
//

#import "BlueToothManagerDelegate.h"

@implementation BlueToothManagerDelegate
static BlueToothManagerDelegate *instance = nil;
+ (BlueToothManagerDelegate*)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc]init];
        }
    });
    return instance;
}
+ (instancetype) allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}
- (instancetype)copyWithZone:(NSZone *)zone
{
    return instance;
}


- (void)bluetoothDidUpdateState:(BOOL)isPoweredOn {
    NSLog(@"蓝牙状态变化: %d", isPoweredOn ? 1 : 0);
    self.blepowerBlock(isPoweredOn);
}

- (void)didDiscoveryDeviceWithDeviceInfo:(TYBLEAdvModel *)deviceInfo {
    NSLog(@"发现未连接蓝牙设备，%@",deviceInfo.description);
    self.modelBlock(deviceInfo);
}
- (void)onCentralDidDisconnectFromDevice:(NSString *)devId error:(NSError *)error {
    NSLog(@"蓝牙设备断连-devid:%@,error:%@",devId,error.description);
}


- (void)bleWifiActivator:(TuyaSmartBLEWifiActivator *)activator didReceiveBLEWifiConfigDevice:(nullable TuyaSmartDeviceModel *)deviceModel error:(nullable NSError *)error {
    NSLog(@"did config device wifi success:%@,error:%@",deviceModel.originJson,error.description);
    if (error == nil) {
        self.configDeviceWifiSuccess(deviceModel.devId);
    }else {
        NSLog(@"配网代理回调失败");
    }
    
}

@end
