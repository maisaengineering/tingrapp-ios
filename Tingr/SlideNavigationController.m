//
//  SlideNavigationController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//
// https://github.com/aryaxt/iOS-Slide-Menu
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SlideNavigationController.h"
#import "SlideNavigationContorllerAnimator.h"
#import "MenuViewController.h"
#import "NIDropDown.h"
#import "PinViewController.h"
typedef enum {
	PopTypeAll,
	PopTypeRoot
} PopType;

@interface SlideNavigationController() <UIGestureRecognizerDelegate,NIDropDownDelegate,UITextViewDelegate,PinViewDelegate>{
    
    NSDictionary *selectedBeaconPromtDict;
    NIDropDown *dropDown;
    UIButton *dropDownOnNameSelectBtn;
    
    UIView *backGroundControl;
    UIView *contenView;
    NSDictionary *beaconPrpmtDict;
    
    NSString *selectedTextForBeaconPrompt;
    NSString *pin;
    BOOL isAddMomentImagePicker;
    NSString *selectedProfileId;
     UIView *popView;
}
@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) CGPoint draggingPoint;
@property (nonatomic, assign) Menu lastRevealedMenu;
@property (nonatomic, assign) BOOL menuNeedsLayout;
@end

@implementation SlideNavigationController

@synthesize beaconPromptArray;

NSString * const SlideNavigationControllerDidOpen = @"SlideNavigationControllerDidOpen";
NSString * const SlideNavigationControllerDidClose = @"SlideNavigationControllerDidClose";
NSString  *const SlideNavigationControllerDidReveal = @"SlideNavigationControllerDidReveal";

#define MENU_SLIDE_ANIMATION_DURATION .3
#define MENU_SLIDE_ANIMATION_OPTION UIViewAnimationOptionCurveEaseOut
#define MENU_QUICK_SLIDE_ANIMATION_DURATION .18
#define MENU_IMAGE @"menu-button"
#define MENU_SHADOW_RADIUS 10
#define MENU_SHADOW_OPACITY 1
#define MENU_DEFAULT_SLIDE_OFFSET 60
#define MENU_FAST_VELOCITY_FOR_SWIPE_FOLLOW_DIRECTION 1200
#define STATUS_BAR_HEIGHT 20
#define NOTIFICATION_USER_INFO_MENU_LEFT @"left"
#define NOTIFICATION_USER_INFO_MENU_RIGHT @"right"
#define NOTIFICATION_USER_INFO_MENU @"menu"

static SlideNavigationController *singletonInstance;

#pragma mark - Initialization -

+ (SlideNavigationController *)sharedInstance
{
    static SlideNavigationController *singletonObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singletonObject = [[self alloc] init];
    });
	
	return singletonInstance;
}

- (id)init
{
	if (self = [super init])
	{
		[self setup];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder])
	{
		[self setup];
	}
	
	return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
	if (self = [super initWithRootViewController:rootViewController])
	{
		[self setup];
	}
	
	return self;
}

- (id)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass
{
	if (self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass])
	{
		[self setup];
	}
	
	return self;
}

