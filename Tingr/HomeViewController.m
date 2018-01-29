//
//  ViewController.m
//  Tingr
//
//  Created by Maisa Pride on 7/17/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "HomeViewController.h"
#import "FeedView.h"
#import "InfoViewController.h"
#import "VerifiedViewController.h"
#import "MessageViewController.h"
#import "SlideNavigationController.h"
@interface HomeViewController ()
{
    UIView *topBar;
    UIButton *menuButton;
    UIButton *lockButton;
    UIButton *infoButton;
    UIButton *messageButton;
    UIButton *bubbleButton;
    UIScrollView *nameScrollView;
    ModelManager *sharedModel;
    SingletonClass *sharedInstance;
    AppDelegate *appDelegate;
    UIView *blueLine;
    UILabel *suggestLoginLabel;
    UIView *suggestLoginView;
    UIButton *verifyButton;
    
    NSMutableArray *isCellThere;
    ProfilePhotoUtils *photoUtil;
    
    
    UIScrollView *scrollView;

}
@end

@implementation HomeViewController
@synthesize pageCollectionView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    sharedInstance = [SingletonClass sharedInstance];
    sharedModel = [ModelManager sharedModel];
    photoUtil = [ProfilePhotoUtils alloc];

    isCellThere = [[NSMutableArray alloc] init];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginClicked) name:@"LoginTapped" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:@"LogOut" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(login) name:@"LogIn" object:nil];
    
    
    [self loadUIControls];
    
    [appDelegate.navgController toggleLeftMenu];
}

-(void)viewWillLayoutSubviews {
    
    
}
-(void)viewDidLayoutSubviews {
    
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint p = CGPointZero;
    p.x = 0;
    p.y = 0;
    [path moveToPoint:p];
    p.x = suggestLoginView.bounds.size.width;
    [path addLineToPoint:p];
    
    p.x -= 20;
    p.y += suggestLoginView.bounds.size.height / 2.0;
    [path addLineToPoint:p];
    p.x += 20;
    p.y += suggestLoginView.bounds.size.height / 2.0;
    [path addLineToPoint:p];
    p.x = 0;
    p.y = suggestLoginView.bounds.size.height;
    [path addLineToPoint:p];
    [path closePath];
    CAShapeLayer *_shape = [[CAShapeLayer alloc] init];
    _shape.path = [path CGPath];
    _shape.fillColor = [UIColor colorWithRed:95/255.0 green:167/255.0 blue:239/255.0 alpha:1.0].CGColor;

    [suggestLoginView.layer addSublayer:_shape];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginClicked)];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [suggestLoginView addGestureRecognizer:singleTap];

    
}
-(void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self removeMessageButtonIfExists];

    [self setContentInScrollView];
    [self setUpViews];

}

