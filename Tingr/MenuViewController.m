//
//  MenuViewController.m
//  Tingr
//
//  Created by Maisa Pride on 7/24/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "MenuViewController.h"
#import "UIImageViewAligned.h"
#import "EditProfileViewController.h"
#import "MyFamilyViewController.h"

@import Firebase;
@import FirebaseMessaging;

@interface MenuViewController ()
{
    UIView *nonLoginVIew;
    UIView *loggedInView;
    AppDelegate *appdelegate;
    ModelManager *sharedModel;
}

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    sharedModel = [ModelManager sharedModel];
    
    self.mediaFocusManager = [[ASMediaFocusManager alloc] init];
    self.mediaFocusManager.delegate = self;

    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    singleTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:singleTap];
    
    
}
-(void)tapped:(UITapGestureRecognizer *)gesture {
    
    if(gesture.view == self.view)
        [[appdelegate navgController] toggleLeftMenu];
  
}
-(void)orgTapped:(id)gesture
{
    NSURL *URL = [NSURL URLWithString:@"https://tingr.org/"];
    WebViewController *webcntrl  = [[WebViewController alloc] init];
    webcntrl.url = URL;
    [self presentViewController:webcntrl animated:YES completion:^{
        
    }];
    

}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // return YES (the default) to allow the gesture recognizer to examine the touch object, NO to prevent the gesture recognizer from seeing this touch object.
    if(touch.view == self.view) {
        return YES;
    }
    else {
        return NO;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self setUpViews];
}
-(void)setUpViews {
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedin"]) {
        
        [self showLoggedInView];
        
    }
    else {
        
        [self showNonLoginView];
        
    }
}
-(void)showNonLoginView {
    
    nonLoginVIew = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth-100, Deviceheight)];
    [self.view addSubview:nonLoginVIew];
    self.gradient = [CAGradientLayer layer];
    self.gradient.frame = nonLoginVIew.bounds;
    self.gradient.colors = @[(id)[UIColor colorWithRed:248/255.0 green:252/255.0 blue:254/255.0 alpha:1.0].CGColor,
                             (id)[UIColor colorWithRed:164/255.0 green:202/255.0 blue:246/255.0 alpha:1.0].CGColor];
    
    [nonLoginVIew.layer insertSublayer:self.gradient atIndex:0];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth-100, 190)];
    [contentView setCenter:nonLoginVIew.center];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((Devicewidth-100-60)/2, 8, 60, 60)];
    [imageView setImage:[UIImage imageNamed:@"AppLogo"]];
    [contentView addSubview:imageView];
    
    UILabel *tingrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height+imageView.frame.origin.y+5, Devicewidth-100, 20)];
    [tingrLabel setTextColor:[UIColor darkGrayColor]];
    [tingrLabel setText:@"www.tingr.org"];
    [tingrLabel setTextAlignment:NSTextAlignmentCenter];
    [tingrLabel setFont:[UIFont fontWithName:@"Anton" size:15]];
    [contentView addSubview:tingrLabel];
    
    UIButton *orgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [orgButton addTarget:self action:@selector(orgTapped:) forControlEvents:UIControlEventTouchUpInside];
    [orgButton setFrame:CGRectMake((Devicewidth-200)/2, 8, 100, 80)];
    [contentView addSubview:orgButton];

    
    UIButton *contactUsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [contactUsButton setTitle:@"contact us" forState:UIControlStateNormal];
    [contactUsButton setTitleColor:UIColorFromRGB(0x99CCFF) forState:UIControlStateNormal ];
    [contactUsButton.titleLabel setFont:[UIFont fontWithName:@"Anton" size:16]];
    [contactUsButton addTarget:self action:@selector(contactUsClicked) forControlEvents:UIControlEventTouchUpInside];
    [contactUsButton setFrame:CGRectMake(0, tingrLabel.frame.size.height+tingrLabel.frame.origin.y+5, Devicewidth-100, 25)];
    [contentView addSubview:contactUsButton];
    

    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setTitle:@"login" forState:UIControlStateNormal];
    [loginButton setTitleColor:UIColorFromRGB(0x99CCFF) forState:UIControlStateNormal ];
    [loginButton.titleLabel setFont:[UIFont fontWithName:@"Anton" size:16]];
    [loginButton addTarget:self action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setFrame:CGRectMake(0, contactUsButton.frame.size.height+contactUsButton.frame.origin.y, Devicewidth-100, 25)];
    [contentView addSubview:loginButton];
    
    UILabel *builtlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, loginButton.frame.size.height+loginButton.frame.origin.y+10, Devicewidth-100, 15)];
    [builtlLabel setText:@"built with lots of \u2665 in \u2600 California"];
    builtlLabel.textAlignment = NSTextAlignmentCenter;
    [builtlLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
    [builtlLabel setTextColor:[UIColor colorWithRed:(145/255.f) green:(186/255.f) blue:(89/255.f) alpha:1]];
    [contentView addSubview:builtlLabel];

    UIButton *termsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [termsButton addTarget:self action:@selector(termsButton) forControlEvents:UIControlEventTouchUpInside];
    [termsButton setFrame:CGRectMake(5, builtlLabel.frame.size.height+builtlLabel.frame.origin.y-8, Devicewidth-110, 25)];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:10]};
    
    termsButton.titleLabel.adjustsFontSizeToFitWidth = YES;

    NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:@"\u2233 by using our services, you agree to our terms & conditions" attributes:attributes];
    
    NSRange range = [tncString.string rangeOfString:@"terms & conditions"];
    
    // workaround for bug in UIButton - first char needs to be underlined for some reason!
    [tncString addAttribute:NSUnderlineStyleAttributeName
                      value:@(NSUnderlineStyleSingle)
                      range:range];
    [termsButton setAttributedTitle:tncString forState:UIControlStateNormal];
    [contentView addSubview:termsButton];
    [nonLoginVIew addSubview:contentView];

}
-(void)showLoggedInView {
    
    loggedInView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth-100, Deviceheight)];
    [loggedInView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:loggedInView];
    
    UIImageViewAligned *profileImage = [[UIImageViewAligned alloc] initWithFrame:CGRectMake(0, 0,loggedInView.frame.size.width, 180)];
    profileImage.contentMode = UIViewContentModeScaleAspectFill;
    profileImage.clipsToBounds = YES;
    profileImage.alignment = UIImageViewAlignmentMaskCenter;
    [loggedInView addSubview:profileImage];
    [profileImage setImageWithURL:[NSURL URLWithString:sharedModel.userProfile.photograph] placeholderImage:[UIImage imageNamed:@"place_holder"]];
    if(sharedModel.userProfile.photograph.length > 0)
        [self.mediaFocusManager installOnView:profileImage];

    
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, profileImage.frame.size.height+profileImage.frame.origin.y, Devicewidth-100, 25)];
    [nameLabel setTextColor:UIColorFromRGB(0x2b78e4)];
    [nameLabel setTextAlignment:NSTextAlignmentCenter];
    [nameLabel setFont:[UIFont fontWithName:@"Antonio-Bold" size:18]];
    [loggedInView addSubview:nameLabel];
    
    NSMutableString *fullName = [[NSMutableString alloc] init];
    if(sharedModel.userProfile.fname.length >0)
        [fullName appendString:sharedModel.userProfile.fname];
    if(sharedModel.userProfile.lname.length >0)
    {
        if(fullName.length > 0)
            [fullName appendString:@" "];
        [fullName appendString:sharedModel.userProfile.lname];
    }
    nameLabel.text = fullName;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, nameLabel.frame.size.height+nameLabel.frame.origin.y, loggedInView.frame.size.width, 0.5)];
    [lineView setBackgroundColor:[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]];
    [loggedInView addSubview:lineView];
    
    UIButton *familyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [familyButton setTitle:@"My Family" forState:UIControlStateNormal];
    familyButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    familyButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [familyButton setImage:[UIImage imageNamed:@"profiles"] forState:UIControlStateNormal];
    [familyButton setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal ];
    [familyButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [familyButton addTarget:self action:@selector(familyClicked) forControlEvents:UIControlEventTouchUpInside];
    [familyButton setFrame:CGRectMake(0, lineView.frame.size.height+lineView.frame.origin.y+3, loggedInView.frame.size.width/2, 50)];
    [loggedInView addSubview:familyButton];
    
    CGSize buttonSize = familyButton.frame.size;
    NSString *buttonTitle = familyButton.titleLabel.text;
    CGSize titleSize = [buttonTitle sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:14] }];
    UIImage *buttonImage = familyButton.imageView.image;
    CGSize buttonImageSize = buttonImage.size;
    CGFloat offsetBetweenImageAndText =-3; //vertical space between image and text

    
    [familyButton setImageEdgeInsets:UIEdgeInsetsMake((buttonSize.height - (titleSize.height + buttonImageSize.height)) / 2 - offsetBetweenImageAndText,
                                                (buttonSize.width - buttonImageSize.width) / 2,
                                                0,0)];
    [familyButton setTitleEdgeInsets:UIEdgeInsetsMake((buttonSize.height - (titleSize.height + buttonImageSize.height)) / 2 + buttonImageSize.height + offsetBetweenImageAndText,
                                                titleSize.width + [familyButton imageEdgeInsets].left > buttonSize.width ? -buttonImage.size.width  +  (buttonSize.width - titleSize.width) / 2 : (buttonSize.width - titleSize.width) / 2 - buttonImage.size.width,
                                                0,0)];

    

    
    UIButton *EditProfileButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [EditProfileButton setTitle:@"Edit Profile" forState:UIControlStateNormal];
    EditProfileButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    EditProfileButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    [EditProfileButton setImage:[UIImage imageNamed:@"person"] forState:UIControlStateNormal];
    [EditProfileButton setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal ];
    [EditProfileButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [EditProfileButton addTarget:self action:@selector(editProfielClicked) forControlEvents:UIControlEventTouchUpInside];
    [EditProfileButton setFrame:CGRectMake(loggedInView.frame.size.width/2, lineView.frame.size.height+lineView.frame.origin.y+3, loggedInView.frame.size.width/2, 50)];
    [loggedInView addSubview:EditProfileButton];
    
    CGSize buttonSize1 = EditProfileButton.frame.size;
    NSString *buttonTitle1 = EditProfileButton.titleLabel.text;
    CGSize titleSize1 = [buttonTitle1 sizeWithAttributes:@{ NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:14] }];
    UIImage *buttonImage1 = EditProfileButton.imageView.image;
    CGSize buttonImageSize1 = buttonImage.size;
    CGFloat offsetBetweenImageAndText1 = -2; //vertical space between image and text
    
    
    [EditProfileButton setImageEdgeInsets:UIEdgeInsetsMake((buttonSize1.height - (titleSize1.height + buttonImageSize1.height)) / 2 - offsetBetweenImageAndText,
                                                      (buttonSize1.width - buttonImageSize1.width) / 2,
                                                      0,0)];
    [EditProfileButton setTitleEdgeInsets:UIEdgeInsetsMake((buttonSize1.height - (titleSize1.height + buttonImageSize1.height)) / 2 + buttonImageSize1.height + offsetBetweenImageAndText1,
                                                      titleSize1.width + [EditProfileButton imageEdgeInsets].left > buttonSize1.width ? -buttonImage1.size.width  +  (buttonSize1.width - titleSize1.width) / 2 : (buttonSize1.width - titleSize1.width) / 2 - buttonImage1.size.width,
                                                      0,0)];

    
    UIView *spaceView = [[UIView alloc] initWithFrame:CGRectMake(0, EditProfileButton.frame.size.height+EditProfileButton.frame.origin.y+2, loggedInView.frame.size.width, 3)];
    [spaceView setBackgroundColor:[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]];
    [loggedInView addSubview:spaceView];

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, Deviceheight-190, Devicewidth-100, 190)];
    [loggedInView addSubview:contentView];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((Devicewidth-100-60)/2, 8, 60, 60)];
    [imageView setImage:[UIImage imageNamed:@"AppLogo"]];
    [contentView addSubview:imageView];
    
    UILabel *tingrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height+imageView.frame.origin.y+5, Devicewidth-100, 20)];
    [tingrLabel setTextColor:[UIColor darkGrayColor]];
    [tingrLabel setText:@"www.tingr.org"];
    [tingrLabel setTextAlignment:NSTextAlignmentCenter];
    [tingrLabel setFont:[UIFont fontWithName:@"Anton" size:15]];
    [contentView addSubview:tingrLabel];
    
    
    UIButton *orgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [orgButton addTarget:self action:@selector(orgTapped:) forControlEvents:UIControlEventTouchUpInside];
    [orgButton setFrame:CGRectMake((Devicewidth-200)/2, 8, 100, 80)];
    [contentView addSubview:orgButton];
    
    
    UIButton *contactUsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [contactUsButton setTitle:@"contact us" forState:UIControlStateNormal];
    [contactUsButton setTitleColor:UIColorFromRGB(0x99CCFF) forState:UIControlStateNormal ];
    [contactUsButton.titleLabel setFont:[UIFont fontWithName:@"Anton" size:16]];
    [contactUsButton addTarget:self action:@selector(contactUsClicked) forControlEvents:UIControlEventTouchUpInside];
    [contactUsButton setFrame:CGRectMake(0, tingrLabel.frame.size.height+tingrLabel.frame.origin.y+5, Devicewidth-100, 25)];
    [contentView addSubview:contactUsButton];
    
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setTitle:@"logout" forState:UIControlStateNormal];
    [loginButton setTitleColor:UIColorFromRGB(0x99CCFF) forState:UIControlStateNormal ];
    [loginButton.titleLabel setFont:[UIFont fontWithName:@"Anton" size:16]];
    [loginButton addTarget:self action:@selector(logoutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [loginButton setFrame:CGRectMake(0, contactUsButton.frame.size.height+contactUsButton.frame.origin.y, Devicewidth-100, 25)];
    [contentView addSubview:loginButton];
    
    UILabel *builtlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, loginButton.frame.size.height+loginButton.frame.origin.y+10, Devicewidth-100, 15)];
    [builtlLabel setText:@"built with lots of \u2665 in \u2600 California"];
    builtlLabel.textAlignment = NSTextAlignmentCenter;
    [builtlLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:10]];
    [builtlLabel setTextColor:[UIColor colorWithRed:(145/255.f) green:(186/255.f) blue:(89/255.f) alpha:1]];
    [contentView addSubview:builtlLabel];
    
    UIButton *termsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [termsButton addTarget:self action:@selector(termsButton) forControlEvents:UIControlEventTouchUpInside];
    [termsButton setFrame:CGRectMake(5, builtlLabel.frame.size.height+builtlLabel.frame.origin.y-8, Devicewidth-110, 25)];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:10]};
    
    termsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:@"\u2233 by using our services, you agree to our terms & conditions" attributes:attributes];
    
    NSRange range = [tncString.string rangeOfString:@"terms & conditions"];
    
    // workaround for bug in UIButton - first char needs to be underlined for some reason!
    [tncString addAttribute:NSUnderlineStyleAttributeName
                      value:@(NSUnderlineStyleSingle)
                      range:range];
    
    [termsButton setAttributedTitle:tncString forState:UIControlStateNormal];
    [contentView addSubview:termsButton];
    [contentView setBackgroundColor:[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]];

    
    
}
-(void)contactUsClicked {
    
    NSURL *URL = [NSURL URLWithString:@"https://tingr.org/help.html"];
    WebViewController *webcntrl  = [[WebViewController alloc] init];
    webcntrl.url = URL;
    [self presentViewController:webcntrl animated:YES completion:^{
    }];
    
}
-(void)loginButtonClicked {

    [[appdelegate navgController] toggleLeftMenu];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginTapped" object:nil];
}
-(void)termsButton {
    
    NSURL *URL = [NSURL URLWithString:@"https://tingr.org/terms.html"];
    WebViewController *webcntrl  = [[WebViewController alloc] init];
    webcntrl.url = URL;
    [self presentViewController:webcntrl animated:YES completion:^{
        
    }];
    
}
-(void)familyClicked {
    
    
    MyFamilyViewController *webcntrl  = [[MyFamilyViewController alloc] init];
    [self presentViewController:webcntrl animated:YES completion:nil];

    
}
-(void)editProfielClicked {
    
    EditProfileViewController *webcntrl  = [[EditProfileViewController alloc] init];
    [self presentViewController:webcntrl animated:YES completion:nil];

}
-(void)logoutButtonClicked {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [[SingletonClass sharedInstance] stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tingr"
                                                       message:@"No internet connection. Try again after connecting to internet"
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        [alert show];
    }
    else
    {
        [SVProgressHUD show];
        
        [appdelegate.navgController toggleLeftMenu];
        AccessToken* token = sharedModel.accessToken;
        UserProfile *userProfile = sharedModel.userProfile;
        
        NSString *command = @"revoke_authentication";
        
        
        //build an info object and convert to json
        NSDictionary* postData = @{@"access_token": token.access_token,
                                   @"auth_token": userProfile.auth_token,
                                   @"command": command,
                                   @"body": @""};
        NSString *urlAsString = [NSString stringWithFormat:@"%@users",BASE_URL];
        NSDictionary *userInfo = @{@"command":command};
        
        NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
        API *api = [[API alloc] init];
        [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {

            [self logoutSuccess];
        } failure:^(NSDictionary *json) {
            
            [SVProgressHUD dismiss];
        }];
    }
}


