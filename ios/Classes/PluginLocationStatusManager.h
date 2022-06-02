//
//  PluginLocationStatusManager.h
//  tuya_plugin
//
//  Created by Mac on 2022/6/2.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN

@interface PluginLocationStatusManager : NSObject
+ (instancetype) sharedInstance;
- (void)startRequestLocationStatus:(void(^)(CLAuthorizationStatus)) block;

@end

NS_ASSUME_NONNULL_END
