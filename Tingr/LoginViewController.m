//
//  LoginEmailViewController.m
//  Tingr
//
//  Created by Maisa Pride on 7/22/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "LoginViewController.h"
#import "VOUserProfile.h"
#import "VOProfilesList.h"
#import "ProfileDateUtils.h"

@interface LoginViewController ()
{
    UIView *emailView;
    UIView *signUpView;
    UIView *passwordView;
    UIView *verificationView;
    UITextField *emailTxtField;
    UITextField *passwordTextField;
    UITextField *choosePasswordTextField;
    UITextField *firstNameTextField;
    UITextField *lastNameTextField;
    UITextField *verificationTextField;
    NSString *gotoResult;
   
    
    UILabel *timerLabel;
    UIButton *menuButton;
    UIButton *forgotPassword;
    UIButton *resend;

    UserProfile *_userProfile;
    ModelManager *sharedModel;
    ProfilesList *profilesListObj;
    SingletonClass *singletonObj;
    AppDelegate *appDelegate;
    ProfileDateUtils *photoDateUtils;
    
     NSTimer *timer;
    
    int currMinute;
    int currSeconds;

    TPKeyboardAvoidingScrollView *scrollView;
    
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    singletonObj = [SingletonClass sharedInstance];
    sharedModel = [ModelManager sharedModel];
    photoDateUtils = [ProfileDateUtils alloc];
    
    UIImageView *bgImage = [[UIImageView alloc] init];
    [bgImage setImage:[UIImage imageNamed:@"login_Bg"]];
    [self.view addSubview:bgImage];
    [self.view addConstraintsWithFormat:@"H:|[v0]|" forViews:@[bgImage]];
    [self.view addConstraintsWithFormat:@"V:|[v0]|" forViews:@[bgImage]];
    
    scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:scrollView];

    
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:menuButton];
    
    menuButton.translatesAutoresizingMaskIntoConstraints = NO;
    /* Leading space to superview */
    NSLayoutConstraint *leftButtonXConstraint = [NSLayoutConstraint
                                                 constraintWithItem:menuButton attribute:NSLayoutAttributeLeft
                                                 relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                 NSLayoutAttributeLeft multiplier:1.0 constant:10];
    /* Top space to superview Y*/
    NSLayoutConstraint *leftButtonYConstraint = [NSLayoutConstraint
                                                 constraintWithItem:menuButton attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                 NSLayoutAttributeTop multiplier:1.0f constant:20];
    /* Fixed width */
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:menuButton
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:42];
    /* Fixed Height */
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:menuButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:42];
    /* 4. Add the constraints to button's superview*/
    [self.view addConstraints:@[leftButtonXConstraint, leftButtonYConstraint, widthConstraint, heightConstraint]];
    


    
    [self setUpEmailView];
    
}
-(void)backClicked {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setUpEmailView {
    
    emailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 170)];
    emailView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    [scrollView addSubview:emailView];
    emailView.center = self.view.center;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, Devicewidth, 40)];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Bold" size:25]};
    NSMutableAttributedString *attributesString = [[NSMutableAttributedString alloc] initWithString:@"TINGR" attributes:attributes];
    
    
    NSRange range;
        range.location = 3;
        range.length = 2;
        [attributesString setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Light" size:25]}
                                          range:range];
    [nameLabel setAttributedText:attributesString];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [emailView addSubview:nameLabel];
    
    emailTxtField = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, Devicewidth-40,30)];
    emailTxtField.delegate = self;
    emailTxtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailTxtField.textAlignment = NSTextAlignmentCenter;
    emailTxtField.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    NSMutableParagraphStyle *style = [emailTxtField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = emailTxtField.font.lineHeight - (emailTxtField.font.lineHeight - [UIFont fontWithName:@"HelveticaNeue" size:16].lineHeight) / 2.0;
    
    emailTxtField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"enter your email"
                                                                       attributes:@{
                                                                                    NSForegroundColorAttributeName: [UIColor grayColor],
                                                                                    NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:16],
                                                                                    NSParagraphStyleAttributeName : style
                                                                                    }
                                        ];
    emailTxtField.returnKeyType = UIReturnKeyGo;
    emailTxtField.keyboardType = UIKeyboardTypeEmailAddress;
    
    [emailView addSubview:emailTxtField];
    
    CGRect rect = emailTxtField.frame;
    
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
         
         [emailTxtField.layer addSublayer:lineLayer];


    UIButton *goButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [goButton setTitle:@"GO" forState:UIControlStateNormal];
    [goButton.titleLabel setFont:[UIFont fontWithName:@"Antonio-Bold" size:20]];
    [goButton setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(goButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [goButton setFrame:CGRectMake(Devicewidth-60, emailTxtField.frame.origin.y+30, 40, 40)];
    [emailView addSubview:goButton];

    
    
}

#pragma mark - Actions
#pragma mark -
- (void)goButtonClick
{
    
    
    // To dismiss the keyboard
    [emailTxtField resignFirstResponder];
    // Validate the email field and also check the valid email or not
    if  (emailTxtField.text.length >0 && [self validateFields:emailTxtField])
    {
        if(![self validateEmailWithString:emailTxtField.text])
        {
            [self validationAlert:@"Invalid email"];
            return;
        }
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
            
            [self callAPI];
        }
    }
    else
    {
        // If user not enterd email , shows the alert
        [self validationAlert:@"Please enter email"];
    }
}
- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
- (BOOL)validateFields:(UITextField *)textField
{
    NSString *trimvalue;
    BOOL isValidField;
    trimvalue = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    isValidField = trimvalue.length > 0;
    return isValidField;
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

#pragma mark- EvaluateUserManagerDelegate Methods
#pragma mark-

-(void)callAPI {
    
    [SVProgressHUD show];
    NSString* token = sharedModel.accessToken.access_token;

    NSDictionary* bodyData = @{@"email": emailTxtField.text};
    NSDictionary* postData = @{@"command": @"evaluate_user",
                               @"access_token": token,
                               @"body": bodyData};

    NSDictionary *userInfo = @{@"command":@"evaluate_user"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [self sendSuccessWithDetails:json];
        
    } failure:^(NSDictionary *json) {
        
        [self sendFailedWithError:json];
    }];
}

