#import <Cordova/CDV.h>

#import "ZBarSDK.h"

@interface CsZBar : CDVPlugin <ZBarReaderDelegate>

- (void)scan: (CDVInvokedUrlCommand*)command;

@property (nonatomic,copy)UIImageView * readLineView;
@property (nonatomic,assign)BOOL is_Anmotion;
@property (nonatomic,assign)BOOL is_AnmotionFinished;


- (void)loopDrawLine:(UIView*) reader;//初始化扫描线

@end
