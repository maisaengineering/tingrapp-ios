//
//  PostDetailedViewController.m
//  Tingr
//
//  Created by Maisa Pride on 7/29/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "PostDetailedViewController.h"
#import "UIImageViewAligned.h"
#import "VideoPlayer.h"
#import "ProfileDateUtils.h"

@interface PostDetailedViewController ()
{
    
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *profileDateUtils;
    ModelManager *sharedModel;
    SingletonClass *singletonObject;
    
    UIScrollView *imagesScrollView;
    
    CGFloat maxHeaderHeight;
    CGFloat minHeaderHeight;
    CGFloat previousScrollOffset;
    UILabel *titleLabel;
    
    UIButton *addHeartBtn;
    
    UIView *tableHeaderView;
    CGRect originalPostion;
    UIView *inputView1;
    CGRect keyboardFrameBeginRect;
    UILabel *placeholderLabel;

    UIView *drawingView;
    
    UIView *overlay;
    UITableView *heartTableView;
    NSArray *heartersList;
    
    BOOL animated;
    float topSpace;
    float bottomSpace;
    
}
@end

@implementation PostDetailedViewController
@synthesize post;
@synthesize messageDetailTableView;
@synthesize showComment;
@synthesize post_ID;
@synthesize comment_ID;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    topSpace = 0;
    bottomSpace = 0;
    if(appDelegate.topSafeAreaInset > 0)
    {
        topSpace = 15;
        bottomSpace = 30;
    }

    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    sharedModel   = [ModelManager sharedModel];
    singletonObject = [SingletonClass sharedInstance];
    photoUtils = [ProfilePhotoUtils alloc];
    profileDateUtils = [ProfileDateUtils alloc];
    self.mediaFocusManager = [[ASMediaFocusManager alloc] init];
    self.mediaFocusManager.delegate = self;

    
    
    maxHeaderHeight = 300;
    minHeaderHeight = 64+topSpace;
    previousScrollOffset = 0;
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    if(self.post.count > 0) {

        [self setUpViews];
    }
    
    [self callPostFullAPI];
 
}
-(void)callPostFullAPI {
   
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedin"])
    {
        NSString *kl_id;
        
        if(self.post.count > 0) {
            
            kl_id = [NSString stringWithFormat:@"%@",[self.post objectForKey:@"kl_id"]];
            int count = [[self.post objectForKey:@"view_count"] intValue];
            [self.post setObject:[NSNumber numberWithInt:count+1] forKey:@"view_count"];

        }
        else if(self.post_ID.length > 0) {
            
            kl_id = [NSString stringWithFormat:@"%@",self.post_ID];
            
            [SVProgressHUD show];
        }
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
     NSString* command = @"post_view";
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": command,
                               @"body":@{@"post_klid": kl_id}
                               };
    
    NSDictionary *userInfo = @{@"command":command};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        if(self.post_ID.length > 0) {
            
            NSDictionary *body = [[json objectForKey:@"response"] objectForKey:@"body"];
            self.post = [[body objectForKey:@"post"] mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setUpViews];
            });

        }
        
        [SVProgressHUD dismiss];
        
        
    } failure:^(NSDictionary *json) {
        
        [SVProgressHUD dismiss];
    }];
        
    }
    
    
}
-(void)viewDidAppear:(BOOL)animate {
    
   
    if(showComment) {
     
        [self animateTopUp];
        animated = TRUE;
        [_txt_comment becomeFirstResponder];
        
    }
}
-(void)setUpViews {
    
    messageDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, maxHeaderHeight, Devicewidth, Deviceheight-maxHeaderHeight-60-bottomSpace)];
    messageDetailTableView.delegate = self;
    messageDetailTableView.tableFooterView = [UIView new];
    messageDetailTableView.dataSource = self;
    messageDetailTableView.backgroundColor  = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0];
    messageDetailTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:messageDetailTableView];
    messageDetailTableView.tableHeaderView  = [self headerView];


    
    tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth,maxHeaderHeight)];
    tableHeaderView.clipsToBounds = YES;
    tableHeaderView.backgroundColor = UIColorFromRGB(0x99CCFF);
    [self.view addSubview:tableHeaderView];

    imagesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 300)];
    [tableHeaderView addSubview:imagesScrollView];
    
    if([[self.post objectForKey:@"images"] count] >0) {
        
        imagesScrollView.pagingEnabled = YES;
        NSArray *imagesArray = [self.post objectForKey:@"images"];
        
        for(int i = 0; i < imagesArray.count; i++) {
            
            NSString *imageUrl = [imagesArray objectAtIndex:i];
            UIImageViewAligned *attachedImage = [[UIImageViewAligned alloc] init];
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*imagesScrollView.frame.size.width, 0, imagesScrollView.frame.size.width,imagesScrollView.frame.size.height)];
            [imagesScrollView addSubview:nameLabel];
            
            NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Bold" size:100]};
            NSMutableAttributedString *attributesString = [[NSMutableAttributedString alloc] initWithString:@"TINGR" attributes:attributes];
            
            
            NSRange range;
            range.location = 3;
            range.length = 2;
            [attributesString setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Light" size:100]}
                                      range:range];
            [nameLabel setAttributedText:attributesString];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            
            
            
            
            attachedImage.frame = CGRectMake(i*imagesScrollView.frame.size.width, 0, imagesScrollView.frame.size.width,imagesScrollView.frame.size.height);
            attachedImage.contentMode = UIViewContentModeScaleAspectFill;
            attachedImage.clipsToBounds = YES;
            attachedImage.tag = i;
            attachedImage.alignment = UIImageViewAlignmentMaskCenter;
            [imagesScrollView addSubview:attachedImage];
            if([imageUrl rangeOfString:@".gif" options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                __weak UIImageView *weakSelf = attachedImage;
                
                UIImage *thumb = [photoUtils getGIFImageFromCache:imageUrl];
                
                if(thumb ==nil)
                {
                    dispatch_queue_t myQueue = dispatch_queue_create("imageque",NULL);
                    dispatch_async(myQueue, ^{
                        NSData *data =  [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
                        UIImage *gif_image = [UIImage animatedImageWithAnimatedGIFData:data];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.image = gif_image;
                            [photoUtils saveImageToCacheWithData:imageUrl :data];
                            
                            
                        });
                    });
                }
                else
                {
                    weakSelf.image = thumb;
                }
                
                UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
                [playButton setFrame:attachedImage.frame];
                playButton.tag = i;
                [playButton addTarget:self action:@selector(playButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
                [imagesScrollView addSubview:playButton];
            }
            else {
                
                [attachedImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
                
                [self.mediaFocusManager installOnView:attachedImage];
                
            }
            
            if(imagesArray.count > 1) {
                
                CGRect frame = attachedImage.frame;
                frame.size.height -= 30;
                attachedImage.frame = frame;
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((i*imagesScrollView.frame.size.width)+(imagesScrollView.frame.size.width - 70)/2, imagesScrollView.frame.size.height-25, 70, 25)];
                label.text = [NSString stringWithFormat:@"%i of %lu",i+1,(unsigned long)imagesArray.count];
                label.textColor = [UIColor grayColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
                [imagesScrollView addSubview:label];
                
                
                CGRect rect = label.frame;
                
                rect.size.height -= 5;
                UIBezierPath * linePath = [UIBezierPath bezierPath];
                
                // start at top left corner
                [linePath moveToPoint:CGPointMake(0,rect.size.height)];
                [linePath addLineToPoint:CGPointMake(rect.size.width, rect.size.height)];
                
                CAShapeLayer * lineLayer = [CAShapeLayer layer];
                lineLayer.lineWidth = 2;
                lineLayer.strokeColor = [UIColor grayColor].CGColor;
                
                lineLayer.fillColor = nil;
                lineLayer.path = linePath.CGPath;
                [label.layer addSublayer:lineLayer];
                
                
            }
        }
        
        
        imagesScrollView.bounces = NO;
        imagesScrollView.showsHorizontalScrollIndicator = NO;
        imagesScrollView.contentSize =CGSizeMake(imagesScrollView.frame.size.width*imagesArray.count,imagesScrollView.frame.size.height );

    }
    
    NSString *byText = [NSString stringWithFormat:@" by %@ ",[self.post objectForKey:@"author_name"]];
    UILabel *byLabel = [[UILabel alloc] init];
    byLabel.text = byText;
    byLabel.backgroundColor = [UIColor whiteColor];
    [byLabel setFont:[UIFont fontWithName:@"Anton" size:16]];
    NSDictionary *attribs = @{
                              NSFontAttributeName: [UIFont fontWithName:@"Anton" size:16]
                              };
    
    CGSize expectedLabelSize = [byText boundingRectWithSize:CGSizeMake(Devicewidth-20, 25) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;

    byLabel.frame = CGRectMake(10, imagesScrollView.bounds.size.height - 85, expectedLabelSize.width+4, 25);
    [imagesScrollView addSubview:byLabel];

    
    
    NSString *storyDate = [self.post objectForKey:@"created_at"];
    NSMutableString *formattedTime = [[profileDateUtils dailyLanguageForMilestone:storyDate actualTimeZone:[self.post objectForKey:@"tzone"]] mutableCopy];
    NSString *timeString  = [NSString stringWithFormat:@" posted on %@ ",formattedTime];

    UILabel *timeLabel = [[UILabel alloc] init];
    NSDictionary *attribs1 = @{
                              NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:14],
                              NSForegroundColorAttributeName:[UIColor grayColor]
                              
                              };
    
    NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:timeString attributes:attribs1];
    
    NSRange range = [tncString.string rangeOfString:formattedTime];
    
    // workaround for bug in UIButton - first char needs to be underlined for some reason!
    [tncString addAttribute:NSUnderlineStyleAttributeName
                      value:@(NSUnderlineStyleSingle)
                      range:range];

    
    
     expectedLabelSize = [timeString boundingRectWithSize:CGSizeMake(Devicewidth-20, 20) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs1 context:nil].size;
    timeLabel.attributedText = tncString;
    timeLabel.backgroundColor = [UIColor whiteColor];
    [timeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    timeLabel.frame = CGRectMake(10, imagesScrollView.bounds.size.height - 60, expectedLabelSize.width, 20);
    [imagesScrollView addSubview:timeLabel];
    
    
    UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 20+topSpace, 44, 44);
    [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    
    
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, maxHeaderHeight-44, Devicewidth-60, 44)];
        titleLabel.text = [self.post objectForKey:@"new_title"];
        titleLabel.font = [UIFont fontWithName:@"Helvetica" size:22];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor =  [UIColor clearColor];
        titleLabel.alpha = 0;
        [tableHeaderView addSubview:titleLabel];
    [self createMessageView];
    
}


