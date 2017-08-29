//
//  MyFamilyViewController.m
//  Tingr
//
//  Created by Maisa Pride on 7/26/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "MyFamilyViewController.h"
#import "VOProfilesList.h"
#import "ProfilePhotoUtils.h"
#import "ProfileDateUtils.h"
#import "UIFloatLabelTextField.h"
#import "Switchy.h"
#import "TPKeyboardAvoidingScrollView.h"
#define KParentNameLblTag 204
#define KKidFnameViewTag 206

#define ACCEPTABLE_CHARACTERS @"0123456789/"


@interface MyFamilyViewController ()
{
    
    ProfilePhotoUtils *photoUtils;
    ModelManager *sharedModel;
    SingletonClass *singletonObj;
    
    UITableView *familyTableView;
    UIImageView *imageHeaderView;
    
    CGFloat maxHeaderHeight;
    CGFloat minHeaderHeight;
    CGFloat previousScrollOffset;
    UILabel *titleLabel;
    UIView *tableHeaderView;
    BOOL animated;

    ProfilesList *profilesListObj;
    ProfileDateUtils *photoDateUtils;
    
    
    UIView *plusOptions;
    TPKeyboardAvoidingScrollView *inviteView;
    UIView *overlay;
    UIView *addChildView;
    UIView *contentView;
    
    UIImageView *profielImageView;
    Switchy *genderSwitch;
    
    UIFloatLabelTextField *fnameTxtField;
    UIFloatLabelTextField *lnameTxtField;
    UIFloatLabelTextField *emailTxtField;
    UIFloatLabelTextField *dateTxtField;
    
    NSMutableArray *selectedParents;
    UIImagePickerController *imagePicker;
    UIImage *changedImage;
    NSDictionary *childDetailsDict;
    int selectedIndex;
}
@end

@implementation MyFamilyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    singletonObj = [SingletonClass sharedInstance];
    photoUtils  = [ProfilePhotoUtils alloc];
    photoDateUtils = [ProfileDateUtils alloc];
    sharedModel   = [ModelManager sharedModel];
    
    
    if(sharedModel.userProfile.photograph.length)
    {
        maxHeaderHeight = 200;
        minHeaderHeight = 64;

    }
    else{
        maxHeaderHeight = 64;
        minHeaderHeight = 64;

    }
    previousScrollOffset = 0;
    
    
    familyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, maxHeaderHeight, Devicewidth, Deviceheight-maxHeaderHeight)];
    familyTableView.delegate = self;
    familyTableView.dataSource = self;
    familyTableView.tableFooterView = [UIView new];
    [self.view addSubview:familyTableView];

    
    
    tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth,maxHeaderHeight)];
    tableHeaderView.clipsToBounds = YES;
    tableHeaderView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tableHeaderView];
    
    if(sharedModel.userProfile.photograph.length)
    {
    imageHeaderView = [[UIImageView alloc] initWithFrame:tableHeaderView.bounds];
    imageHeaderView.contentMode = UIViewContentModeScaleAspectFill;
    imageHeaderView.clipsToBounds = true;
    [imageHeaderView setImageWithURL:[NSURL URLWithString:sharedModel.userProfile.photograph] placeholderImage:nil];
    [tableHeaderView addSubview:imageHeaderView];
    }
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, Devicewidth-100, 44)];
    [titleLabel setText:@"Manage Family"];
    [titleLabel setTextColor:[UIColor grayColor]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24.0];
    [self.view addSubview:titleLabel];
    
    UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 20, 44, 44);
    [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *addButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(Devicewidth - 54, 20, 44, 44);
    [addButton setImage:[UIImage imageNamed:@"invite"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];

    if(!sharedModel.userProfile.photograph.length)
    {
        
        CGRect rect = tableHeaderView.frame;
        rect.size.height -= 1;
        UIBezierPath * linePath1 = [UIBezierPath bezierPath];
        [linePath1 moveToPoint:CGPointMake(0,rect.size.height)];
        [linePath1 addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
        CAShapeLayer * lineLayer1 = [CAShapeLayer layer];
        lineLayer1.lineWidth = 1;
        lineLayer1.strokeColor = [UIColor darkGrayColor].CGColor;
        lineLayer1.fillColor = nil;
        lineLayer1.opacity =0.5;
        lineLayer1.path = linePath1.CGPath;
        [tableHeaderView.layer addSublayer:lineLayer1];

    }

    ALAssetsLibrary * assetLibrary1 = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary1];

    
    selectedParents = [[NSMutableArray alloc] init];
    
    [self callProfilesAPI];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

-(void)addClicked {
    
    childDetailsDict = nil;
   
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, Deviceheight)];
    [overlay setBackgroundColor:[UIColor clearColor]];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:overlay];

    plusOptions = [[UIView alloc] initWithFrame:CGRectMake(0, Deviceheight, Devicewidth, 50)];
    [plusOptions setBackgroundColor:[UIColor grayColor]];
    [overlay addSubview:plusOptions];
    
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    singleTap.numberOfTouchesRequired = 1;
    [overlay addGestureRecognizer:singleTap];

    
    
    UIButton *addChildButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [addChildButton setTitle:@"Add Child" forState:UIControlStateNormal];
    [addChildButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:25]];
    [addChildButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addChildButton setBackgroundColor:UIColorFromRGB(0x99CCFF)];
    [addChildButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [addChildButton setFrame:CGRectMake(0, 0, Devicewidth/2.0f-0.5f, 50)];
    [plusOptions addSubview:addChildButton];

    UIButton *inviteButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"Invite Member" forState:UIControlStateNormal];
    [inviteButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:25]];
    [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [inviteButton setBackgroundColor:UIColorFromRGB(0x99CCFF)];
    [inviteButton addTarget:self action:@selector(inviteClicked) forControlEvents:UIControlEventTouchUpInside];
    [inviteButton setFrame:CGRectMake(Devicewidth/2.0f+0.5f, 0, Devicewidth/2.0f-0.5f, 50)];
    [plusOptions addSubview:inviteButton];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        plusOptions.frame = CGRectMake(0, Deviceheight-50, Devicewidth, 50);
        
    }];
    
    
    CABasicAnimation *theAnimation=[CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    theAnimation.duration=0.3;
    theAnimation.removedOnCompletion = NO;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.fromValue= (__bridge id _Nullable)([[UIColor clearColor] CGColor]);
    theAnimation.toValue= (__bridge id _Nullable)([[UIColor colorWithRed:0 green:0 blue:0  alpha:0.5] CGColor]);
    [overlay.layer addAnimation:theAnimation forKey:@"ColorPulse" ];
    
    
}
-(void)tapped:(UITapGestureRecognizer *)gesture {
    
    
    if(gesture.view == overlay)
        [overlay removeFromSuperview];
}