- (void)sendSuccessWithDetails:(NSDictionary *)responseDetails
{
    // NSDictionary *info = [responseDetails objectForKey:@"userInfo"];
    responseDetails = [responseDetails objectForKey:@"response"];
    [SVProgressHUD dismiss];
    // User login success bool
    DebugLog(@"%@",responseDetails);
    NSMutableDictionary *body = [responseDetails objectForKey:@"body"];
    
    NSNumber *respStatus = [responseDetails valueForKey:@"status"];
    NSString *respStrStatus = [NSString stringWithFormat:@"%@",[respStatus stringValue]];
    
    if ([respStrStatus isEqualToString:@"200"])
    {
        gotoResult = [body valueForKey:@"goto"];
        if ([gotoResult isEqualToString:@"login"])
        {
            
            [self performSelectorOnMainThread:@selector(showPasswordView) withObject:nil waitUntilDone:NO];
        }
        else if ([gotoResult isEqualToString:@"signup"])
        {
            
            
            [self performSelectorOnMainThread:@selector(showSignUpView) withObject:nil waitUntilDone:NO];
        }
        else if ([gotoResult isEqualToString:@"create_user"])
        {
            
            [self performSelectorOnMainThread:@selector(showPasswordView) withObject:nil waitUntilDone:NO];
            
        }
    }
}
- (void)sendFailedWithError:(NSDictionary *)responseDetails
{
    
    [SVProgressHUD dismiss];
}


#pragma mark TextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    
        CAShapeLayer * lineLayer = (CAShapeLayer *)[[textField.layer sublayers] firstObject];
        lineLayer.strokeColor = UIColorFromRGB(0x2b78e4).CGColor;
        [lineLayer setNeedsDisplay];
        
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    
    if(textField == emailTxtField) {
        
        CAShapeLayer * lineLayer = (CAShapeLayer *)[[emailTxtField.layer sublayers] firstObject];
        lineLayer.strokeColor = [UIColor grayColor].CGColor;
        [lineLayer setNeedsDisplay];
        
        [textField resignFirstResponder];
        
        [self goButtonClick];
    }
    
    else if(textField == passwordTextField) {
        
        CAShapeLayer * lineLayer = (CAShapeLayer *)[[passwordTextField.layer sublayers] firstObject];
        lineLayer.strokeColor = [UIColor grayColor].CGColor;
        [lineLayer setNeedsDisplay];
        
        [textField resignFirstResponder];
        
        if([gotoResult isEqualToString:@"signup"])
            [self callSignUP];
            else
        [self callLoginApi];
    }
    else if(textField == firstNameTextField) {
        
        CAShapeLayer * lineLayer = (CAShapeLayer *)[[firstNameTextField.layer sublayers] firstObject];
        lineLayer.strokeColor = [UIColor darkGrayColor].CGColor;
        [lineLayer setNeedsDisplay];
        
        [textField resignFirstResponder];
        
    }
    else if(textField == lastNameTextField) {
        
        CAShapeLayer * lineLayer = (CAShapeLayer *)[[lastNameTextField.layer sublayers] firstObject];
        lineLayer.strokeColor = [UIColor darkGrayColor].CGColor;
        [lineLayer setNeedsDisplay];
        
        [textField resignFirstResponder];
        
    }
    else if(textField == verificationTextField) {
        
        CAShapeLayer * lineLayer = (CAShapeLayer *)[[verificationTextField.layer sublayers] firstObject];
        lineLayer.strokeColor = [UIColor grayColor].CGColor;
        [lineLayer setNeedsDisplay];
        
        [self verifyClicked];
        
    }
    
    scrollView.contentOffset = CGPointMake(0, 0);
    scrollView.contentSize = CGSizeMake(Devicewidth, Deviceheight);

    return YES;
}

