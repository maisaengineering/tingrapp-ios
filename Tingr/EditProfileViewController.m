//
//  EditProfileViewController.m
//  Tingr
//
//  Created by Maisa Pride on 7/26/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "EditProfileViewController.h"
#import "UIFloatLabelTextField.h"
#import "ProfilePhotoUtils.h"
#import "TPKeyboardAvoidingScrollView.h"
@interface EditProfileViewController ()
{
    UIFloatLabelTextField *fnameTxtField;
    UIFloatLabelTextField *lnameTxtField;
    UIFloatLabelTextField *emailTxtField;
    
    UIView *topBar;
    UIImageView *profileImageView;
    
    UILabel *titleLabel;
    
    ModelManager *sharedModel;
    SingletonClass *singletonObj;
    UIImagePickerController *imagePicker;
    ProfilePhotoUtils *photoUtils;
    
    UIImage *changedImage;
    
    TPKeyboardAvoidingScrollView *scrollView;
    BOOL isUpdateApiInProgress;
    BOOL isChangeImageApiInProgress;
    float topSpace;
}
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    topSpace = 0;
    if(appDelegate.topSafeAreaInset > 0)
        topSpace = 15;

    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    sharedModel = [ModelManager sharedModel];
    singletonObj = [SingletonClass sharedInstance];
    photoUtils = [ProfilePhotoUtils alloc];
    ALAssetsLibrary * assetLibrary1 = [[ALAssetsLibrary alloc] init];
    [self setAssetLibrary:assetLibrary1];

    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setUpViews];
    // Do any additional setup after loading the view.
    
}
-(void)setUpViews {
    

    
    topBar =[[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 64+topSpace)];
    [topBar setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:topBar];
    
    UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 20+topSpace, 44, 44);
    [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:backButton];
    
    UIButton *tickButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    tickButton.frame = CGRectMake(Devicewidth-44, 20+topSpace, 44, 44);
    [tickButton setImage:[UIImage imageNamed:@"navigation_done"] forState:UIControlStateNormal];
    [tickButton addTarget:self action:@selector(sumbitClicked) forControlEvents:UIControlEventTouchUpInside];
    [topBar addSubview:tickButton];

    
    NSMutableString *fullName = [[NSMutableString alloc] init];
    if(sharedModel.userProfile.fname.length >0)
        [fullName appendString:sharedModel.userProfile.fname];
    if(sharedModel.userProfile.lname.length >0)
    {
        if(fullName.length > 0)
            [fullName appendString:@" "];
        [fullName appendString:sharedModel.userProfile.lname];
    }
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20+topSpace, Devicewidth-100, 44)];
    [titleLabel setText:fullName];
    [titleLabel setTextColor:[UIColor grayColor]];
    titleLabel.font = [UIFont fontWithName:@"Anton" size:20.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [topBar addSubview:titleLabel];
    
    topBar.layer.shadowOpacity = 0.5;
    topBar.layer.shadowOffset =  CGSizeMake(0, 1.0);
    topBar.layer.shadowRadius = 2.0;
    topBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    scrollView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, topBar.frame.size.height+topSpace, Devicewidth, Deviceheight -topBar.frame.size.height )];
    [self.view addSubview:scrollView];
    
    profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake((Devicewidth-150)/2, 20, 150, 150)];
    [scrollView addSubview:profileImageView];
    [profileImageView setBackgroundColor:[UIColor colorWithRed:95/255.0 green:167/255.0 blue:239/255.0 alpha:1.0]];
    
    if(sharedModel.userProfile.photograph.length)
        [profileImageView setImageWithURL:[NSURL URLWithString:sharedModel.userProfile.photograph]];
    else
    {
        UIImageView *camImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [scrollView addSubview:camImage];
        camImage.center = profileImageView.center;
        [camImage setImage:[UIImage imageNamed:@"camera"]];
    }
    
    UIButton *camButton = [UIButton buttonWithType:UIButtonTypeCustom];
    camButton.frame = profileImageView.frame;
    [camButton addTarget:self action:@selector(editPhotoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:camButton];
    
    [[UIFloatLabelTextField appearance] setBackgroundColor:[UIColor whiteColor]];
    
    fnameTxtField = [[UIFloatLabelTextField alloc] initWithFrame:CGRectMake(10, profileImageView.frame.size.height+profileImageView.frame.origin.y+10, (Devicewidth-25)/2,40)];
    fnameTxtField.delegate = self;
    fnameTxtField.textColor = UIColorFromRGB(0x2b78e4);
    fnameTxtField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    fnameTxtField.floatLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    fnameTxtField.floatLabelActiveColor = UIColorFromRGB(0x2b78e4);
    fnameTxtField.placeholder = @"First Name";
    [scrollView addSubview:fnameTxtField];
    
    if(sharedModel.userProfile.fname)
        fnameTxtField.text = sharedModel.userProfile.fname;
    
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

    lnameTxtField = [[UIFloatLabelTextField alloc] initWithFrame:CGRectMake((Devicewidth-25)/2+15, profileImageView.frame.size.height+profileImageView.frame.origin.y+10, (Devicewidth-25)/2,40)];
    lnameTxtField.delegate = self;
    lnameTxtField.textColor = UIColorFromRGB(0x2b78e4);
    lnameTxtField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    lnameTxtField.floatLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    lnameTxtField.floatLabelActiveColor = UIColorFromRGB(0x2b78e4);
    lnameTxtField.placeholder = @"Last Name";
    [scrollView addSubview:lnameTxtField];
    
    if(sharedModel.userProfile.lname)
        lnameTxtField.text = sharedModel.userProfile.lname;
    
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

    
    
    emailTxtField = [[UIFloatLabelTextField alloc] initWithFrame:CGRectMake(10, lnameTxtField.frame.size.height+lnameTxtField.frame.origin.y+20, Devicewidth-20,40)];
    emailTxtField.delegate = self;
    emailTxtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailTxtField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    emailTxtField.floatLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    emailTxtField.keyboardType = UIKeyboardTypeEmailAddress;
    emailTxtField.textColor = UIColorFromRGB(0x2b78e4);
    emailTxtField.floatLabelActiveColor = UIColorFromRGB(0x2b78e4);
    emailTxtField.placeholder = @"Email";
    [scrollView addSubview:emailTxtField];
    
    
    if(sharedModel.userProfile.email)
        emailTxtField.text = sharedModel.userProfile.email;
    
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
    
}
-(void)backClicked {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)editPhotoButtonPressed:(id)sender
{
    
 
    UIActionSheet *addImageActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                          @"Take photo", @"Choose existing", nil];
    addImageActionSheet.tag = 1000;
    [addImageActionSheet setDelegate:self];
    [addImageActionSheet showInView:[UIApplication sharedApplication].keyWindow];

    
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
                changedImage = image;
                
                
                for(UIView *view in profileImageView.subviews)
                    [view removeFromSuperview];
                profileImageView.image = changedImage;
                
                
            }
            else
            {
                UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
                changedImage = image;
                
                for(UIView *view in profileImageView.subviews)
                    [view removeFromSuperview];
                profileImageView.image = changedImage;

                
            
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
    
    changedImage = nil;
    image = [photoUtils compressForUpload:image :0.67];
    
    
    NSData *imageData1 = UIImageJPEGRepresentation(image, 0.7);
    
    NSString *imageExtension = @"JPEG";
    
    
    NSString *imageDataEncodedeString = [imageData1 base64EncodedString];
    [self sendImageInfoToServerWithName:[NSString stringWithFormat:@"temp.%@",imageExtension] contentType:[NSString stringWithFormat:@"image/%@",[imageExtension lowercaseString]] content:imageDataEncodedeString];

}