-(void)createMessageView {
    
    self.commentView = [[UIView alloc] initWithFrame:CGRectMake(0, Deviceheight - 60 - bottomSpace, Devicewidth, 60+bottomSpace)];
    self.commentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.commentView];
    self.txt_comment = [[UITextView alloc] initWithFrame:CGRectMake(2, 0, Devicewidth-50, 60)];
    self.txt_comment.delegate = self;
    [self.txt_comment setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    
    [self.commentView addSubview:self.txt_comment];
    
    UIView *lineView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 0.5)];
    lineView.backgroundColor = [UIColor grayColor];
    [self.commentView addSubview:lineView];
    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0, self.txt_comment.frame.size.width - 15.0, 60)];
    //[placeholderLabel setText:placeholder];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setNumberOfLines:0];
    placeholderLabel.text = @"enter your comment here...";
    [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
    [placeholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:14]];
    [placeholderLabel setTextColor:[UIColor colorWithRed:113/255.0 green:113/255.0 blue:113/255.0 alpha:1.0]];
    [self.txt_comment addSubview:placeholderLabel];
    
    
    //Upvote
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setFrame:CGRectMake(Devicewidth-50, 0, 50, 60)];
    [sendBtn setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
    [sendBtn setTitle:@"SEND" forState:UIControlStateNormal];
    [sendBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [sendBtn addTarget:self action:@selector(sendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.commentView addSubview:sendBtn];
    
    
    inputView1 =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [inputView1 setBackgroundColor:[UIColor colorWithRed:0.56f
                                                   green:0.59f
                                                    blue:0.63f
                                                   alpha:1.0f]];
    UIButton *donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn setFrame:CGRectMake(Devicewidth-70, 0, 70, 40)];
    [donebtn setTitle:@"Done" forState:UIControlStateNormal];
    [donebtn.titleLabel setFont:[UIFont fontWithName:@"SanFranciscoText-Medium" size:15]];
    [donebtn addTarget:self action:@selector(doneClick:) forControlEvents:UIControlEventTouchUpInside];
    [inputView1 addSubview:donebtn];
    
}
-(UIView *)headerView {
    
    drawingView = [[UIView alloc] init];
    drawingView.backgroundColor = [UIColor whiteColor];
    float yPosition = 0;
    UIView *tagsAndLikesView;
    UILabel *descriptionLabel;
    tagsAndLikesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 30)];
    
    
    UIScrollView *tagScrollView;
    if([[self.post objectForKey:@"tagged_to"] count] > 0)
    {
        tagScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(2, 0, tagsAndLikesView.frame.size.width-32, 30)];
        [tagsAndLikesView addSubview:tagScrollView];
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:[self.post objectForKey:@"tagged_to"]];
        int x = 0;
        
        for(int i = 0; i < array.count; i++)
            //for(id dict in array)
        {
            
            id dict = [array objectAtIndex:i];
            NSString *url;
            UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(x, 5, 20, 20)];
            [tagScrollView addSubview:imagVw];
            
            [imagVw setImage:[UIImage imageNamed:@"EmptyProfile.png"]];
            //add initials
            
            NSMutableString *parentFnameInitial = [[NSMutableString alloc] init];
            if([dict valueForKey:@"nickname"] != (id)[NSNull null] && [[dict valueForKey:@"nickname"] length] > 0)
            {
                [parentFnameInitial appendString:[[[dict valueForKey:@"nickname"] substringToIndex:1] uppercaseString]];
            }
            else
            {
                if([dict valueForKey:@"fname"] != (id)[NSNull null] && [[dict valueForKey:@"fname"] length] >0)
                    [parentFnameInitial appendString:[[[dict valueForKey:@"fname"] substringToIndex:1] uppercaseString]];
                if([dict valueForKey:@"lname"] != (id)[NSNull null] && [[dict valueForKey:@"lname"] length]>0)
                    [parentFnameInitial appendString:[[[dict valueForKey:@"lname"] substringToIndex:1] uppercaseString]];
            }
            
            NSMutableAttributedString *attributedText =
            [[NSMutableAttributedString alloc] initWithString:parentFnameInitial
                                                   attributes:nil];
            NSRange range;
            if(parentFnameInitial.length > 0)
            {
                range.location = 0;
                range.length = 1;
                [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Bold" size:10]}
                                        range:range];
            }
            if(parentFnameInitial.length > 1)
            {
                range.location = 1;
                range.length = 1;
                [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Light" size:10]}
                                        range:range];
            }
            
            
            //add initials
            
            UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            initial.attributedText = attributedText;
            [initial setBackgroundColor:[UIColor clearColor]];
            initial.textAlignment = NSTextAlignmentCenter;
            [imagVw addSubview:initial];
            
            //end add initials
            
            if([dict isKindOfClass:[NSDictionary class]])
                url  = [dict objectForKey:@"photograph"];
            else if([dict isKindOfClass:[NSString class]])
                url = dict;
            if(url != (id)[NSNull null] && url.length > 0)
            {
                UIImage *thumb = [photoUtils getImageFromCache:url];
                __weak UIImageView *weakSelf = imagVw;
                if (thumb == nil)
                {
                    // Fetch image, cache it, and add it to the tag.
                    [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                     {
                         [photoUtils saveImageToCache:url :image];
                         [weakSelf setImage:[UIImage imageNamed:@"EmptyProfile.png"]];
                         UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                         userImage.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(15, 15)] withRadious:0];
                         [weakSelf addSubview:userImage];
                         [initial removeFromSuperview];
                     }
                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                     {
                         DebugLog(@"fail");
                     }];
                }
                else
                {
                    // Add cached image to the tag.
                    [weakSelf setImage:[UIImage imageNamed:@"EmptyProfile.png"]];
                    UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                    userImage.image = [photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:thumb scaledToSize:CGSizeMake(15, 15)] withRadious:0];
                    [weakSelf addSubview:userImage];
                    [initial removeFromSuperview];
                }
                
            }
            
            x+= 22;
        }
        
        tagScrollView.contentSize = CGSizeMake(22*array.count, 30);
    }
    
    
    addHeartBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addHeartBtn addTarget:self action:@selector(heartBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if([[self.post objectForKey:@"hearts_count"] intValue] == 0)
    {
        [addHeartBtn setBackgroundImage:[UIImage imageNamed:@"hearted_fill"] forState:UIControlStateNormal];
        [addHeartBtn setTitle:@"" forState:UIControlStateNormal];
    }
    else
    {
        [addHeartBtn setBackgroundImage:[UIImage imageNamed:@"hearted_unfill"] forState:UIControlStateNormal];
        [addHeartBtn setTitleColor:[UIColor colorWithRed:240/255.0 green:203/255.0f blue:91/255.0 alpha:1.0] forState:UIControlStateNormal];
        [addHeartBtn.titleLabel  setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:8]];
        [addHeartBtn setTitle:[NSString stringWithFormat:@"%i+",[[self.post objectForKey:@"hearts_count"] intValue]] forState:UIControlStateNormal];
    }
    
    [addHeartBtn setFrame:CGRectMake(tagsAndLikesView.frame.size.width-30, 1, 28, 28)];
    [tagsAndLikesView addSubview:addHeartBtn];
    
    [drawingView addSubview:tagsAndLikesView];
    yPosition += 30;
    
    NSString *title = [self.post objectForKey:@"new_title"];
    if(title.length) {
        
        NSDictionary *attribs1 = @{
                                   NSFontAttributeName: [UIFont fontWithName:@"Anton" size:16],
                                   NSForegroundColorAttributeName:[UIColor blackColor]
                                   
                                   };
        
        NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:title attributes:attribs1];
        
        NSRange range = [tncString.string rangeOfString:title];
        
        // workaround for bug in UIButton - first char needs to be underlined for some reason!
        [tncString addAttribute:NSUnderlineStyleAttributeName
                          value:@(NSUnderlineStyleSingle)
                          range:range];
        
        
        
        
        UILabel *textTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, yPosition, Devicewidth, 30)];
        textTitleLabel.attributedText = tncString;
        [drawingView addSubview:textTitleLabel];
        
        yPosition += 30;
        
    }
    
    if([[self.post objectForKey:@"text"] length] >0) {
        
        NSString *description = [NSString stringWithFormat:@"%@",[self.post objectForKey:@"text"]];
        
        NSDictionary *attribs = @{
                                  NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:14]
                                  };
        
        ;
        
        CGSize expectedLabelSize = [description boundingRectWithSize:CGSizeMake(Devicewidth-6, 9999) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, yPosition+2, Devicewidth, expectedLabelSize.height)];
        descriptionLabel.text = description;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        descriptionLabel.textColor = [UIColor grayColor];
        [drawingView addSubview:descriptionLabel];
        
        yPosition += expectedLabelSize.height+4;
    }
    
    NSArray *commentsArray = [self.post objectForKey:@"comments"];
    if(commentsArray.count > 1)
    {
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yPosition, Devicewidth, 30)];
        descriptionLabel.text = @"showing all comments";
        descriptionLabel.font = [UIFont fontWithName:@"Anton" size:14];
        descriptionLabel.textColor = [UIColor grayColor];
        descriptionLabel.textAlignment = NSTextAlignmentCenter;
        [descriptionLabel setBackgroundColor:[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]];
        
        [drawingView addSubview:descriptionLabel];
        
        yPosition += 30;
        
    }
    
    drawingView.frame  = CGRectMake(0, 0, Devicewidth, yPosition);

    return drawingView;
}
-(void)backClicked {
    
    [self.delegate changedDetails:self.post];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)playButtonTapped:(UIButton *)button {
    
    
    NSString *originalImage = [NSString stringWithFormat:@"%@",[[self.post objectForKey:@"large_images"] objectAtIndex:button.tag]];
    NSURL *url = [NSURL URLWithString:originalImage];
    
    VideoPlayer *videoPLayer = [VideoPlayer alloc];
    videoPLayer.url = url;
    if([[self.post objectForKey:@"tagged_to"] count] == 1)
    {
        videoPLayer.canShowDownload = YES;
    }
    else
    {
        videoPLayer.canShowDownload = NO;
    }
    videoPLayer = [videoPLayer initWithFrame:CGRectMake(0, 0, Devicewidth, Deviceheight)];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:videoPLayer];
    
}
-(void)doneClick:(id)sender
{
    [self.txt_comment resignFirstResponder];
    messageDetailTableView.frame = originalPostion;
}

