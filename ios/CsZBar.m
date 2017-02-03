#import "CsZBar.h"
#import <AVFoundation/AVFoundation.h>
#import "AlmaZBarReaderViewController.h"

#define DeviceMaxHeight ([UIScreen mainScreen].bounds.size.height)
#define DeviceMaxWidth ([UIScreen mainScreen].bounds.size.width)
#define widthRate DeviceMaxWidth/320
#define contentTitleColorStr @"666666"

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

- (void)pluginInitialize {
    self.scanInProgress = NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    return;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Plugin API

- (void)scan: (CDVInvokedUrlCommand*)command;
{
    if (self.scanInProgress) {
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
        
        
       self.scanReader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        
        
        // Hack to hide the bottom bar's Info button... originally based on http://stackoverflow.com/a/16353530
        NSInteger infoButtonIndex;
        if ([[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending) {
            infoButtonIndex = 1;
        } else {
            infoButtonIndex = 3;
        }
        UIView *infoButton = [[[[[self.scanReader.view.subviews objectAtIndex:2] subviews] objectAtIndex:0] subviews] objectAtIndex:infoButtonIndex];
        [infoButton setHidden:YES];
        
      
        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        
        
        
        //扫描区域
        UIView *polygonView = [[UIView alloc] initWithFrame: screenRect];
        UIImage *hbImage=[self getImageFromBundle:@"scanBg"];
        UIImageView * scanZomeBack=[[UIImageView alloc] init];
        scanZomeBack.backgroundColor = [UIColor clearColor];
        scanZomeBack.layer.borderColor = [UIColor whiteColor].CGColor;
        scanZomeBack.layer.borderWidth = 1.5;
        scanZomeBack.image = hbImage;
        //添加一个背景图片
        CGRect mImagerect = CGRectMake(60*widthRate, (screenHeight-200*widthRate)/2, 200*widthRate, 200*widthRate);
        [scanZomeBack setFrame:mImagerect];
//        CGRect scanCrop=[self getScanCrop:mImagerect readerViewBounds:screenRect];
//        self.scanReader.scanCrop = scanCrop;
//        NSString *defaultScantitle = @"请将二维码置于框内";
        NSString *textTitle = [params objectForKey:@"text_title"];
        [self setOverlayPickerView : polygonView readerViewBounds:screenRect textTitle:textTitle];
        [polygonView addSubview:scanZomeBack];

        self.scanReader.cameraOverlayView =polygonView;
        [self loopDrawLine: polygonView];
        

        
        [self.viewController presentViewController:self.scanReader animated:YES completion:nil];
    }
}

-(UIImage *)getImageFromBundle:(NSString *)imageName
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CsZBar" ofType:@"bundle"]];

    UIImage *result = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    
    return result;
}

-(void)loopDrawLine: (UIView *)reader
{
    _is_AnmotionFinished = NO;
    CGRect rect = CGRectMake(60*widthRate, (DeviceMaxHeight-200*widthRate)/2, 200*widthRate, 2);
    if (_readLineView) {
        _readLineView.alpha = 1;
        _readLineView.frame = rect;
    }
    else{
        _readLineView = [[UIImageView alloc] initWithFrame:rect];
        [_readLineView setImage:[self getImageFromBundle:@"scanLine"]];
        [reader addSubview:_readLineView];
    }
    
    [UIView animateWithDuration:1.5 animations:^{
        //修改fream的代码写在这里
        _readLineView.frame =CGRectMake(60*widthRate, (DeviceMaxHeight-200*widthRate)/2+200*widthRate-5, 200*widthRate, 2);
    } completion:^(BOOL finished) {
        if (!_is_Anmotion) {
            [self loopDrawLine:reader];
        }
        _is_AnmotionFinished = YES;
    }];
}

- (void)setOverlayPickerView:(UIView *)reader readerViewBounds:(CGRect)readerViewBounds textTitle:(NSString *)textTitle
{
    CGFloat screenWidth = readerViewBounds.size.width;
    CGFloat screenHeight = readerViewBounds.size.height;
    
    
    CGFloat wid = 60*widthRate;
    CGFloat heih = (screenHeight-200*widthRate)/2;
    
    //最上部view
    CGFloat alpha = 0.6;
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, heih)];
    upView.alpha = alpha;
    upView.backgroundColor = [self colorFromHexRGB:contentTitleColorStr];
    [reader addSubview:upView];
    
    //用于说明的label
    UILabel * labIntroudction= [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame=CGRectMake(0, 84+(heih-64-50*widthRate)/2, screenWidth, 50*widthRate);
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.textColor=[UIColor whiteColor];
    labIntroudction.text=textTitle;
    labIntroudction.numberOfLines = 0;
    labIntroudction.textAlignment = UITextAlignmentCenter;    
    [upView addSubview:labIntroudction];
    
    //左侧的view
    UIView * cLeftView = [[UIView alloc] initWithFrame:CGRectMake(0, heih, wid, 200*widthRate)];
    cLeftView.alpha = alpha;
    cLeftView.backgroundColor = [self colorFromHexRGB:contentTitleColorStr];
    [reader addSubview:cLeftView];
    
    //右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(screenWidth-wid, heih, wid, 200*widthRate)];
    rightView.alpha = alpha;
    rightView.backgroundColor = [self colorFromHexRGB:contentTitleColorStr];
    [reader addSubview:rightView];
    
    //底部view
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, heih+200*widthRate, screenWidth, screenHeight - heih-200*widthRate)];
    downView.alpha = alpha;
    downView.backgroundColor = [self colorFromHexRGB:contentTitleColorStr];
    [reader addSubview:downView];
    
    //开关灯button
    UIButton * turnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    turnBtn.backgroundColor = [UIColor clearColor];
    [turnBtn setBackgroundImage:[self getImageFromBundle:@"lightNormal"] forState:UIControlStateNormal];
    [turnBtn setBackgroundImage:[self getImageFromBundle:@"lightSelect"] forState:UIControlStateSelected];
    turnBtn.frame=CGRectMake((screenWidth-44*widthRate)/2, (CGRectGetHeight(downView.frame)-48*widthRate)/2, 44*widthRate, 48*widthRate);
    [turnBtn addTarget:self action:@selector(turnBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:turnBtn];
    
}