#pragma mark- ImageUploading to server

-(void)sendImageInfoToServerWithName:(NSString *)name contentType:(NSString *)contentType content:(NSString *)content
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
    }
    else
    {
        
        isChangeImageApiInProgress = YES;
        
        AccessToken  *token          = sharedModel.accessToken;
        UserProfile  *_userProfile   = sharedModel.userProfile;
        
        NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
        [bodyRequest setValue:_userProfile.kl_id          forKey:@"profile_id"];
        [bodyRequest setValue:name                                   forKey:@"name"];
        [bodyRequest setValue:contentType                                forKey:@"content_type"];
        [bodyRequest setValue:content                                forKey:@"content"];
        
        NSMutableDictionary *finalRequest = [[NSMutableDictionary alloc]init];
        [finalRequest setValue:token.access_token       forKey:@"access_token"];
        [finalRequest setValue:_userProfile.auth_token  forKey:@"auth_token"];
        [finalRequest setValue:@"change_photograph"     forKey:@"command"];
        [finalRequest setValue:bodyRequest              forKey:@"body"];
        
        NSError *error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:finalRequest options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@v2/document-vault",BASE_URL]]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setHTTPBody:jsonData];
        
        // Create url connection and fire request
        //NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        //[conn start];
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue currentQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
         {
             
             isChangeImageApiInProgress = NO;
             if(!isUpdateApiInProgress)
                 [SVProgressHUD dismiss];
             
             if (connectionError)
             {
                 
                 //401 REPLACE WITH ERROR CODE
                 
             }
             else if (data != nil)
             {
                 NSError *error;
                 NSMutableDictionary *dictionaryResponseAll = [NSJSONSerialization JSONObjectWithData:data //1
                                                                                              options:kNilOptions
                                                                                                error:&error];
                 DebugLog(@"dictionaryResponseAll=%@",dictionaryResponseAll);
                 if(dictionaryResponseAll==nil)
                 {
                     UIAlertView *wrongFormatImage = [[UIAlertView alloc]initWithTitle:nil message:@"Error at server, try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
                     
                     [wrongFormatImage show];
                     return;
                     
                 }
                 NSNumber *validResponseStatus = [dictionaryResponseAll valueForKey:@"status"];
                 NSString *stringStatus1 = [validResponseStatus stringValue];
                 
                 if ([stringStatus1 isEqualToString:@"200"])
                 {
                     sharedModel.userProfile.photograph = [[dictionaryResponseAll valueForKey:@"body"] valueForKey:@"photograph"];
                     
                     NSMutableDictionary *profilesListResponse = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userProfile"] mutableCopy];
                     NSMutableDictionary *body = [[profilesListResponse valueForKey:@"body"] mutableCopy];
                     NSMutableDictionary *dic = [[[profilesListResponse valueForKey:@"body"] valueForKey:@"profile"] mutableCopy];
                     [dic setObject:[[dictionaryResponseAll valueForKey:@"body"] valueForKey:@"photograph"] forKey:@"photograph"];
                     
                     [body setObject:dic forKey:@"profile"];
                     [profilesListResponse setObject:body forKey:@"body"];
                     
                     [[NSUserDefaults standardUserDefaults] setObject:profilesListResponse forKey:@"userProfile"];
                 }
             }
         }];
    }
}