-(void)heartBtnAction:(UIButton *)sender
{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedin"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tingr"
                                                       message:@"you must login to continue..."
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        [alert show];

        
        return;
    }
    
    NSString *kl_id = [NSString stringWithFormat:@"%@",[self.post objectForKey:@"kl_id"]];
    
    BOOL isHeartStatus = [[self.post objectForKey:@"hearted"] boolValue];
    NSString *command = @"";
    int count = [[self.post objectForKey:@"hearts_count"] intValue];
    if  (!isHeartStatus)
    {
        
        [SVProgressHUD show];
        
        command = @"add_heart";
        //isHeartSelected = YES;
        [self.post setObject:[NSNumber numberWithBool:YES]  forKey:@"hearted"];
        [self.post setObject:[NSNumber numberWithInt:count+1] forKey:@"hearts_count"];
        
        AccessToken* token = sharedModel.accessToken;
        UserProfile *_userProfile = sharedModel.userProfile;
        
        // NSString* postCommand = @"add_heart";
        //build an info object and convert to json
        NSDictionary* postData = @{@"access_token": token.access_token,
                                   @"auth_token": _userProfile.auth_token,
                                   @"command": command,
                                   };
        
        NSDictionary *userInfo = @{@"command":command};
        
        
        NSString *urlAsString = [NSString stringWithFormat:@"%@v2/posts/%@",BASE_URL,kl_id];
        
        NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
        API *api = [[API alloc] init];
        [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
            [self heartSuccess:[json objectForKey:@"response"]];
            
        } failure:^(NSDictionary *json) {
            
            [SVProgressHUD dismiss];
            
        }];

        
    }
    else {
        
        addHeartBtn.userInteractionEnabled = NO;
        [self getHeartsList];
    }


    
}
-(void)heartSuccess:(NSDictionary *)json {
    
    [SVProgressHUD dismiss];
    
        [addHeartBtn setBackgroundImage:[UIImage imageNamed:@"hearted_unfill"] forState:UIControlStateNormal];
        [addHeartBtn setTitleColor:[UIColor colorWithRed:240/255.0 green:203/255.0f blue:91/255.0 alpha:1.0] forState:UIControlStateNormal];
        [addHeartBtn.titleLabel  setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:8]];
        [addHeartBtn setTitle:[NSString stringWithFormat:@"%i+",[[self.post objectForKey:@"hearts_count"] intValue]] forState:UIControlStateNormal];
        
    [drawingView setNeedsDisplay];
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {

    if(scrollView == messageDetailTableView)
    {
        [_txt_comment resignFirstResponder];
        [self tableScrolled:scrollView.contentOffset.y];
    }

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
        
        
        originalPostion = CGRectMake(0, minHeaderHeight, Devicewidth, Deviceheight-minHeaderHeight);
        tableHeaderView.frame = CGRectMake(0, -(maxHeaderHeight-minHeaderHeight), Devicewidth, maxHeaderHeight);
        titleLabel.alpha = 1;
        imagesScrollView.alpha = 0;
        
        messageDetailTableView.frame  = CGRectMake(0, minHeaderHeight, Devicewidth, Deviceheight-minHeaderHeight-60);
        
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
                         messageDetailTableView.frame  = CGRectMake(0, maxHeaderHeight, Devicewidth, Deviceheight-maxHeaderHeight-60);
                         titleLabel.alpha = 0;
                         imagesScrollView.alpha = 1;
                     }
     ];
    
    
    
}