-(void)backClicked {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)addButtonClick {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    
    
    
    [overlay removeFromSuperview];
    
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, Deviceheight)];
    [overlay setBackgroundColor:[UIColor clearColor]];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:overlay];
    
    addChildView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, Devicewidth-40, Deviceheight-40)];
    [overlay addSubview:addChildView];
    addChildView.clipsToBounds = YES;
    addChildView.backgroundColor = [UIColor whiteColor];
    addChildView.layer.cornerRadius = 5;
    
    profielImageView = [[UIImageView alloc] initWithFrame:CGRectMake((addChildView.frame.size.width-70)/2, 10, 70, 70)];
    [profielImageView.layer setCornerRadius:35];
    profielImageView.layer.borderColor = UIColorFromRGB(0x99CCFF).CGColor;
    profielImageView.layer.borderWidth = 1;
    [profielImageView setImage:[UIImage imageNamed:@"camera_blue"]];
    [addChildView addSubview:profielImageView];
    

    UIButton *captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [captureButton setFrame:profielImageView.frame];
    [captureButton addTarget:self action:@selector(cameraTapped) forControlEvents:UIControlEventTouchUpInside];
    [addChildView addSubview:captureButton];

    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setFrame:CGRectMake(addChildView.frame.size.width-80, 10, 30, 30)];
    [menuButton setImage:[UIImage imageNamed:@"navigation_close"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(closeClicked) forControlEvents:UIControlEventTouchUpInside];
    [addChildView addSubview:menuButton];

    UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(addChildView.frame.size.width-40, 10, 30, 30);
    [backButton setImage:[UIImage imageNamed:@"navigation_done"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(doneClicked) forControlEvents:UIControlEventTouchUpInside];
    [addChildView addSubview:backButton];
    
    
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor whiteColor]];
    
    fnameTxtField = [[UIFloatLabelTextField alloc] initWithFrame:CGRectMake(10, profielImageView.frame.size.height+profielImageView.frame.origin.y+10, (addChildView.frame.size.width-25)/2,45)];
    fnameTxtField.delegate = self;
    fnameTxtField.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    fnameTxtField.floatLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    fnameTxtField.floatLabelActiveColor = UIColorFromRGB(0x2b78e4);
    fnameTxtField.placeholder = @"First Name";
    [addChildView addSubview:fnameTxtField];
    
    
    CGRect rect = fnameTxtField.frame;
    rect.size.height -= 3;
    UIBezierPath * linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(0,rect.size.height)];
    [linePath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    CAShapeLayer * lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 1;
    lineLayer.strokeColor = [UIColor darkGrayColor].CGColor;
    lineLayer.fillColor = nil;
    lineLayer.path = linePath.CGPath;
    [fnameTxtField.layer addSublayer:lineLayer];
    
    lnameTxtField = [[UIFloatLabelTextField alloc] initWithFrame:CGRectMake((addChildView.frame.size.width-25)/2+15, profielImageView.frame.size.height+profielImageView.frame.origin.y+10, (Devicewidth-25)/2,45)];
    lnameTxtField.delegate = self;
    lnameTxtField.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    lnameTxtField.floatLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    lnameTxtField.floatLabelActiveColor = UIColorFromRGB(0x2b78e4);
    lnameTxtField.placeholder = @"Last Name";
    [addChildView addSubview:lnameTxtField];
    
    
    rect = lnameTxtField.frame;
    rect.size.height -= 3;
    UIBezierPath * linePath1 = [UIBezierPath bezierPath];
    [linePath1 moveToPoint:CGPointMake(0,rect.size.height)];
    [linePath1 addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    CAShapeLayer * lineLayer1 = [CAShapeLayer layer];
    lineLayer1.lineWidth = 1;
    lineLayer1.strokeColor = [UIColor darkGrayColor].CGColor;
    lineLayer1.fillColor = nil;
    lineLayer1.path = linePath.CGPath;
    [lnameTxtField.layer addSublayer:lineLayer1];
    
    
    
    dateTxtField = [[UIFloatLabelTextField alloc] initWithFrame:CGRectMake(10, lnameTxtField.frame.size.height+lnameTxtField.frame.origin.y+20, addChildView.frame.size.width-20,45)];
    dateTxtField.delegate = self;
    dateTxtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    dateTxtField.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    dateTxtField.floatLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    dateTxtField.keyboardType = UIKeyboardTypeEmailAddress;
    dateTxtField.floatLabelActiveColor = UIColorFromRGB(0x2b78e4);
    dateTxtField.placeholder = @"Date of Birth (mm/dd/yyyy)";
    [addChildView addSubview:dateTxtField];
    
    CGRect rect2 = dateTxtField.frame;
    
    rect2.size.height -= 4;
    UIBezierPath * linePath2 = [UIBezierPath bezierPath];
    [linePath2 moveToPoint:CGPointMake(0,rect2.size.height)];
    [linePath2 addLineToPoint:CGPointMake(rect2.size.width, rect2.size.height)];
    // create a layer that uses your defined path
    CAShapeLayer * lineLayer2 = [CAShapeLayer layer];
    lineLayer2.lineWidth = 1.0;
    lineLayer2.strokeColor = [UIColor darkGrayColor].CGColor;
    lineLayer2.fillColor = nil;
    lineLayer2.path = linePath2.CGPath;
    
    [dateTxtField.layer addSublayer:lineLayer2];

    
    genderSwitch = [[Switchy alloc] initWithFrame:CGRectMake(0, 0, 79, 30) withOnLabel:@"BOY" andOfflabel:@"GIRL"
                     withContainerColor1:[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]
                      andContainerColor2:[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]
                          withKnobColor1:[UIColor colorWithRed:(145/255.f) green:(185/255.f) blue:(88/255.f) alpha:1]
                           andKnobColor2:[UIColor colorWithRed:(145/255.f) green:(185/255.f) blue:(88/255.f) alpha:1] withShine:YES];
    [addChildView addSubview:genderSwitch];
    genderSwitch.center = CGPointMake(CGRectGetMidX(addChildView.bounds), dateTxtField.frame.size.height+dateTxtField.frame.origin.y+30);
    
    if(childDetailsDict.count > 0)
    {
        fnameTxtField.text = [childDetailsDict objectForKey:@"fname"];
        lnameTxtField.text = [childDetailsDict objectForKey:@"lname"];
        dateTxtField.text = [childDetailsDict objectForKey:@"birthdate"];
        
        __weak UIImageView *weakSelf = profielImageView;
        __weak ProfilePhotoUtils *weakphotoUtils = photoUtils;
        NSString *url = [childDetailsDict valueForKey:@"photograph"];
        if(url != (id)[NSNull null] && url.length > 0)
        {
            
            [profielImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 weakSelf.image = [weakphotoUtils makeRoundWithBoarder:[weakphotoUtils squareImageWithImage:image scaledToSize:CGSizeMake(70, 70)] withRadious:0];
                 
             }
                                         failure:nil];
        }

        
        
        if([[childDetailsDict objectForKey:@"gender"] isEqualToString:@"Male"]) {
            
            [genderSwitch setState:YES];
        }
        else {
            
            [genderSwitch setState:NO];
        }
    }
    
    UIView *parentAccessView = [[UIView alloc] initWithFrame:CGRectMake(10, genderSwitch.frame.size.height+genderSwitch.frame.origin.y+20, addChildView.frame.size.width-20, addChildView.frame.size.height - (genderSwitch.frame.size.height+genderSwitch.frame.origin.y+30))];
    [parentAccessView.layer setCornerRadius:4];
    parentAccessView.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    [addChildView addSubview:parentAccessView];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, parentAccessView.frame.size.width, 30)];
    [messageLabel setText:@"who can access your child's digital portfolio?"];
    [messageLabel setTextColor:[UIColor grayColor]];
    messageLabel.font = [UIFont fontWithName:@"Anton" size:13.0];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [parentAccessView addSubview:messageLabel];

    UIScrollView *selectScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, messageLabel.frame.size.height+8, parentAccessView.frame.size.width, parentAccessView.frame.size.height - messageLabel.frame.size.height -16)];
    [parentAccessView addSubview:selectScrollView];
    float yposition = 0;
    for (int i=0; i<  singletonObj.allProfileParents.count;i++)
    {
        
        NSDictionary *personDict = singletonObj.allProfileParents[i];
        NSString *fname = [personDict valueForKey:@"fname"];
        NSString *lname = [personDict valueForKey:@"lname"];
        NSMutableString *name = [[NSMutableString alloc] init];
        if(fname.length)
            [name appendString:fname];
        if(lname.length)
        {
            if(fname.length >0)
                [name appendString:@" "];
            [name appendString:lname];
        }
        
        
        
        UIButton *goButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [goButton setTitle:name forState:UIControlStateNormal];
        [goButton.titleLabel setFont:[UIFont fontWithName:@"Antonio-Bold" size:18]];
        [goButton setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
        goButton.selected = YES;
        [goButton setTag:i];
        [goButton addTarget:self action:@selector(selectClicked:) forControlEvents:UIControlEventTouchUpInside];
        [goButton setFrame:CGRectMake(0, yposition, selectScrollView.frame.size.width, 30)];
        [selectScrollView addSubview:goButton];
        
        [selectedParents addObject:[personDict valueForKey:@"kl_id"]];

        yposition += 30;
    }
    selectScrollView.contentSize  = CGSizeMake(selectScrollView.frame.size.width, yposition);
    
    CABasicAnimation *theAnimation=[CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    theAnimation.duration=0.1;
    theAnimation.removedOnCompletion = NO;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.fromValue= (__bridge id _Nullable)([[UIColor clearColor] CGColor]);
    theAnimation.toValue= (__bridge id _Nullable)([[UIColor colorWithRed:0 green:0 blue:0  alpha:0.5] CGColor]);
    [overlay.layer addAnimation:theAnimation forKey:@"ColorPulse" ];

    
    
    
}

-(void)cameraTapped {
    
  
    [self rsignAllFields];
    
    UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                          @"Take photo", @"Choose existing", nil];
    addImageActionSheet.tag = 1000;
    [addImageActionSheet setDelegate:self];
    [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];

}
-(void)rsignAllFields {
    
    [fnameTxtField resignFirstResponder];
    [lnameTxtField resignFirstResponder];
    [dateTxtField resignFirstResponder];
    [emailTxtField resignFirstResponder];
}
#pragma mark- UIActionSheet Delegate Methods
#pragma mark-
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 1000:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                    {
                        imagePicker = [[UIImagePickerController alloc]init];
                        
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                        imagePicker.delegate = self;
                        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
                        [self presentViewController:imagePicker animated:YES completion:NULL];
                    }
                    else
                    {
                        UIAlertView *alert;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:@"This device doesn't have a camera."
                                                          delegate:self cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
                        
                        
                        [alert show];
                    }
                    break;
                }
                case 1:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
                    {
                        imagePicker = [[UIImagePickerController alloc]init];
                        imagePicker.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                        imagePicker.delegate = self;
                        [self presentViewController:imagePicker animated:YES completion:NULL];
                    }
                    else
                    {
                        
                        UIAlertView *alert;
                        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                           message:@"This device doesn't support photo libraries."
                                                          delegate:self cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
                        [alert show];
                    }
                    break;
                }
                case 2:
                {
                    
                }
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSURL * assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    void(^completion)(void)  = ^(void){
        
        [[self assetLibrary] assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            if (asset){
                UIImage * image = [self highResImageForAsset:asset];
                [self finishedTakingImage:image];
                
            }
            else
            {
                UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
                [self finishedTakingImage:image];
                
            }
        } failureBlock:^(NSError *error) {
            UIAlertView *disableAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable access to your device's photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            
            [disableAlert show];
        }];
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:NO completion:completion];
    }else{
        // [self dismissPopoverWithCompletion:completion];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (UIImage *)highResImageForAsset:(ALAsset*)asset
{
    ALAssetRepresentation * representation = [asset defaultRepresentation];
    
    CGImageRef image = [representation fullResolutionImage];
    UIImageOrientation orientation = (UIImageOrientation)[representation orientation];
    CGFloat scale = [representation scale];
    
    return [UIImage imageWithCGImage:image scale:scale orientation:orientation];
}


-(void)finishedTakingImage:(UIImage *)image {
    
    image = [photoUtils compressForUpload:image :0.67];
    
    changedImage = image;
    NSData *imageData1 = UIImageJPEGRepresentation(image, 0.7);
    
    NSString *imageExtension = @"JPEG";
    
    [SVProgressHUD show];
    
    NSString *imageDataEncodedeString = [imageData1 base64EncodedString];
    [self sendImageInfoToServerWithName:[NSString stringWithFormat:@"temp.%@",imageExtension] contentType:[NSString stringWithFormat:@"image/%@",[imageExtension lowercaseString]] content:imageDataEncodedeString];
    
}
-(void)sendImageInfoToServerWithName:(NSString *)name contentType:(NSString *)contentType content:(NSString *)content
{
    AccessToken  *token          = sharedModel.accessToken;
    UserProfile  *_userProfile   = sharedModel.userProfile;
    
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
    [bodyRequest setValue:name          forKey:@"name"];
    if(childDetailsDict.count > 0)
    [bodyRequest setValue:[childDetailsDict objectForKey:@"kl_id"]          forKey:@"profile_id"];
    [bodyRequest setValue:contentType   forKey:@"content_type"];
    [bodyRequest setValue:content       forKey:@"content"];
    
    NSMutableDictionary *finalRequest = [[NSMutableDictionary alloc]init];
    [finalRequest setValue:token.access_token       forKey:@"access_token"];
    [finalRequest setValue:_userProfile.auth_token  forKey:@"auth_token"];
    if(childDetailsDict.count > 0)
    [finalRequest setValue:@"change_photograph"     forKey:@"command"];
    else
        [finalRequest setValue:@"upload_multimedia"     forKey:@"command"];
    [finalRequest setValue:bodyRequest              forKey:@"body"];
    
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:finalRequest options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@v2/document-vault",BASE_URL]]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    // 2
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         //         DebugLog(@"%lu",(long)operation.response.statusCode);
         NSMutableDictionary *dictionaryResponseAll = responseObject;
         if(dictionaryResponseAll==nil)
         {
             UIAlertView *wrongFormatImage = [[UIAlertView alloc]initWithTitle:nil message:@"Error at server, try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
             
             [wrongFormatImage show];
             return;
         }
         if (operation.response.statusCode == 200)
         {
             [SVProgressHUD dismiss];
             
             if(!childDetailsDict) {
                 
                 NSMutableDictionary *documentDictionary = [[dictionaryResponseAll valueForKey:@"body"] valueForKey:@"document"];
                 singletonObj.addKidPhotoId=[documentDictionary valueForKey:@"kl_id"];

             }
             
             profielImageView.image =  [photoUtils makeRoundKidPhoto:[photoUtils squareImageWithImage:changedImage scaledToSize:CGSizeMake(70, 70)]];

         }
         else if (operation.response.statusCode == 401 || error.code == -1012)
         {
             NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
             [popData setValue:@"401" forKey:@"error_type"];
             NSString *className = NSStringFromClass([self class]);
             [popData setValue:className forKey:@"classname_name"];
             [popData setValue:dictionaryResponseAll forKey:@"return_data"];
             
             [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
             
         }
         else
         {
             [[NSNotificationCenter defaultCenter]postNotificationName:@"ImageUploadedUnSuccessfully" object:nil];
             
             UIAlertView *wrongFormatImage = [[UIAlertView alloc]initWithTitle:nil message:@"Invalid Image Type" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
             
             [wrongFormatImage show];
         }
         
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error at Server, while upload_multimedia for add kid"
                                                             message:[error localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
         
         [alertView show];
         
         
         [SVProgressHUD dismiss];
         
         
     }];
    [operation start];
}
-(void)callEditKidApi {
    
    if([self validateFields:fnameTxtField] && [self validateFields:lnameTxtField] && [self validateFields:dateTxtField])
    {
        if(![self validateDateFromString:dateTxtField.text])
        {
            [self validationAlert:@"Invalid date format"];
            return;
        }
        [overlay removeFromSuperview];
        
        
        NSString *stringFromDate = dateTxtField.text; //txtBirthDate.text;
        NSString *stringGender = genderSwitch.isOn?@"Male":@"Female";
        NSMutableArray *arrayManagedBy = [[NSMutableArray alloc]init];
        //get managed profiles
        
        for (NSString *klid in selectedParents)
        {
            
            NSMutableDictionary *dictionaryManaged = [[NSMutableDictionary alloc]init];
            [dictionaryManaged setValue:klid forKey:@"profile_id"];
            [dictionaryManaged setValue:@"Guardian" forKey:@"relationship"];
            [arrayManagedBy addObject:dictionaryManaged];
        }
        
        
        [SVProgressHUD show];
        
        
        //ModelManager *sharedModel = [ModelManager sharedModel];
        AccessToken* token = sharedModel.accessToken;
        UserProfile *_userProfile = sharedModel.userProfile;
        
        NSDictionary* bodyData = @{@"fname": fnameTxtField.text,@"lname": lnameTxtField.text,@"birthdate":stringFromDate,@"gender":stringGender,@"managed_by":arrayManagedBy};
        
        
        NSDictionary* postData = @{@"access_token": token.access_token,
                                   @"auth_token":_userProfile.auth_token,
                                   @"command": @"update_kid_profile",
                                   @"body": bodyData};
        
        NSDictionary *userInfo = @{@"command":@"update_kid_profile"};
        NSString *urlAsString = [NSString stringWithFormat:@"%@profiles/%@",BASE_URL, [childDetailsDict valueForKey:@"kl_id"]];
        
        NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
        API *api = [[API alloc] init];
        [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
            
            NSArray *kidsArray = [Factory addKidFromJSON:[json objectForKey:@"response"]];
            [self didReceiveAddKid:kidsArray];
        } failure:^(NSDictionary *json) {
            
            [SVProgressHUD dismiss];
        }];
        
    }
    
    else {
        
        [self validationAlert:ALL_FIELDS_REQUIRED];
    }
    
}

-(void)callAddKidApi
{
    if([self validateFields:fnameTxtField] && [self validateFields:lnameTxtField] && [self validateFields:dateTxtField])
    {
        if(![self validateDateFromString:dateTxtField.text])
        {
            [self validationAlert:@"Invalid date format"];
            return;
        }
        [overlay removeFromSuperview];

        
        NSString *stringPhotoId  = singletonObj.addKidPhotoId;
        NSString *stringFromDate = dateTxtField.text; //txtBirthDate.text;
        NSString *stringGender = genderSwitch.isOn?@"Male":@"Female";
        NSMutableArray *arrayManagedBy = [[NSMutableArray alloc]init];
            //get managed profiles
            
            for (NSString *klid in selectedParents)
            {
                
                NSMutableDictionary *dictionaryManaged = [[NSMutableDictionary alloc]init];
                [dictionaryManaged setValue:klid forKey:@"profile_id"];
                [dictionaryManaged setValue:@"Guardian" forKey:@"relationship"];
                [arrayManagedBy addObject:dictionaryManaged];
            }
        
            
            [SVProgressHUD show];
            
        
            //ModelManager *sharedModel = [ModelManager sharedModel];
            AccessToken* token = sharedModel.accessToken;
            UserProfile *_userProfile = sharedModel.userProfile;
            
            NSDictionary* bodyData = @{@"fname": fnameTxtField.text,@"lname": lnameTxtField.text,@"birthdate":stringFromDate,@"gender":stringGender,@"photo_id":stringPhotoId,@"managed_by":arrayManagedBy};
            
        
            NSDictionary* postData = @{@"access_token": token.access_token,
                                       @"auth_token":_userProfile.auth_token,
                                       @"command": @"add_new_kid",
                                       @"body": bodyData};
            
            NSDictionary *userInfo = @{@"command":@"update_kid_profile"};
            NSString *urlAsString = [NSString stringWithFormat:@"%@v2/profiles",BASE_URL];
            
            NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
            API *api = [[API alloc] init];
            [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
                
                NSArray *kidsArray = [Factory addKidFromJSON:[json objectForKey:@"response"]];
                [self didReceiveAddKid:kidsArray];
            } failure:^(NSDictionary *json) {
                
                [SVProgressHUD dismiss];
            }];
            
            
            singletonObj.addKidPhotoId = @"";
            
    
        

        
    }
    else {
        
        [self validationAlert:ALL_FIELDS_REQUIRED];
    }
    
}
- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

-(BOOL)validateDateFromString:(NSString *)dateString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm/dd/yyyy"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    if(date == nil){
        
        return NO;
    }
    return YES;

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
                          initWithTitle:@"Alert"
                          message:comment
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
    
}

