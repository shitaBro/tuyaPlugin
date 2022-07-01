//
//  TuYaPluginDeviceDelegate.m
//  tuya_plugin
//
//  Created by Mac on 2022/5/31.
//

#import "TuYaPluginDeviceDelegate.h"
static TuYaPluginDeviceDelegate *instance = nil;
@implementation TuYaPluginDeviceDelegate

+ (instancetype)sharedInstance {
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

- (void)device:(TuyaSmartDevice *)device dpsUpdate:(NSDictionary *)dps {
    // 设备的 dps 状态发生变化，刷新界面 UI
    NSLog(@"设备的 dps 状态发生变化，刷新界面 UI,%@",dps);
}

- (void)deviceInfoUpdate:(TuyaSmartDevice *)device {
    //当前设备信息更新 比如 设备名称修改、设备在线离线状态等
    NSLog(@"当前设备信息更新 比如 设备名称修改、设备在线离线状态等");
}

- (void)deviceRemoved:(TuyaSmartDevice *)device {
    //当前设备被移除
    NSLog(@"当前设备被移除:%@",device.deviceModel.devId);
}

- (void)device:(TuyaSmartDevice *)device signal:(NSString *)signal {
    // Wifi信号强度
    NSLog(@"Wifi信号强度:%@",signal);
}

- (void)device:(TuyaSmartDevice *)device firmwareUpgradeProgress:(NSInteger)type progress:(double)progress {
    // 固件升级进度
    NSLog(@"固件升级进度:%f",progress);
}

- (void)device:(TuyaSmartDevice *)device firmwareUpgradeStatusModel:(TuyaSmartFirmwareUpgradeStatusModel *)upgradeStatusModel {
    // 设备升级状态的回调
    NSLog(@"设备升级状态的回调:%@",upgradeStatusModel.description);
}
@end
