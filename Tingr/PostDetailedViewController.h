//
//  PostDetailedViewController.h
//  Tingr
//
//  Created by Maisa Pride on 7/29/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASMediaFocusManager.h"
@protocol PostDetailedDelegate <NSObject>
- (void)changedDetails:(NSDictionary *)postDict;

@end


@interface PostDetailedViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,ASMediasFocusDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) NSMutableDictionary *post;
@property (strong, nonatomic) ASMediaFocusManager *mediaFocusManager;
@property (nonatomic, strong)  UITableView *messageDetailTableView;
@property (nonatomic, weak) id<PostDetailedDelegate> delegate;
@property (nonatomic, strong) UIView *commentView;
@property (nonatomic, strong) UITextView *txt_comment;
@property (nonatomic, assign) BOOL showComment;



@end
