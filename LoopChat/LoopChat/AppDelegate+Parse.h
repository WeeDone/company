//
//  AppDelegate+Parse.h
//  LoopChat
//
//  Created by XinJinquan on 2016/2/18.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Parse)

- (void)parseApplication:(UIApplication *)appleaction didFinishLaunchWithOptons:(NSDictionary *)launchOptions;
- (void)initParse;
- (void)clearParse;


@end
