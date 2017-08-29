//
//  LodingViewController.m
//  Tingr
//
//  Created by Maisa Pride on 7/23/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "LoadingViewController.h"
#import "VOAccessToken.h"
#import "HomeViewController.h"

@interface LoadingViewController ()
{
    ProfilePhotoUtils *photoUtils;
}
@end

@implementation LoadingViewController
@synthesize singletonObj;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    singletonObj = [SingletonClass sharedInstance];
    photoUtils = [ProfilePhotoUtils alloc];

    
    
    
    NSArray * colorsArray = @[@0xcb5382,@0x007966,@0xcb0e40];
      int randomIndex = arc4random() % 3;
    self.view.backgroundColor = UIColorFromRGB([colorsArray[randomIndex] integerValue]);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 90, 90)];
    [imageView setCenter:self.view.center];
    [self.view addSubview:imageView];
   
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loading" ofType:@"gif"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *gif_image = [UIImage animatedImageWithAnimatedGIFData:data];
    [imageView setImage:gif_image];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedin"])
        [self callAccessTokenApi];
    else {
        
        [self callUserInfo];
    }
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
}
- (void)callAccessTokenApi
{
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"grant_type": @"client_credentials",
                               @"client_id": CLIENT_ID,
                               @"client_secret": CLIENT_SECRET,
                               @"scope": @"ikidslink"};
    NSDictionary* userInfo = @{@"command": @"userInfo"};
    NSString *urlAsString = [NSString stringWithFormat:@"%@clients/token",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        
        NSArray *tokenArray = [Factory tokenFromJSON:json];
        [self didReceiveTokens:tokenArray];
        
    } failure:^(NSDictionary *json) {
        
        [self fetchingTokensFailedWithError:json];
        
    }];
    
    
    
}
-(void)callUserInfo {
    
    
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    UserProfile *userProfile = sharedModel.userProfile;
    
    NSString *command = @"user_info";
    
    
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

        id profiles = [Factory userProfileFromJSON:[json objectForKey:@"response"]];
        [self didReceiveProfile:profiles];
        
    } failure:^(NSDictionary *json) {
        
        [self callUserInfo];

    }];
    
    
}
- (void)didReceiveProfile:(id)profiles
{
    ModelManager *sharedModel = [ModelManager sharedModel];
    sharedModel.userProfile = [profiles objectAtIndex:0];
    [self gotoHome];
}


#pragma mark- AccessTokenManagerDelegate Methods
#pragma mark-
- (void)didReceiveTokens:(NSArray *)tokens
{
    ModelManager *sharedModel = [ModelManager sharedModel];
    sharedModel.accessToken = [tokens objectAtIndex:0];
    [self gotoHome];
    
}

- (void)fetchingTokensFailedWithError:(NSDictionary *)error
{
    [self callAccessTokenApi];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)gotoHome {

    HomeViewController *home = [[HomeViewController alloc] init];
   // [self.navigationController pushViewController:home animated:YES];
    NSMutableArray *viewControlers = [self.navigationController.viewControllers mutableCopy];
    [viewControlers addObject:home];
    [viewControlers removeObject:self];
    [self.navigationController setViewControllers:viewControlers animated:YES];
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
