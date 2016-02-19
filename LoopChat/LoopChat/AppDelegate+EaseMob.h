//
//  AppDelegate+EaseMob.h
//  LoopChat
//
//  Created by XinJinquan on 2016/2/18.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (EaseMob)<EMChatManagerDelegate>

- (void)easemobApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
@end
