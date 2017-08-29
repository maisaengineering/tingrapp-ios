//
//  PinViewController.h
//  Tingr
//
//  Created by Maisa Pride on 2/26/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PinViewDelegate <NSObject>
- (void)enteredPin:(NSString *)pin;
-(void)gotoKidDashboard;
@end


@interface PinViewController : UIViewController<UITextFieldDelegate>
{
}
@property (strong, nonatomic)  UIButton *linkButton;
@property (nonatomic, strong)  UITextField *textField1;
@property (nonatomic, strong)  UITextField *textField2;
@property (nonatomic, strong)  UITextField *textField3;
@property (nonatomic, strong)  UITextField *textField4;
@property (nonatomic, strong)  UIButton *continueButton;
@property (nonatomic, strong)  UIView *modelView;
@property (nonatomic, strong) NSDictionary *selectedKidDetails;

@property (nonatomic,weak) id <PinViewDelegate> delegate;
-(void)continueTapped:(id)sender;
-(void)textFieldDidChange:(UITextField *)textField;
- (void)linkToKidsTapped:(id)sender;

@property (strong, nonatomic)  UIButton *linkToKIdsTocBtn;

@end
