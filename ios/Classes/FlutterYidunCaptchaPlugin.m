#import "FlutterYidunCaptchaPlugin.h"


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height


@implementation FlutterYidunCaptchaPlugin {
    FlutterEventSink _eventSink;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"flutter_yidun_captcha"
                                     binaryMessenger:[registrar messenger]];
    FlutterYidunCaptchaPlugin* instance = [[FlutterYidunCaptchaPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    
    FlutterEventChannel* eventChannel =
    [FlutterEventChannel eventChannelWithName:@"flutter_yidun_captcha/event_channel"
                              binaryMessenger:[registrar messenger]];
    [eventChannel setStreamHandler:instance];
}

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    _eventSink = nil;
    
    return nil;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getSDKVersion" isEqualToString:call.method]) {
        [self handleMethodGetSDKVersion:call result:result];
    } else if ([@"verify" isEqualToString:call.method]) {
        [self handleMethodVerify:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}


- (void)handleMethodGetSDKVersion:(FlutterMethodCall*)call
                           result:(FlutterResult)result
{
    NSString *sdkVersion = [[NTESVerifyCodeManager getInstance] getSDKVersion];
    
    result(sdkVersion);
}

- (void)handleMethodVerify:(FlutterMethodCall*)call
                    result:(FlutterResult)result
{
    NSString *captchaId = call.arguments[@"captchaId"];
    
    self.manager = [NTESVerifyCodeManager getInstance];
    self.manager.delegate = self;
    
    [self.manager configureVerifyCode:captchaId timeout:7.0];
    self.manager.mode = NTESVerifyCodeNormal;
    self.manager.lang = NTESVerifyCodeLangCN;
    self.manager.alpha = 0.6;
    self.manager.color = [UIColor blackColor];
    self.manager.frame = CGRectNull;
    self.manager.openFallBack = YES;
    self.manager.fallBackCount = 3;
    self.manager.closeButtonHidden = NO;
    
    self.manager.shouldCloseByTouchBackground = YES;
    
    [self.manager openVerifyCodeView: nil];
    
    result([NSNumber numberWithBool: YES]);
}

- (void)sendEventData:(NSString*)method data:(NSDictionary *)data  {
    NSDictionary<NSString *, id> *eventData = @{
        @"method": method,
        @"data": data != nil ? data : @{},
    };
    self->_eventSink(eventData);
}

#pragma mark - NTESVerifyCodeManagerDelegate
/**
 * 验证码组件初始化完成
 */
- (void)verifyCodeInitFinish{
    NSLog(@"收到初始化完成的回调");
    [self sendEventData:@"onReady" data:nil];
}

/**
 * 验证码组件初始化出错
 *
 * @param message 错误信息
 */
- (void)verifyCodeInitFailed:(NSString *)message{
    NSLog(@"收到初始化失败的回调:%@",message);
    [self sendEventData:@"onError" data:nil];
}

/**
 * 完成验证之后的回调
 *
 * @param result 验证结果 BOOL:YES/NO
 * @param validate 二次校验数据，如果验证结果为false，validate返回空
 * @param message 结果描述信息
 *
 */
- (void)verifyCodeValidateFinish:(BOOL)result validate:(NSString *)validate message:(NSString *)message{
    NSLog(@"收到验证结果的回调:(%d,%@,%@)", result, validate, message);
    
    NSDictionary<NSString *, id> *data = @{
        @"result": result ? @"true" : @"false",
        @"validate": validate,
        @"message": message,
    };
    
    [self sendEventData:@"onValidate" data:data];
}

/**
 * 关闭验证码窗口后的回调
 */
- (void)verifyCodeCloseWindow{
    //用户关闭验证后执行的方法
    NSLog(@"收到关闭验证码视图的回调");
    [self sendEventData:@"onClose" data:nil];
}

/**
 * 网络错误
 *
 * @param error 网络错误信息
 */
- (void)verifyCodeNetError:(NSError *)error{
    //用户关闭验证后执行的方法
    NSLog(@"收到网络错误的回调:%@(%ld)", [error localizedDescription], (long)error.code);
    NSDictionary<NSString *, id> *data = @{
        @"code": @(error.code),
        @"message": [error localizedDescription],
    };
    [self sendEventData:@"onError" data:data];
}

@end
