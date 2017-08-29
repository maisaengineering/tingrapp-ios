//
//  ContentCell.m
//  Tingr
//
//  Created by Maisa Pride on 7/25/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "ContentCell.h"
#import "ProfilePhotoUtils.h"
#import "ProfileDateUtils.h"
#import "UIImageViewAligned.h"
#import "VideoPlayer.h"
@implementation ContentCell
{
    ProfileDateUtils *profileDateUtils;
    ProfilePhotoUtils *photoUtils;
    NSArray *colorsArray;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        
        profileDateUtils = [ProfileDateUtils alloc];
        photoUtils = [ProfilePhotoUtils alloc];
        colorsArray = @[@0xcb5382,@0x007966,@0xcb0e40];
        
        self.mediaFocusManager = [[ASMediaFocusManager alloc] init];
        self.mediaFocusManager.delegate = self;

    }
    return self;
}

- (void)setPost:(NSDictionary *)post
{
        _post = post;
        [self setUpViews];
    if([[self.post objectForKey:@"tagged_to"] count] == 1)
    {
        self.mediaFocusManager.canShowDownload = YES;
    }
    else
    {
        self.mediaFocusManager.canShowDownload = NO;
    }
}


-(void)setUpViews {
    
    float yPosition = 0;
    
    for(UIView *subView in [self.contentView subviews])
        [subView removeFromSuperview];
    UIView *drawingView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, Devicewidth-16, self.contentView.frame.size.height)];
    [self.contentView addSubview:drawingView];
    
    //Header View
    UIView *headerVeiw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, drawingView.frame.size.width, 25)];
    [drawingView addSubview:headerVeiw];
    [headerVeiw setBackgroundColor:UIColorFromRGB(0x99CCFF)];
    
    
    //Time Label
    NSString *storyDate = [self.post objectForKey:@"created_at"];
    NSMutableString *formattedTime = [[profileDateUtils dailyLanguageForMilestone:storyDate actualTimeZone:[self.post objectForKey:@"tzone"]] mutableCopy];
   UILabel *timeLabel = [[UILabel alloc] init];
    NSDictionary *attribs = @{
                              NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14]
                              };
    
    CGSize expectedLabelSize = [formattedTime boundingRectWithSize:CGSizeMake(Devicewidth-16, 25) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
    timeLabel.text = formattedTime;
    timeLabel.textColor = [UIColor whiteColor];
    [timeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14]];
    timeLabel.frame = CGRectMake(headerVeiw.frame.size.width-expectedLabelSize.width-3, 0, expectedLabelSize.width, 25);
    [headerVeiw addSubview:timeLabel];
    
    //Time Icon
    UIImageView *timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(timeLabel.frame.origin.x-13, 6.5, 12, 12)];
    [timeIcon setImage:[UIImage imageNamed:@"clock"]];
    [headerVeiw addSubview:timeIcon];

    //Views Count Label
    NSString *viewCount = [[self.post objectForKey:@"view_count"] stringValue];
     expectedLabelSize = [viewCount boundingRectWithSize:CGSizeMake(Devicewidth-16, 25) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;

    UILabel *viewCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeIcon.frame.origin.x-expectedLabelSize.width-6, 0, expectedLabelSize.width, 25)];
    viewCountLabel.text = viewCount;
    viewCountLabel.textColor = [UIColor whiteColor];
    [viewCountLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14]];
    [headerVeiw addSubview:viewCountLabel];

    
    //Time Icon
    UIImageView *viewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(viewCountLabel.frame.origin.x-13, 6.5, 12, 12)];
    [viewIcon setImage:[UIImage imageNamed:@"views"]];
    [headerVeiw addSubview:viewIcon];

    //Views Count Label
    NSString *byText = [NSString stringWithFormat:@"by %@",[self.post objectForKey:@"author_name"]];
    UILabel *byLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0,viewIcon.frame.origin.x-2, 25)];
    byLabel.text = byText;
    
    byLabel.textColor = [UIColor whiteColor];
    [byLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]];
    [headerVeiw addSubview:byLabel];

    yPosition += 25;
    
    //Title Label
    NSString *title = [self.post objectForKey:@"new_title"];
    if(title.length) {
        
        NSDictionary *attribs = @{
                                  NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:17]
                                  };
        CGSize expectedLabelSize = [title boundingRectWithSize:CGSizeMake(Devicewidth-16, 9999) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
        
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yPosition, drawingView.frame.size.width, expectedLabelSize.height)];
        titleLabel.text = [NSString stringWithFormat:@" %@",title];
        titleLabel.textColor = UIColorFromRGB(0x2b78e4);
        [titleLabel setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.6]];
        [titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
        [drawingView addSubview:titleLabel];

        yPosition += expectedLabelSize.height;

    }

    
    UIView *tagsAndLikesView;
    UILabel *descriptionLabel;
    
    if([[self.post objectForKey:@"tagged_to"] count] > 0 || [[self.post objectForKey:@"hearts_count"] intValue] > 0)
    {
        tagsAndLikesView = [[UIView alloc] initWithFrame:CGRectMake(0, yPosition, drawingView.frame.size.width, 30)];
        
        UIScrollView *tagScrollView;
        if([[self.post objectForKey:@"tagged_to"] count] > 0)
        {
            tagScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(2, 0, tagsAndLikesView.frame.size.width-30, 30)];
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
                    [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Bold" size:12]}
                                            range:range];
                }
                if(parentFnameInitial.length > 1)
                {
                    range.location = 1;
                    range.length = 1;
                    [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:(123/255.f) green:(123/255.f) blue:(123/255.f) alpha:1],NSFontAttributeName:[UIFont fontWithName:@"Antonio-Light" size:12]}
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
        
        if([[self.post objectForKey:@"hearts_count"] intValue] > 0) {
            
            UIImageView *heartsImage = [[UIImageView alloc] initWithFrame:CGRectMake(tagsAndLikesView.frame.size.width-28, 2, 26, 26)];
            [heartsImage setImage:[UIImage imageNamed:@"light_heart"]];
            [tagsAndLikesView addSubview:heartsImage];
            
            UILabel *countLabel = [[UILabel alloc] initWithFrame:heartsImage.bounds];
            countLabel.text = [NSString stringWithFormat:@"%i+",[[self.post objectForKey:@"hearts_count"] intValue]];
            countLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:8];
            countLabel.textAlignment = NSTextAlignmentCenter;
            countLabel.textColor = [UIColor whiteColor];
            [heartsImage addSubview:countLabel];
            
        }
        else {
            
            if(tagScrollView) {
                
                tagScrollView.frame = CGRectMake(2, 0, tagsAndLikesView.frame.size.width-4, 30);
            }
        }
        
        [drawingView addSubview:tagsAndLikesView];
    }
    
    if([[self.post objectForKey:@"text"] length] >0) {
        
        NSString *description = [NSString stringWithFormat:@"%@",[self.post objectForKey:@"text"]];
        
        NSDictionary *attribs = @{
                                  NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:14]
                                  };
        
        ;
        
        CGSize expectedLabelSize = [description boundingRectWithSize:CGSizeMake(drawingView.frame.size.width-6, 9999) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
        
        descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, yPosition+4, drawingView.frame.size.width, expectedLabelSize.height)];
        descriptionLabel.text = description;
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        descriptionLabel.textColor = [UIColor whiteColor];
        [drawingView addSubview:descriptionLabel];


    }
    
    
    if([[self.post objectForKey:@"images"] count] >0) {
  
        UIScrollView *imagesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, yPosition, drawingView.frame.size.width, 300)];
        [drawingView addSubview:imagesScrollView];
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
    
        yPosition += imagesScrollView.frame.size.height;
        
        
        CGRect frame;
        
        if(tagsAndLikesView) {
            
            frame = tagsAndLikesView.frame;
            frame.origin.y = yPosition;
            tagsAndLikesView.frame = frame;
            yPosition += frame.size.height;
        }
        
        if(descriptionLabel) {
            
            frame = descriptionLabel.frame;
            frame.origin.y = yPosition+4;
            descriptionLabel.frame = frame;
            
            yPosition += frame.size.height+4;

        }
        
    }
    else {
        
        CGRect frame;
        
        if(descriptionLabel) {
            
            descriptionLabel.textAlignment = NSTextAlignmentCenter;
            frame = descriptionLabel.frame;
            frame.origin.y = yPosition+4;
            descriptionLabel.frame = frame;
            yPosition += frame.size.height+4;

        }
        
        if(tagsAndLikesView) {
            
            frame = tagsAndLikesView.frame;
            frame.origin.y = yPosition;
            tagsAndLikesView.frame = frame;
            yPosition += frame.size.height;

        }

    }
    
    
    //Recent Comments
    NSArray *commentsArray = [self.post objectForKey:@"comments"];
    if(commentsArray.count >0)
    {
        NSDictionary *dict = [commentsArray lastObject];
        NSString *commentText = [NSString stringWithFormat:@"recent comment by %@\n%@",[dict objectForKey:@"commented_by"],[dict objectForKey:@"content"]];
        
        NSDictionary *attribs = @{
                                  NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14],
                                  NSForegroundColorAttributeName:[UIColor whiteColor]
                                  };
        
        ;
        
        NSMutableAttributedString* tncString = [[NSMutableAttributedString alloc] initWithString:commentText attributes:attribs];
        
        NSRange range = [tncString.string rangeOfString:[NSString stringWithFormat:@"recent comment by %@",[dict objectForKey:@"commented_by"]]];
        
        // workaround for bug in UIButton - first char needs to be underlined for some reason!
        [tncString addAttribute:NSUnderlineStyleAttributeName
                          value:@(NSUnderlineStyleSingle)
                          range:range];
        [tncString addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:range];
        
        
        CGSize expectedLabelSize = [commentText boundingRectWithSize:CGSizeMake(Devicewidth-22, 9999) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3, yPosition, expectedLabelSize.width, expectedLabelSize.height)];
        label.attributedText = tncString;
        label.numberOfLines = 0;
        [drawingView addSubview:label];

        
        yPosition += expectedLabelSize.height;
        
        // View More comments height
        if(commentsArray.count > 1) {
            
            UIButton *viewMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [viewMoreButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14]];
            [viewMoreButton setTitleColor:UIColorFromRGB(0x2b78e4) forState:UIControlStateNormal];
            [viewMoreButton setTitle:[NSString stringWithFormat:@"view %lu remaining comments",commentsArray.count - 1] forState:UIControlStateNormal];
            [viewMoreButton addTarget:self action:@selector(viewMoreCommentClicked) forControlEvents:UIControlEventTouchUpInside];
            [drawingView addSubview:viewMoreButton];
            

            
            viewMoreButton.frame = CGRectMake((drawingView.frame.size.width - 200)/2, yPosition, 200, 25);
            
            yPosition += 25;
        }
    }

    UIButton *commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [commentButton addTarget:self action:@selector(viewMoreCommentClicked) forControlEvents:UIControlEventTouchUpInside];
    [commentButton setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    commentButton.frame = CGRectMake((drawingView.frame.size.width - 30)/2, yPosition, 30, 30);
    [drawingView addSubview:commentButton];
    yPosition += 35;
    

    
    int randomIndex = arc4random() % 3;
    drawingView.backgroundColor = UIColorFromRGB([colorsArray[randomIndex] integerValue]);

    CGRect frame = drawingView.frame;
    frame.size.height = yPosition;
    drawingView.frame = frame;
    drawingView.layer.cornerRadius = 5;
    drawingView.clipsToBounds = YES;
    
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: headerVeiw.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){5, 5}].CGPath;
    
    headerVeiw.layer.mask = maskLayer;

    
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:drawingView.bounds];
    drawingView.layer.masksToBounds = NO;
    drawingView.layer.shadowRadius = 1;
    drawingView.layer.shadowColor = [UIColor blackColor].CGColor;
    drawingView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    drawingView.layer.shadowOpacity = 0.5f;
    drawingView.layer.shadowPath = shadowPath.CGPath;

    
    
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
-(void)viewMoreCommentClicked {
    
    
    [self.delegate commentClick:self.postIndex];
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
    AppDelegate *appdelgate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [[appdelgate.navgController viewControllers] firstObject];
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



@end
