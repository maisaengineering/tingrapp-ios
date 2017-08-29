//
//  ProfilePhotoUtils.h
//  KidsLink
//
//  Created by Dale McIntyre on 4/22/14.
//  Copyright (c) 2014 Kids Link. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+animatedGIF.h"
@interface ProfilePhotoUtils : NSObject

- (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (UIImage *)makeRoundKidPhoto:(UIImage *)personImage;
- (UIImage *)makeRoundWithBoarder:(UIImage *)fooImage withRadious:(float)value;
-(UIImage *)makeRoundedCornersWithBorder:(UIImage *)fooImage withRadious:(float)value;
- (UIImage *)getImageFromCache:(NSString *)url;
- (UIImageView*)GrabInitials :(int)diameter :(NSString *)firstName :(NSString *)lastName;
- (void)saveImageToCache:(NSString *)url :(UIImage *)personImage;
- (UIImage *)compressForUpload:(UIImage *)original :(CGFloat)scale;
- (void)clearCache;
- (void)saveImageToPhotoLib:(NSURL *)filePath;
- (void)saveVideoToPhotoLib:(NSURL *)filePath;
-(void)downLoadImagewithUrl:(NSString *)imageUrl;
-(void)downLoadVideowithUrl:(NSString *)videoUrl;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToMaxWidth:(CGFloat)width maxHeight:(CGFloat)height;
- (void)saveRoundedRectImageToCache:(NSString *)url :(UIImage *)image;
- (UIImage *)getGIFImageFromCache:(NSString *)url;
- (void)saveImageToCacheWithData:(NSString *)url :(NSData *)data;

@property (nonatomic, strong) ALAssetsLibrary     * assetLibrary;

@end