- (void)setup
{
	if (singletonInstance)
		NSLog(@"Singleton instance already exists. You can only instantiate one instance of SlideNavigationController. This could cause major issues");
	
	singletonInstance = self;
	
	self.menuRevealAnimationDuration = MENU_SLIDE_ANIMATION_DURATION;
	self.menuRevealAnimationOption = MENU_SLIDE_ANIMATION_OPTION;
	self.landscapeSlideOffset = MENU_DEFAULT_SLIDE_OFFSET;
	self.portraitSlideOffset = MENU_DEFAULT_SLIDE_OFFSET;
	self.panGestureSideOffset = 0;
	self.avoidSwitchingToSameClassViewController = YES;
	self.enableShadow = YES;
	self.enableSwipeGesture = YES;
    
    self.navigationBar.translucent = NO;

	self.delegate = self;
    
    _bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beaconFound:) name:@"BeaconPrompt" object:nil];

    
    
    BOOL key = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedin"];
    if(key)
    {
        if([[ModelManager sharedModel] accessToken] == nil)
        {
            
            ModelManager *shared = [ModelManager sharedModel];
            SingletonClass *singletonObj = [SingletonClass sharedInstance];
            AccessToken *token = [[AccessToken alloc] init];
            NSMutableDictionary *parsedObject = [[NSUserDefaults standardUserDefaults] objectForKey:@"tokens"];
            
            NSMutableDictionary *profilesListResponse = [[NSUserDefaults standardUserDefaults] objectForKey:@"userProfile"];
            UserProfile *userProfile = [[UserProfile alloc] init];
            userProfile.auth_token   = [[profilesListResponse valueForKey:@"body"] valueForKey:@"auth_token"];
            userProfile.onboarding   = [[[profilesListResponse valueForKey:@"body"] valueForKey:@"onboarding"] intValue];
            userProfile.onboarding_partner   = [[profilesListResponse valueForKey:@"body"] valueForKey:@"onboarding_partner"];
            NSDictionary *dic = [[profilesListResponse valueForKey:@"body"] valueForKey:@"profile"];
            userProfile.onboarding_tour   = [[profilesListResponse valueForKey:@"body"] valueForKey:@"onboarding_tour"];
            
            userProfile.kl_id = [dic valueForKey:@"kl_id"];
            userProfile.photograph = [dic valueForKey:@"photograph"];
            userProfile.fname = [dic valueForKey:@"fname"];
            userProfile.lname = [dic valueForKey:@"lname"];
            userProfile.email = [dic valueForKey:@"email"];
            userProfile.phone_numbers = [dic valueForKey:@"phone_numbers"];
            userProfile.verified_phone_number = [dic valueForKey:@"verified_phone_number"];
            userProfile.isight_enabled                    = [[[parsedObject valueForKey:@"body"] valueForKey:@"isight_enabled"] boolValue];
            
            userProfile.verified = [[[profilesListResponse objectForKey:@"body"] objectForKey:@"verified"] boolValue];
            //TODO: This is overriding the original user profile and items like the verfified phone number
            //are not being put in
            //we should have the user profile once and in one place
            
            shared.userProfile = userProfile;
            
            singletonObj.profileKids            = [[[NSUserDefaults standardUserDefaults] objectForKey:@"profileKids"] mutableCopy];
            singletonObj.profileParents         = [[NSUserDefaults standardUserDefaults] objectForKey:@"profileParents"];
            singletonObj.profileOnboarding      = [[NSUserDefaults standardUserDefaults] objectForKey:@"profileOnboarding"];
            singletonObj.sortedParentKidDetails = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sortedParentKidDetails"] mutableCopy];
            singletonObj.sortedKidDetails = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sortedKidDetails"] mutableCopy];
            
            
            singletonObj.arrayKidsLinkUsers     = [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayKidsLinkUsers"];
            singletonObj.arrayShowProfiles      = [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayShowProfiles"];
            
            for (NSString *key in parsedObject)
            {
                if ([token respondsToSelector:NSSelectorFromString(key)]) {
                    
                    [token setValue:[parsedObject valueForKey:key] forKey:key];
                }
            }
            
            shared.accessToken = token;
            
        }
    }
    
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	// Update shadow size of enabled
	if (self.enableShadow)
		self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
    
    // When menu open we disable user interaction
    // When rotates we want to make sure that userInteraction is enabled again
    [self enableTapGestureToCloseMenu:NO];
    
    if (self.menuNeedsLayout)
    {
        [self updateMenuFrameAndTransformAccordingToOrientation];
        
        // Handle different horizontal/vertical slideOffset during rotation
        // On iOS below 8 we just close the menu, iOS8 handles rotation better so we support keepiong the menu open
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0") && [self isMenuOpen])
        {
            Menu menu = (self.horizontalLocation > 0) ? MenuLeft : MenuRight;
            [self openMenu:menu withDuration:0 andCompletion:nil];
        }
        
        self.menuNeedsLayout = NO;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    self.menuNeedsLayout = YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];

    self.menuNeedsLayout = YES;
}

#pragma mark - Public Methods -

- (void)bounceMenu:(Menu)menu withCompletion:(void (^)())completion
{
	[self prepareMenuForReveal:menu];
	NSInteger movementDirection = (menu == MenuLeft) ? 1 : -1;
	
	[UIView animateWithDuration:.16 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
		[self moveHorizontallyToLocation:30*movementDirection];
	} completion:^(BOOL finished){
		[UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
			[self moveHorizontallyToLocation:0];
		} completion:^(BOOL finished){
			[UIView animateWithDuration:.12 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				[self moveHorizontallyToLocation:16*movementDirection];
			} completion:^(BOOL finished){
				[UIView animateWithDuration:.08 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
					[self moveHorizontallyToLocation:0];
				} completion:^(BOOL finished){
					[UIView animateWithDuration:.08 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
						[self moveHorizontallyToLocation:6*movementDirection];
					} completion:^(BOOL finished){
						[UIView animateWithDuration:.06 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
							[self moveHorizontallyToLocation:0];
						} completion:^(BOOL finished){
							if (completion)
								completion();
						}];
					}];
				}];
			}];
		}];
	}];
}

- (void)switchToViewController:(UIViewController *)viewController
		 withSlideOutAnimation:(BOOL)slideOutAnimation
					   popType:(PopType)poptype
				 andCompletion:(void (^)())completion
{
	if (self.avoidSwitchingToSameClassViewController && [self.topViewController isKindOfClass:viewController.class])
	{
		[self closeMenuWithCompletion:completion];
		return;
	}
	
	void (^switchAndCallCompletion)(BOOL) = ^(BOOL closeMenuBeforeCallingCompletion) {
		if (poptype == PopTypeAll) {
			[self setViewControllers:@[viewController]];
		}
		else {
			[super popToRootViewControllerAnimated:NO];
			[super pushViewController:viewController animated:NO];
		}
		
		if (closeMenuBeforeCallingCompletion)
		{
			[self closeMenuWithCompletion:^{
				if (completion)
					completion();
			}];
		}
		else
		{
			if (completion)
				completion();
		}
	};
	
	if ([self isMenuOpen])
	{
		if (slideOutAnimation)
		{
			[UIView animateWithDuration:(slideOutAnimation) ? self.menuRevealAnimationDuration : 0
								  delay:0
								options:self.menuRevealAnimationOption
							 animations:^{
								 CGFloat width = self.horizontalSize;
								 CGFloat moveLocation = (self.horizontalLocation> 0) ? width : -1*width;
								 [self moveHorizontallyToLocation:moveLocation];
							 } completion:^(BOOL finished) {
								 switchAndCallCompletion(YES);
							 }];
		}
		else
		{
			switchAndCallCompletion(YES);
		}
	}
	else
	{
		switchAndCallCompletion(NO);
	}
}

- (void)switchToViewController:(UIViewController *)viewController withCompletion:(void (^)())completion
{
	[self switchToViewController:viewController withSlideOutAnimation:YES popType:PopTypeRoot andCompletion:completion];
}

- (void)popToRootAndSwitchToViewController:(UIViewController *)viewController
				  withSlideOutAnimation:(BOOL)slideOutAnimation
						  andCompletion:(void (^)())completion
{
	[self switchToViewController:viewController withSlideOutAnimation:slideOutAnimation popType:PopTypeRoot andCompletion:completion];
}

- (void)popToRootAndSwitchToViewController:(UIViewController *)viewController
						 withCompletion:(void (^)())completion
{
	[self switchToViewController:viewController withSlideOutAnimation:YES popType:PopTypeRoot andCompletion:completion];
}

