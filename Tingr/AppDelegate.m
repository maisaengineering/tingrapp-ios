//
//  AppDelegate.m
//  Tingr
//
//  Created by Maisa Pride on 7/17/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "AppDelegate.h"
#import "LoadingViewController.h"
@import UserNotifications;
@import Firebase;


CLLocationManager *locationManager;
@interface AppDelegate ()<FIRMessagingDelegate,UNUserNotificationCenterDelegate>
{
    CLBeaconRegion *region;
    NSDictionary *regionDictionary;
    CBCentralManager *centralManager;
    UIBackgroundTaskIdentifier bgTask;
    
}
@end

@implementation AppDelegate
@synthesize navgController;
@synthesize isCalledAPIForBeacon;
@synthesize bottomSafeAreaInset;
@synthesize topSafeAreaInset;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    bottomSafeAreaInset = 0;
    topSafeAreaInset = 0;

    
    [FIRApp configure];
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:2 * 1024 * 1024
                                                            diskCapacity:100 * 1024 * 1024
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    if (@available(iOS 11, *)) {
        UIEdgeInsets inset = [[UIApplication sharedApplication] delegate].window.safeAreaInsets;
        bottomSafeAreaInset = inset.bottom;
        topSafeAreaInset = inset.top;
    }

   
        LoadingViewController *home = [[LoadingViewController alloc] init];
        navgController = [[SlideNavigationController alloc] initWithRootViewController:home];
        self.window.rootViewController = navgController;

    
    MenuViewController *leftMenu = [[MenuViewController alloc] init];
    navgController.leftMenu = leftMenu;
    navgController.menuRevealAnimationDuration = 0.5;
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidClose object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Closed %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidOpen object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Opened %@", menu);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SlideNavigationControllerDidReveal object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSString *menu = note.userInfo[@"menu"];
        NSLog(@"Revealed %@", menu);
    }];
    
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:BEACON_UUID];
    region = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:BEACON_IDENTIFIER];
    regionDictionary = @{BEACON_IDENTIFIER:BEACON_UUID};
    
    locationManager = [[CLLocationManager alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isISightOn = [[userDefaults objectForKey:@"isight_enabled"] boolValue];
    if(isISightOn)
        [self initialise];

    
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


#pragma mark -
#pragma mark Notification Permission
-(void)askForNotificationPermission
{
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        
        
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
        
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        // For iOS 10 data message (sent via FCM)
        [FIRMessaging messaging].remoteMessageDelegate = self;
#endif
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    // Print full message.
    DebugLog(@"%@", userInfo);
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
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
        
#ifdef DEBUG
        [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeSandbox];
#else
        [[FIRInstanceID instanceID] setAPNSToken:deviceToken type:FIRInstanceIDAPNSTokenTypeProd];
#endif
        
        
        
        // Store the deviceToken in the current installation and save it to Parse.
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    
}

#pragma mark -
#pragma Device Lock/UnLock Delegates


-(void)subscribeUserToFirebase {
    
    
    NSString *string = [NSString stringWithFormat:@"/topics/tingr_%@",[[[ModelManager sharedModel] userProfile] kl_id]];
    [[FIRMessaging messaging] subscribeToTopic:string];
    
    
}



#pragma mark -
#pragma mark Beacon Methos

-(void)initialise {
    
    
    [self initialiseLocationManager];
}
-(void)stopMonitoring {
    
    [locationManager stopMonitoringForRegion:region];
    [locationManager stopRangingBeaconsInRegion:region];
    
}
-(void)initialiseLocationManager {
    
    
    locationManager.delegate  = self;
    if([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        
        [locationManager requestAlwaysAuthorization];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isight_enabled"];
        [self checkBluetooth];
    }
    region.notifyOnExit = YES;
    region.notifyOnEntry = YES;
    region.notifyEntryStateOnDisplay = YES;
    [locationManager startMonitoringForRegion:region];
    [locationManager startRangingBeaconsInRegion:region];
    
    [self checkPermissions];
    
}
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusRestricted:
        case kCLAuthorizationStatusDenied:
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isight_enabled"];
            // do some error handling
        }
            break;
        default:{
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"isight_enabled"];
            
            [self checkBluetooth];
            
        }
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    
    
    ModelManager *sharedModel  = [ModelManager sharedModel];
    UserProfile *_userProfile = sharedModel.userProfile;
    if(_userProfile.auth_token == nil || _userProfile.auth_token.length == 0)
        return;
    if([[SingletonClass sharedInstance] isShowingBeaconPrompt] || isCalledAPIForBeacon)
    {
        return;
    }
    
    NSArray *kownBeacons = beacons;
    if(kownBeacons.count > 0)
    {
        CLBeacon *beacon = [kownBeacons firstObject];
        NSString *beacinUUID = beacon.proximityUUID.UUIDString;
        NSString *majorNumber = [NSString stringWithFormat:@"%@", beacon.major];
        NSString *minorNumber = [NSString stringWithFormat:@"%@", beacon.minor];
        
        NSDictionary *dict = @{@"isight_uuid":beacinUUID,
                               @"major_id":majorNumber,
                               @"minor_id":minorNumber};
        
        isCalledAPIForBeacon = YES;
        
        if([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
        {
            
            
            bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler: ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[UIApplication sharedApplication] endBackgroundTask:self->bgTask];
                    self->bgTask = UIBackgroundTaskInvalid;
                });
            }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                if ([[UIApplication sharedApplication] backgroundTimeRemaining] > 1.0) {
                    // Start background service synchronously
                    
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@attendances",BASE_URL]]];
                    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [request setHTTPMethod:@"POST"];
                    NSMutableDictionary *bodyDict = dict.mutableCopy;
                    //DM
                    ModelManager *sharedModel  = [ModelManager sharedModel];
                    AccessToken* token = sharedModel.accessToken;
                    UserProfile *_userProfile = sharedModel.userProfile;
                    
                    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
                        [bodyDict setObject:[NSNumber numberWithBool:YES] forKey:@"is_foreground"];
                    else
                        [bodyDict setObject:[NSNumber numberWithBool:NO] forKey:@"is_foreground"];
                    
                    DebugLog(@"request in background %@",bodyDict);
                    
                    
                    //build an info object and convert to json
                    NSDictionary* postData = @{@"access_token": token.access_token,
                                               @"auth_token": _userProfile.auth_token,
                                               @"command": @"isight_promt",
                                               @"body": bodyDict};
                    
                    NSError *error;
                    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:postData options:kNilOptions error:&error];
                    [request setHTTPBody:newAccountJSONData];
                    NSHTTPURLResponse *response = nil;
                    NSError *error1;
                    NSData *conn = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error1];
                    NSMutableDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:conn
                                                                                        options:kNilOptions
                                                                                          error:&error1];
                    isCalledAPIForBeacon = NO;
                    DebugLog(@"response in background %@",jsonResponse);
                    
                }
                isCalledAPIForBeacon = NO;
                [[UIApplication sharedApplication] endBackgroundTask:self->bgTask];
                self->bgTask = UIBackgroundTaskInvalid;
                
            });
            
        }
        else
            [self callIsightAPI:dict];
        
    }
    
}
-(void)callIsightAPI:(NSDictionary *)beaconInfo {
    
    NSMutableDictionary *bodyDict = beaconInfo.mutableCopy;
    //DM
    ModelManager *sharedModel  = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    if([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
        [bodyDict setObject:[NSNumber numberWithBool:YES] forKey:@"is_foreground"];
    else
        [bodyDict setObject:[NSNumber numberWithBool:NO] forKey:@"is_foreground"];
    
    DebugLog(@"request in foreground %@",bodyDict);
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"isight_promt",
                               @"body": bodyDict};
    
    NSDictionary *userInfo = @{@"command":@"isight_promt"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@attendances",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        DebugLog(@"request in foreground %@",[json objectForKey:@"response"]);
        
        NSDictionary *body = [[json objectForKey:@"response"] objectForKey:@"body"];
        if([[body objectForKey:@"show_promt"] boolValue] && [[body objectForKey:@"kids"] count])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BeaconPrompt" object:body];
            
        }
        else {
            
            isCalledAPIForBeacon = NO;
        }
        
    } failure:^(NSDictionary *json) {
        
        isCalledAPIForBeacon = NO;
    }];
    
    
    
}
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    
    
    
}
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    
    
}
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region1 {
    
    
    
    if(region1.identifier.length > 0)
    {
        
        [locationManager startRangingBeaconsInRegion:region];
        
        DebugLog(@"backgorund monitoring");
    }
    
}
- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region1 {
    
    [locationManager stopRangingBeaconsInRegion:region];
    
}
- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(nullable CLRegion *)region
              withError:(NSError *)error {
    
}
-(void)checkPermissions {
    
    
    if (![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled!"
                                                            message:@"Please enable Location Based Services for better experience with the app."
                                                           delegate:self
                                                  cancelButtonTitle:@"Settings"
                                                  otherButtonTitles:@"Cancel", nil];
        
        //TODO if user has not given permission to device
        if (![CLLocationManager locationServicesEnabled])
        {
            alertView.tag = 100;
        }
        //TODO if user has not given permission to particular app
        else
        {
            alertView.tag = 200;
        }
        
        [alertView show];
        
        return;
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //   [self askForNotificationPermission];
    
    if(buttonIndex == 0)//Settings button pressed
    {
        if (alertView.tag == 100)
        {
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"]];
                
            }
            else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:root=LOCATION_SERVICES"]];
            }
            
            
        }
        else if (alertView.tag == 200)
        {
            //This will opne particular app location settings
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
        }
    }
    else if(buttonIndex == 1)//Cancel button pressed.
    {
        //TODO for cancel
    }
    
    [self checkBluetooth];
}


-(void)checkBluetooth {
    
    centralManager = [[CBCentralManager alloc]
                      initWithDelegate:self
                      queue:dispatch_get_main_queue()
                      options:@{CBCentralManagerOptionShowPowerAlertKey: @(YES)}];
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if (central.state == CBCentralManagerStatePoweredOn) {
        
        
        //Do what you intend to do
    } else if(central.state == CBCentralManagerStatePoweredOff) {
        //Bluetooth is disabled. ios pops-up an alert automatically
    }
    else if(central.state == CBCentralManagerStateUnauthorized) {
        
        //Bluetooth is disabled. ios pops-up an alert automatically
    }
    
    
}



@end
