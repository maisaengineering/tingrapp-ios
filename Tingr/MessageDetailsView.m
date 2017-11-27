//
//  MessageDetailsView.m
//  Tingr
//
//  Created by Maisa Pride on 7/28/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "MessageDetailsView.h"
#import "ProfileDateUtils.h"
#import "UIImageView+AFNetworking.h"

@implementation MessageDetailsView
{
    ProfilePhotoUtils *photoUtils;
    ProfileDateUtils *profileDateUtils;
    CGRect originalPostion;
    UIView *inputView1;
    CGRect keyboardFrameBeginRect;
    UILabel *placeholderLabel;
    ModelManager *sharedModel;
    
    BOOL isDragging;
    BOOL isMoreAvailabel;
    NSMutableArray *sortedKeys;
    UIRefreshControl *refreshControl;

}
@synthesize messagesData;
@synthesize messageDetailTableView;
@synthesize messageDictFromLastPage;
@synthesize bProcessing;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self baseInit];
    }
    return self;
}

-(void)baseInit {
    
    
    sharedModel   = [ModelManager sharedModel];
    photoUtils = [ProfilePhotoUtils alloc];
    
    self.backgroundColor = [UIColor whiteColor];


    
    messageDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-80)];
    [messageDetailTableView setDelegate:self];
    [messageDetailTableView setDataSource:self];
    messageDetailTableView.tableFooterView = [[UIView alloc] init];
    messageDetailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:messageDetailTableView];
    
    refreshControl = [[UIRefreshControl alloc]init];
    
    refreshControl.transform = CGAffineTransformMakeScale(0.75, 0.75);
    
    [messageDetailTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    
    originalPostion = messageDetailTableView.frame;
    
    messagesData = [[NSMutableDictionary alloc] init];
    [self createMessageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];



    
}
-(void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)fetchData {
    
    [self getMessages];
    
}
-(void)createMessageView {
    
    self.commentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 80, self.frame.size.width, 80)];
    self.commentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.commentView];
    self.txt_comment = [[UITextView alloc] initWithFrame:CGRectMake(2, 0, self.frame.size.width-87, 80)];
    self.txt_comment.delegate = self;
    [self.txt_comment setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    
    [self.commentView addSubview:self.txt_comment];
    
    placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0, self.txt_comment.frame.size.width - 15.0, 80)];
    //[placeholderLabel setText:placeholder];
    [placeholderLabel setBackgroundColor:[UIColor clearColor]];
    [placeholderLabel setNumberOfLines:0];
    placeholderLabel.text = @"type your message here...";
    [placeholderLabel setTextAlignment:NSTextAlignmentLeft];
    [placeholderLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:14]];
    [placeholderLabel setTextColor:[UIColor colorWithRed:113/255.0 green:113/255.0 blue:113/255.0 alpha:1.0]];
    [self.txt_comment addSubview:placeholderLabel];
    
    
    //Upvote
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setFrame:CGRectMake(Devicewidth-80, 0, 80, 80)];
    sendBtn.backgroundColor = [UIColor colorWithRed:95/255.0 green:167/255.0 blue:239/255.0 alpha:1.0];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
    
    
    self.commentView.layer.borderColor = [UIColor colorWithRed:95/255.0 green:167/255.0 blue:239/255.0 alpha:1.0].CGColor;
    self.commentView.layer.cornerRadius = 5;
    self.commentView.layer.borderWidth = 1;
}

