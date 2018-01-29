//
//  AppDelegate.h
//  Tingr
//
//  Created by Maisa Pride on 7/17/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

@class SlideNavigationController;
@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate,CBCentralManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SlideNavigationController *navgController;
@property (nonatomic) BOOL isCalledAPIForBeacon;
@property (nonatomic, assign) float bottomSafeAreaInset;
@property (nonatomic, assign) float topSafeAreaInset;


-(void)askForNotificationPermission;
-(void)subscribeUserToFirebase;

-(void)initialise;
-(void)stopMonitoring;

@end

