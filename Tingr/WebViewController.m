//
//  WebViewController.m
//  Tingr
//
//  Created by Maisa Pride on 7/24/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

{
    UIWebView *webView;
}
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    webView = [[UIWebView alloc] init];
    [webView setFrame:self.view.bounds];
    [webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    [self.view addSubview:webView];
    
    
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setFrame:CGRectMake(Devicewidth-64, 10, 64, 64)];
    [menuButton setImage:[UIImage imageNamed:@"navigation_close"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:menuButton];

}
-(void)backClicked {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
