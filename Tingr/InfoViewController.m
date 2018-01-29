//
//  InfoViewController.m
//  Tingr
//
//  Created by Maisa Pride on 7/26/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "InfoViewController.h"
#import "UIImage+ImageEffects.h"
#import "WebViewController.h"
@interface InfoViewController ()

{
    ProfilePhotoUtils *photoUtils;
    ModelManager *sharedModel;
    SingletonClass *singletonObject;
    AppDelegate *appDelegate;
    UITableView *tableView;
    UIImageView *imageHeaderView;
    
    CGFloat maxHeaderHeight;
    CGFloat minHeaderHeight;
    CGFloat previousScrollOffset;
    UILabel *titleLabel;
    UIView *tableHeaderView;
    BOOL animated;
    BOOL canShowISight;
    NSString *microSiteUrl;
    float topSpace;
    
}


@end


@implementation InfoViewController
@synthesize  infoData;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    sharedModel   = [ModelManager sharedModel];
    singletonObject = [SingletonClass sharedInstance];
    photoUtils = [ProfilePhotoUtils alloc];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    topSpace = 0;
    if(appDelegate.topSafeAreaInset > 0)
        topSpace = 15;

    
    maxHeaderHeight = 200;
    minHeaderHeight = 64+topSpace;
    previousScrollOffset = 0;

    tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth,maxHeaderHeight)];
    tableHeaderView.clipsToBounds = YES;
    [self.view addSubview:tableHeaderView];
    
    imageHeaderView = [[UIImageView alloc] initWithFrame:tableHeaderView.bounds];
    imageHeaderView.contentMode = UIViewContentModeScaleAspectFill;
    imageHeaderView.backgroundColor = [UIColor lightGrayColor];
    imageHeaderView.clipsToBounds = true;
    [imageHeaderView setImageWithURL:[NSURL URLWithString:[singletonObject.selecteOrganisation objectForKey:@"logo"]] placeholderImage:nil];
    [tableHeaderView addSubview:imageHeaderView];

    NSString *name = [singletonObject.selecteOrganisation objectForKey:@"name"];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, tableHeaderView.frame.size.height- 64, Devicewidth-40, 64)];
    [titleLabel setText:name];
    [titleLabel setTextColor:UIColorFromRGB(0x2b78e4)];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24.0];
    [tableHeaderView addSubview:titleLabel];

    UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 20+topSpace, 44, 44);
    [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, maxHeaderHeight, Devicewidth, Deviceheight-maxHeaderHeight)];
    tableView.delegate = self;
    tableView.tableFooterView = [UIView new];
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    

    
    UserProfile *userProfile = sharedModel.userProfile;
    if(userProfile.isight_enabled && ![name isEqualToString:@"TINGR"])
        canShowISight = YES;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: YES];
    
    [self getInfo];
    
    
}
-(void)writeClicked {
    
 
    NSString* urlTextEscaped = [microSiteUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *URL = [NSURL URLWithString:urlTextEscaped];
    WebViewController *webcntrl  = [[WebViewController alloc] init];
    webcntrl.url = URL;
    [self presentViewController:webcntrl animated:YES completion:^{
    }];

    
}
-(void)backClicked {
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)getInfo {
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    NSString *orgId  = [[[SingletonClass sharedInstance] selecteOrganisation] objectForKey:@"id"];
    if(orgId.length > 0)
        [dict setValue:orgId forKeyPath:@"organization_id"];
    
    
    //DM
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"school_info",
                               @"body": dict};
    
    NSDictionary *userInfo = @{@"command":@"school_info"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@organizations",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        [self didRecieveResponse:[json objectForKey:@"response"]];
        
    } failure:^(NSDictionary *json) {
    }];
    
    
    
}
-(void)didRecieveResponse:(NSDictionary *)json
{
    microSiteUrl = [[json objectForKey:@"body"] objectForKey:@"url"];
    infoData = [[json objectForKey:@"body"] objectForKey:@"info"];
    
    [tableView reloadData];
}
#pragma mark
#pragma TableVie Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0)
        return 100;
    else
        return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if(section == 0)
    {
        if(canShowISight)
            return 1;
        else
            return 0;
    }
    else {
        
        return infoData.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        
        NSString *reuseIdentifier = @"iSightCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleSubtitle
                    reuseIdentifier:reuseIdentifier];
            
            NSString *message = @"Enable iSIGHTNext time, simply use your phone to SIGN-IN your child at supporting schools. Works auto-magically. Ask your school today.";
            
            NSDictionary *attribs = @{
                                      NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]
                                      };
            
            CGSize expectedLabelSize = [message boundingRectWithSize:CGSizeMake(Devicewidth-80, 100) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
            
            float y = (100 - expectedLabelSize.height - 30)/2.0;
            
            UILabel *autoLabel;
            autoLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, y, Devicewidth-80, 30)];
            [autoLabel setText:@"Enable iSIGHT"];
            autoLabel.textColor = [UIColor darkGrayColor];
            autoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20];
            [autoLabel setTextAlignment:NSTextAlignmentLeft];
            [cell.contentView addSubview:autoLabel];
            
            
            UILabel *detailLabel;
            detailLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, y+25, Devicewidth-80, expectedLabelSize.height)];
            [detailLabel setText:@"Next time, simply use your phone to SIGN-IN your child at supporting schools. Works auto-magically. Ask your school today."];
            detailLabel.numberOfLines = 0;
            detailLabel.textColor = [UIColor lightGrayColor];
            [detailLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:12]];
            [cell.contentView addSubview:detailLabel];
            
            
            UISwitch *switchCntrl = [[UISwitch alloc] initWithFrame:CGRectMake(Devicewidth-60, 39.5, 50, 30)];
            switchCntrl.on = NO;
            switchCntrl.tag = 101;
            switchCntrl.tintColor = [UIColor whiteColor];
            [switchCntrl addTarget:self action:@selector(switchControlValueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchCntrl];
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0]];
        }
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL isISightOn = [[userDefaults objectForKey:@"isight_enabled"] boolValue];
        if(isISightOn && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways))
        {
            UISwitch *switchCntrl = (UISwitch *) [cell.contentView viewWithTag:101];
            switchCntrl.on = YES;
        }
        
        return cell;
    }
    else {
    
        static NSString *simpleTableIdentifier = @"StreamCell";
        UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        NSDictionary *detailsDict = infoData[indexPath.row];
        NSString *text = [detailsDict objectForKey:@"name"];
        cell.textLabel.textColor = UIColorFromRGB(0x2b78e4);
        cell.textLabel.text = [NSString stringWithFormat:@"%@",text];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        return cell;

    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 0;
    else
        return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        
        return nil;
        
    }
    else
    {
    
        UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, 30)];
        view.backgroundColor = [UIColor whiteColor];
        CALayer *upperBorder = [CALayer layer];
        upperBorder.backgroundColor = [[UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1.0] CGColor];
        upperBorder.frame = CGRectMake(0, 30, Devicewidth , 1.0f);
        [view.layer addSublayer:upperBorder];
        
        UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
        [label setText:@"School info links"];
        label.textAlignment = NSTextAlignmentCenter;
        label.font =[UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
        label.textColor = [UIColor lightGrayColor];
        [view addSubview:label];
        return view;
    }
    
    
}