- (void)popAllAndSwitchToViewController:(UIViewController *)viewController
		 withSlideOutAnimation:(BOOL)slideOutAnimation
				 andCompletion:(void (^)())completion
{
	[self switchToViewController:viewController withSlideOutAnimation:slideOutAnimation popType:PopTypeAll andCompletion:completion];
}

- (void)popAllAndSwitchToViewController:(UIViewController *)viewController
						 withCompletion:(void (^)())completion
{
	[self switchToViewController:viewController withSlideOutAnimation:YES popType:PopTypeAll andCompletion:completion];
}

- (void)closeMenuWithCompletion:(void (^)())completion
{
	[self closeMenuWithDuration:self.menuRevealAnimationDuration andCompletion:completion];
}

- (void)openMenu:(Menu)menu withCompletion:(void (^)())completion
{
	[self openMenu:menu withDuration:self.menuRevealAnimationDuration andCompletion:completion];
}

- (void)toggleLeftMenu
{
	[self toggleMenu:MenuLeft withCompletion:nil];
}

- (void)toggleRightMenu
{
	[self toggleMenu:MenuRight withCompletion:nil];
}

- (BOOL)isMenuOpen
{
	return (self.leftMenu.view.frame.origin.x == -self.leftMenu.view.frame.size.width) ? NO : YES;
}

- (void)setEnableShadow:(BOOL)enable
{
	_enableShadow = enable;
	
	if (enable)
	{
		self.view.layer.shadowColor = [UIColor darkGrayColor].CGColor;
		self.view.layer.shadowRadius = MENU_SHADOW_RADIUS;
		self.view.layer.shadowOpacity = MENU_SHADOW_OPACITY;
		self.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
		self.view.layer.shouldRasterize = YES;
		self.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
	}
	else
	{
		self.view.layer.shadowOpacity = 0;
		self.view.layer.shadowRadius = 0;
	}
}

#pragma mark - Override Methods -

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
	if ([self isMenuOpen])
	{
		[self closeMenuWithCompletion:^{
			[super popToRootViewControllerAnimated:animated];
		}];
	}
	else
	{
		return [super popToRootViewControllerAnimated:animated];
	}
	
	return nil;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([self isMenuOpen])
	{
		[self closeMenuWithCompletion:^{
			[super pushViewController:viewController animated:animated];
		}];
	}
	else
	{
		[super pushViewController:viewController animated:animated];
	}
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([self isMenuOpen])
	{
		[self closeMenuWithCompletion:^{
			[super popToViewController:viewController animated:animated];
		}];
	}
	else
	{
		return [super popToViewController:viewController animated:animated];
	}
	
	return nil;
}

#pragma mark - Private Methods -

- (void)updateMenuFrameAndTransformAccordingToOrientation
{
	// Animate rotatation when menu is open and device rotates
	CGAffineTransform transform = self.view.transform;
	self.leftMenu.view.transform = transform;
	self.rightMenu.view.transform = transform;
	
	self.leftMenu.view.frame = CGRectMake(-self.leftMenu.view.frame.size.width, 0, self.leftMenu.view.frame.size.width, self.view.frame.size.height);
	self.rightMenu.view.frame = [self initialRectForMenu];
}

- (void)enableTapGestureToCloseMenu:(BOOL)enable
{
	if (enable)
	{
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
			self.interactivePopGestureRecognizer.enabled = NO;
		
		self.topViewController.view.userInteractionEnabled = NO;
		[self.view addGestureRecognizer:self.tapRecognizer];
	}
	else
	{
		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
			self.interactivePopGestureRecognizer.enabled = YES;
		
		self.topViewController.view.userInteractionEnabled = YES;
		[self.view removeGestureRecognizer:self.tapRecognizer];
	}
}

- (void)toggleMenu:(Menu)menu withCompletion:(void (^)())completion
{
	if ([self isMenuOpen])
    {
        [_bgView removeFromSuperview];
		[self closeMenuWithCompletion:completion];
    }
	else
    {
        [self.view addSubview:_bgView];
		[self openMenu:menu withCompletion:completion];
    }
}

- (UIBarButtonItem *)barButtonItemForMenu:(Menu)menu
{
	SEL selector = (menu == MenuLeft) ? @selector(leftMenuSelected:) : @selector(righttMenuSelected:);
	UIBarButtonItem *customButton = (menu == MenuLeft) ? self.leftBarButtonItem : self.rightBarButtonItem;
	
	if (customButton)
	{
		customButton.action = selector;
		customButton.target = self;
		return customButton;
	}
	else
	{
		UIImage *image = [UIImage imageNamed:MENU_IMAGE];
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:selector];
        [barButton setTintColor:[UIColor colorWithPatternImage:image]];
        return barButton;
	}
}

- (BOOL)shouldDisplayMenu:(Menu)menu forViewController:(UIViewController *)vc
{
	if (menu == MenuRight)
	{
		if ([vc respondsToSelector:@selector(slideNavigationControllerShouldDisplayRightMenu)] &&
			[(UIViewController<SlideNavigationControllerDelegate> *)vc slideNavigationControllerShouldDisplayRightMenu])
		{
			return YES;
		}
	}
	if (menu == MenuLeft)
	{
		if ([vc respondsToSelector:@selector(slideNavigationControllerShouldDisplayLeftMenu)] &&
			[(UIViewController<SlideNavigationControllerDelegate> *)vc slideNavigationControllerShouldDisplayLeftMenu])
		{
			return YES;
		}
	}
	
	return NO;
}

