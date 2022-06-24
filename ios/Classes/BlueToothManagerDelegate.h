//
//  BlueToothManagerDelegate.h
//  tuya_plugin
//
//  Created by Mac on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import <TuyaSmartHomeKit/TuyaSmartKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef void (^BlueToothPowerBlock)(BOOL powerOn);

@interface BlueToothManagerDelegate : NSObject<TuyaSmartBLEManagerDelegate,TuyaSmartBLEWifiActivatorDelegate>
@property (nonatomic, copy) _Nullable BlueToothPowerBlock blepowerBlock;
@property (nonatomic,copy) void (^ _Nullable modelBlock)(TYBLEAdvModel*);
@property (nonatomic,copy) void (^ _Nullable configDeviceWifiSuccess)(BOOL,NSString*);

+ (BlueToothManagerDelegate *)sharedInstance;
@end

NS_ASSUME_NONNULL_END