-(void)setUpViews {
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedin"]) {
       
        lockButton.hidden = YES;
        suggestLoginLabel.hidden = YES;
        suggestLoginView.hidden = YES;
        blueLine.hidden = YES;
        pageCollectionView.hidden = NO;
        infoButton.hidden = NO;
        messageButton.hidden = NO;
        
        if(!sharedModel.userProfile.verified)
            verifyButton.hidden = NO;
        else
            verifyButton.hidden = YES;
    }
    else {
        
        lockButton.hidden = NO;
        suggestLoginLabel.hidden = NO;
        suggestLoginView.hidden = NO;
        blueLine.hidden = NO;
        pageCollectionView.hidden = YES;
        infoButton.hidden = YES;
        messageButton.hidden = YES;
        verifyButton.hidden = YES;
    }

    [self showSchollName];

}
-(void)showSchollName {
    

        
        NSArray *subViewArray = [nameScrollView subviews];
        for (id obj in subViewArray)
        {
            [obj removeFromSuperview];
        }
        
        if(sharedInstance.selecteOrganisation.count == 0 && self.organisationaArray.count > 0)
        {
            
            sharedInstance.selecteOrganisation = [self.organisationaArray objectAtIndex:0];
            
        }
        
        
        
        
        if(sharedInstance.selecteOrganisation.count == 0)
        {
            // [streamView setHidden:YES];
            // [self showEmptyContentMessageView];
            
            UILabel *nameLabel  = [[UILabel alloc] initWithFrame:nameScrollView.bounds];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.text = [@"Tingr" uppercaseString];
            nameLabel.textColor = [UIColor grayColor];
            nameLabel.font = [UIFont fontWithName:@"Anton" size:25.0];
            [nameScrollView addSubview:nameLabel];
            nameScrollView.contentSize = nameScrollView.frame.size;
            
        }
        
        else {
            
            UILabel *nameLabel  = [[UILabel alloc] init];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.numberOfLines = 1;
            nameLabel.text = [[sharedInstance.selecteOrganisation objectForKey:@"name"] uppercaseString];
            nameLabel.textColor = [UIColor grayColor];
            nameLabel.font = [UIFont fontWithName:@"Anton" size:25.0];
            [nameScrollView addSubview:nameLabel];
            
            
            NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Anton" size:25.0]};
            // NSString class method: boundingRectWithSize:options:attributes:context is
            // available only on ios7.0 sdk.
            CGRect textSize = [[[sharedInstance.selecteOrganisation objectForKey:@"name"] uppercaseString] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30)
                                                                                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                                                                                     attributes:attributes
                                                                                                                        context:nil];
            
            
            if(textSize.size.width > nameScrollView.bounds.size.width) {
                nameLabel.frame = CGRectMake(0, 0, textSize.size.width, nameScrollView.bounds.size.height);
            }
            else {
                nameLabel.frame = CGRectMake(0, 0, nameScrollView.frame.size.width, nameScrollView.frame.size.height);
            }
            
            if(nameLabel.frame.size.width > nameScrollView.frame.size.width) {
                
                nameScrollView.contentSize = CGSizeMake(nameLabel.frame.size.width,nameScrollView.frame.size.height);
                
                
            }
            else {
                
                nameScrollView.contentSize = nameScrollView.frame.size;
                
            }
            
            
        }
        
        [pageCollectionView reloadData];
        
        
        if(self.organisationaArray.count >0)
        {
            CGRect frame = scrollView.frame;
            frame.origin.x = scrollView.frame.size.width *[self.organisationaArray indexOfObject:sharedInstance.selecteOrganisation];
            [scrollView scrollRectToVisible:frame animated:YES];
        
        }
        

    
}
-(void)setContentInScrollView {


    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedin"]) {
        
        if([self.organisationaArray isEqualToArray: sharedModel.userProfile.organizations])
        {
            
        }
        else {
            
            for(UIView *view in  [scrollView subviews])
            {
                [view removeFromSuperview];
            }

            
            self.organisationaArray = [sharedModel.userProfile.organizations mutableCopy];
            
            
            for(int i=0;i<self.organisationaArray.count ;i++) {
                
                FeedView *feedView = [[FeedView alloc] initWithFrame:CGRectMake(i*Devicewidth, 0, Devicewidth, Deviceheight-100)];
                feedView.orgID = [self.organisationaArray[i] objectForKey:@"id"];
                [feedView fetchPosts];
                [scrollView addSubview:feedView];
                
            }
            
            
        }
        
        
        
    }
    else
    {
        if([scrollView subviews].count <=1) {
            
            FeedView *feedView = [[FeedView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, Deviceheight-100)];
            feedView.orgID = @"";
            [feedView fetchPosts];
            [scrollView addSubview:feedView];
            
        }
        
    }
    
    scrollView.contentSize = CGSizeMake(Devicewidth*self.organisationaArray.count, Devicewidth-100);

    
}
-(void)loadUIControls {
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    
    float topSpace = 0;
    if(appDelegate.topSafeAreaInset > 0)
        topSpace = 10;
    
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100+topSpace, Devicewidth, Deviceheight - 100 - topSpace)];
    [scrollView setPagingEnabled:YES];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];

    
    topBar = [[UIView alloc] init];
    [self.view addSubview:topBar];
    [self.view addConstraintsWithFormat:@"H:|[v0]|" forViews:@[topBar]];
    if(topSpace)
        [self.view addConstraintsWithFormat:@"V:[v0(100)]" forViews:@[topBar]];
    else
        [self.view addConstraintsWithFormat:@"V:[v0(110)]" forViews:@[topBar]];
    menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton addTarget:self action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setImage:[UIImage imageNamed:@"hamburger"] forState:UIControlStateNormal];
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
                                                 NSLayoutAttributeTop multiplier:1.0f constant:20+topSpace];
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

    
    lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lockButton setImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
    [self.view addSubview:lockButton];
    [lockButton addTarget:self action:@selector(loginClicked) forControlEvents:UIControlEventTouchUpInside];
    
    lockButton.translatesAutoresizingMaskIntoConstraints = NO;
    /* Leading space to superview */
    NSLayoutConstraint *lockButtonXConstraint = [NSLayoutConstraint
                                                 constraintWithItem:lockButton attribute:NSLayoutAttributeTrailing
                                                 relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                 NSLayoutAttributeTrailingMargin multiplier:1.0 constant:10];
    /* Top space to superview Y*/
    NSLayoutConstraint *lockButtonYConstraint = [NSLayoutConstraint
                                                 constraintWithItem:lockButton attribute:NSLayoutAttributeTop
                                                 relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                 NSLayoutAttributeTop multiplier:1.0f constant:20+topSpace];
    /* Fixed width */
    NSLayoutConstraint *lockButtonwidthConstraint = [NSLayoutConstraint constraintWithItem:lockButton
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:42];
    /* Fixed Height */
    NSLayoutConstraint *lockButtonheightConstraint = [NSLayoutConstraint constraintWithItem:lockButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:42];
    /* 4. Add the constraints to button's superview*/
    [self.view addConstraints:@[lockButtonXConstraint, lockButtonYConstraint, lockButtonwidthConstraint, lockButtonheightConstraint]];

    
    topBar.layer.shadowOpacity = 0.5;
    topBar.layer.shadowOffset =  CGSizeMake(0, 1.0);
    topBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    topBar.backgroundColor = [UIColor whiteColor];

    
    nameScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(60, 25+topSpace, Devicewidth - 120, 30)];
    [self.view addSubview:nameScrollView];

    blueLine = [[UIView alloc] initWithFrame:CGRectMake((Devicewidth-100)/2,98, 100, 2)];
    [blueLine setBackgroundColor:[UIColor colorWithRed:(89/255.f) green:(148/255.f) blue:(240/255.f) alpha:1]];
    [topBar addSubview:blueLine];
    
    UICollectionViewFlowLayout *layout2=[[UICollectionViewFlowLayout alloc] init];
    layout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout2.minimumLineSpacing = 0;

    
    pageCollectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, 62+topSpace, Devicewidth, 30) collectionViewLayout:layout2];
    [pageCollectionView setDataSource:self];
    [pageCollectionView setDelegate:self];
    pageCollectionView.backgroundColor = [UIColor whiteColor];
    [pageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:pageCollectionView];

    
    
    suggestLoginView = [[UIView alloc] init];
    suggestLoginView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:suggestLoginView];

    suggestLoginLabel = [[UILabel alloc] init];
    suggestLoginLabel.numberOfLines = 2;
    suggestLoginLabel.textColor = [UIColor whiteColor];
    suggestLoginLabel.font = [UIFont fontWithName:@"Anton" size:18];
    suggestLoginLabel.text = @"LET'S GET STARTED\nCLICK HERE TO CONTINUE";
    suggestLoginLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:suggestLoginLabel];
    suggestLoginLabel.translatesAutoresizingMaskIntoConstraints = NO;

    
    
    NSLayoutConstraint *suggestLoginLabelXConstraint = [NSLayoutConstraint
                                                     constraintWithItem:suggestLoginLabel attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                     NSLayoutAttributeLeft multiplier:1.0 constant:0];
    /* Top space to superview Y*/
    NSLayoutConstraint *suggestLoginLabelYConstraint = [NSLayoutConstraint
                                                     constraintWithItem:suggestLoginLabel attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                     NSLayoutAttributeBottom multiplier:1.0f constant:-20];
    /* Fixed width */
    
    
    NSLayoutConstraint *suggestLoginLabelTrailingConstraint = [NSLayoutConstraint
                                                            constraintWithItem:suggestLoginLabel attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                            NSLayoutAttributeRight multiplier:1.0 constant:-80];

    
    NSLayoutConstraint *suggestLoginLabelheightConstraint = [NSLayoutConstraint constraintWithItem:suggestLoginLabel
                                                                                      attribute:NSLayoutAttributeHeight
                                                                                      relatedBy:NSLayoutRelationEqual
                                                                                         toItem:nil
                                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                                     multiplier:1.0
                                                                                       constant:60];

    
    [self.view addConstraints:@[suggestLoginLabelXConstraint, suggestLoginLabelYConstraint, suggestLoginLabelTrailingConstraint,suggestLoginLabelheightConstraint]];

    NSLayoutConstraint *suggestLoginViewXConstraint = [NSLayoutConstraint
                                                        constraintWithItem:suggestLoginView attribute:NSLayoutAttributeLeft
                                                        relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                        NSLayoutAttributeLeft multiplier:1.0 constant:0];
    /* Top space to superview Y*/
    NSLayoutConstraint *suggestLoginViewYConstraint = [NSLayoutConstraint
                                                        constraintWithItem:suggestLoginView attribute:NSLayoutAttributeBottom
                                                        relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                        NSLayoutAttributeBottom multiplier:1.0f constant:-20];
    /* Fixed width */
    
    
    NSLayoutConstraint *suggestLoginViewTrailingConstraint = [NSLayoutConstraint
                                                               constraintWithItem:suggestLoginView attribute:NSLayoutAttributeRight
                                                               relatedBy:NSLayoutRelationEqual toItem:self.view attribute:
                                                               NSLayoutAttributeRight multiplier:1.0 constant:-80];
    
    
    NSLayoutConstraint *suggestLoginViewheightConstraint = [NSLayoutConstraint constraintWithItem:suggestLoginView
                                                                                         attribute:NSLayoutAttributeHeight
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:nil
                                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                                        multiplier:1.0
                                                                                          constant:60];
    
    
    [self.view addConstraints:@[suggestLoginViewXConstraint, suggestLoginViewYConstraint, suggestLoginViewTrailingConstraint,suggestLoginViewheightConstraint]];

    
    infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [infoButton addTarget:self action:@selector(infoClicked) forControlEvents:UIControlEventTouchUpInside];
    [infoButton setImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    infoButton.frame = CGRectMake(10, Deviceheight-50-10, 50, 50);
    [self.view addSubview:infoButton];
    
    messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [messageButton addTarget:self action:@selector(messageClicked) forControlEvents:UIControlEventTouchUpInside];
    [messageButton setImage:[UIImage imageNamed:@"plus_message"] forState:UIControlStateNormal];
    messageButton.frame = CGRectMake(Devicewidth-40-10, Deviceheight-59, 40, 40);
    [self.view addSubview:messageButton];
    
    if(!sharedModel.userProfile.verified)
    {
        verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [verifyButton addTarget:self action:@selector(verfiyClicked) forControlEvents:UIControlEventTouchUpInside];
        [verifyButton setTitle:@"PLEASE VERIFY YOU HAVE ACCESS TO YOUR EMAIL" forState:UIControlStateNormal];
        [verifyButton.titleLabel setFont:[UIFont fontWithName:@"Anton" size:14]];
        [verifyButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [verifyButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [verifyButton setBackgroundColor:[UIColor colorWithRed:(242/255.f) green:(208/255.f) blue:(48/255.f) alpha:1]];
        verifyButton.frame = CGRectMake(60, Deviceheight-50-10+7.5, Devicewidth - 120, 35);
        [self.view addSubview:verifyButton];
        
        verifyButton.hidden = YES;
    }

}

-(void)messageClicked {
    
    
    if([bubbleButton superview]) {
        
        messageButton.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             bubbleButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
                             
                             messageButton.transform = CGAffineTransformMakeRotation(0);
                         }
                         completion:^(BOOL finished) {
                             
                                                  [bubbleButton removeFromSuperview];
                                                messageButton.userInteractionEnabled = YES;
                         }];

        return;
    }
    
    messageButton.userInteractionEnabled = NO;
    messageButton.selected = YES;
    bubbleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [bubbleButton addTarget:self action:@selector(bubbleButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [bubbleButton setImage:[UIImage imageNamed:@"message_round"] forState:UIControlStateNormal];
    bubbleButton.frame = CGRectMake(Devicewidth-56-4+28, Deviceheight-10-59-50+28, 0.5, 0.5);
    [self.view addSubview:bubbleButton];

 

    
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         bubbleButton.transform = CGAffineTransformMakeScale(112, 112);
                         
                         messageButton.transform = CGAffineTransformMakeRotation(-M_PI_4*3);

                     }
                     completion:^(BOOL finished) {
        
                         bubbleButton.frame = CGRectMake(Devicewidth-56-4, Deviceheight-10-59-50, 56, 56);
                         
                         messageButton.userInteractionEnabled = YES;
                     }];
    

}
-(void)removeMessageButtonIfExists {
    
    if([bubbleButton superview]) {
        
        messageButton.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             bubbleButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
                             
                             messageButton.transform = CGAffineTransformMakeRotation(0);
                         }
                         completion:^(BOOL finished) {
                             
                             [bubbleButton removeFromSuperview];
                             messageButton.userInteractionEnabled = YES;
                         }];
        
        return;
    }
    

    
}
-(void)bubbleButtonClicked {
    
    
    
    messageButton.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         bubbleButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
                         
                         messageButton.transform = CGAffineTransformMakeRotation(0);
                     }
                     completion:^(BOOL finished) {
                         
                         [bubbleButton removeFromSuperview];
                         messageButton.userInteractionEnabled = YES;
                     }];
    

    
    MessageViewController *verifiedCntrl = [[MessageViewController alloc] init];
    [self.navigationController pushViewController:verifiedCntrl animated:YES];

    
}
-(void)verfiyClicked  {
    
    VerifiedViewController *verifiedCntrl = [[VerifiedViewController alloc] init];
    [self presentViewController:verifiedCntrl animated:YES completion:nil];
    
}
-(void)infoClicked {
    
    InfoViewController *infoCntrl = [[InfoViewController alloc] init];
    [self.navigationController pushViewController:infoCntrl animated:YES];

}
-(void)menuClicked {
    
    [[appDelegate navgController] toggleLeftMenu];
}
-(void)loginClicked {
    
    [self removeMessageButtonIfExists];
    
    LoginViewController *loginCntrl = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginCntrl animated:YES];
    
}
-(void)logout {
    
    [self removeMessageButtonIfExists];
    
    [self.organisationaArray removeAllObjects];

    
    if([NSThread isMainThread]) {
        
        for(UIView *view in  [scrollView subviews])
        {
            [view removeFromSuperview];
        }
        
        [self setContentInScrollView];
        [self setUpViews];
        
        
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            for(UIView *view in  [scrollView subviews])
            {
                [view removeFromSuperview];
            }
            [self setContentInScrollView];
            [self setUpViews];
        });
        
        

        
    }
    
    
    
    
}
-(void)login {
    
   

    
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;

}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


