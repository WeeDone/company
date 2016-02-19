//
//  AppDelegate+Parse.m
//  LoopChat
//
//  Created by XinJinquan on 2016/2/18.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "AppDelegate+Parse.h"
#import "LCUserProfileManage.h"
@implementation AppDelegate (Parse)

- (void)parseApplication:(UIApplication *)appleaction didFinishLaunchWithOptons:(NSDictionary *)launchOptions
{
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"UUL8TxlHwKj7ZXEUr2brF3ydOxirCXdIj9LscvJs"
                  clientKey:@"B1jH9bmxuYyTcpoFfpeVslhmLYsytWTxqYqKQhBJ"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
}
- (void)initParse
{
    [[LCUserProfileManage sharedInstance]initParse];
}
- (void)clearParse
{
    [[LCUserProfileManage sharedInstance]clearParse];
}
@end
