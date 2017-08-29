//
//  NIDropDown.m
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"

@interface NIDropDown ()
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, retain) NSArray *list;
@property(nonatomic, retain) NSArray *imageList;
@property(nonatomic) float bWidth;
@end

@implementation NIDropDown
@synthesize table;
@synthesize btnSender;
@synthesize list;
@synthesize imageList;
@synthesize delegate;
@synthesize bWidth;
@synthesize animationDirection;

- (id)showDropDown:(UIButton *)b :(CGFloat *)height :(NSArray *)arr :(NSArray *)imgArr :(NSString *)direction :(float)width{
    btnSender = b;
    animationDirection = direction;
    bWidth = width;
    self.table = (UITableView *)[super init];
    if (self) {
        // Initialization code
        CGRect btn = b.frame;
        self.list = [NSArray arrayWithArray:arr];
        self.imageList = [NSArray arrayWithArray:imgArr];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+b.superview.frame.origin.y, (bWidth), 0);
            self.layer.shadowOffset = CGSizeMake(-5, -5);
        }else if ([direction isEqualToString:@"down"]) {
            
            if(btn.origin.x + bWidth > Devicewidth-10)
            {
                self.frame = CGRectMake(Devicewidth-10 - bWidth, btn.origin.y+btn.size.height+b.superview.frame.origin.y, (bWidth), 0);
            }
            else
                self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height+b.superview.frame.origin.y, (bWidth), 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
        }
        
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, bWidth, 0)];
        table.delegate = self;
        table.dataSource = self;
        table.layer.cornerRadius = 5;
        table.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        table.separatorColor = [UIColor grayColor];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, b.superview.frame.origin.y+btn.origin.y-*height, (bWidth), *height);
        } else if([direction isEqualToString:@"down"]) {
            
            if(btn.origin.x + bWidth > Devicewidth-10)
            {
                self.frame = CGRectMake(Devicewidth-10 - bWidth, btn.origin.y+btn.size.height+b.superview.frame.origin.y, (bWidth), *height);
            }
            else
                self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height+b.superview.frame.origin.y, (bWidth), *height);

            
        }
        table.frame = CGRectMake(0, 0, (bWidth), *height);
        [UIView commitAnimations];
        
        [[[[UIApplication sharedApplication] windows] lastObject] addSubview:self];;
        [self addSubview:table];
    }
    return self;
}

-(void)hideDropDown:(UIButton *)b {
    CGRect btn = b.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    if ([animationDirection isEqualToString:@"up"]) {
        self.frame = CGRectMake(self.frame.origin.x, btn.origin.y+b.superview.frame.origin.y, (bWidth), 0);
    }else if ([animationDirection isEqualToString:@"down"]) {
        
        
        self.frame = CGRectMake(self.frame.origin.x, btn.origin.y+btn.size.height+b.superview.frame.origin.y, (bWidth), 0);
    }
    table.frame = CGRectMake(0, 0, (bWidth), 0);
    [UIView commitAnimations];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        
    }
    cell.textLabel.text = [list objectAtIndex:indexPath.row];
    cell.textLabel.textColor = UIColorFromRGB(0x1B7EF9);
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self hideDropDown:btnSender];
    [self.delegate selectedIndex:(int) indexPath.row];
}

- (void) myDelegate {
    [self.delegate niDropDownDelegateMethod:self];
}

-(void)dealloc {
//    [super dealloc];
//    [table release];
//    [self release];
}

@end