-(void)showPasswordView {
    
    passwordView = [[UIView alloc] initWithFrame:CGRectMake(-Devicewidth, (Deviceheight-170)/2.0, Devicewidth, 170)];
    passwordView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    [scrollView addSubview:passwordView];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, Devicewidth, 40)];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Bold" size:25]};
    NSMutableAttributedString *attributesString = [[NSMutableAttributedString alloc] initWithString:@"TINGR" attributes:attributes];
    
    
    NSRange range;
    range.location = 3;
    range.length = 2;
    [attributesString setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Light" size:25]}
                              range:range];
    [nameLabel setAttributedText:attributesString];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [passwordView addSubview:nameLabel];
    
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 70, Devicewidth-40,30)];
    passwordTextField.delegate = self;
    passwordTextField.textAlignment = NSTextAlignmentCenter;
    passwordTextField.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    NSMutableParagraphStyle *style = [passwordTextField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = passwordTextField.font.lineHeight - (passwordTextField.font.lineHeight - [UIFont fontWithName:@"HelveticaNeue" size:16].lineHeight) / 2.0;
    
    passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"enter your password"
                                                                          attributes:@{
                                                                                       NSForegroundColorAttributeName: [UIColor grayColor],
                                                                                       NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:16],
                                                                                       NSParagraphStyleAttributeName : style
                                                                                       }
                                           ];
    passwordTextField.returnKeyType = UIReturnKeyGo;
    passwordTextField.secureTextEntry = YES;
    [passwordView addSubview:passwordTextField];
    
    CGRect rect = passwordTextField.frame;
    
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
    
    [passwordTextField.layer addSublayer:lineLayer];
    
    
    forgotPassword  = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgotPassword setTitle:@"forgot password? click here to reset now" forState:UIControlStateNormal];
    [forgotPassword.titleLabel setFont:[UIFont fontWithName:@"Antonio-Regular" size:15]];
    [forgotPassword setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
    [forgotPassword addTarget:self action:@selector(forgotClicked) forControlEvents:UIControlEventTouchUpInside];
    [forgotPassword setFrame:CGRectMake(20, passwordTextField.frame.origin.y+30, Devicewidth-40,25)];
    [passwordView addSubview:forgotPassword];

    forgotPassword.hidden = YES;
    
    
    UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"<" forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont fontWithName:@"Antonio-Light" size:50]];
    [backButton setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(passwordBackArrowClicked) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(20, forgotPassword.frame.origin.y+25, 40, 40)];
    [passwordView addSubview:backButton];

    
    
    UIButton *goButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [goButton setTitle:@">" forState:UIControlStateNormal];
    [goButton.titleLabel setFont:[UIFont fontWithName:@"Antonio-Light" size:50]];
    [goButton setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(passwordNextClicked) forControlEvents:UIControlEventTouchUpInside];
    [goButton setFrame:CGRectMake(Devicewidth-60, forgotPassword.frame.origin.y+25, 40, 40)];
    [passwordView addSubview:goButton];

    [UIView animateWithDuration:0.2f
                     animations:^{
                         CGRect frame = emailView.frame;
                         frame.origin.x = -emailView.frame.size.width;
                         emailView.frame = frame;
                         frame = passwordView.frame;
                         frame.origin.x = 0;
                         passwordView.frame = frame;
                     }
     ];

    
}
-(void)forgotClicked {
    
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [singletonObj stringFromStatus:status];
    
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
        [SVProgressHUD show];
        NSString *username = emailTxtField.text;
        NSString* token = sharedModel.accessToken.access_token;
        
        NSDictionary* bodyData = @{@"email": username};
        
        //build an info object and convert to json
        NSDictionary* postData = @{@"command": @"forgot_password",
                                   @"access_token": token,
                                   @"body": bodyData};
        NSDictionary *userInfo = @{@"command":@"forgot_password"};
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
        
        NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
        API *api = [[API alloc] init];
        [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
            
            [SVProgressHUD dismiss];
            [self sendSuccess];
            
        } failure:^(NSDictionary *json) {
            
            [SVProgressHUD dismiss];

            [self validationAlert:[json objectForKey:@"message"]];

        }];
        
        
        
    }

}