-(void)switchControlValueChanged:(UISwitch *)switchCntrl {
    
    if(switchCntrl.on) {
      
        [appDelegate initialise];
    }
    else {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:@"isight_enabled"];
        [appDelegate stopMonitoring];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        NSDictionary *detailsDict = infoData[indexPath.row];
        NSString *utlString = [detailsDict objectForKey:@"url"];
        NSString* urlTextEscaped = [utlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *URL = [NSURL URLWithString:urlTextEscaped];
        WebViewController *webcntrl  = [[WebViewController alloc] init];
        webcntrl.url = URL;
        [self presentViewController:webcntrl animated:YES completion:^{
        }];

        
    }

    
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
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)bakButtonTapped {
    
    [self.navigationController popViewControllerAnimated:YES];
    
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
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        titleLabel.frame = CGRectMake(60, tableHeaderView.frame.size.height- 44, Devicewidth-70, 44);
        
            tableView.frame  = CGRectMake(0, minHeaderHeight, Devicewidth, Deviceheight-minHeaderHeight);
        
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
                         tableView.frame  = CGRectMake(0, maxHeaderHeight, Devicewidth, Deviceheight-maxHeaderHeight);
                         titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:24.0];
                         titleLabel.frame = CGRectMake(20, tableHeaderView.frame.size.height- 64, Devicewidth-40, 64);
                       
                     }
     ];
    
    
    
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
