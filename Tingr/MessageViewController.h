//
//  MessageViewController.h
//  Tingr
//
//  Created by Maisa Pride on 7/28/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *pageCollectionView;
@property (nonatomic, assign) BOOL isFromPushNotification;
@property(nonatomic, strong) NSDictionary *pushNotificationDict;

@end