- (void)sendSuccess
{
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Success"
                          message:FORGOT_PASS_SUCCESS_MESSAGE
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    
}

-(void)passwordBackArrowClicked {
    
    [passwordTextField resignFirstResponder];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         CGRect frame = emailView.frame;
                         frame.origin.x = 0;
                         emailView.frame = frame;
                         frame = passwordView.frame;
                         frame.origin.x = passwordView.frame.size.width;
                         passwordView.frame = frame;
                     }
     ];

}
-(void)passwordNextClicked {
    
    [passwordTextField resignFirstResponder];
    
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [singletonObj stringFromStatus:status];
    
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
        
            if([self validateFields:passwordTextField])
            {
                
                [self callLoginApi];
                
            }
            else
            {
                [self validationAlert:@"Please enter password."];
                
            }
    }
}


-(void)showSignUpView {
    
    signUpView = [[UIView alloc] initWithFrame:CGRectMake(-Devicewidth, (Deviceheight-200)/2.0, Devicewidth, 200)];
    signUpView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    [scrollView addSubview:signUpView];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, Devicewidth, 40)];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Bold" size:25]};
    NSMutableAttributedString *attributesString = [[NSMutableAttributedString alloc] initWithString:@"TINGR" attributes:attributes];
    
    
    NSRange range;
    range.location = 3;
    range.length = 2;
    [attributesString setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Light" size:25]}
                              range:range];
    [nameLabel setAttributedText:attributesString];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [signUpView addSubview:nameLabel];
    
    
    firstNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, (Devicewidth-50)/2.0,30)];
    firstNameTextField.delegate = self;
    firstNameTextField.textColor = UIColorFromRGB(0x2b78e4);
    firstNameTextField.textAlignment = NSTextAlignmentCenter;
    firstNameTextField.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    NSMutableParagraphStyle *style = [firstNameTextField.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
    style.minimumLineHeight = firstNameTextField.font.lineHeight - (firstNameTextField.font.lineHeight - [UIFont fontWithName:@"HelveticaNeue-Bold" size:16].lineHeight) / 2.0;
    
    firstNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First Name"
                                                                              attributes:@{
                                                                                           NSForegroundColorAttributeName: [UIColor grayColor],
                                                                                           NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:16],
                                                                                           NSParagraphStyleAttributeName : style
                                                                                           }
                                               ];
    [signUpView addSubview:firstNameTextField];
    
    CGRect rect = firstNameTextField.frame;
    
    rect.size.height -= 3;
    UIBezierPath * linePath = [UIBezierPath bezierPath];
    
    // start at top left corner
    [linePath moveToPoint:CGPointMake(0,rect.size.height)];
    // draw right vertical side
    [linePath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    
    
    // create a layer that uses your defined path
    CAShapeLayer * lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 1.2;
    lineLayer.strokeColor = [UIColor darkGrayColor].CGColor;
    
    lineLayer.fillColor = nil;
    lineLayer.path = linePath.CGPath;
    
    [firstNameTextField.layer addSublayer:lineLayer];
    
    lastNameTextField = [[UITextField alloc] initWithFrame:CGRectMake((Devicewidth-50)/2.0+30, 80, (Devicewidth-50)/2.0,30)];
    lastNameTextField.delegate = self;
    lastNameTextField.textColor = UIColorFromRGB(0x2b78e4);
    lastNameTextField.textAlignment = NSTextAlignmentCenter;
    lastNameTextField.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
    style.minimumLineHeight = lastNameTextField.font.lineHeight - (lastNameTextField.font.lineHeight - [UIFont fontWithName:@"HelveticaNeue-Bold" size:16].lineHeight) / 2.0;
    
    lastNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last Name"
                                                                               attributes:@{
                                                                                            NSForegroundColorAttributeName: [UIColor grayColor],
                                                                                            NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Bold" size:16],
                                                                                            NSParagraphStyleAttributeName : style
                                                                                            }
                                                ];
    [signUpView addSubview:lastNameTextField];
    
     rect = lastNameTextField.frame;
    
    rect.size.height -= 3;
    UIBezierPath * linePath2 = [UIBezierPath bezierPath];
    
    // start at top left corner
    [linePath2 moveToPoint:CGPointMake(0,rect.size.height)];
    // draw right vertical side
    [linePath2 addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    
    
    // create a layer that uses your defined path
    CAShapeLayer * lineLayer1 = [CAShapeLayer layer];
    lineLayer1.lineWidth = 1.2;
    lineLayer1.strokeColor = [UIColor darkGrayColor].CGColor;
    
    lineLayer1.fillColor = nil;
    lineLayer1.path = linePath2.CGPath;
    
    [lastNameTextField.layer addSublayer:lineLayer1];
    

    

    
    
    passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 125, Devicewidth-40,30)];
    passwordTextField.delegate = self;
    passwordTextField.textAlignment = NSTextAlignmentCenter;
    passwordTextField.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    style.minimumLineHeight = passwordTextField.font.lineHeight - (passwordTextField.font.lineHeight - [UIFont fontWithName:@"HelveticaNeue" size:16].lineHeight) / 2.0;
    
    passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"choose your password"
                                                                              attributes:@{
                                                                                           NSForegroundColorAttributeName: [UIColor grayColor],
                                                                                           NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:16],
                                                                                           NSParagraphStyleAttributeName : style
                                                                                           }
                                               ];
    passwordTextField.returnKeyType = UIReturnKeyGo;
    passwordTextField.secureTextEntry = YES;
    [signUpView addSubview:passwordTextField];
    
     rect = passwordTextField.frame;
    
    rect.size.height -= 4;
    UIBezierPath * linePath3 = [UIBezierPath bezierPath];
    
    // start at top left corner
    [linePath3 moveToPoint:CGPointMake(0,rect.size.height-5)];
    // draw right vertical side
    [linePath3 addLineToPoint:CGPointMake(0, rect.size.height)];
    // draw left vertical side
    [linePath3 addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    
    // draw from bottom right corner back to bottom left corner
    [linePath3 addLineToPoint:CGPointMake(rect.size.width, rect.size.height-5)];
    
    // create a layer that uses your defined path
    CAShapeLayer * lineLayer2 = [CAShapeLayer layer];
    lineLayer2.lineWidth = 1.0;
    lineLayer2.strokeColor = [UIColor grayColor].CGColor;
    
    lineLayer2.fillColor = nil;
    lineLayer2.path = linePath3.CGPath;
    
    [passwordTextField.layer addSublayer:lineLayer2];
    
    UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setTitle:@"<" forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont fontWithName:@"Antonio-Light" size:50]];
    [backButton setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(signUpBackArrowClicked) forControlEvents:UIControlEventTouchUpInside];
    [backButton setFrame:CGRectMake(20, passwordTextField.frame.origin.y+26, 40, 40)];
    [signUpView addSubview:backButton];
    
    
    
    UIButton *goButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [goButton setTitle:@">" forState:UIControlStateNormal];
    [goButton.titleLabel setFont:[UIFont fontWithName:@"Antonio-Light" size:50]];
    [goButton setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
    [goButton addTarget:self action:@selector(signUpNextClicked) forControlEvents:UIControlEventTouchUpInside];
    [goButton setFrame:CGRectMake(Devicewidth-60, passwordTextField.frame.origin.y+26, 40, 40)];
    [signUpView addSubview:goButton];
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         CGRect frame = emailView.frame;
                         frame.origin.x = -emailView.frame.size.width;
                         emailView.frame = frame;
                         frame = signUpView.frame;
                         frame.origin.x = 0;
                         signUpView.frame = frame;
                     }
     ];
    
    
}
-(void)signUpBackArrowClicked {
    
    
    [passwordTextField resignFirstResponder];
    [firstNameTextField resignFirstResponder];
    [lastNameTextField resignFirstResponder];
    [UIView animateWithDuration:0.2f
                     animations:^{
                         CGRect frame = emailView.frame;
                         frame.origin.x = 0;
                         emailView.frame = frame;
                         frame = signUpView.frame;
                         frame.origin.x = signUpView.frame.size.width;
                         signUpView.frame = frame;
                     }
     ];

}
-(void)signUpNextClicked {
    
    [passwordTextField resignFirstResponder];
    [firstNameTextField resignFirstResponder];
    [lastNameTextField resignFirstResponder];

    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [singletonObj stringFromStatus:status];
    
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
            if([self validateFields:firstNameTextField] && [self validateFields:lastNameTextField] && [self validateFields:passwordTextField])
            {
                [self callSignUP];
            }
            else
            {
                [self validationAlert:ALL_FIELDS_REQUIRED];
                
            }
       
    }

}
-(void)callSignUP {
    
    [SVProgressHUD show];
    
    AccessToken* token = sharedModel.accessToken;
    
    
    NSMutableDictionary* bodyData = @{@"fname": firstNameTextField.text,
                                      @"lname": lastNameTextField.text}.mutableCopy;
    
    [bodyData setObject:passwordTextField.text forKey:@"password"];
    [bodyData setObject:passwordTextField.text forKey:@"password_confirmation"];
    [bodyData setObject:emailTxtField.text forKey:@"email"];
    [bodyData setObject:[NSNumber numberWithBool:YES] forKey:@"remember_me"];
    
    NSString *command = @"signup_parent";
    
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": bodyData};
    
    NSDictionary *userInfo = @{@"command":command};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        id profiles = [Factory userProfileFromJSON:[json objectForKey:@"response"]];
        [self didReceiveProfile:profiles];
        
        
        
    } failure:^(NSDictionary *json) {
        
        [self signUpFailed:[json objectForKey:@"response"]];
    }];
    
}
- (void)callLoginApi
{
    [SVProgressHUD show];
    
    AccessToken* token = sharedModel.accessToken;
    
    //DebugLog(@"token.access_token:%@",token.access_token);
    
    NSDictionary* bodyData = @{@"user_email": emailTxtField.text,
                               @"password": passwordTextField.text,
                               @"remember_me":[NSNumber numberWithBool:YES]};
    
    NSString *command = @"authentication";
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"command": command,
                               @"body": bodyData};
    
    NSDictionary *userInfo = @{@"command":command};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        id profiles = [Factory userProfileFromJSON:[json objectForKey:@"response"]];
        [self didReceiveProfile:profiles];
        
    } failure:^(NSDictionary *json) {
        
        [self fetchingProfileFailedWithError:[json objectForKey:@"response"]];
    }];
    
}

