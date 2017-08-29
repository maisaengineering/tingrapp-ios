//
//  VerifiedViewController.m
//  Tingr
//
//  Created by Maisa Pride on 7/27/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "VerifiedViewController.h"
#import "UIView+Toast.h"
@interface VerifiedViewController ()
{
    UITextField *verificationTextField;
    
    UILabel *timerLabel;
    UIButton *resend;
    NSTimer *timer;
    
    ModelManager *sharedModel;
    
    int currMinute;
    int currSeconds;
    
    BOOL viewAppeared;
}
@end

@implementation VerifiedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *verificationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 100)];
    [self.view addSubview:verificationView];
    verificationView.center = self.view.center;
    
    
    currMinute=0;
    currSeconds=59;
    
    
    sharedModel = [ModelManager sharedModel];
    
    verificationTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 0, Devicewidth-20,30)];
    verificationTextField.delegate = self;
    verificationTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    verificationTextField.textAlignment = NSTextAlignmentCenter;
    verificationTextField.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    NSMutableParagraphStyle *style = [verificationTextField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = verificationTextField.font.lineHeight - (verificationTextField.font.lineHeight - [UIFont fontWithName:@"HelveticaNeue" size:16].lineHeight) / 2.0;
    
    verificationTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"ENTER PIN"
                                                                                  attributes:@{
                                                                                               NSForegroundColorAttributeName: [UIColor blackColor],
                                                                                               NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:18],
                                                                                               NSParagraphStyleAttributeName : style
                                                                                               }
                                                   ];
    verificationTextField.returnKeyType = UIReturnKeyGo;
    
    [verificationView addSubview:verificationTextField];
    
    CGRect rect = verificationTextField.frame;
    
    rect.size.height -= 4;
    UIBezierPath * linePath = [UIBezierPath bezierPath];
    
    // start at top left corner
    [linePath moveToPoint:CGPointMake(0,rect.size.height-5)];
    // draw right vertical side
    [linePath addLineToPoint:CGPointMake(0, rect.size.height)];
    // draw left vertical side
    [linePath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    
    // draw from bottom right corner back to bottom left corner
    [linePath addLineToPoint:CGPointMake(rect.size.width, rect.size.height-5)];
    
    // create a layer that uses your defined path
    CAShapeLayer * lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 1.0;
    lineLayer.strokeColor = [UIColor grayColor].CGColor;
    
    lineLayer.fillColor = nil;
    lineLayer.path = linePath.CGPath;
    
    [verificationTextField.layer addSublayer:lineLayer];
    
    
    timerLabel = [[UILabel alloc] initWithFrame:CGRectMake((Devicewidth-100)/2.0, verificationTextField.frame.origin.y+30, 100, 30)];
    [timerLabel setText:@"00:60"];
    [timerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    timerLabel.textAlignment = NSTextAlignmentCenter;
    [timerLabel setTextColor:[UIColor grayColor]];
    [verificationView addSubview:timerLabel];
    
    
    resend  = [UIButton buttonWithType:UIButtonTypeCustom];
    [resend setTitle:@"resend" forState:UIControlStateNormal];
    [resend.titleLabel setFont:[UIFont fontWithName:@"Antonio-Regular" size:16]];
    [resend setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
    [resend addTarget:self action:@selector(resendClicked) forControlEvents:UIControlEventTouchUpInside];
    [resend setFrame:timerLabel.frame];
    [verificationView addSubview:resend];
    
    resend.hidden = YES;
    
    
    
    
    UIButton *laterButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [laterButton setTitle:@"later" forState:UIControlStateNormal];
    [laterButton.titleLabel setFont:[UIFont fontWithName:@"Antonio" size:20]];
    [laterButton setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
    [laterButton addTarget:self action:@selector(laterClicked) forControlEvents:UIControlEventTouchUpInside];
    [laterButton setFrame:CGRectMake(20, timerLabel.frame.origin.y+30, 40, 40)];
    [verificationView addSubview:laterButton];
    
    
    
    UIButton *verifyButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [verifyButton setTitle:@"VERIFY" forState:UIControlStateNormal];
    [verifyButton.titleLabel setFont:[UIFont fontWithName:@"Antonio-Bold" size:20]];
    [verifyButton setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
    [verifyButton addTarget:self action:@selector(verifyClicked) forControlEvents:UIControlEventTouchUpInside];
    [verifyButton setFrame:CGRectMake(Devicewidth-75, timerLabel.frame.origin.y+30, 60, 40)];
    [verificationView addSubview:verifyButton];
    

    viewAppeared = YES;
    [self resendClicked];
}

-(void)viewDidAppear:(BOOL)animated {
    
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.messageFont = [UIFont fontWithName:@"Helvetica" size:13.0];
    
    
    [[[[UIApplication sharedApplication] windows] lastObject]  makeToast:@"we'he emailed you a PIN for acc. verification purpose. please check."
                                     duration:2.0
                                     position:CSToastPositionBottom
                                        title:nil
                                        image:nil
                                        style:style
                                   completion:nil];

    
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];


    
}


-(void)timerFired
{
    if((currMinute>0 || currSeconds>=0) && currMinute>=0)
    {
        if(currSeconds==0)
        {
            currMinute-=1;
            currSeconds=59;
        }
        else if(currSeconds>0)
        {
            currSeconds-=1;
        }
        if(currMinute>-1)
            [timerLabel setText:[NSString stringWithFormat:@"%02d%@%02d",currMinute,@":",currSeconds]];
    }
    else
    {
        [timer invalidate];
        
        timerLabel.hidden = YES;
        resend.hidden = NO;
    }
}

-(void)verifyClicked {
    
    
    [verificationTextField resignFirstResponder];
    
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [[SingletonClass sharedInstance] stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tingr"
                                                       message:NO_INTERNET_CONNECTION
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        
        [alert show];
    }
    else
    {
        if([self validateFields:verificationTextField])
        {
            [self callVerifyApi];
            
        }
        else
        {
            [self validationAlert:@"Please enter verification code."];
            
        }
    }
    
}
-(void)validationAlert: (NSString *) comment
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error"
                          message:comment
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
}

- (BOOL)validateFields:(UITextField *)textField
{
    NSString *trimvalue;
    BOOL isValidField;
    trimvalue = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    isValidField = trimvalue.length > 0;
    return isValidField;
}



-(void)callVerifyApi {
    
    [SVProgressHUD show];
    AccessToken* token = sharedModel.accessToken;
    UserProfile *userProfile = sharedModel.userProfile;
    //DebugLog(@"token.access_token:%@",token.access_token);
    
    NSDictionary* bodyData = @{@"code": verificationTextField.text};
    
    NSString *command = @"verify_account";
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": userProfile.auth_token,
                               @"command": command,
                               @"body": bodyData};
    
    NSDictionary *userInfo = @{@"command":command};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        NSMutableDictionary *profilesListResponse = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userProfile"] mutableCopy];
        
        NSMutableDictionary *body =  [[profilesListResponse objectForKey:@"body"] mutableCopy];
        [body setObject:[NSNumber numberWithBool:YES] forKey:@"verified"];
        [profilesListResponse setObject:body forKey:@"body"];
        [[NSUserDefaults standardUserDefaults] setObject:profilesListResponse forKey:@"userProfile"];
        
        sharedModel.userProfile.verified = YES;
        
        [self gotoHome];
        
        [SVProgressHUD dismiss];
    } failure:^(NSDictionary *json) {
        
        
        [self verificationFailed];
        [SVProgressHUD dismiss];
    }];
    
}
-(void)verificationFailed {
    
     [self validationAlert:@"Oops! Incorrect code"];
    resend.hidden = NO;
    timerLabel.hidden = YES;
}
-(void)resendClicked {
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *userProfile = sharedModel.userProfile;
    
    //DebugLog(@"token.access_token:%@",token.access_token);
    
    NSDictionary* bodyData = @{};
    
    NSString *command = @"resend_code";
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": userProfile.auth_token,
                               @"command": command,
                               @"body": bodyData};
    
    NSDictionary *userInfo = @{@"command":command};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [self resendSuccess];
        
    } failure:^(NSDictionary *json) {
        
        [self resendFailed];
        
    }];
    
}
-(void)resendFailed {
    
    viewAppeared = NO;
}
-(void)resendSuccess {
    
    if(!viewAppeared)
    {
        NSString *message = [NSString stringWithFormat:@"Successfully sent verification code. Please check %@.",sharedModel.userProfile.email];
        
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.messageFont = [UIFont fontWithName:@"Helvetica" size:13.0];
        
        
        [[[[UIApplication sharedApplication] windows] lastObject] makeToast:message
                    duration:2.0
                    position:CSToastPositionBottom
                       title:nil
                       image:nil
                       style:style
                  completion:nil];

    }
    viewAppeared = NO;

}
-(void)laterClicked {
    
    [verificationTextField resignFirstResponder];
    [self gotoHome];
    
}
-(void)gotoHome {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    
    CAShapeLayer * lineLayer = (CAShapeLayer *)[[textField.layer sublayers] firstObject];
    lineLayer.strokeColor = UIColorFromRGB(0x2b78e4).CGColor;
    [lineLayer setNeedsDisplay];
    
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    
     if(textField == verificationTextField) {
        
        CAShapeLayer * lineLayer = (CAShapeLayer *)[[verificationTextField.layer sublayers] firstObject];
        lineLayer.strokeColor = [UIColor grayColor].CGColor;
        [lineLayer setNeedsDisplay];
        
        [textField resignFirstResponder];
         
         [self verifyClicked];
        
    }
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
