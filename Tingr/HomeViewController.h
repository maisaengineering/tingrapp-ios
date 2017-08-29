//
//  ViewController.h
//  Tingr
//
//  Created by Maisa Pride on 7/17/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
@interface HomeViewController : UIViewController<UIGestureRecognizerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>


@property(nonatomic, strong) UICollectionView *pageCollectionView;
@property(nonatomic, strong) NSMutableArray *organisationaArray;
@end

