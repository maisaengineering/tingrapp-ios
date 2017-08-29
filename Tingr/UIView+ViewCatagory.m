//
//  UIView+ViewCatagory.m
//  Tingr
//
//  Created by Maisa Pride on 7/17/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "UIView+ViewCatagory.h"

@implementation UIView (ViewCatagory)

-(void)addConstraintsWithFormat:(NSString *)format forViews:(NSArray *)viewsArray {

    NSMutableDictionary *viewsDictionary = [[NSMutableDictionary alloc] init];
    for(int index = 0; index < viewsArray.count; index++) {
        
        UIView *view = viewsArray[index];
        NSString *key = [NSString stringWithFormat:@"v%i",index];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        viewsDictionary[key] = view;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:viewsDictionary]];
    }
        
    }
    
@end