- (void)openMenu:(Menu)menu withDuration:(float)duration andCompletion:(void (^)())completion
{
    [(MenuViewController *)self.leftMenu setUpViews];


    [self enableTapGestureToCloseMenu:YES];

	[self prepareMenuForReveal:menu];
    
    

    
	[UIView animateWithDuration:duration
						  delay:0
						options:self.menuRevealAnimationOption
					 animations:^{
						 CGRect rect = self.view.frame;
						 CGFloat width = self.horizontalSize;
						 rect.origin.x = (menu == MenuLeft) ? (width - self.slideOffset) : ((width - self.slideOffset )* -1);
						 [self moveHorizontallyToLocation:0];

					 }
					 completion:^(BOOL finished) {
						 if (completion)
							 completion();
                         
                         [self postNotificationWithName:SlideNavigationControllerDidOpen forMenu:menu];
					 }];
    
    
    CABasicAnimation *theAnimation=[CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    theAnimation.duration=0.3;
    theAnimation.removedOnCompletion = NO;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.fromValue= (__bridge id _Nullable)([[UIColor clearColor] CGColor]);
    theAnimation.toValue= (__bridge id _Nullable)([[UIColor colorWithRed:0 green:0 blue:0  alpha:0.6] CGColor]);
    [_bgView.layer addAnimation:theAnimation forKey:@"ColorPulse" ];

    

}

- (void)closeMenuWithDuration:(float)duration andCompletion:(void (^)())completion
{
	[self enableTapGestureToCloseMenu:NO];
    
     Menu menu = (self.horizontalLocation > 0) ? MenuLeft : MenuRight;
	
	[UIView animateWithDuration:duration
						  delay:0
						options:self.menuRevealAnimationOption
					 animations:^{
						 CGRect rect = self.leftMenu.view.frame;
						 rect.origin.x = -self.leftMenu.view.frame.size.width;
						 [self.leftMenu.view setFrame:rect];

					 }
					 completion:^(BOOL finished) {
						 if (completion)
							 completion();
                         
                         [self postNotificationWithName:SlideNavigationControllerDidClose forMenu:menu];
					 }];
}

- (void)moveHorizontallyToLocation:(CGFloat)location
{
	CGRect rect = self.leftMenu.view.frame;
    
//    if ((location > 0 && self.horizontalLocation <= 0) || (location < 0 && self.horizontalLocation >= 0)) {
//        [self postNotificationWithName:SlideNavigationControllerDidReveal forMenu:(location > 0) ? MenuLeft : MenuRight];
//    }
	
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        rect.origin.x = location;
        rect.origin.y = 0;
    }
    else
    {
        rect.origin.x = location;
        rect.origin.y = 0;
    }
    rect.origin.x= location;
	self.leftMenu.view.frame = rect;
    [self.leftMenu.view.superview bringSubviewToFront:self.leftMenu.view];
	//[self updateMenuAnimation:menu];
}

- (void)updateMenuAnimation:(Menu)menu
{
	CGFloat progress = (menu == MenuLeft)
		? (self.horizontalLocation / (self.horizontalSize - self.slideOffset))
		: (self.horizontalLocation / ((self.horizontalSize - self.slideOffset) * -1));
	
	[self.menuRevealAnimator animateMenu:menu withProgress:progress];
}

- (CGRect)initialRectForMenu
{
	CGRect rect = self.view.frame;
	rect.origin.x = 0;
	rect.origin.y = 0;
	
	if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        return rect;
    }
	
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	
	if (UIDeviceOrientationIsLandscape(orientation))
	{
        // For some reasons in landscape below the status bar is considered y=0, but in portrait it's considered y=20
        rect.origin.x = (orientation == UIDeviceOrientationLandscapeRight) ? 0 : STATUS_BAR_HEIGHT;
        rect.size.width = self.view.frame.size.width-STATUS_BAR_HEIGHT;
	}
	else
	{
        // For some reasons in landscape below the status bar is considered y=0, but in portrait it's considered y=20
        rect.origin.y = (orientation == UIDeviceOrientationPortrait) ? STATUS_BAR_HEIGHT : 0;
        rect.size.height = self.view.frame.size.height-STATUS_BAR_HEIGHT;
	}
	
	return rect;
}

- (void)prepareMenuForReveal:(Menu)menu
{
	// Only prepare menu if it has changed (ex: from MenuLeft to MenuRight or vice versa)
    if (self.lastRevealedMenu && menu == self.lastRevealedMenu)
        return;
    
    UIViewController *menuViewController = (menu == MenuLeft) ? self.leftMenu : self.rightMenu;
	UIViewController *removingMenuViewController = (menu == MenuLeft) ? self.rightMenu : self.leftMenu;

    self.lastRevealedMenu = menu;
	
	[removingMenuViewController.view removeFromSuperview];
	[self.view.window insertSubview:menuViewController.view atIndex:0];

	[self updateMenuFrameAndTransformAccordingToOrientation];
	
	[self.menuRevealAnimator prepareMenuForAnimation:menu];
}

- (CGFloat)horizontalLocation
{
	CGRect rect = self.view.frame;
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        return rect.origin.x;
    }
    else
    {
        if (UIDeviceOrientationIsLandscape(orientation))
        {
            return (orientation == UIDeviceOrientationLandscapeRight)
            ? rect.origin.y
            : rect.origin.y*-1;
        }
        else
        {
            return (orientation == UIDeviceOrientationPortrait)
            ? rect.origin.x
            : rect.origin.x*-1;
        }
    }
}

- (CGFloat)horizontalSize
{
	CGRect rect = self.view.frame;
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        return rect.size.width;
    }
    else
    {
        if (UIDeviceOrientationIsLandscape(orientation))
        {
            return rect.size.height;
        }
        else
        {
            return rect.size.width;
        }
    }
}

- (void)postNotificationWithName:(NSString *)name forMenu:(Menu)menu
{
    NSString *menuString = (menu == MenuLeft) ? NOTIFICATION_USER_INFO_MENU_LEFT : NOTIFICATION_USER_INFO_MENU_RIGHT;
    NSDictionary *userInfo = @{ NOTIFICATION_USER_INFO_MENU : menuString };
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:userInfo];
}

#pragma mark - UINavigationControllerDelegate Methods -