-(void)getMessages
{
    if(bProcessing)
        return;
    
    bProcessing = YES;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:[messageDictFromLastPage objectForKey:@"conversation_klid"] forKeyPath:@"conversation_klid"];
    [dict setValue:[messageDictFromLastPage objectForKey:@"kid_klid"] forKeyPath:@"kid_klid"];
    [dict setValue:[messageDictFromLastPage objectForKey:@"org_id"] forKeyPath:@"organization_id"];
    
    
    if(messagesData.count > 0)
    {
        NSArray *detailsArray = [messagesData objectForKey:[sortedKeys firstObject]];
        NSDictionary *detailsDict = [detailsArray firstObject];
        [dict setValue:[detailsDict objectForKey:@"created_at"] forKeyPath:@"last_message_time"];
    }
    
    //DM
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"messages",
                               @"body": dict};
    
    NSDictionary *userInfo = @{@"command":@"messages"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@conversations",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        [self didRecievedMessages:[json objectForKey:@"response"]];
        
    } failure:^(NSDictionary *json) {
        [self didFailedToRecieveMessages:[json objectForKey:@"response"]];
        
    }];
    
    
}
-(void)didRecievedMessages:(NSDictionary *)parsedObject {
    
    [self.activityIndicator stopAnimating];
    
    NSMutableArray *unreadMessages = [[NSMutableArray alloc] init];
    NSDictionary *messagesDict = [[parsedObject objectForKey:@"body"] objectForKey:@"messages"];
    
    if([messagesData count] > 0)
    {
        NSArray *keysArray = [messagesDict allKeys];
        for(NSString *key in keysArray)
        {
            NSArray *msgArray = [messagesDict objectForKey:key];
            NSMutableArray *currentDateArray = [[messagesData objectForKey:key] mutableCopy];
            if(currentDateArray == nil)
            {
                currentDateArray = msgArray.mutableCopy;
                
            }
            else
            {
                for(long int i= msgArray.count -1; i>=0; i--)
                {
                    NSDictionary *dict = msgArray[i];
                    [currentDateArray insertObject:dict atIndex:0];
                }
            }
            NSArray *array  = [msgArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"read_message != 1"]];
            
            if(array.count > 0)
                [unreadMessages addObjectsFromArray:array];
            
            [messagesData setObject:currentDateArray forKey:key];
        }
        
    }
    else
    {
        messagesData = [[[parsedObject objectForKey:@"body"] objectForKey:@"messages"] mutableCopy];
        
    }
    
    if([messagesDict count] == 0)
    {
        messageDetailTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        isMoreAvailabel = NO;
    }
    else
    {
        // [self setupTableViewHeader];
        isMoreAvailabel  = YES;
    }
    
    NSArray *aUnsorted = [messagesData allKeys];
    sortedKeys= [[aUnsorted sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM/dd/yyyy"];
        NSDate *d1 = [df dateFromString:(NSString*) obj1];
        NSDate *d2 = [df dateFromString:(NSString*) obj2];
        return [d1 compare: d2];
    }] mutableCopy];
    
    
    [messageDetailTableView reloadData];
    bProcessing = NO;
    
    //  if(!isDragging)
    // [messageDetailTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    
    if(unreadMessages.count)
        [self callReadMessages:unreadMessages];
    
    [refreshControl endRefreshing];
    
    [[SingletonClass sharedInstance] setMessageCount:@"0"];
}

-(void)didFailedToRecieveMessages:(NSDictionary *)parsedObject {
    
    [refreshControl endRefreshing];
    
    [self.activityIndicator stopAnimating];
    bProcessing = NO;
    
}


-(void)callReadMessages:(NSArray *)array{
   
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:[messageDictFromLastPage objectForKey:@"conversation_klid"] forKeyPath:@"conversation_klid"];
    [dict setValue:sharedModel.userProfile.kl_id forKeyPath:@"profile_klid"];
    
    NSMutableArray *msgIdsArray = [[NSMutableArray alloc] init];
    for(NSDictionary *dict in array)
    {
        [msgIdsArray addObject:[dict objectForKey:@"kl_id"]];
    }
    
    
    [dict setValue:msgIdsArray forKeyPath:@"messages_klid"];
    
    
    //DM
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"read_message",
                               @"body": dict};
    
    NSDictionary *userInfo = @{@"command":@"read_message"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@conversations",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
    } failure:^(NSDictionary *json) {
        
    }];
    
    
}

