//
//  PinViewController.m
//  Tingr
//
//  Created by Maisa Pride on 2/26/17.
//  Copyright © 2017 Maisa Pride. All rights reserved.
//

#import "PinViewController.h"

@interface PinViewController ()
{
    
    CGRect keyboardFrameBeginRect;
    UIView *modelView;

}
@end

@implementation PinViewController

@synthesize textField1;
@synthesize textField2;
@synthesize textField3;
@synthesize textField4;
@synthesize linkButton;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showKeyBoard)
                                                 name:@"SHOW_KEYBOARD_PINVIEW"
                                               object:nil];
    
    
    
    [self setupViews];
    [textField1.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textField1.layer setBorderWidth:1];
    [textField1.layer setCornerRadius:5];
    
    [textField2.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textField2.layer setBorderWidth:1];
    [textField2.layer setCornerRadius:5];
    
    [textField3.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textField3.layer setBorderWidth:1];
    [textField3.layer setCornerRadius:5];
    
    [textField4.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textField4.layer setBorderWidth:1];
    [textField4.layer setCornerRadius:5];
    
    
    [textField4.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [textField4.layer setBorderWidth:1];
    [textField4.layer setCornerRadius:5];
    
    
    
    [self.continueButton.layer setCornerRadius:5];
    
    [textField1 becomeFirstResponder];
    
    NSDictionary * linkAttributes = @{NSForegroundColorAttributeName:UIColorFromRGB(0x1B7EF9), NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:linkButton.titleLabel.text attributes:linkAttributes];
    [linkButton.titleLabel setAttributedText:attributedString];
    [linkButton setTitleColor:UIColorFromRGB(0x1B7EF9) forState:UIControlStateNormal];
    
}

-(void)setupViews {
    
    UIView *blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Devicewidth, Deviceheight)];
    [blackView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    [self.view addSubview:blackView];
    
    modelView = [[UIView alloc] initWithFrame:CGRectMake(0, 50, Devicewidth, 212)];
    [modelView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:modelView];

    modelView.center = self.view.center;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, Devicewidth, 21)];
    [nameLabel setText:@"Enter your PIN"];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [modelView addSubview:nameLabel];
    
    
    
    float distance = (Devicewidth - 60 - 200)/3.0;
    
    textField1 = [[UITextField alloc] initWithFrame:CGRectMake(30, 59,50,50)];
    textField1.delegate = self;
    textField1.borderStyle = UITextBorderStyleNone;
    textField1.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField1.textAlignment = NSTextAlignmentCenter;
    textField1.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
    textField1.autocorrectionType = UITextAutocorrectionTypeNo;
    [textField1 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [modelView addSubview:textField1];

    textField2 = [[UITextField alloc] initWithFrame:CGRectMake(textField1.frame.origin.x+textField1.frame.size.width + distance, 59,50,50)];
    textField2.delegate = self;
    textField2.borderStyle = UITextBorderStyleNone;
    textField2.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField2.textAlignment = NSTextAlignmentCenter;
    textField2.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
    [textField2 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    textField2.autocorrectionType = UITextAutocorrectionTypeNo;
    [modelView addSubview:textField2];

    textField3 = [[UITextField alloc] initWithFrame:CGRectMake(textField2.frame.origin.x+textField2.frame.size.width + distance, 59,50,50)];
    textField3.delegate = self;
    textField3.borderStyle = UITextBorderStyleNone;
    textField3.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField3.textAlignment = NSTextAlignmentCenter;
    textField3.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
    [textField3 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    textField3.autocorrectionType = UITextAutocorrectionTypeNo;
    [modelView addSubview:textField3];

    textField4 = [[UITextField alloc] initWithFrame:CGRectMake(textField3.frame.origin.x+textField3.frame.size.width + distance, 59,50,50)];
    textField4.delegate = self;
    textField4.borderStyle = UITextBorderStyleNone;
    textField4.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField4.textAlignment = NSTextAlignmentCenter;
    textField4.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
    [textField4 addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    textField4.autocorrectionType = UITextAutocorrectionTypeNo;
    [modelView addSubview:textField4];

    
    self.continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.continueButton.frame = CGRectMake((Devicewidth-120)/2, 134, 120, 35);
    [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
    [self.continueButton addTarget:self action:@selector(continueTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.continueButton.backgroundColor = [UIColor colorWithRed:95/255.0 green:167/255.0 blue:239/255.0 alpha:1.0];
    [self.continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.continueButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [modelView addSubview:self.continueButton];
    
    self.linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.linkButton.frame = CGRectMake(0, 134+35, Devicewidth, 30);
    [self.linkButton setTitle:@"tap here to find your pin" forState:UIControlStateNormal];
    [self.linkButton addTarget:self action:@selector(linkToKidsTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.linkButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.linkButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [modelView addSubview:self.linkButton];
    
    
    
    
    
    
}
-(void)viewWillAppear:(BOOL)animated {
    
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:YES];
}
-(void)showKeyBoard {
    
    if(textField1.text.length == 0)
        [textField1 becomeFirstResponder];
    else if(textField2.text.length == 0)
        [textField2 becomeFirstResponder];
    else if(textField3.text.length == 0)
        [textField3 becomeFirstResponder];
    else
        [textField4 becomeFirstResponder];
    
}
- (void)keyboardWillShow:(NSNotification*)notification {
    
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    float yPostion = 0;
    
    yPostion =  Deviceheight - kbSize.height;
    CGRect frame = modelView.frame;
    frame.origin.y = yPostion - frame.size.height - 5;
    modelView.frame = frame;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)hideKeyBoard
{
    [textField1 resignFirstResponder];
    [textField2 resignFirstResponder];
    [textField3 resignFirstResponder];
    [textField4 resignFirstResponder];
}

-(IBAction)continueTapped:(id)sender
{
    if([self validateFields:textField1] && [self validateFields:textField2] && [self validateFields:textField3] && [self validateFields:textField4])
    {
        [self hideKeyBoard];
        NSString *verificationCode = [NSString stringWithFormat:@"%@%@%@%@",textField1.text,textField2.text,textField3.text,textField4.text];
        [self.delegate enteredPin:verificationCode];
    }
    else {
        
        [self validationAlert:ALL_FIELDS_REQUIRED];
    }
}
-(void)validationAlert: (NSString *) comment
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Alert"
                          message:comment
                          delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    
    [alert show];
}

- (BOOL)validateFields:(UITextField *)textField
{
    NSString *trimvalue;
    BOOL isValidField;
    trimvalue = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    isValidField = trimvalue.length > 0;
    return isValidField;
}


-(void)textFieldDidChange:(UITextField *)textField
{
    if(textField.text.length > 0)
    {
        if(textField == textField1)
        {
            [textField2 becomeFirstResponder];
        }
        if(textField == textField2)
        {
            [textField3 becomeFirstResponder];
        }
        if(textField == textField3)
        {
            [textField4 becomeFirstResponder];
        }
    }
    else
    {
        if(textField == textField4)
        {
            [textField3 becomeFirstResponder];
        }
        if(textField == textField3)
        {
            [textField2 becomeFirstResponder];
        }
        if(textField == textField2)
        {
            [textField1 becomeFirstResponder];
        }
    }
    
}

- (IBAction)linkToKidsTapped:(id)sender {
    
    //[self hideKeyBoard];
    [self.delegate gotoKidDashboard];
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if( textField.text.length > 0 && string.length > 0)
    {
        return NO;
    }
    return YES;
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