- (void)navigationController:(UINavigationController *)navigationController
	  willShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated
{
	if ([self shouldDisplayMenu:MenuLeft forViewController:viewController])
		viewController.navigationItem.leftBarButtonItem = [self barButtonItemForMenu:MenuLeft];
	
	if ([self shouldDisplayMenu:MenuRight forViewController:viewController])
		viewController.navigationItem.rightBarButtonItem = [self barButtonItemForMenu:MenuRight];
}

- (CGFloat)slideOffset
{
	return (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
		? self.landscapeSlideOffset
		: self.portraitSlideOffset;
}

#pragma mark - IBActions -

- (void)leftMenuSelected:(id)sender
{
	if ([self isMenuOpen])
		[self closeMenuWithCompletion:nil];
	else
		[self openMenu:MenuLeft withCompletion:nil];
}

- (void)righttMenuSelected:(id)sender
{
	if ([self isMenuOpen])
		[self closeMenuWithCompletion:nil];
	else
		[self openMenu:MenuRight withCompletion:nil];
}

#pragma mark - Gesture Recognizing -

- (void)tapDetected:(UITapGestureRecognizer *)tapRecognizer
{
	[self closeMenuWithCompletion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	if (self.panGestureSideOffset == 0)
		return YES;
	
	CGPoint pointInView = [touch locationInView:self.view];
	CGFloat horizontalSize = [self horizontalSize];
	
	return (pointInView.x <= self.panGestureSideOffset || pointInView.x >= horizontalSize - self.panGestureSideOffset)
		? YES
		: NO;
}


- (void)panDetected:(UIPanGestureRecognizer *)aPanRecognizer
{
    return;
	CGPoint translation = [aPanRecognizer translationInView:aPanRecognizer.view];
    CGPoint velocity = [aPanRecognizer velocityInView:aPanRecognizer.view];
	NSInteger movement = translation.x - self.draggingPoint.x;
	
    Menu currentMenu;
    
    if (self.horizontalLocation > 0)
        currentMenu = MenuLeft;
    else if (self.horizontalLocation < 0)
        currentMenu = MenuRight;
    else
        currentMenu = (translation.x > 0) ? MenuLeft : MenuRight;
    
    if (![self shouldDisplayMenu:currentMenu forViewController:self.topViewController])
        return;
    
    [self prepareMenuForReveal:currentMenu];
    
    if (aPanRecognizer.state == UIGestureRecognizerStateBegan)
	{
		self.draggingPoint = translation;
    }
	else if (aPanRecognizer.state == UIGestureRecognizerStateChanged)
	{
		static CGFloat lastHorizontalLocation = 0;
		CGFloat newHorizontalLocation = [self horizontalLocation];
		lastHorizontalLocation = newHorizontalLocation;
		newHorizontalLocation += movement;
		
		if (newHorizontalLocation >= self.minXForDragging && newHorizontalLocation <= self.maxXForDragging)
			[self moveHorizontallyToLocation:newHorizontalLocation];
		
		self.draggingPoint = translation;
	}
	else if (aPanRecognizer.state == UIGestureRecognizerStateEnded)
	{
        NSInteger currentX = [self horizontalLocation];
		NSInteger currentXOffset = (currentX > 0) ? currentX : currentX * -1;
		NSInteger positiveVelocity = (velocity.x > 0) ? velocity.x : velocity.x * -1;
		
		// If the speed is high enough follow direction
		if (positiveVelocity >= MENU_FAST_VELOCITY_FOR_SWIPE_FOLLOW_DIRECTION)
		{
			Menu menu = (velocity.x > 0) ? MenuLeft : MenuRight;
			
			// Moving Right
			if (velocity.x > 0)
			{
				if (currentX > 0)
				{
					if ([self shouldDisplayMenu:menu forViewController:self.visibleViewController])
						[self openMenu:(velocity.x > 0) ? MenuLeft : MenuRight withDuration:MENU_QUICK_SLIDE_ANIMATION_DURATION andCompletion:nil];
				}
				else
				{
					[self closeMenuWithDuration:MENU_QUICK_SLIDE_ANIMATION_DURATION andCompletion:nil];
				}
			}
			// Moving Left
			else
			{
				if (currentX > 0)
				{
					[self closeMenuWithDuration:MENU_QUICK_SLIDE_ANIMATION_DURATION andCompletion:nil];
				}
				else
				{
					if ([self shouldDisplayMenu:menu forViewController:self.visibleViewController])
						[self openMenu:(velocity.x > 0) ? MenuLeft : MenuRight withDuration:MENU_QUICK_SLIDE_ANIMATION_DURATION andCompletion:nil];
				}
			}
		}
		else
		{
			if (currentXOffset < (self.horizontalSize - self.slideOffset)/2)
				[self closeMenuWithCompletion:nil];
			else
				[self openMenu:(currentX > 0) ? MenuLeft : MenuRight withCompletion:nil];
		}
    }
}

- (NSInteger)minXForDragging
{
	if ([self shouldDisplayMenu:MenuRight forViewController:self.topViewController])
	{
		return (self.horizontalSize - self.slideOffset)  * -1;
	}
	
	return 0;
}

- (NSInteger)maxXForDragging
{
	if ([self shouldDisplayMenu:MenuLeft forViewController:self.topViewController])
	{
		return self.horizontalSize - self.slideOffset;
	}
	
	return 0;
}

#pragma mark - Setter & Getter -

- (UITapGestureRecognizer *)tapRecognizer
{
	if (!_tapRecognizer)
	{
		_tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
	}
	
	return _tapRecognizer;
}

- (UIPanGestureRecognizer *)panRecognizer
{
	if (!_panRecognizer)
	{
		_panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
		_panRecognizer.delegate = self;
	}
	
	return _panRecognizer;
}

- (void)setEnableSwipeGesture:(BOOL)markEnableSwipeGesture
{
	_enableSwipeGesture = markEnableSwipeGesture;
	
	if (_enableSwipeGesture)
	{
		[self.view addGestureRecognizer:self.panRecognizer];
	}
	else
	{
		[self.view removeGestureRecognizer:self.panRecognizer];
	}
}

- (void)setMenuRevealAnimator:(id<SlideNavigationContorllerAnimator>)menuRevealAnimator
{
	[self.menuRevealAnimator clear];
	
	_menuRevealAnimator = menuRevealAnimator;
}

- (void)setLeftMenu:(UIViewController *)leftMenu
{
    [_leftMenu.view removeFromSuperview];
    
    _leftMenu = leftMenu;
}

- (void)setRightMenu:(UIViewController *)rightMenu
{
    [_rightMenu.view removeFromSuperview];
    
    _rightMenu = rightMenu;
}


#pragma mark -
#pragma mark Prompts On Beacon Found

-(void)beaconFound:(NSNotification *)notification {
    
    beaconPrpmtDict = [notification object];
    self.beaconPromptArray = [[beaconPrpmtDict objectForKey:@"kids"] mutableCopy];
    if(self.beaconPromptArray.count >0 && ![[SingletonClass sharedInstance] isShowingBeaconPrompt])
    {
        [[SingletonClass sharedInstance] setIsShowingBeaconPrompt:YES];
        if([[SingletonClass sharedInstance] isShowingBeaconPrompt])
            [self showPromptBeaconFound:[self.beaconPromptArray firstObject]];
        
        AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appdelegate setIsCalledAPIForBeacon:NO];
    }
}
-(void)showPromptBeaconFound:(NSDictionary *)detailsDict {

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    float bottomSpace = 0;
    if(appDelegate.topSafeAreaInset > 0)
    {
        bottomSpace = 30;
    }

    
    
    selectedBeaconPromtDict = detailsDict;
    
    if(popView.hidden == YES && [[SingletonClass sharedInstance] isShowingBeaconPrompt])
    {
        popView.hidden = NO;
    }
    else
    {
        if([popView superview])
            [popView removeFromSuperview];
        popView = nil;
        
        popView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, Deviceheight)];
        [popView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6f]];
    }
    contenView = [[UIView alloc] initWithFrame:CGRectMake(0, Deviceheight-210-bottomSpace, Devicewidth, 210+bottomSpace)];
    contenView.backgroundColor = [UIColor whiteColor];
    [popView addSubview:contenView];
    
    UILabel *schoolName = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, Devicewidth, 30)];
    [schoolName setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    [schoolName setText:[beaconPrpmtDict objectForKey:@"org_name"]];
    schoolName.textAlignment = NSTextAlignmentCenter;
    [contenView addSubview:schoolName];
    
    UITextView *textLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, schoolName.frame.size.height+schoolName.frame.origin.y-8, Devicewidth, 30)];
    textLabel.delegate = self;
    [textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]];
    [textLabel setBackgroundColor:[UIColor clearColor]];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.editable = NO;
    textLabel.tag = 11;
    textLabel.textContainer.maximumNumberOfLines = 1;
    textLabel.textContainer.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    [contenView addSubview:textLabel];
    
    if(beaconPromptArray.count > 1)
    {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = [UIImage imageNamed:@"down_arrow"];
        
        
        NSString *textStr = [NSString stringWithFormat:@"Are you here to SIGN-IN/OUT %@",[detailsDict objectForKey:@"full_name"]];
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:textStr attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]}];
        
        NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:5]}];
        [myString appendAttributedString:space];
        
        NSAttributedString *downArrow = [[NSAttributedString alloc] initWithString:@"\u25BE" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:69.0/255.0 green:199.0/255.0 blue:242.0/255.0 alpha:1.0],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]}];
        [myString appendAttributedString:downArrow];
        
        
        
        NSRange range = [textStr rangeOfString:[NSString stringWithFormat:@"%@",[detailsDict objectForKey:@"full_name"]]];
        
        [myString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14],NSForegroundColorAttributeName:[UIColor colorWithRed:69.0/255.0 green:199.0/255.0 blue:242.0/255.0 alpha:1.0]}
                          range:range];
        
        // [myString appendAttributedString:attachmentString];
        NSAttributedString *space2 = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:5]}];
        [myString appendAttributedString:space2];
        
        
        NSAttributedString *questionMark = [[NSAttributedString alloc] initWithString:@"?" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]}];
        [myString appendAttributedString:questionMark];
        
        range = [myString.string rangeOfString:[NSString stringWithFormat:@"%@ \u25BE",[detailsDict objectForKey:@"full_name"]]];
        
        NSString *string = [NSString stringWithFormat:@"username://%@",[[detailsDict objectForKey:@"full_name"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
        [myString addAttribute:NSLinkAttributeName value:string range:range];
        
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        [myString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [myString.string length])];
        
        
        textLabel.attributedText = myString;
        
        dropDownOnNameSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [contenView addSubview:dropDownOnNameSelectBtn];
        [dropDownOnNameSelectBtn addTarget:self action:@selector(showDropDown:) forControlEvents:UIControlEventTouchUpInside];
        
        UITextPosition *Pos2 = [textLabel positionFromPosition: textLabel.endOfDocument offset: 0];
        UITextPosition *Pos1 = [textLabel positionFromPosition: textLabel.endOfDocument offset: -[[detailsDict objectForKey:@"full_name"] length]-3];
        
        UITextRange *range1 = [textLabel textRangeFromPosition:Pos1 toPosition:Pos2];
        
        
        CGRect btnFrame = [textLabel firstRectForRange:(UITextRange *)range1 ];
        dropDownOnNameSelectBtn.frame = CGRectMake(btnFrame.origin.x - 10, textLabel.frame.origin.y, btnFrame.size.width + 20, 30);
        
    }
    else
    {
        textLabel.text = [NSString stringWithFormat:@"Are you here to SIGN-IN/OUT %@ ?",[detailsDict objectForKey:@"full_name"]];
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 60 - 0.5, Devicewidth, 0.5f)];
    [lineView setBackgroundColor:[UIColor lightGrayColor]];
    [contenView addSubview:lineView];
    
    UIButton *signInBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [signInBtn setTitle:@"Sign-in" forState:UIControlStateNormal];
    [signInBtn addTarget:self action:@selector(promptButtonsClicked:) forControlEvents:UIControlEventTouchUpInside];
    signInBtn.tag = 1;
    [signInBtn setTitleColor:UIColorFromRGB(0x1B7EF9) forState:UIControlStateNormal];
    [signInBtn setFrame:CGRectMake(0, textLabel.frame.size.height+textLabel.frame.origin.y, Devicewidth, 50)];
    [contenView addSubview:signInBtn];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, signInBtn.frame.size.height+signInBtn.frame.origin.y-0.5, Devicewidth, 0.5f)];
    [lineView2 setBackgroundColor:[UIColor lightGrayColor]];
    [contenView addSubview:lineView2];
    
    
    UIButton *signOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [signOutBtn setTitle:@"Sign-out" forState:UIControlStateNormal];
    [signOutBtn addTarget:self action:@selector(promptButtonsClicked:) forControlEvents:UIControlEventTouchUpInside];
    signOutBtn.tag = 2;
    [signOutBtn setFrame:CGRectMake(0, signInBtn.frame.size.height+signInBtn.frame.origin.y+0.5, Devicewidth, 50)];
    [signOutBtn setTitleColor:UIColorFromRGB(0x1B7EF9) forState:UIControlStateNormal];
    [contenView addSubview:signOutBtn];
    
    
    UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(0, signOutBtn.frame.size.height+signOutBtn.frame.origin.y-0.5, Devicewidth, 0.5f)];
    [lineView3 setBackgroundColor:[UIColor lightGrayColor]];
    [contenView addSubview:lineView3];
    
    
    UIButton *otherBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [otherBtn setTitle:@"Other" forState:UIControlStateNormal];
    [otherBtn addTarget:self action:@selector(promptButtonsClicked:) forControlEvents:UIControlEventTouchUpInside];
    otherBtn.tag = 3;
    [otherBtn setTitleColor:UIColorFromRGB(0x1B7EF9) forState:UIControlStateNormal];
    [otherBtn setFrame:CGRectMake(0, signOutBtn.frame.size.height+signOutBtn.frame.origin.y+0.5, Devicewidth, 50)];
    [contenView addSubview:otherBtn];
    
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:popView];
}
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    
    
    
    // Call your method here.
    return YES;
}
-(void)showDropDown:(id)sender
{
    if(dropDown == nil) {
        
        [[[[UIApplication sharedApplication] windows] lastObject] addSubview:backGroundControl];
        //     [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:backGroundControl];
        
        
        
        
        NSArray * sortedArray = [self.beaconPromptArray valueForKeyPath:@"full_name"];
        CGFloat f = 30*sortedArray.count;
        
        if(f + dropDownOnNameSelectBtn.frame.origin.y + 40  > 210)
            f = 210 - dropDownOnNameSelectBtn.frame.origin.y - 40;
        
        NSString *longest = nil;
        for(NSString *str in sortedArray) {
            if (longest == nil || [str length] > [longest length]) {
                longest = str;
            }
        }
        
        CGFloat width = 0;
        CGSize frameSize = CGSizeMake(Devicewidth-20, 50);
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        
        CGRect idealFrame = [longest boundingRectWithSize:frameSize
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{ NSFontAttributeName:font }
                                                  context:nil];
        if(idealFrame.size.width+20 > dropDownOnNameSelectBtn.frame.size.width)
        {
            width = idealFrame.size.width+20;
        }
        else
        {
            width = dropDownOnNameSelectBtn.frame.size.width;
        }
        
        dropDown = [[NIDropDown alloc]showDropDown:dropDownOnNameSelectBtn :&f :sortedArray :nil :@"down" :width];
        dropDown.delegate = self;
    }
    else {
        
        [backGroundControl removeFromSuperview];
        [dropDown hideDropDown:dropDownOnNameSelectBtn];
        dropDown = nil;
    }
    
}
- (void) niDropDownDelegateMethod: (NIDropDown *) sender {
    
    dropDown = nil;
    
}
- (void) selectedIndex: (int) index {
    
    selectedBeaconPromtDict = [self.beaconPromptArray objectAtIndex:index];
    
    NSDictionary *detailsDict = [self.beaconPromptArray objectAtIndex:index];
    UITextView *textLabel = [contenView viewWithTag:11];
    
    if(beaconPromptArray.count > 1)
    {
        
        NSString *textStr = [NSString stringWithFormat:@"Are you here to SIGN-IN/OUT %@",[detailsDict objectForKey:@"full_name"]];
        NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:textStr attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]}];
        
        NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:5]}];
        [myString appendAttributedString:space];
        
        NSAttributedString *downArrow = [[NSAttributedString alloc] initWithString:@"\u25BE" attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x1B7EF9),NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]}];
        [myString appendAttributedString:downArrow];
        
        
        
        NSRange range = [textStr rangeOfString:[NSString stringWithFormat:@"%@",[detailsDict objectForKey:@"full_name"]]];
        
        [myString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:14],NSForegroundColorAttributeName:UIColorFromRGB(0x1B7EF9)}
                          range:range];
        
        // [myString appendAttributedString:attachmentString];
        NSAttributedString *space2 = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:5]}];
        [myString appendAttributedString:space2];
        
        
        NSAttributedString *questionMark = [[NSAttributedString alloc] initWithString:@"?" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:13]}];
        [myString appendAttributedString:questionMark];
        
        range = [myString.string rangeOfString:[NSString stringWithFormat:@"%@ \u25BE",[detailsDict objectForKey:@"full_name"]]];
        
        NSString *string = [NSString stringWithFormat:@"username://%@",[[detailsDict objectForKey:@"full_name"] stringByReplacingOccurrencesOfString:@" " withString:@""]];
        [myString addAttribute:NSLinkAttributeName value:string range:range];
        
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        
        [myString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [myString.string length])];
        
        
        textLabel.attributedText = myString;
        
        
        dropDownOnNameSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [contenView addSubview:dropDownOnNameSelectBtn];
        [dropDownOnNameSelectBtn addTarget:self action:@selector(showDropDown:) forControlEvents:UIControlEventTouchUpInside];
        
        UITextPosition *Pos2 = [textLabel positionFromPosition: textLabel.endOfDocument offset: 0];
        UITextPosition *Pos1 = [textLabel positionFromPosition: textLabel.endOfDocument offset: -[[detailsDict objectForKey:@"full_name"] length]-3];
        
        UITextRange *range1 = [textLabel textRangeFromPosition:Pos1 toPosition:Pos2];
        
        
        CGRect btnFrame = [textLabel firstRectForRange:(UITextRange *)range1 ];
        dropDownOnNameSelectBtn.frame = CGRectMake(btnFrame.origin.x - 10, textLabel.frame.origin.y, btnFrame.size.width + 20, 30);
        
    }
    else
    {
        textLabel.text = [NSString stringWithFormat:@"Are you here to SIGN-IN/OUT %@ ?",[detailsDict objectForKey:@"full_name"]];
    }
    
    [backGroundControl removeFromSuperview];
    dropDown = nil;
    
}
-(void)promptButtonsClicked:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    selectedTextForBeaconPrompt = [btn titleForState:UIControlStateNormal];
    pin = @"";
    if(btn.tag == 3)
    {
        [self callAPIWithResponse:selectedTextForBeaconPrompt];
    }
    else {
        
        [popView removeFromSuperview];
        popView = nil;
        
        if([[selectedBeaconPromtDict objectForKey:@"pin_exists"] boolValue])
            [self showEnterPinVew];
        else
            [self callAPIWithResponse:selectedTextForBeaconPrompt];
    }
  
  
}
-(void)showEnterPinVew {
    
    PinViewController *viewCntrl = [[PinViewController alloc] init];
    viewCntrl.delegate = self;
    
    UINavigationController *navg = [[UINavigationController alloc] initWithRootViewController:viewCntrl];
    navg.navigationBarHidden = YES;
    navg.view.backgroundColor = [UIColor clearColor];
    [navg setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:navg animated:YES completion:nil];
    
}
- (void)enteredPin:(NSString *)pin1 {
    
    pin = pin1;
    [self callAPIWithResponse:selectedTextForBeaconPrompt];
    
}
-(void)gotoKidDashboard {
    
    SingletonClass *singletonObj = [SingletonClass sharedInstance];
    NSArray *arr = [singletonObj.profileKids filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"kl_id = %@",[selectedBeaconPromtDict objectForKey:@"kid_klid"]]];
    
    NSMutableDictionary *kid =  [arr firstObject];
    if(kid == nil)
        kid = [singletonObj.profileKids firstObject];

    
    NSString *message = [NSString stringWithFormat:@"your PIN number is %@",[kid valueForKey:@"pin_no"]];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tingr"
                                                   message:message
                                                  delegate:nil cancelButtonTitle:@"Ok"
                          
                                         otherButtonTitles:nil,nil];
    [alert show];
    
    

}

