//
//  FeedView.m
//  Tingr
//
//  Created by Maisa Pride on 7/30/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "FeedView.h"

#import "PostDetailedViewController.h"

@implementation FeedView
{
    ModelManager *sharedModel;
    NSString *timeStamp;
    NSNumber *postCount;
    UIRefreshControl *refreshControl;
    int selelctedIndex;
}
@synthesize orgID,feedCollectionView;
@synthesize bProcessing;
@synthesize isDeletingProcessed;
@synthesize storiesArray;
@synthesize isMoreAvailabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        sharedModel = [ModelManager sharedModel];
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 0;
        
        refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor grayColor];
        [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
        
        
        feedCollectionView =[[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [feedCollectionView setDataSource:self];
        [feedCollectionView setDelegate:self];
        feedCollectionView.backgroundColor = [UIColor whiteColor];
        [feedCollectionView registerClass:[ContentCell class] forCellWithReuseIdentifier:@"ContentCell"];
        [self addSubview:feedCollectionView];
        

        [feedCollectionView addSubview:refreshControl];
        feedCollectionView.alwaysBounceVertical = YES;

        
        storiesArray = [[NSMutableArray alloc] init];
        
        
    }
    return self;
}

#pragma mark- Fetch Posts Methods
#pragma mark-
-(void)clearAllData {
    
    timeStamp = @"";
    postCount = 0;
    
}
- (void)changedDetails:(NSDictionary *)postDict {
    
    [storiesArray replaceObjectAtIndex:selelctedIndex withObject:postDict];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selelctedIndex inSection:0];
    [feedCollectionView reloadItemsAtIndexPaths:@[indexPath]];
    
}
-(void)handleRefresh:(id)sender
{
    //    UIRefreshControl *refresh = sender;
    //     refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
    if (bProcessing) return;
    // Released above the header
    [self clearAllData];
    timeStamp = @"";
    [self performSelectorInBackground:@selector(callStoresApi:) withObject:@"next"];

}

-(void)callStoresApi:(NSString *)step
{
    
    if(bProcessing)
        return;
    if(!bProcessing)
    {
        bProcessing = YES;
        if([step isEqualToString:@"new"])
            self.isRefreshing = YES;
        else
            self.isRefreshing = NO;
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setValue:timeStamp forKeyPath:@"last_modified"];
        [dict setValue:postCount forKeyPath:@"post_count"];
        [dict setValue:step forKeyPath:@"step"];
        [dict setObject:[NSNumber numberWithBool:TRUE] forKey:@"paginate"];
        
        
        //DM
        AccessToken* token = sharedModel.accessToken;
        UserProfile *_userProfile = sharedModel.userProfile;
        
        NSString* postCommand = @"";
        NSString *urlAsString = [NSString stringWithFormat:@"%@v2/posts",BASE_URL];
        
        
        if(orgID.length == 0)
        {
            postCommand = @"public_posts";
            urlAsString = [NSString stringWithFormat:@"%@posts",BASE_URL];
        }
        else {
            postCommand = @"org_posts";
            [dict setValue:orgID  forKey:@"organization_id"];
            
            
        }
        
        
        //build an info object and convert to json
        NSDictionary* postData = @{@"access_token": token.access_token,
                                   @"auth_token": _userProfile.auth_token  ? _userProfile.auth_token:@"",
                                   @"command": postCommand,
                                   @"body": dict};
        
        NSDictionary *userInfo = @{@"command":postCommand};
        
        NSDictionary *parameterDict = @{@"postData":postData,@"urlAsString":urlAsString,@"userInfo":userInfo};
        API *api = [[API alloc] init];
        [api fetchJSON:parameterDict completionWithSuccess:^(NSDictionary *json) {
            
            NSArray *streamArray = [Factory stroriesFromJSON:[json objectForKey:@"response"]];
            [self receivedStories:streamArray];
            
        } failure:^(NSDictionary *json) {
            
            [self fetchinStoriesFailedWithError:nil];
        }];
        
        
    }
}

