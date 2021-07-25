#import <Cordova/CDV.h>

#import <ATBarSDK/ZBarSDK.h>
#import <UIKit/UIKit.h>

@interface CsZBar : CDVPlugin <ZBarReaderDelegate>

- (void)scan: (CDVInvokedUrlCommand*)command;
- (void)toggleflash;




@end
