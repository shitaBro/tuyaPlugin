//
//  PluginLocationStatusManager.m
//  tuya_plugin
//
//  Created by Mac on 2022/6/2.
//

#import "PluginLocationStatusManager.h"

@interface PluginLocationStatusManager()<CLLocationManagerDelegate>
@property (nonatomic,copy) void (^statusBlock)(CLAuthorizationStatus);
@property (nonatomic,strong) CLLocationManager *locManager;
@end

static PluginLocationStatusManager * instance = nil;
@implementation PluginLocationStatusManager
+ (instancetype) sharedInstance {
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
- (instancetype)init {
    if (self = [super init]) {
        self.locManager = [[CLLocationManager alloc]init];
        self.locManager.delegate = self;
    }
    return self;
}

- (void)startRequestLocationStatus:(void(^)(CLAuthorizationStatus)) block{
    self.statusBlock = block;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        [_locManager requestAlwaysAuthorization];
    }else {
        self.statusBlock(status);
    }
    
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"loc status：%d",status);
    self.statusBlock(status);
}

@end