- (void)receivedStories:(NSArray *)completeRegistration
{
    if(isDeletingProcessed)
    {
        return;
    }
    
    if([timeStamp length] == 0)
    {
        [self.storiesArray removeAllObjects];
    }
    
    if([completeRegistration count] > 0)
    {
        NSDictionary *dict = [completeRegistration objectAtIndex:0];
        
        
        if(self.isRefreshing)
        {
            if([dict objectForKey:@"posts"]!= nil && [[dict objectForKey:@"posts"] count] > 0)
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                timeStamp = [dict objectForKey:@"last_modified"];
                postCount = [dict objectForKey:@"post_count"];
                storiesArray = [[dict objectForKey:@"posts"] mutableCopy];
                
            }
        }
        else
        {
            timeStamp = [dict objectForKey:@"last_modified"];
            postCount = [dict objectForKey:@"post_count"];
            if([storiesArray count] > 0)
            {
                
                [storiesArray addObjectsFromArray:[[dict objectForKey:@"posts"] mutableCopy]];
                
            }
            else
            {
                storiesArray = [[dict objectForKey:@"posts"] mutableCopy];
            }
            
            if([[dict objectForKey:@"posts"] count] == 0)
            {
                isMoreAvailabel = NO;
            }
            else
            {
                isMoreAvailabel  = YES;
            }
            
        }
        
        bProcessing = NO;
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:storiesArray];
        storiesArray = [orderedSet.array mutableCopy];
        
        //test if prompt is there yet
        NSDictionary *dict1 = [[NSDictionary alloc]init];
        
        if ([storiesArray count]>1)
        {
            dict1 = [storiesArray objectAtIndex:1];
        }
        
        [feedCollectionView reloadData];
        
        
    }
    
    [refreshControl endRefreshing];
    
}

- (void)fetchinStoriesFailedWithError:(NSError *)error
{
    bProcessing = NO;
    [refreshControl endRefreshing];
}


-(void)fetchPosts {
    
    [self clearAllData];
    [storiesArray removeAllObjects];
    [feedCollectionView reloadData];
    
    [self callStoresApi:@"next"];
}
#pragma mark -
#pragma CollectionView Delegate Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return storiesArray.count;
    
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ContentCell" forIndexPath:indexPath];
    cell.post = storiesArray[indexPath.row];
    cell.delegate = self;
    cell.postIndex = (int)indexPath.row;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float height = [self calculateHeightForRow:indexPath.row];
    
    return CGSizeMake(Devicewidth, height);
}
-(float )calculateHeightForRow:(long int)row {
    
    NSDictionary *post = [storiesArray objectAtIndex:row];
    float height = 16;
    
    //For Header (By and title bar)
    height += 25;
    
    //Title Height
    NSString *title = [post objectForKey:@"new_title"];
    if(title.length) {
        
        NSDictionary *attribs = @{
                                  NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:15]
                                  };
        
        ;
        
        CGSize expectedLabelSize = [title boundingRectWithSize:CGSizeMake(Devicewidth-16, 9999) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
        
        height += expectedLabelSize.height;
    }
    
    
    //If Images are there then Add that height
    if([[post objectForKey:@"images"] count] >0) {
        
        height += 300;
    }
    
    
    //Description Height
    
    if([[post objectForKey:@"text"] length] >0) {
        
        NSString *description = [NSString stringWithFormat:@"%@",[post objectForKey:@"text"]];
        
        
        NSDictionary *attribs = @{
                                  NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:13]
                                  };
        
        ;
        
        CGSize expectedLabelSize = [description boundingRectWithSize:CGSizeMake(Devicewidth-22, 9999) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
        
        height += expectedLabelSize.height+8;
        
        
    }
    
    //Tags and Heart Count Height
    if([[post objectForKey:@"tagged_to"] count] > 0 || [[post objectForKey:@"hearts_count"] intValue] > 0)
    {
        height += 30;
    }
    
    //Recent Comments Height
    NSArray *commentsArray = [post objectForKey:@"comments"];
    if(commentsArray.count >0)
    {
        NSDictionary *dict = [commentsArray lastObject];
        NSString *commentText = [NSString stringWithFormat:@"recent coment \n%@",[dict objectForKey:@"content"]];
        
        NSDictionary *attribs = @{
                                  NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:13]
                                  };
        
        ;
        
        CGSize expectedLabelSize = [commentText boundingRectWithSize:CGSizeMake(Devicewidth-22, 9999) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attribs context:nil].size;
        
        height += expectedLabelSize.height;
        
        // View More comments height
        if(commentsArray.count > 1) {
            
            height += 25;
        }
        
    }
    
    //Comment Button Height
    height += 35;
    
    return height;
    
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(storiesArray.count -1 == indexPath.row && isMoreAvailabel)
    {
        
        [self performSelectorInBackground:@selector(callStoresApi:) withObject:@"next"];;
    }
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    selelctedIndex = (int)indexPath.row;
    NSDictionary *post = [storiesArray objectAtIndex:indexPath.row];
    PostDetailedViewController *postCntrl = [[PostDetailedViewController alloc] init];
    postCntrl.delegate = self;
    postCntrl.post = [post mutableCopy];
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate.navgController pushViewController:postCntrl animated:YES];
    
    
}

- (void)commentClick:(int)index {
    
    selelctedIndex = index;
    NSDictionary *post = [storiesArray objectAtIndex:index];
    PostDetailedViewController *postCntrl = [[PostDetailedViewController alloc] init];
    postCntrl.delegate = self;
    postCntrl.showComment = YES;
    postCntrl.post = [post mutableCopy];
    AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appdelegate.navgController pushViewController:postCntrl animated:YES];
    

}
@end