#pragma mark
#pragma KeyBoard Notification Methods
- (void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGRect frame = messageDetailTableView.frame;
    frame.size.height -= keyboardFrameBeginRect.size.height;
    messageDetailTableView.frame = frame;
}
-(void) keyboardWillShow:(NSNotification *)note{
    
    [self animateTopUp];
    
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = Deviceheight - (keyboardBounds.size.height + containerFrame.size.height);
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = Deviceheight - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    self.commentView.frame = containerFrame;
    
    
    // commit animations
    [UIView commitAnimations];
    
    messageDetailTableView.frame = originalPostion;
}

#pragma mark -
#pragma mark TextView Delegate Methods
- (void)textViewDidBeginEditing:(UITextView *)textView1
{
    [placeholderLabel removeFromSuperview];
    [textView1 setInputAccessoryView:inputView1];
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView1
{
    
    [textView1 setInputAccessoryView:inputView1];
    [placeholderLabel removeFromSuperview];
    
    return YES;
    
    
}
- (void)textViewDidEndEditing:(UITextView *)txtView
{
    if (![txtView hasText])
        [txtView addSubview:placeholderLabel];
}
- (void)textViewDidChange:(UITextView *)textView1
{
    if(![textView1 hasText])
    {
        [textView1 addSubview:placeholderLabel];
    }
    else if ([[textView1 subviews] containsObject:placeholderLabel])
    {
        [placeholderLabel removeFromSuperview];
        
    }
    
}

-(void)textChangedCustomEvent
{
    [placeholderLabel removeFromSuperview];
    
}

#pragma mark -
#pragma TableVie Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView == messageDetailTableView) {
        
        NSArray *commentsArray = [self.post objectForKey:@"comments"];
        return commentsArray.count;
    }
    else {
        
        return heartersList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == messageDetailTableView) {
        
        
    NSArray *commentsArray = [self.post objectForKey:@"comments"];
    NSDictionary *detailsDict  = commentsArray[indexPath.row];

    
    NSString *text = [detailsDict objectForKey:@"content"];
    NSString *name = [detailsDict objectForKey:@"commented_by"];
    
    float leftSideHeight = 50;
    float rightSideHeight = 70;
    float height = 25;
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:14]};
    
    CGRect rect = [name boundingRectWithSize:CGSizeMake(56, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    
    leftSideHeight += rect.size.height;
    
    
    NSDictionary *attributes1 = @{NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Light" size:14]};
    
    
    
    CGRect rect2 = [text boundingRectWithSize:CGSizeMake(Devicewidth-60-5-5, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributes1
                                      context:nil];
    
    if(rect2.size.height+5 > rightSideHeight)
        rightSideHeight = rect2.size.height+5;
    
    height += leftSideHeight > rightSideHeight ? leftSideHeight: rightSideHeight;
    
    
    
    return height+10;
        
    }
    else {
        
        return 50;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == messageDetailTableView)
    {
    static NSString *simpleTableIdentifier = @"StreamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0]];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
    }
    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }
    
    NSArray *commentsArray = [self.post objectForKey:@"comments"];
    NSDictionary *detailsDict  = commentsArray[indexPath.row];
    

    NSString *text = [detailsDict objectForKey:@"content"];
    NSString *name = [detailsDict objectForKey:@"commented_by"];
    NSString *url = [detailsDict objectForKey:@"commenter_photo"];
    NSString *create_at = [detailsDict objectForKey:@"created_at"];
    
    
    NSString *formattedTime = [[profileDateUtils dailyLanguageForMilestone:create_at actualTimeZone:[self.post objectForKey:@"tzone"]] mutableCopy];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    NSDictionary *attribs = @{
                              NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14]
                              };
    
    CGSize expectedLabelSize = [formattedTime boundingRectWithSize:CGSizeMake(Devicewidth-16, 20) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
    timeLabel.text = formattedTime;
    timeLabel.textColor = [UIColor lightGrayColor];
    [timeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14]];
    timeLabel.frame = CGRectMake(Devicewidth-5-expectedLabelSize.width-3, 5, expectedLabelSize.width, 20);
    [cell.contentView addSubview:timeLabel];
    
    //Time Icon
    UIImageView *timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(timeLabel.frame.origin.x-13, 9, 12, 12)];
    [timeIcon setImage:[UIImage imageNamed:@"clock"]];
    [cell.contentView addSubview:timeIcon];
    
    
    
    
    
    UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(5, 30, 50, 50)];
    [imagVw setBackgroundColor:[UIColor whiteColor]];
    imagVw.layer.cornerRadius = 3;
    imagVw.layer.borderWidth = 0.5;
    imagVw.clipsToBounds = YES;
    imagVw.layer.borderColor = UIColorFromRGB(0x2b78e4).CGColor;
    //add initials
    
    NSString *firstName = [[name substringToIndex:1]uppercaseString];;
    
    
    NSMutableString *commenterInitial = [[NSMutableString alloc] init];
    [commenterInitial appendString:firstName];
    
    NSMutableAttributedString *attributedTextForComment = [[NSMutableAttributedString alloc] initWithString:commenterInitial attributes:nil];
    
    NSRange range;
    if(firstName.length > 0)
    {
        range.location = 0;
        range.length = 1;
        [attributedTextForComment setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:20]}
                                          range:range];
    }
    
    
    UILabel *initial = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    initial.attributedText = attributedTextForComment;
    [initial setBackgroundColor:[UIColor clearColor]];
    initial.textAlignment = NSTextAlignmentCenter;
    [imagVw addSubview:initial];
    //end add initials
    
    __weak UIImageView *weakSelf = imagVw;
    if(url != (id)[NSNull null] && url.length > 0)
    {
        // Fetch image, cache it, and add it to the tag.
        [imagVw setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             [weakSelf setImage:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(50, 50)]];
             [initial removeFromSuperview];
         }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
         {
             DebugLog(@"fail");
         }];
    }
    
    [cell.contentView addSubview:imagVw];
    
    float leftSideHeight = 50;
    
    
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:14]};
    
    CGRect rect = [name boundingRectWithSize:CGSizeMake(56, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes
                                     context:nil];
    
    leftSideHeight += rect.size.height;
    
    UILabel *nameLabel  = [[UILabel alloc] initWithFrame:CGRectMake(2, imagVw.frame.size.height + imagVw.frame.origin.y, 56, rect.size.height)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = name;
    nameLabel.numberOfLines = 0;
    nameLabel.textColor = [UIColor grayColor];
    nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    [cell.contentView addSubview:nameLabel];
    
    
    float rightSideHeight = 70;
    NSDictionary *attributes1 = @{NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Light" size:12]};
    
    
    
    CGRect rect2 = [text boundingRectWithSize:CGSizeMake(Devicewidth-60-5-5, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributes1
                                      context:nil];
    
    if(rect2.size.height+5 > rightSideHeight)
        rightSideHeight = rect2.size.height+5;
    
    UILabel *textLabel  = [[UILabel alloc] initWithFrame:CGRectMake(60, 25, Devicewidth-60-5, rightSideHeight+5)];
    textLabel.text = text;
    textLabel.numberOfLines = 0;
    textLabel.backgroundColor = [UIColor whiteColor];
    textLabel.textColor = [UIColor grayColor];
    textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:14];
    textLabel.layer.cornerRadius = 5;
    textLabel.clipsToBounds = YES;
    [cell.contentView addSubview:textLabel];
    
    
    
    return cell;
        
    }
    else {
        
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
        
      
            
            personDict  = [heartersList objectAtIndex:indexPath.row];
        
        
        
        kidFirstNameView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        kidFirstNameView.font =[UIFont fontWithName:@"Antonio-Bold" size:15]; //Archer-Bold
        kidFirstNameView.textColor = UIColorFromRGB(0x2b78e4);
        kidFirstNameView.textAlignment = NSTextAlignmentCenter;
        
        
        UIImageView *profileImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7.5, 35, 35)];
        [cell.contentView addSubview:profileImage];
        __weak UIImageView *weakSelf = profileImage;
        NSString *url = [personDict valueForKey:@"photograph_url"];
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
        
        
        NSMutableAttributedString *attributedText =
        [[NSMutableAttributedString alloc] initWithString:name
                                               attributes:nil];
        NSRange range;
        if(fname.length > 0)
        {
            range = [name rangeOfString:fname];
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]}
                                    range:range];
        }
        if(lname.length > 0)
        {
            range = [name rangeOfString:lname];
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor],NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:18]}
                                    range:range];
        }

        
        nameLabel.attributedText  = attributedText;

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, Devicewidth, 0.5)];
        [line setBackgroundColor:[UIColor lightGrayColor]];
        [cell.contentView addSubview:line];

        
        
        return cell;

    }
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
    
    if([[self.post objectForKey:@"tagged_to"] count] == 1)
    {
        self.mediaFocusManager.canShowDownload = YES;
    }
    else
    {
        self.mediaFocusManager.canShowDownload = NO;
    }
    

    
    NSURL *url;
    NSString *originalImage = [NSString stringWithFormat:@"%@",[self.post objectForKey:@"large_images"][view.tag]];
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


