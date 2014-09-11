#import <Cordova/CDV.h>

#import "ZBarSDK.h"

@interface CsZBar : CDVPlugin <ZBarReaderDelegate>

- (void)scan: (CDVInvokedUrlCommand*)command;

@end