#pragma mark- AddKidManagerDelegate Methods
#pragma mark-
- (void)didReceiveAddKid:(NSArray *)addkids
{
    [SVProgressHUD dismiss];
    
    NSDictionary *kid =  [[[addkids objectAtIndex:0] valueForKey:@"body"] valueForKey:@"profile"];

    if(childDetailsDict.count >0)
        [singletonObj.profileKids replaceObjectAtIndex:selectedIndex withObject:kid];
        
    else
        [singletonObj.profileKids addObject:kid];
    
    [[NSUserDefaults standardUserDefaults] setObject:singletonObj.profileKids forKey:@"profileKids"];
    
    [familyTableView reloadData];
  
}


-(void)selectClicked:(UIButton *)sender {
    
    
    NSDictionary *personDict = singletonObj.allProfileParents[sender.tag];
    if(sender.selected)
    {
        [sender.titleLabel setFont:[UIFont fontWithName:@"Antonio-Regular" size:18]];
        [sender setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [selectedParents addObject:[personDict valueForKey:@"kl_id"]];
    }
    else {
        
        [sender.titleLabel setFont:[UIFont fontWithName:@"Antonio-Bold" size:18]];
        [sender setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
        [selectedParents removeObject:[personDict valueForKey:@"kl_id"]];
        

    }
    sender.selected = !sender.selected;
    
}
-(void)closeClicked {
    [overlay removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}
-(void)doneClicked {
    
    
    [self rsignAllFields];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    
    if(childDetailsDict.count >0)
        [self callEditKidApi];
    else
        [self callAddKidApi];
    
}
-(void)inviteClicked {
    
    [overlay removeFromSuperview];
    
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, Deviceheight)];
    [overlay setBackgroundColor:[UIColor clearColor]];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:overlay];

    inviteView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 210, Devicewidth, Deviceheight)];
    [overlay addSubview:inviteView];
    
    
    UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:inviteView.bounds];
    [button addTarget:self action:@selector(removeOverlay) forControlEvents:UIControlEventTouchUpInside];
    [inviteView addSubview:button];

    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    singleTap.numberOfTouchesRequired = 1;
    [inviteView addGestureRecognizer:singleTap];
    
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, Deviceheight-210, Devicewidth, 210)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [inviteView addSubview:contentView];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 30)];
    [messageLabel setText:@"INVITE YOUR FAMILY MEMBER TO JOIN YOU HERE TODAY!"];
    [messageLabel setTextColor:[UIColor grayColor]];
    messageLabel.font = [UIFont fontWithName:@"Anton" size:13.0];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:messageLabel];

    

    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor whiteColor]];
    
    fnameTxtField = [[UIFloatLabelTextField alloc] initWithFrame:CGRectMake(10, messageLabel.frame.size.height+messageLabel.frame.origin.y+10, (Devicewidth-25)/2,45)];
    fnameTxtField.delegate = self;
    fnameTxtField.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    fnameTxtField.floatLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    fnameTxtField.floatLabelActiveColor = UIColorFromRGB(0x2b78e4);
    fnameTxtField.placeholder = @"First Name";
    [contentView addSubview:fnameTxtField];
    
    
    CGRect rect = fnameTxtField.frame;
    rect.size.height -= 3;
    UIBezierPath * linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(0,rect.size.height)];
    [linePath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    CAShapeLayer * lineLayer = [CAShapeLayer layer];
    lineLayer.lineWidth = 1;
    lineLayer.strokeColor = [UIColor darkGrayColor].CGColor;
    lineLayer.fillColor = nil;
    lineLayer.path = linePath.CGPath;
    [fnameTxtField.layer addSublayer:lineLayer];
    
    lnameTxtField = [[UIFloatLabelTextField alloc] initWithFrame:CGRectMake((Devicewidth-25)/2+15, messageLabel.frame.size.height+messageLabel.frame.origin.y+10, (Devicewidth-25)/2,45)];
    lnameTxtField.delegate = self;
    lnameTxtField.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    lnameTxtField.floatLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    lnameTxtField.floatLabelActiveColor = UIColorFromRGB(0x2b78e4);
    lnameTxtField.placeholder = @"Last Name";
    [contentView addSubview:lnameTxtField];

    
    rect = lnameTxtField.frame;
    rect.size.height -= 3;
    UIBezierPath * linePath1 = [UIBezierPath bezierPath];
    [linePath1 moveToPoint:CGPointMake(0,rect.size.height)];
    [linePath1 addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
    CAShapeLayer * lineLayer1 = [CAShapeLayer layer];
    lineLayer1.lineWidth = 1;
    lineLayer1.strokeColor = [UIColor darkGrayColor].CGColor;
    lineLayer1.fillColor = nil;
    lineLayer1.path = linePath.CGPath;
    [lnameTxtField.layer addSublayer:lineLayer1];
    
    
    
    emailTxtField = [[UIFloatLabelTextField alloc] initWithFrame:CGRectMake(10, lnameTxtField.frame.size.height+lnameTxtField.frame.origin.y+20, Devicewidth-20,45)];
    emailTxtField.delegate = self;
    emailTxtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailTxtField.font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    emailTxtField.floatLabelFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    emailTxtField.keyboardType = UIKeyboardTypeEmailAddress;
    emailTxtField.floatLabelActiveColor = UIColorFromRGB(0x2b78e4);
    emailTxtField.placeholder = @"Email";
    [contentView addSubview:emailTxtField];
    
    
    CGRect rect2 = emailTxtField.frame;
    
    rect2.size.height -= 4;
    UIBezierPath * linePath2 = [UIBezierPath bezierPath];
    [linePath2 moveToPoint:CGPointMake(0,rect2.size.height)];
    [linePath2 addLineToPoint:CGPointMake(rect2.size.width, rect2.size.height)];
    // create a layer that uses your defined path
    CAShapeLayer * lineLayer2 = [CAShapeLayer layer];
    lineLayer2.lineWidth = 1.0;
    lineLayer2.strokeColor = [UIColor darkGrayColor].CGColor;
    lineLayer2.fillColor = nil;
    lineLayer2.path = linePath2.CGPath;
    
    [emailTxtField.layer addSublayer:lineLayer2];
    
    
    UIButton *inviteButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"SEND INVITATION" forState:UIControlStateNormal];
    [inviteButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:20]];
    [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [inviteButton setBackgroundColor:UIColorFromRGB(0x99CCFF)];
    [inviteButton addTarget:self action:@selector(sendInviteClicked) forControlEvents:UIControlEventTouchUpInside];
    [inviteButton setFrame:CGRectMake(0, contentView.frame.size.height - 50, Devicewidth, 50)];
    [contentView addSubview:inviteButton];


    
    [UIView animateWithDuration:0.3 animations:^{
        
        inviteView.frame = CGRectMake(0, 0, Devicewidth, Deviceheight);
        
    }];
    
    
    CABasicAnimation *theAnimation=[CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    theAnimation.duration=0.3;
    theAnimation.removedOnCompletion = NO;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.fromValue= (__bridge id _Nullable)([[UIColor clearColor] CGColor]);
    theAnimation.toValue= (__bridge id _Nullable)([[UIColor colorWithRed:0 green:0 blue:0  alpha:0.5] CGColor]);
    [overlay.layer addAnimation:theAnimation forKey:@"ColorPulse" ];

    
}
-(void)removeOverlay {
    
    [overlay removeFromSuperview];
    
    
}
-(void)sendInviteClicked {
    
    
    [self rsignAllFields];
    
    if([self validateFields:fnameTxtField] && [self validateFields:lnameTxtField] && [self validateFields:emailTxtField])
    {
        if(![self validateEmailWithString:emailTxtField.text])
        {
            [self validationAlert:@"Invalid email"];
            return;
        }

        
        [overlay removeFromSuperview];
        
        [SVProgressHUD show];
        
        
        NSMutableArray *arrayManagedBy = [[NSMutableArray alloc]init];
        for (NSDictionary *kid in singletonObj.profileKids)
        {
            
            NSMutableDictionary *dictionaryManaged = [[NSMutableDictionary alloc]init];
            [dictionaryManaged setValue:[kid objectForKey:@"kl_id"] forKey:@"kid_profile_id"];
            [dictionaryManaged setValue:[NSNumber numberWithBool:YES] forKey:@"manageable"];
            [dictionaryManaged setValue:@"Guardian" forKey:@"relationship"];
            [arrayManagedBy addObject:dictionaryManaged];
        }

        
        
        //ModelManager *sharedModel = [ModelManager sharedModel];
        AccessToken* token = sharedModel.accessToken;
        UserProfile *_userProfile = sharedModel.userProfile;
        
        NSDictionary* bodyData = @{@"fname": fnameTxtField.text,@"lname": lnameTxtField.text,@"email":emailTxtField.text,@"allow_to_join_family":[NSNumber numberWithBool:YES],@"kids":arrayManagedBy};
        
        
        NSDictionary* postData = @{@"access_token": token.access_token,
                                   @"auth_token":_userProfile.auth_token,
                                   @"command": @"invite_family_member",
                                   @"body": bodyData};
        
        NSDictionary *userInfo = @{@"command":@"invite_family_member"};
        NSString *urlAsString = [NSString stringWithFormat:@"%@invitations",BASE_URL];
        
        NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
        API *api = [[API alloc] init];
        [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
            
            [self invitationSuccess];
        } failure:^(NSDictionary *json) {
            
            [SVProgressHUD dismiss];
        }];
        
    }
    
    else {
        
        [self validationAlert:ALL_FIELDS_REQUIRED];
    }

}
-(void) invitationSuccess{
    
    [SVProgressHUD dismiss];
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Tingr"
                          message:@"We have successfully invited your family member to join on Tingr. As soon as your invitation gets accepted, we’ll keep you informed."
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];

}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    for(id obj in [textField.layer sublayers])
    {
        if([obj isKindOfClass:[CAShapeLayer class]])
        {
            [(CAShapeLayer *)obj setStrokeColor:UIColorFromRGB(0x2b78e4).CGColor];
            [(CAShapeLayer *)obj setNeedsDisplay];
        }
    }
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    for(id obj in [textField.layer sublayers])
    {
        if([obj isKindOfClass:[CAShapeLayer class]])
        {
            [(CAShapeLayer *)obj setStrokeColor:[UIColor darkGrayColor].CGColor];
            [(CAShapeLayer *)obj setNeedsDisplay];
        }
    }
    
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    
    [textField resignFirstResponder];
    
    inviteView.contentOffset = CGPointMake(0, 0);
    inviteView.contentSize = CGSizeMake(Devicewidth, Deviceheight);

    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string  {
    
    if(textField == dateTxtField)
    {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARACTERS] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        return [string isEqualToString:filtered];

        
    }
    return YES;
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
//If all fails, you may brute-force your Table View margins:
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Force your tableview margins (this may be a bad idea)
    if ([familyTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [familyTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([familyTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [familyTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self tableScrolled:scrollView.contentOffset.y];
}

//DM: called from the StreamDisplayView delegate
- (void)tableScrolled:(float)index
{
    
    if (index < -20 && animated == TRUE)
    {
        [self animateTopDown];
        animated = FALSE;
    }
    
    else if (index > 0)
    {
        [self animateTopUp];
        animated = TRUE;
        
    }
}

//The event handling method
- (void)animateTopUp
{
    
    
    // originalPosition = streamView.frame;
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        
        
        tableHeaderView.frame = CGRectMake(0, -(maxHeaderHeight-minHeaderHeight), Devicewidth, maxHeaderHeight);
        
        familyTableView.frame  = CGRectMake(0, minHeaderHeight, Devicewidth, Deviceheight-minHeaderHeight);
        
    }
                     completion:^(BOOL finished){
                         
                     }
     ];
    
}

- (void)animateTopDown
{
    
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         tableHeaderView.frame = CGRectMake(0, 0, Devicewidth, maxHeaderHeight);
                         familyTableView.frame  = CGRectMake(0, maxHeaderHeight, Devicewidth, Deviceheight-maxHeaderHeight);
                         
                     }
     ];
    
    
    
}



