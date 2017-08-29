//
//  MenuViewController.h
//  Tingr
//
//  Created by Maisa Pride on 7/24/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASMediaFocusManager.h"

@interface MenuViewController : UIViewController<UIGestureRecognizerDelegate,ASMediasFocusDelegate>

@property (nonatomic, strong) CAGradientLayer  *gradient;
@property (strong, nonatomic) ASMediaFocusManager *mediaFocusManager;
-(void)setUpViews;
@end