-(void)sumbitClicked
{
    [emailTxtField  resignFirstResponder];
    [fnameTxtField   resignFirstResponder];
    [lnameTxtField resignFirstResponder];
    
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
    }
    else
    {
        if([self validateFields:fnameTxtField] && [self validateFields:lnameTxtField] && [self validateFields:emailTxtField])
        {
            [SVProgressHUD show];
            
            isUpdateApiInProgress = YES;
            
            if(changedImage) {
                [self finishedTakingImage:changedImage];
                
            }
            AccessToken  *token          = sharedModel.accessToken;
            UserProfile  *_userProfile   = sharedModel.userProfile;
            
            NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
            
            [bodyRequest setValue:fnameTxtField.text                 forKey:@"fname"];
            [bodyRequest setValue:lnameTxtField.text                forKey:@"lname"];
            [bodyRequest setValue:emailTxtField.text                  forKey:@"email"];
            
            NSMutableDictionary *postData = [[NSMutableDictionary alloc]init];
            [postData setValue:token.access_token               forKey:@"access_token"];
            [postData setValue:_userProfile.auth_token          forKey:@"auth_token"];
            [postData setValue:@"update_parent"            forKey:@"command"];
            [postData setValue:bodyRequest                      forKey:@"body"];
            
            NSDictionary *userInfo = @{@"command":@"update_parent"};
            NSString *urlAsString = [NSString stringWithFormat:@"%@profiles/%@",BASE_URL, _userProfile.kl_id];
            
            NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
            API *api = [[API alloc] init];
            [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {

                [self receivedJSON:[json objectForKey:@"response"]];
                
            } failure:^(NSDictionary *json) {
                
                [self fetchingJSONFailedWithError:json];
            }];
        }
        else
        {
            [self validationAlert:ALL_FIELDS_REQUIRED];
        }
    }
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
- (BOOL)validateFields:(UITextField *)textField
{
    NSString *trimvalue;
    BOOL isValidField;
    trimvalue = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    isValidField = trimvalue.length > 0;
    return isValidField;
}

- (void)receivedJSON:(NSDictionary *)jsonResponse
{
    NSNumber *validResponseStatus = [jsonResponse valueForKey:@"status"];
    NSString *stringStatus1 = [validResponseStatus stringValue];
    if ([stringStatus1 isEqualToString:@"200"])
    {
        id profiles = [Factory userProfileFromJSON:jsonResponse];
     
        sharedModel.userProfile = [profiles objectAtIndex:0];
        
        NSMutableString *fullName = [[NSMutableString alloc] init];
        if(sharedModel.userProfile.fname.length >0)
            [fullName appendString:sharedModel.userProfile.fname];
        if(sharedModel.userProfile.lname.length >0)
        {
            if(fullName.length > 0)
                [fullName appendString:@" "];
            [fullName appendString:sharedModel.userProfile.lname];
        }
        titleLabel.text  = fullName;
    }
    
    if(!isChangeImageApiInProgress)
        [SVProgressHUD dismiss];
    
    isUpdateApiInProgress = NO;
}

- (void)fetchingJSONFailedWithError:(NSDictionary *)jsonResponse
{
    if([jsonResponse objectForKey:@"message"])
        [self validationAlert:[jsonResponse objectForKey:@"message"]];
    else {
        [self validationAlert:[jsonResponse objectForKey:@"There is an error in updating. Please try again."]];
    }
    
    isUpdateApiInProgress = NO;
    
    if(!isChangeImageApiInProgress)
        [SVProgressHUD dismiss];
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
    
    scrollView.contentOffset = CGPointMake(0, 0);
}
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    scrollView.contentOffset = CGPointMake(0, 0);
    [textField resignFirstResponder];
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