- (void)turnBtnEvent:(UIButton *)button_
{
    button_.selected = !button_.selected;
    if (button_.selected) {
        [self turnTorchOn:YES];
    }
    else{
        [self turnTorchOn:NO];
    }
    
}

- (void)turnTorchOn:(bool)on
{
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}
#pragma mark - 颜色
//获取颜色
- (UIColor *)colorFromHexRGB:(NSString *)inColorString
{
    UIColor *result = nil;
    unsigned int colorCode = 0;
    unsigned char redByte, greenByte, blueByte;
    
    if (nil != inColorString)
    {
        NSScanner *scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char) (colorCode >> 16);
    greenByte = (unsigned char) (colorCode >> 8);
    blueByte = (unsigned char) (colorCode); // masks off high bits
    result = [UIColor
              colorWithRed: (float)redByte / 0xff
              green: (float)greenByte/ 0xff
              blue: (float)blueByte / 0xff
              alpha:1.0];
    return result;
}

#pragma mark - Helpers

- (void)sendScanResult: (CDVPluginResult*)result {
    [self.commandDelegate sendPluginResult: result callbackId: self.scanCallbackId];
}

#pragma mark - ZBarReaderDelegate

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    return;
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    if ([self.scanReader isBeingDismissed]) {
        return;
    }
    
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    
    ZBarSymbol *symbol = nil;
    for (symbol in results) break; // get the first result
    
    [self.scanReader dismissViewControllerAnimated: YES completion: ^(void) {
        self.scanInProgress = NO;
        [self sendScanResult: [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsString: symbol.data]];
    }];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController*)picker {
    [self.scanReader dismissViewControllerAnimated: YES completion: ^(void) {
        self.scanInProgress = NO;
        [self sendScanResult: [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_ERROR
                               messageAsString: @"cancelled"]];
    }];
}

- (void) readerControllerDidFailToRead:(ZBarReaderController*)reader withRetry:(BOOL)retry {
    [self.scanReader dismissViewControllerAnimated: YES completion: ^(void) {
        self.scanInProgress = NO;
        [self sendScanResult: [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_ERROR
                               messageAsString: @"Failed"]];
    }];
}

- (void)toggleflash {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [device lockForConfiguration:nil];
    if (device.torchAvailable == 1) {
        if (device.torchMode == 0) {
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
        }
    }
    
    [device unlockForConfiguration];
}
@end