#pragma mark - 
#pragma CollectionView Delegate Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedin"])  {
        
        return [self.organisationaArray count];
    }
    else
    {
       
            return 0;
    
    }
   
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
        UICollectionViewCell *cell= [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

        for(UIView *view in [cell.contentView subviews])
            [view removeFromSuperview];
        
        if([self.organisationaArray indexOfObject:sharedInstance.selecteOrganisation] == indexPath.row) {
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
            view.backgroundColor = UIColorFromRGB(0x2b78e4);
            view.layer.cornerRadius = 8;
            view.center = cell.contentView.center;
            [cell.contentView addSubview:view];
        }
        else {
            
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
            view.backgroundColor = [UIColor lightGrayColor];
            view.layer.cornerRadius = 6;
            view.center = cell.contentView.center;
            [cell.contentView addSubview:view];
        }
        
        
        return cell;

        
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
        return CGSizeMake(20, 20);

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    // Add inset to the collection view if there are not enough cells to fill the width.
    CGFloat cellSpacing = ((UICollectionViewFlowLayout *) collectionViewLayout).minimumLineSpacing;
    CGFloat cellWidth = 20;
    NSInteger cellCount = [collectionView numberOfItemsInSection:section];
    CGFloat inset = (collectionView.bounds.size.width - (cellCount * cellWidth) - ((cellCount - 1)*cellSpacing)) * 0.5;
    inset = MAX(inset, 0.0);
    return UIEdgeInsetsMake(0.0, inset, 0.0, 0.0);
}




- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if([self.organisationaArray indexOfObject:sharedInstance.selecteOrganisation] != indexPath.row) {
        
        [self removeMessageButtonIfExists];
        sharedInstance.selecteOrganisation = [self.organisationaArray objectAtIndex:indexPath.row];
        [pageCollectionView reloadData];
        
        CGRect frame = scrollView.frame;
        frame.origin.x = scrollView.frame.size.width *indexPath.row;
        [scrollView scrollRectToVisible:frame animated:YES];
        
        
        
        [self showSchollName];
        
        
    }
    
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

    [self removeMessageButtonIfExists];
    
    int index = targetContentOffset->x / self.view.frame.size.width;
    sharedInstance.selecteOrganisation = [self.organisationaArray objectAtIndex:index];
    [pageCollectionView reloadData];
    
    [self showSchollName];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