- (void)callProfilesAPI
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [singletonObj stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tingr"
                                                       message:@"No internet connection. Try again after connecting to internet"
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        
        [alert show];
        return;
    }

    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSString *command = @"family_info";
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": command,
                               @"body": @""};
    NSString *urlAsString = [NSString stringWithFormat:@"%@v2/profiles",BASE_URL];
    NSDictionary *userInfo = @{@"command":command};
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        [self recieviedProfiles:[json objectForKey:@"response"]];
        
    } failure:^(NSDictionary *json) {

    }];
}
-(void)recieviedProfiles:(NSDictionary *)responseObject{
    //DebugLog(@"responseObject:%@",responseObject);
    NSMutableDictionary *dictionaryResponseAll = responseObject.mutableCopy;
    if(dictionaryResponseAll==nil)
    {
        return;
    }
    NSNumber *validResponseStatus = [dictionaryResponseAll valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    
    if ([stringStatus1 isEqualToString:@"200"])
    {
        NSMutableDictionary *profilesListResponse = [dictionaryResponseAll valueForKey:@"body"];
        NSMutableArray *profiles    = [[NSMutableArray alloc] init];
        
        ProfilesList *profilesList  = [[ProfilesList alloc] init];
        for (NSString *key in profilesListResponse)
        {
            if ([profilesList respondsToSelector:NSSelectorFromString(key)])
                [profilesList setValue:[profilesListResponse valueForKey:key] forKey:key];
        }
        
        [profiles addObject:profilesList];
        
        profilesListObj = [profiles objectAtIndex:0];
        if(profilesListObj!=nil)
        {
            //dispatch_async(dispatch_get_main_queue(), ^{
            
            
        
            singletonObj.profileKids = [profilesListObj.kids mutableCopy];
            singletonObj.allProfileParents =  [profilesListObj.parents mutableCopy];
            
            singletonObj.profileParents = [[profilesListObj.parents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"accessibility != -1"]] mutableCopy];
            
            singletonObj.profileOnboarding = profilesListObj.onboarding_partner;
            singletonObj.profileKids = [photoDateUtils sortByStringDate:[singletonObj.profileKids mutableCopy]];
            
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
            [prefs setObject:singletonObj.sortedKidDetails forKey:@"sortedtKidDetails"];
            [prefs setObject:singletonObj.arrayShowProfiles forKey:@"arrayShowProfiles"];
            [prefs synchronize];
            
            [familyTableView reloadData];
            
            /*  if(profilesListObj.vphr)
             if([[VerifiedPhone sharedInstance] superview] == nil)
             {
             [[[UIApplication sharedApplication] keyWindow] addSubview:[VerifiedPhone sharedInstance]];
             }
             */
            //[tableViewProfile setHidden:FALSE];
            //});
        }
        DebugLog(@"%@",singletonObj.profileParents);
        
        
    }
    else if ([stringStatus1 isEqualToString:@"401"])
    {
        NSMutableDictionary *popData = [[NSMutableDictionary alloc] init];
        [popData setValue:@"401" forKey:@"error_type"];
        NSString *className = NSStringFromClass([self class]);
        [popData setValue:className forKey:@"classname_name"];
        [popData setValue:dictionaryResponseAll forKey:@"return_data"];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:POP_TO_LOGIN object:nil userInfo:popData];
    }
    else
    {
        DebugLog(@"responseObject:%@",responseObject);
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
            return singletonObj.profileKids.count;
        else
        {
                return singletonObj.profileParents.count;
        }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
    
    UITableViewCell *cell = nil;
    cell.userInteractionEnabled = YES;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"KidProfileCell"];

    UILabel * kidFirstNameView;
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"KidProfileCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    for(UIView *subView in [cell.contentView subviews])
        [subView removeFromSuperview];
    
    NSDictionary *personDict;
    
    if (indexPath.section == 0) //kids section
    {
        personDict  = [singletonObj.profileParents objectAtIndex:indexPath.row];
    }
    else {
        
        personDict  = [singletonObj.profileKids objectAtIndex:indexPath.row];
    }
    
    
    
    kidFirstNameView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    kidFirstNameView.font =[UIFont fontWithName:@"Antonio-Bold" size:15]; //Archer-Bold
    kidFirstNameView.textColor = UIColorFromRGB(0x2b78e4);
    kidFirstNameView.textAlignment = NSTextAlignmentCenter;

    
        UIImageView *profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7.5, 35, 35)];
        [cell.contentView addSubview:profileImage];
        __weak UIImageView *weakSelf = profileImage;
        NSString *url = [personDict valueForKey:@"photograph"];
        if(url != (id)[NSNull null] && url.length > 0)
        {
            [kidFirstNameView setHidden:YES];
            
            [profileImage setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:[UIImage imageNamed:@"default_icon_3.png"] scaledToSize:CGSizeMake(30,30)] withRadious:5.0f] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
             {
                 weakSelf.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(30, 30)] withRadious:0];
                 
             }
                                         failure:nil];
        }
        else
        {
            

            NSString *fname = [personDict valueForKey:@"fname"];
            NSString *lname = [personDict valueForKey:@"lname"];
            NSMutableString *name = [[NSMutableString alloc] init];
            if(fname.length)
                [name appendString:[fname substringToIndex:1]];
            if(lname.length)
                [name appendString:[lname substringToIndex:1]];
        
                if(name.length)
                    kidFirstNameView.text = [name uppercaseString];
            
            profileImage.backgroundColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
            profileImage.layer.cornerRadius = 35/2.0;
            [profileImage addSubview:kidFirstNameView];
            
        }
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 7.5, Devicewidth-70, 35)];
    nameLabel.font =[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]; //Archer-Bold
    [cell.contentView addSubview:nameLabel];
    
        
    
        NSString *fname = [personDict valueForKey:@"fname"];
        NSString *lname = [personDict valueForKey:@"lname"];
        NSMutableString *name = [[NSMutableString alloc] init];
        if(fname.length)
            [name appendString:fname];
        if(lname.length)
        {
            if(fname.length >0)
                [name appendString:@" "];
            [name appendString:lname];
        }

        nameLabel.text  = name;
        
   
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return 50;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1)
    {
        selectedIndex = indexPath.row;
        childDetailsDict = [singletonObj.profileKids objectAtIndex:indexPath.row];
        [self addButtonClick];
        
    }
    
}


-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = CGRectMake(20, 20, Devicewidth-40, Deviceheight-keyboardBounds.size.height-40);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    addChildView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = CGRectMake(20, 20, Devicewidth-40, Deviceheight-40);
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    addChildView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
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
