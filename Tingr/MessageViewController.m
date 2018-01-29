//
//  MessageViewController.m
//  Tingr
//
//  Created by Maisa Pride on 7/28/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageDetailsView.h"
@interface MessageViewController ()
{
    UIView *topBar;
    ModelManager *sharedModel;
    SingletonClass *singletonObj;
    int selectedIndex;
    NSMutableArray *messagesDataArray;
    UIScrollView *scrollView;
    
    float topSpace;
    float bottomSpace;

}
@end

@implementation MessageViewController
@synthesize pageCollectionView;

- (void)viewDidLoad {
    [super viewDidLoad];
    singletonObj = [SingletonClass sharedInstance];
    sharedModel   = [ModelManager sharedModel];
    selectedIndex  = 0;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    topSpace = 0;
    bottomSpace = 0;
    if(appDelegate.topSafeAreaInset > 0)
    {
        topSpace = 15;
        bottomSpace = 30;
    }

    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUpViews];
    
    
    // Do any additional setup after loading the view.
}
-(void)setUpViews{
    
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100+topSpace, Devicewidth, Deviceheight - 100-topSpace)];
    [scrollView setPagingEnabled:YES];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    [self.view addSubview:scrollView];
    
    topBar = [[UIView alloc] init];
    [self.view addSubview:topBar];
    [self.view addConstraintsWithFormat:@"H:|[v0]|" forViews:@[topBar]];
    if(topSpace)
        [self.view addConstraintsWithFormat:@"V:[v0(115)]" forViews:@[topBar]];
    else
        [self.view addConstraintsWithFormat:@"V:[v0(100)]" forViews:@[topBar]];
    
    UICollectionViewFlowLayout *layout2=[[UICollectionViewFlowLayout alloc] init];
    layout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout2.minimumLineSpacing = 0;
    
    UIButton *backButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 20+topSpace, 44, 44);
    [backButton setImage:[UIImage imageNamed:@"back_arrow"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    
    UILabel *nameLabel  = [[UILabel alloc] initWithFrame:CGRectMake(60, 25+topSpace, Devicewidth - 120, 30)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = @"MESSAGES";
    nameLabel.textColor = [UIColor grayColor];
    nameLabel.font = [UIFont fontWithName:@"Anton" size:25.0];
    [topBar addSubview:nameLabel];
    
    pageCollectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, 62+topSpace, Devicewidth, 30) collectionViewLayout:layout2];
    [pageCollectionView setDataSource:self];
    [pageCollectionView setDelegate:self];
    pageCollectionView.backgroundColor = [UIColor whiteColor];
    [pageCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self.view addSubview:pageCollectionView];
    
    topBar.layer.shadowOpacity = 0.5;
    topBar.layer.shadowOffset =  CGSizeMake(0, 1.0);
    topBar.layer.shadowRadius = 2.0;
    topBar.layer.shadowColor = [[UIColor blackColor] CGColor];
    
    topBar.backgroundColor = [UIColor whiteColor];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self callAPI];
}
-(void)backClicked {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)callAPI {
    
    
    AccessToken* token = sharedModel.accessToken;
    UserProfile *_userProfile = sharedModel.userProfile;
    
    NSDictionary *body = @{};
    
    //build an info object and convert to json
    NSDictionary* postData = @{@"access_token": token.access_token,
                               @"auth_token": _userProfile.auth_token,
                               @"command": @"conversation_list",
                               @"body": body};
    
    NSDictionary *userInfo = @{@"command":@"conversation_list"};
    
    NSString *urlAsString = [NSString stringWithFormat:@"%@conversations",BASE_URL];
    NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
    API *api = [[API alloc] init];
    [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
        
        NSDictionary *body = [[json objectForKey:@"response"] objectForKey:@"body"];
        NSArray *array  = [body objectForKey:@"conversations"];
        [self recievedConversationList:array];
        
    } failure:^(NSDictionary *json) {
        
    }];
    
}
-(void)recievedConversationList:(NSArray *)conversationsArray
{
    
    messagesDataArray = [[conversationsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"org_id = %@",[singletonObj.selecteOrganisation objectForKey:@"id"]]] mutableCopy];
    
    [self setContentInMessageDetails];
    scrollView.contentSize = CGSizeMake(Devicewidth*messagesDataArray.count, Devicewidth-100);
    
    [pageCollectionView reloadData];
}
-(void)setContentInMessageDetails {
    
    
    for(int i=0;i<messagesDataArray.count ;i++){
        
        MessageDetailsView *messageView = [[MessageDetailsView alloc] initWithFrame:CGRectMake(i*Devicewidth, 0, Devicewidth, Deviceheight-100)];
        
        messageView.messageDictFromLastPage = messagesDataArray[i];
        [scrollView addSubview:messageView];
        [messageView fetchData];
        
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messagesDataArray count];
    
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell= [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary *messageDetails = messagesDataArray[indexPath.row];
    
    for(UIView *view in [cell.contentView subviews])
        [view removeFromSuperview];
    
    
        UIView *view = [[UIView alloc] init];
        view.layer.cornerRadius = 8;
        [cell.contentView addSubview:view];
    
    UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [imageView setImage:[UIImage imageNamed:@"message"]];
    [view addSubview:imageView];

    UILabel *nameLabel  = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.text = [messageDetails objectForKey:@"kid_name"];
    nameLabel.textColor = [UIColor colorWithRed:95/255.0 green:167/255.0 blue:239/255.0 alpha:1.0];
    nameLabel.font = [UIFont fontWithName:@"Anton" size:15.0];
    [view addSubview:nameLabel];
    

    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"Anton" size:15]};
    CGRect textSize = [[messageDetails objectForKey:@"kid_name"] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 30)
                                                                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                                                             attributes:attributes
                                                                                                                context:nil];
    
    float width = Devicewidth/(float)messagesDataArray.count;

        nameLabel.frame =  CGRectMake(30, 0, textSize.size.width, 30);
        view.frame = CGRectMake(0, 0, width, 30);
        
    
    view.center = cell.contentView.center;

    if(messagesDataArray.count >= 4) {
        
        nameLabel.hidden = YES;
        imageView.center = view.center;
    }
    
    
    
    return cell;
    
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float count = (float)messagesDataArray.count;
        return CGSizeMake(Devicewidth/count, 30);
        
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    CGRect frame = scrollView.frame;
    frame.origin.x = scrollView.frame.size.width *indexPath.row;
    [scrollView scrollRectToVisible:frame animated:YES];

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