-(void)sendButtonTapped
{
    
    
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    if(self.txt_comment.text.length ==  0 || ([[self.txt_comment.text stringByTrimmingCharactersInSet: set] length] == 0))
    {
        ShowAlert(PROJECT_NAME, @"Please enter message", @"OK");
        return;
    }
    
    
    
    
    [self.txt_comment resignFirstResponder];
    
    
    [SVProgressHUD show];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:sharedModel.userProfile.kl_id forKeyPath:@"sender_klid"];
    [dict setValue:[messageDictFromLastPage objectForKey:@"conversation_klid"] forKeyPath:@"conversation_klid"];
    [dict setValue:[messageDictFromLastPage objectForKey:@"kid_klid"] forKeyPath:@"kid_klid"];
    [dict setValue:[messageDictFromLastPage objectForKey:@"org_id"] forKeyPath:@"organization_id"];
    [dict setValue:self.txt_comment.text forKeyPath:@"text"];
    
    
    //DM
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"send_message",
                               @"body": dict};
    
    NSDictionary *userInfo = @{@"command":@"send_message"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@conversations",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [self addCurrentMessage:[[json objectForKey:@"response"] objectForKey:@"body"]];
        
        
        [SVProgressHUD dismiss];
    } failure:^(NSDictionary *json) {
        
        [SVProgressHUD dismiss];
    }];
    
    [self.txt_comment addSubview:placeholderLabel];
    self.txt_comment.text = @"";
}
-(void)addCurrentMessage:(NSDictionary *)message {
    
    
    if([[messageDictFromLastPage objectForKey:@"conversation_klid"] length] == 0)
    {
        NSMutableDictionary *dict = [messageDictFromLastPage mutableCopy];
        [dict setObject:[message objectForKey:@"conversation_klid"] forKey:@"conversation_klid"];
        messageDictFromLastPage = dict;
    }
    
    
    NSDate *date = [[NSDate alloc]init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *key  = [formatter stringFromDate:date];
    
    NSMutableArray *currentDateArray = [[messagesData objectForKey:key] mutableCopy];
    if(currentDateArray == nil)
    {
        currentDateArray = [[NSMutableArray alloc] init];
        [currentDateArray addObject:message];
    }
    else
    {
        [currentDateArray addObject:message];
    }
    
    [messagesData setObject:currentDateArray forKey:key];
    
    NSArray *aUnsorted = [messagesData allKeys];
    sortedKeys= [[aUnsorted sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"MM/dd/yyyy"];
        NSDate *d1 = [df dateFromString:(NSString*) obj1];
        NSDate *d2 = [df dateFromString:(NSString*) obj2];
        return [d1 compare: d2];
    }] mutableCopy];
    
    
    [messageDetailTableView reloadData];
    
    NSArray *detailsArray = [messagesData objectForKey:sortedKeys[messagesData.count-1]];
    NSIndexPath* ipath = [NSIndexPath indexPathForRow: detailsArray.count-1  inSection: messagesData.count-1];
    [messageDetailTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
    
    
    
}
-(void)doneClick:(id)sender
{
    [self.txt_comment resignFirstResponder];
    messageDetailTableView.frame = originalPostion;
}