-(void)sendButtonTapped
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    NSString *networkStatus = [[SingletonClass sharedInstance] stringFromStatus:status];
    
    if ([networkStatus isEqualToString:@"Not Reachable"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tingr"
                                                       message:@"No internet connection. Please connect to network and try again"
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        [alert show];
    }
    else
    {
        if (_txt_comment.text.length >0)
        {
            
                [self callCommentAPIWithScope:@"public"];
            
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tingr"
                                                                message:@"Please write a comment"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
}
- (void)callCommentAPIWithScope:(NSString *)scope
{
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedin"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Tingr"
                                                       message:@"you must login to continue..."
                                                      delegate:self cancelButtonTitle:@"Ok"
                              
                                             otherButtonTitles:nil,nil];
        [alert show];
        
        
        return;
    }

    [SVProgressHUD show];
    AccessToken* token          = sharedModel.accessToken;
    UserProfile *_userProfile   = sharedModel.userProfile;
    
    NSMutableDictionary *bodyRequest = [[NSMutableDictionary alloc]init];
    [bodyRequest setValue:[self.post objectForKey:@"kl_id"]        forKey:@"post_klid"];
    [bodyRequest setValue:_txt_comment.text            forKey:@"content"];
    [bodyRequest setValue:scope                forKey:@"scope"];
    
    [_txt_comment resignFirstResponder];
    _txt_comment.text = @"";

    
    NSMutableDictionary *finalRequest = [[NSMutableDictionary alloc]init];
    [finalRequest setValue:token.access_token       forKey:@"access_token"];
    [finalRequest setValue:_userProfile.auth_token  forKey:@"auth_token"];
    [finalRequest setValue:@"add_comment"                forKey:@"command"];
    [finalRequest setValue:bodyRequest              forKey:@"body"];
    
    DebugLog(@"finalRequest:%@",finalRequest);
    NSString *urlString = [NSString stringWithFormat:@"%@comments",BASE_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSData *newAccountJSONData = [NSJSONSerialization dataWithJSONObject:finalRequest options:kNilOptions error:nil];
    [request setHTTPBody:newAccountJSONData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [SVProgressHUD dismiss];
         DebugLog(@"responseObject:%@",responseObject);
         NSNumber *validResponseStatus = [responseObject valueForKey:@"status"];
         NSString *stringStatus1 = [validResponseStatus stringValue];
         
         if ([stringStatus1 isEqualToString:@"200"])
         {
             //[HUD hide:YES];
             NSMutableArray *array = [[NSMutableArray alloc] init];
             [array addObjectsFromArray:[self.post objectForKey:@"comments"]];
             [array addObject:[responseObject objectForKey:@"body"]];
             [self.post setObject:array forKey:@"comments"];
             [messageDetailTableView reloadData];
             
                 [self scrollToBottom];

         }
         else
         {
             //[HUD hide:YES];
         }
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         
         [SVProgressHUD dismiss];
         
         if (error.code == -1005)
         {
             
         }
         
         
         
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error at Server, while creating a  comment"
                                                             message:[error localizedDescription]
                                                            delegate:nil
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil];
         [alertView show];
     }];
    
    [operation start];
}

