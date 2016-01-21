//
//  RegistersViewController.m
//  LoopChat
//
//  Created by XinJinquan on 2016/1/15.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "RegistersViewController.h"

@interface RegistersViewController () <UITextFieldDelegate, UIAlertViewDelegate, EMChatManagerDelegate>
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *userName;

@end

@implementation RegistersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)isEmpty
{
    BOOL ret = NO;
    NSString *user = _userName.text;
    NSString *pass = _password.text;
    if (([user  length]== 0 ) || ([pass length] == 0)) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle: @"错误"
                                    message:@"请输入正确密码"
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert showViewController:self sender:nil];
    }
    return ret;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _userName) {
        _password.text = @"";
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _userName) {
        [_userName resignFirstResponder];
        [_password becomeFirstResponder];
    } else if (textField == _password) {
        [_password resignFirstResponder];
        [self registers:nil];
    }
    return YES;
}

- (IBAction)registers:(id)sender {
    if (![self isEmpty]) {
        [self.view endEditing:YES];
        return;
    }

}


#pragma  mark - private
- (void)saveLastLoginUsername
{
    NSString *username = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:USER_NAME];
    if (username && username.length > 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:username forKey:[NSString stringWithFormat:@"em_lastLogin_%@",USER_NAME]];
        [ud synchronize];
    }
}

- (NSString*)lastLoginUsername
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *username = [ud objectForKey:[NSString stringWithFormat:@"em_lastLogin_%@",USER_NAME]];
    if (username && username.length > 0) {
        return username;
    }
    return nil;
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