- (void)didReceiveProfile:(id)profiles
{
    
    menuButton.hidden = YES;
    _userProfile = [profiles objectAtIndex:0];
    sharedModel.userProfile = _userProfile;
    
    //reset the badge
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //set the Parse user id
    
    //unregister user for any other channels
    // [NotificationUtils resetParseChannels];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HAS_REGISTERED_KLID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [singletonObj stringFromStatus:status];
    
    //get country code
    //   CountryCodeUtils *utils = [[CountryCodeUtils alloc] init];
    // [utils checkForCountryCode];
    
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
        [self callProfileListApi];
    }
    
}

- (void)fetchingProfileFailedWithError:(NSDictionary *)error
{
    forgotPassword.hidden = NO;
    [SVProgressHUD dismiss];
    if([[error objectForKey:@"message"] length] > 0)
        [self validationAlert:[error objectForKey:@"message"]];
    else
        [self validationAlert:FAILED_LOGIN];
    
}

- (void)signUpFailed:(NSDictionary *)error
{
    
    [SVProgressHUD dismiss];
    if([[error objectForKey:@"message"] length] > 0)
        [self validationAlert:[error objectForKey:@"message"]];
    else
        
    [self validationAlert:@"Sign Up Failed. Please try agin"];
}

- (void)callProfileListApi
{
    AccessToken* token = sharedModel.accessToken;
    UserProfile *userProfile = sharedModel.userProfile;
    
    NSString *command = @"family_info";
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": userProfile.auth_token,
                               @"command": command,
                               @"body": @""};
    NSString *urlAsString = [NSString stringWithFormat:@"%@v2/profiles",BASE_URL];
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        NSArray *array =  [Factory profilesListFromJSON:[json objectForKey:@"response"]];
        [self didReceiveProfileList:array];
        
    } failure:^(NSDictionary *json) {
        
        [SVProgressHUD dismiss];
    }];
    
    
}

