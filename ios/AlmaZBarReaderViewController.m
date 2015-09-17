//
//  AlmaZBarReaderViewController.m
//  BarCodeMix
//
//  Created by eCompliance on 23/01/15.
//
//

#import "AlmaZBarReaderViewController.h"
#import "CsZbar.h"

@interface AlmaZBarReaderViewController ()

@end

@implementation AlmaZBarReaderViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[button setTitle:@"Flash" forState:UIControlStateNormal];
    [button sizeToFit];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    //[button setContentEdgeInsets:UIEdgeInsetsMake(20, 30, 20, 30)];
    CGRect frame;
    if(screenRect.size.height>(screenRect.size.width)){
        frame = CGRectMake(0,0, screenRect.size.width*(0.15), screenRect.size.height*0.15);
        
        //button.center = CGPointMake( 0,0);
    }else{
        frame = CGRectMake(0,0, screenRect.size.width*(0.10), screenRect.size.height*0.20);
        
        //button.center = CGPointMake(0,0);
    }
    
    button.frame =frame;
    button.layer.cornerRadius = 10;
    button.clipsToBounds = YES;
    // Set a new (x,y) point for the button's center
    
    UIImage *btnImage = [UIImage imageNamed:@"flash.png"];
    
    [button setImage:btnImage forState:UIControlStateNormal];

    //[button setBackgroundColor:[UIColor colorWithRed:.859 green:.765 blue:.616 alpha:1.0] forState:UIControlStateHighlighted];
    
    //button.center = CGPointMake( 0,0);
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//Techedge Changes NSS fase 2
- (void)buttonPressed: (UIButton *) button {
    
    CsZBar *obj = [[CsZBar alloc] init];
    
    [obj toggleflash];
    
}


- (BOOL)shouldAutorotate{
    return YES;
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //AlmaZBarReaderViewController.scanner.scanner.cameraOverlayView = poli
    //NSDictionary *params = (NSDictionary*) [command argumentAtIndex:0];
    BOOL drawSight = true;//[params objectForKey:@"drawSight"] ? [[params objectForKey:@"drawSight"] boolValue] : true;
    if(drawSight){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        CGFloat dim = screenWidth < screenHeight ? screenWidth / 1.1 : screenHeight / 1.1;
        UIView *polygonView = [[UIView alloc] initWithFrame: CGRectMake  ( (screenWidth/2) - (dim/2), (screenHeight/2) - (dim/2), dim, dim)];
        //polygonView.center = self.scanReader.view.center;
        //polygonView.layer.borderColor = [UIColor greenColor].CGColor;
        //polygonView.layer.borderWidth = 3.0f;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,dim / 2, dim, 1)];
        lineView.backgroundColor = [UIColor redColor];
        [polygonView addSubview:lineView];
        self.cameraOverlayView = polygonView;
        
        
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
