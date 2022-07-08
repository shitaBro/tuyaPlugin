#import <Flutter/Flutter.h>

@interface TuyaPlugin : NSObject<FlutterPlugin,FlutterStreamHandler>
+ (instancetype)sharedInstance;
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end
