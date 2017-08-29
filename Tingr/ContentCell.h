//
//  ContentCell.h
//  Tingr
//
//  Created by Maisa Pride on 7/25/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASMediaFocusManager.h"

@protocol ContentCellDelegate <NSObject>
- (void)commentClick:(int)index;
@end


@interface ContentCell : UICollectionViewCell<ASMediasFocusDelegate>
@property (nonatomic, weak) id<ContentCellDelegate> delegate;
@property (nonatomic, strong) NSDictionary *post;
@property (nonatomic, assign) int postIndex;
@property (strong, nonatomic) ASMediaFocusManager *mediaFocusManager;
@end
