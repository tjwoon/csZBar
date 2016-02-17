#import "CsZBar.h"
#import "AlmaZBarReaderViewController.h"

#pragma mark - State

@interface CsZBar ()
@property bool scanInProgress;
@property NSString *scanCallbackId;
@property AlmaZBarReaderViewController *scanReader;
@end


#pragma mark - Synthesize

@implementation CsZBar

@synthesize scanInProgress;
@synthesize scanCallbackId;
@synthesize scanReader;


#pragma mark - Cordova Plugin

- (void)pluginInitialize
{
    self.scanInProgress = NO;
}


#pragma mark - Plugin API

- (void)scan: (CDVInvokedUrlCommand*)command;
{
    if(self.scanInProgress) {
        [self.commandDelegate
         sendPluginResult: [CDVPluginResult
                            resultWithStatus: CDVCommandStatus_ERROR
                            messageAsString:@"A scan is already in progress."]
         callbackId: [command callbackId]];
    } else {
        self.scanInProgress = YES;
        self.scanCallbackId = [command callbackId];
        self.scanReader = [AlmaZBarReaderViewController new];

        self.scanReader.readerDelegate = self;
        self.scanReader.supportedOrientationsMask = ZBarOrientationMask(UIInterfaceOrientationPortrait);

        // Get user parameters
        NSDictionary *params = (NSDictionary*) [command argumentAtIndex:0];
        NSString *camera = [params objectForKey:@"camera"];
        if([camera isEqualToString:@"front"]) {
            // We do not set any specific device for the default "back" setting,
            // as not all devices will have a rear-facing camera.
            self.scanReader.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
        NSString *flash = [params objectForKey:@"flash"];
        if([flash isEqualToString:@"on"]) {
            self.scanReader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        } else if([flash isEqualToString:@"off"]) {
            self.scanReader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        }

        // Hack to hide the bottom bar's Info button... originally based on http://stackoverflow.com/a/16353530
        UIView *infoButton = [[[[[self.scanReader.view.subviews objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:3];
        [infoButton setHidden:YES];

        BOOL drawSight = [params objectForKey:@"drawSight"] ? [[params objectForKey:@"drawSight"] boolValue] : true;
        if(drawSight){
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            CGFloat screenWidth = screenRect.size.width;
            CGFloat screenHeight = screenRect.size.height;
            CGFloat dim = screenWidth < screenHeight ? screenWidth / 1.1 : screenHeight / 1.1;
            UIView *polygonView = [[UIView alloc] initWithFrame: CGRectMake ( (screenWidth/2) - (dim/2), (screenHeight/2) - (dim/2), dim, dim)];
            //polygonView.center = self.scanReader.view.center;
            //polygonView.layer.borderColor = [UIColor greenColor].CGColor;
            //polygonView.layer.borderWidth = 3.0f;

            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(dim / 2, 0, 1, dim)];
            lineView.backgroundColor = [UIColor redColor];
            [polygonView addSubview:lineView];

            self.scanReader.cameraOverlayView = polygonView;
            //[self.scanReader.view addSubview:polygonView];
        }

        [self.viewController presentModalViewController: self.scanReader animated: YES];
    }
}


#pragma mark - Helpers

- (void)sendScanResult: (CDVPluginResult*)result
{
    [self.commandDelegate sendPluginResult: result callbackId: self.scanCallbackId];
}


#pragma mark - ZBarReaderDelegate

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results) break; // get the first result

    [self.scanReader dismissViewControllerAnimated: YES completion: ^(void) {
        self.scanInProgress = NO;
        [self sendScanResult: [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsString: symbol.data]];
    }];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker
{
    [self.scanReader dismissViewControllerAnimated: YES completion: ^(void) {
        self.scanInProgress = NO;
        [self sendScanResult: [CDVPluginResult
                                resultWithStatus: CDVCommandStatus_ERROR
                                messageAsString: @"cancelled"]];
    }];
}

- (void) readerControllerDidFailToRead:(ZBarReaderController*)reader withRetry:(BOOL)retry
{
    [self.scanReader dismissViewControllerAnimated: YES completion: ^(void) {
        self.scanInProgress = NO;
        [self sendScanResult: [CDVPluginResult
                                resultWithStatus: CDVCommandStatus_ERROR
                                messageAsString: @"Failed"]];
    }];
}


@end
