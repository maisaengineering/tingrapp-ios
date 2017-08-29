//
//  EditProfileViewController.h
//  Tingr
//
//  Created by Maisa Pride on 7/26/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import "Base64.h"

@interface EditProfileViewController : UIViewController<UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) ALAssetsLibrary * assetLibrary;

@end