-(void)callAPIWithResponse:(NSString *)optionString
{
    
    
    [SVProgressHUD show];
    ModelManager *sharedModel = [ModelManager sharedModel];
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:[beaconPrpmtDict objectForKey:@"org_id"] forKey:@"org_id"];
    [dict setObject:[beaconPrpmtDict objectForKey:@"season_id"] forKey:@"season_id"];
    [dict setObject:[beaconPrpmtDict objectForKey:@"session_id"] forKey:@"session_id"];
    [dict setObject:[selectedBeaconPromtDict objectForKey:@"kid_klid"] forKey:@"kid_klid"];
    [dict setObject:optionString forKey:@"option"];
    if(pin.length >0)
    {
        [dict setObject:pin forKey:@"pin_no"];
    }
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"isight_respond",
                               @"body": dict};
    
    NSDictionary *userInfo = @{@"command":@"isight_respond"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@attendances", BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [self didRecieveResponseForBeaconPrompt:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
        
    } failure:^(NSDictionary *json) {
        [self didFailForBeaconPrompt:json];
    }];
    
}
-(void)didRecieveResponseForBeaconPrompt:(NSDictionary *)response {
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    popView.hidden = YES;
    [self.beaconPromptArray removeObject:selectedBeaconPromtDict];
    
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tingr"
                                                   message:[response objectForKey:@"text"]
                                                  delegate:self cancelButtonTitle:@"Ok"
                          
                                         otherButtonTitles:nil,nil];
    alert.tag = 101;
    [alert show];
    
    [SVProgressHUD dismiss];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 101)
    {
        
        if(beaconPromptArray.count > 0)
        {
            [self performSelectorOnMainThread:@selector(showPromptBeaconFound:) withObject:[self.beaconPromptArray firstObject] waitUntilDone:NO];
        }
        else
        {
            
            [[SingletonClass sharedInstance] setIsShowingBeaconPrompt:NO];
            [popView removeFromSuperview];
            popView = nil;
        }
    }
    
}



-(void)didFailForBeaconPrompt:(NSDictionary *)response {
    
    [SVProgressHUD dismiss];
    
    if([response objectForKey:@"message"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                       message:[response objectForKey:@"message"]
                                                      delegate:nil cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        [alert show];
    }
    else  {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
                                                       message:@"There was an error. Please try again."
                                                      delegate:nil cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        [alert show];
        
    }

    
}


@end