#pragma mark
#pragma TableVie Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    long int count = messagesData.count;
    return count;
    
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *detailsArray = [messagesData objectForKey:sortedKeys[section]];
    return detailsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *detailsArray = [messagesData objectForKey:sortedKeys[indexPath.section]];
    NSDictionary *detailsDict = detailsArray[indexPath.row];
    NSString *text = [detailsDict objectForKey:@"text"];
    NSString *name = [detailsDict objectForKey:@"sender_name"];
    
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
    
    
    
    CGRect rect2 = [text boundingRectWithSize:CGSizeMake(Devicewidth-60-5, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attributes1
                                     context:nil];

    if(rect2.size.height > rightSideHeight)
        rightSideHeight = rect2.size.height;
    
    height += leftSideHeight > rightSideHeight ? leftSideHeight: rightSideHeight;
    
    
    
    return height;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"StreamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0]];
        cell.contentView.backgroundColor = [UIColor clearColor];
        

    }
    
    //removes any subviews from the cell
    for(UIView *viw in [[cell contentView] subviews])
    {
        [viw removeFromSuperview];
    }
    
    NSArray *detailsArray = [messagesData objectForKey:sortedKeys[indexPath.section]];
    NSDictionary *detailsDict = detailsArray[indexPath.row];
    NSString *text = [detailsDict objectForKey:@"text"];
    NSString *name = [detailsDict objectForKey:@"sender_name"];
    NSString *url = [detailsDict objectForKey:@"photograph"];
    NSString *create_at = [detailsDict objectForKey:@"created_at"];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssz"];
    NSDate *date = [dateFormatter dateFromString:create_at];
    [dateFormatter setDateFormat:@"EEE, MMM d, ''yy 'at' hh:mm a"];
    NSString *formattedTime = [dateFormatter stringFromDate:date];
    
    UILabel *timeLabel = [[UILabel alloc] init];
    NSDictionary *attribs = @{
                              NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14]
                              };
    
    CGSize expectedLabelSize = [formattedTime boundingRectWithSize:CGSizeMake(Devicewidth-16, 20) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
    timeLabel.text = formattedTime;
    timeLabel.textColor = [UIColor lightGrayColor];
    [timeLabel setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:14]];
    timeLabel.frame = CGRectMake(Devicewidth-5-expectedLabelSize.width-3, 0, expectedLabelSize.width, 20);
    [cell.contentView addSubview:timeLabel];
    
    //Time Icon
    UIImageView *timeIcon = [[UIImageView alloc] initWithFrame:CGRectMake(timeLabel.frame.origin.x-13, 4, 12, 12)];
    [timeIcon setImage:[UIImage imageNamed:@"clock"]];
    [cell.contentView addSubview:timeIcon];
    

    
    

    
    UIImageView *imagVw = [[UIImageView alloc] initWithFrame:CGRectMake(5, 20, 50, 50)];
    [imagVw setImage:[UIImage imageNamed:@"EmptyProfile.png"]];
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
             [weakSelf setImage:[photoUtils makeRoundWithBoarder:[photoUtils squareImageWithImage:image scaledToSize:CGSizeMake(50, 50)] withRadious:0]];
             [initial removeFromSuperview];
         }
                               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
         {
             DebugLog(@"fail");
         }];
    }
    
    [cell.contentView addSubview:imagVw];
    
    float leftSideHeight = 50;
    float height = 25;

    
    
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
    nameLabel.textColor = [UIColor lightGrayColor];
    nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    [cell.contentView addSubview:nameLabel];
    
    
    float rightSideHeight = 70;
    NSDictionary *attributes1 = @{NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Light" size:14]};
    
    
    
    CGRect rect2 = [text boundingRectWithSize:CGSizeMake(Devicewidth-60-5, CGFLOAT_MAX)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributes1
                                      context:nil];
    
    if(rect2.size.height > rightSideHeight)
        rightSideHeight = rect2.size.height;

    UILabel *textLabel  = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, Devicewidth-60-5, rightSideHeight)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.text = text;
    textLabel.numberOfLines = 0;
    textLabel.backgroundColor = [UIColor whiteColor];
    textLabel.textColor = [UIColor lightGrayColor];
    textLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:14];
    [cell.contentView addSubview:textLabel];

    textLabel.layer.cornerRadius = 5;
    textLabel.layer.borderColor = [UIColor colorWithRed:95/255.0 green:167/255.0 blue:239/255.0 alpha:1.0].CGColor;
    textLabel.layer.borderWidth  =1;
    
    height += leftSideHeight > rightSideHeight ? leftSideHeight: rightSideHeight;

    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,height - 0.5, Deviceheight, 0.5)];
    [line setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:line];
    
    
    
    
    
    return cell;
}

/*
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView
 {
 
 if (bProcessing) return;
 
 
 if (scrollView.contentOffset.y <= 0)
 {
 // ask next page only if we haven't reached last page
 if(isMoreAvailabel)
 {
 isDragging = YES;
 [self.activityIndicator startAnimating];
 [self getMessages];
 // fetch next page of results
 }
 }
 }
 */
-(void)refreshTable {
    
    if(isMoreAvailabel)
    {
        [self getMessages];
    }
    else {
        
        [refreshControl endRefreshing];
        
    }
    
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
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = self.commentView.frame;
    containerFrame.origin.y = self.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
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
    containerFrame.origin.y = self.bounds.size.height - containerFrame.size.height;
    
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


@end