-(void)didReceiveProfileList:(NSArray *)profileList
{
    
    profilesListObj = [profileList objectAtIndex:0];
    singletonObj.profileKids = [profilesListObj.kids mutableCopy];
    singletonObj.allProfileParents =  [profilesListObj.parents mutableCopy];
    singletonObj.profileParents = [[profilesListObj.parents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"accessibility != -1"]] mutableCopy];
    
    singletonObj.profileOnboarding = profilesListObj.onboarding_partner;
    
    NSSortDescriptor *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fname" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    id sortDescriptors = [NSArray arrayWithObject:brandDescriptor];
    
    NSMutableArray *sortedArr  = [[singletonObj.profileParents sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    if([singletonObj.profileParents count] > 1)
    {
        NSArray *arr = [sortedArr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"kl_id = %@",sharedModel.userProfile.kl_id]];
        
        int index= (int)[sortedArr indexOfObject:[arr objectAtIndex:0]];
        if(index != 0)
        {
            [sortedArr removeObject:[arr objectAtIndex:0]];
            [singletonObj.profileParents removeAllObjects];
            [singletonObj.profileParents addObject:[arr objectAtIndex:0]];
            [singletonObj.profileParents addObjectsFromArray:sortedArr];
        }
        else
            singletonObj.profileParents = sortedArr;
    }
    else
        singletonObj.profileParents = sortedArr;
    
    
    NSMutableArray *arrTemp = [[NSMutableArray alloc]init];
    for (long int i=0;i<singletonObj.profileParents.count; i++)
    {
        NSMutableDictionary *dic = [singletonObj.profileParents objectAtIndex:i];
        NSMutableDictionary *dic2 = [[NSMutableDictionary alloc]init];
        [dic2 setValue:[dic valueForKey:@"fname"]           forKey:@"name"];
        [dic2 setValue:[dic valueForKey:@"kl_id"]           forKey:@"kl_id"];
        [dic2 setValue:[dic valueForKey:@"sharing_documents_with_me"] forKey:@"sharing_documents_with_me"];
        [dic2 setValue:[dic valueForKey:@"is_kidslink_user"] forKey:@"is_kidslink_user"];
        [dic2 setValue:[dic valueForKey:@"accessibility"] forKey:@"accessibility"];
        [dic2 setValue:[dic valueForKey:@"photograph"] forKey:@"photograph"];
        [arrTemp addObject:dic2];
        
    }
    
    singletonObj.profileKids = [photoDateUtils sortByStringDate:[singletonObj.profileKids mutableCopy]];
    
    NSMutableArray *arrTemp1 = [[NSMutableArray alloc]init];
    for (long int i=0;i<singletonObj.profileKids.count; i++)
    {
        NSMutableDictionary *dic = [singletonObj.profileKids objectAtIndex:i];
        
        NSMutableDictionary *dic2 = [[NSMutableDictionary alloc]init];
        [dic2 setValue:[dic valueForKey:@"nickname"] forKey:@"name"];
        [dic2 setValue:[dic valueForKey:@"kl_id"]    forKey:@"kl_id"];
        [dic2 setValue:[dic valueForKey:@"sharing_documents_with_me"] forKey:@"sharing_documents_with_me"];
        [dic2 setValue:[NSNumber numberWithBool:YES] forKey:@"is_kidslink_user"];
        [dic2 setValue:[NSNumber numberWithInt:2] forKey:@"accessibility"];
        [dic2 setValue:[dic valueForKey:@"photograph"] forKey:@"photograph"];
        [arrTemp1 addObject:dic2];
    }
    singletonObj.sortedKidDetails = arrTemp1;
    
    [arrTemp addObjectsFromArray:arrTemp1];
    
    NSSortDescriptor *brandDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    id sortDescriptors1 = [NSArray arrayWithObject:brandDescriptor1];
    
    singletonObj.sortedParentKidDetails = [[arrTemp sortedArrayUsingDescriptors:sortDescriptors1] mutableCopy];
    singletonObj.sortedParentKidDetails = arrTemp;
    
    singletonObj.arrayKidsLinkUsers = [[NSMutableArray alloc]init];
    
    for (NSMutableDictionary *kidsLinkUser in arrTemp)
    {
        BOOL isDocumentSharing = [[kidsLinkUser valueForKey:@"accessibility"] intValue] == 2 ? YES:NO;
        BOOL is_kidslink_user = [[kidsLinkUser valueForKey:@"is_kidslink_user"] boolValue];
        if (isDocumentSharing && is_kidslink_user)
        {
            [singletonObj.arrayKidsLinkUsers addObject:kidsLinkUser];
        }
    }
    // for show in the view all
    singletonObj.arrayShowProfiles           = [[NSMutableArray alloc]initWithArray:singletonObj.sortedParentKidDetails];
    NSMutableDictionary *entireFamilyDicionary = [[NSMutableDictionary alloc]init];
    [entireFamilyDicionary setValue:@"entire family" forKey:@"name"];
    [entireFamilyDicionary setValue:@""              forKey:@"kl_id"];
    [entireFamilyDicionary setValue:[NSNumber numberWithBool:YES] forKey:@"is_kidslink_user"];
    [entireFamilyDicionary setValue:[NSNumber numberWithBool:YES] forKey:@"sharing_documents_with_me"];
    [entireFamilyDicionary setValue:[NSNumber numberWithInt:2] forKey:@"accessibility"];
    
    [singletonObj.arrayShowProfiles insertObject:entireFamilyDicionary  atIndex:0];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:singletonObj.arrayKidsLinkUsers forKey:@"arrayKidsLinkUsers"];
    [prefs setObject:[NSDate date] forKey:@"loginDate"];
    [prefs setObject:singletonObj.profileKids forKey:@"profileKids"];
    [prefs setObject:singletonObj.profileParents forKey:@"profileParents"];
    [prefs setObject:singletonObj.profileOnboarding forKey:@"profileOnboarding"];
    [prefs setObject:singletonObj.sortedParentKidDetails forKey:@"sortedParentKidDetails"];
    [prefs setObject:singletonObj.sortedKidDetails forKey:@"sortedKidDetails"];
    [prefs setObject:singletonObj.arrayShowProfiles forKey:@"arrayShowProfiles"];
    //[prefs setObject:@"yes" forKey:@"isRemember"];
    [prefs setBool:YES forKey:@"isLoggedin"];
    
    if(_userProfile.verified_phone_number != nil && _userProfile.verified_phone_number.length > 0)
    {
        [prefs setBool:YES forKey:@"isVerified"];
    }
    
    [prefs synchronize];
    
    
    
    if(_userProfile.verified == NO)
    {
        
        [SVProgressHUD dismiss];
        [self showVerficationView];
        return;
    }
    else
    {
        
        
        [SVProgressHUD dismiss];
        [self gotoHome];
    }
}

