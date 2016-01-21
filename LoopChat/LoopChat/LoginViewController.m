//
//  LoginViewController.m
//  LoopChat
//
//  Created by XinJinquan on 2016/1/15.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UILabel *userNmae;
@property (strong, nonatomic) IBOutlet UILabel *password;
@property (strong, nonatomic) IBOutlet UIButton *registers;
@property (strong, nonatomic) IBOutlet UIButton *login;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UITextField *userNameText;

@end

@implementation LoginViewController
static  BOOL pushFlag;
- (void)viewDidLoad {
    [super viewDidLoad];
    pushFlag = NO;
    [self.view setBackgroundColor:[UIColor colorWithRed:72 / 255.0 green:62 / 255.0 blue:39 / 255.0 alpha:1.0]];
    self.passwordText.secureTextEntry = YES;
    self.passwordText.keyboardType = UIKeyboardTypeDefault;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1];
    NSShadow  *shadow = [[NSShadow alloc]init];
    shadow.shadowColor = [UIColor colorWithRed:0 green:0.7f blue:0.8f alpha:1];
    shadow.shadowOffset = CGSizeMake(0, 0);
    NSDictionary *dic = @{
                          NSForegroundColorAttributeName:[UIColor whiteColor],
                          NSShadowAttributeName:shadow,
                          NSFontAttributeName:[UIFont boldSystemFontOfSize:18],
                          };
    [self.navigationController.navigationBar setTitleTextAttributes:dic];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.userNmae setBackgroundColor:[UIColor grayColor]];
    [self.password setBackgroundColor:[UIColor grayColor]];
    self.userNmae.alpha = 0.5;
    self.password.alpha = 0.5;
    self.login.layer.cornerRadius = 4;
    [self.login.layer setMasksToBounds:YES];
    self.navigationItem.hidesBackButton = YES;
    // Do any additional setup after loading the view.
}

- (IBAction)login:(id)sender {
    [self.passwordText resignFirstResponder];
    [self.userNameText resignFirstResponder];
}
- (void)userLoginSave {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.userNameText.text forKey:USER_NAME];
    [userDefaults setObject:self.passwordText.text forKey:USER_PASSWORD];
    [userDefaults synchronize];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    _userNameText.text = @"";
    _passwordText.text = @"";
    [self.navigationController.navigationBar setHidden:NO];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (pushFlag) {
        [self.navigationController.navigationBar setHidden:NO];
    } else {
        [self.navigationController.navigationBar setHidden:YES];
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.userNameText resignFirstResponder];
    [self.passwordText resignFirstResponder];
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