-(void)logoutSuccess {

    
    [self clearUserDefaults];
    
    NSString *string = [NSString stringWithFormat:@"/topics/tingr_%@",[[[ModelManager sharedModel] userProfile] kl_id]];
    [[FIRMessaging messaging] unsubscribeFromTopic:string];

    AccessToken* token = sharedModel.accessToken;
    UserProfile *userProfile = sharedModel.userProfile;

    token.access_token     = @"";
    userProfile.auth_token  = @"";
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate stopMonitoring];

    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [[SingletonClass sharedInstance] stringFromStatus:status];
    
    [[SingletonClass sharedInstance] clear];
    [sharedModel clear];
    SingletonClass *singleton = [SingletonClass sharedInstance];
    singleton.selecteOrganisation = nil;
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
        [self performSelectorInBackground:@selector(getAccessToken) withObject:nil];
    }

    
    
}

- (void)getAccessToken
{
    
    NSError* error;
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"grant_type": @"client_credentials",
                               @"client_id": CLIENT_ID,
                               @"client_secret": CLIENT_SECRET,
                               @"scope": @"ikidslink"};
    
    //convert object to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:postData options:NSJSONWritingPrettyPrinted error:&error];
    
    //convert data to string
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //DebugLog(@"AccessToken--Request: %@", jsonString);
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@clients/token",BASE_URL];
    //DebugLog(@"AccessToken---URL: %@", urlAsString);
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    //DebugLog(@"AccessToken---URL: %@", urlAsString);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSData *requestData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSHTTPURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error)
    {
        
    }
    else
    {
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        DebugLog(@"parsedObject:%@",parsedObject);
        
        [[NSUserDefaults standardUserDefaults] setObject:parsedObject forKey:@"tokens"];
        
        NSMutableArray *tokens = [[NSMutableArray alloc] init];
        AccessToken *token = [[AccessToken alloc] init];
        
        for (NSString *key in parsedObject)
        {
            if ([token respondsToSelector:NSSelectorFromString(key)]) {
                [token setValue:[parsedObject valueForKey:key] forKey:key];
            }
        }
        
        [tokens addObject:token];
        
        sharedModel.accessToken = [tokens objectAtIndex:0];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LogOut" object:nil];
        [SVProgressHUD dismiss];
    }
    
    
}
-(void)clearUserDefaults
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"streamArray"];
    [prefs removeObjectForKey:@"tokens"];
    [prefs removeObjectForKey:@"userProfile"];
    [prefs removeObjectForKey:@"profileKids"];
    [prefs removeObjectForKey:@"profileParents"];
    [prefs removeObjectForKey:@"profileOnboarding"];
    [prefs removeObjectForKey:@"sortedParentKidDetails"];
    [prefs removeObjectForKey:@"sortedKidDetails"];
    [prefs removeObjectForKey:@"arrayKidsLinkUsers"];
    [prefs removeObjectForKey:@"arrayShowProfiles"];
    [prefs removeObjectForKey:@"NewKidStreamEmptyData"];
    [prefs setBool:NO forKey:@"isLoggedin"];
    [prefs setBool:NO forKey:@"isVerified"];
    [prefs setBool:NO forKey:@"isPersonality"];
    [prefs removeObjectForKey:@"inviteTotal"];
    [prefs removeObjectForKey:@"oneWayFriendsCount"];
    [prefs removeObjectForKey:@"isight_enabled"];
    [prefs synchronize];
    
    SingletonClass *obj = [SingletonClass sharedInstance];
    obj.selecteOrganisation = nil;
}