-(void)showVerficationView {
    
    currMinute=0;
    currSeconds=59;
    
    
    verificationView = [[UIView alloc] initWithFrame:CGRectMake(-Devicewidth, 0, Devicewidth, 200)];
    verificationView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    [scrollView addSubview:verificationView];
    verificationView.center = self.view.center;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, Devicewidth, 40)];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Bold" size:25]};
    NSMutableAttributedString *attributesString = [[NSMutableAttributedString alloc] initWithString:@"TINGR" attributes:attributes];
    
    
    NSRange range;
    range.location = 3;
    range.length = 2;
    [attributesString setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Light" size:25]}
                              range:range];
    [nameLabel setAttributedText:attributesString];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [verificationView addSubview:nameLabel];
    
    UILabel *confirmLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, Devicewidth-20, 28)];
    [confirmLabel setText:[NSString stringWithFormat:@"please confirm you've access to email address: %@",emailTxtField.text]];
    [confirmLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:12]];
    confirmLabel.numberOfLines = 2;
    confirmLabel.textAlignment = NSTextAlignmentCenter;
    [confirmLabel setTextColor:[UIColor lightGrayColor]];
    [verificationView addSubview:confirmLabel];
    
    
    
    
    
    verificationTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 95, Devicewidth-40,30)];
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

    if(![gotoResult isEqualToString:@"signup"])
    {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             CGRect frame = passwordView.frame;
                             frame.origin.x = -passwordView.frame.size.width;
                             passwordView.frame = frame;
                             frame = verificationView.frame;
                             frame.origin.x = 0;
                             verificationView.frame = frame;
                             
                         }
                         completion:^(BOOL finished) {
                             timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
                             
                         }
         ];
   
    }
    else
    {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             CGRect frame = signUpView.frame;
                             frame.origin.x = -signUpView.frame.size.width;
                             signUpView.frame = frame;
                             frame = verificationView.frame;
                             frame.origin.x = 0;
                             verificationView.frame = frame;
                             
                         }
                         completion:^(BOOL finished) {
                             timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
                             
                         }
         ];
        
    }

    
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
        
    }];
    
}
-(void)resendSuccess {
    
    
    [self validationAlert:@"Verification code has been sent to your email address."];
    
}
-(void)laterClicked {
    
    [self gotoHome];
    
}
-(void)gotoHome {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LogIn" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    
    [appDelegate subscribeUserToFirebase];
    [appDelegate askForNotificationPermission];

    
    
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
