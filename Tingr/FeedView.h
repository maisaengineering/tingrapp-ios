//
//  FeedView.h
//  Tingr
//
//  Created by Maisa Pride on 7/30/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostDetailedViewController.h"
#import "ContentCell.h"
@interface FeedView : UIView<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate,PostDetailedDelegate,ContentCellDelegate>
@property (nonatomic, strong) NSString *orgID;
@property (nonatomic) BOOL bProcessing;
@property (nonatomic, strong) UICollectionView *feedCollectionView;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isDeletingProcessed;
@property (nonatomic, strong) NSMutableArray *storiesArray;
@property (nonatomic, assign) BOOL isMoreAvailabel;


-(void)clearAllData;
-(void)fetchPosts;


@end