- (void)scrollToBottom
{
    [messageDetailTableView scrollRectToVisible:CGRectMake(0, messageDetailTableView.contentSize.height - messageDetailTableView.bounds.size.height, messageDetailTableView.bounds.size.width, messageDetailTableView.bounds.size.height) animated:YES];

    
}

#pragma mark -
#pragma Herats List
-(void)getHeartsList {
    
    
    NSString *command = @"hearters";
    NSString *kl_id = [NSString stringWithFormat:@"%@",[self.post objectForKey:@"kl_id"]];
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    // NSString* postCommand = @"add_heart";
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": command,
                               };
    
    NSDictionary *userInfo = @{@"command":command};
    
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@posts/%@",BASE_URL,kl_id];
    
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
   
    __weak PostDetailedViewController *weakSelf = self;

    
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        [weakSelf heartListSuccess:[json objectForKey:@"response"]];
        
    } failure:^(NSDictionary *json) {
        
        
        [weakSelf heartListFailed];
        
    }];
    
}
-(void)heartListSuccess:(NSDictionary *)dict {
    
    heartersList = [[dict objectForKey:@"body"] objectForKey:@"hearters"];
    
    
    
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, Deviceheight)];
    [overlay setBackgroundColor:[UIColor clearColor]];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:overlay];
    

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    singleTap.numberOfTouchesRequired = 1;
    [overlay addGestureRecognizer:singleTap];

    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 30)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
    label.text = @"people who also liked this post";
    label.textColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"Anton" size:14];
    [headerView addSubview:label];
    

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 29.5, Devicewidth, 0.5)];
    [line setBackgroundColor:[UIColor lightGrayColor]];
    [headerView addSubview:line];
    
    
    float maxAllowableHeight = Deviceheight - 100;
    float height = (30+heartersList.count*50)>maxAllowableHeight?maxAllowableHeight:(30+heartersList.count*50);
    
    heartTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Deviceheight, Devicewidth, height)];
    heartTableView.delegate = self;
    heartTableView.tableFooterView = [UIView new];
    heartTableView.dataSource = self;
    heartTableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    [overlay addSubview:heartTableView];
    heartTableView.tableHeaderView  = headerView;
    

    
    [UIView animateWithDuration:0.3 animations:^{
        
        heartTableView.frame = CGRectMake(0, Deviceheight-height, Devicewidth, height);
        
    }];
    
    
    CABasicAnimation *theAnimation=[CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    theAnimation.duration=0.3;
    theAnimation.removedOnCompletion = NO;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.fromValue= (__bridge id _Nullable)([[UIColor clearColor] CGColor]);
    theAnimation.toValue= (__bridge id _Nullable)([[UIColor colorWithRed:0 green:0 blue:0  alpha:0.5] CGColor]);
    [overlay.layer addAnimation:theAnimation forKey:@"ColorPulse" ];
    
    
    
    addHeartBtn.userInteractionEnabled = YES;
    
    
}
-(void)heartListFailed {
    
    addHeartBtn.userInteractionEnabled = YES;
    
}
-(void)tapped:(UITapGestureRecognizer *)gesture {
    
    if(gesture.view == overlay)
        [overlay removeFromSuperview];
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
