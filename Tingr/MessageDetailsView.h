//
//  MessageDetailsView.h
//  Tingr
//
//  Created by Maisa Pride on 7/28/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageDetailsView : UIView<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (nonatomic, strong)  UITableView *messageDetailTableView;
@property (nonatomic, strong) NSMutableDictionary *messagesData;
@property (nonatomic, strong) NSDictionary *messageDictFromLastPage;
@property (nonatomic, strong) UIView *commentView;
@property (nonatomic, strong) UITextView *txt_comment;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) BOOL bProcessing;
-(void)fetchData;
@end