#pragma mark - ASMediaFocusDelegate
- (UIImageView *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager imageViewForView:(UIView *)view
{
    return (UIImageView *)view;
}

- (CGRect)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager finalFrameForView:(UIView *)view
{
    return [[UIScreen mainScreen] bounds];
}

- (UIViewController *)parentViewControllerForMediaFocusManager:(ASMediaFocusManager *)mediaFocusManager
{
    return self;
}

- (NSURL *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager mediaURLForView:(UIView *)view
{
    
    
    NSURL *url;
    NSString *originalImage = [NSString stringWithFormat:@"%@",sharedModel.userProfile.photograph];
    DebugLog(@"originalImage:%@",originalImage);
    if (originalImage != (id)[NSNull null] && originalImage.length > 0)
    {
        url = [NSURL URLWithString:originalImage];
    }
    return url;
}

- (NSString *)mediaFocusManager:(ASMediaFocusManager *)mediaFocusManager titleForView:(UIView *)view;
{
    return @"";
}

- (void)mediaFocusManagerWillAppear:(ASMediaFocusManager *)mediaFocusManager
{
    
    
}

- (void)mediaFocusManagerWillDisappear:(ASMediaFocusManager *)mediaFocusManager
{
}

- (void)mediaFocusManagerDidDisappear:(ASMediaFocusManager *)mediaFocusManager
{
    
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
