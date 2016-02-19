//
//  AppDelegate+EaseMob.m
//  LoopChat
//
//  Created by XinJinquan on 2016/2/18.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "AppDelegate+EaseMob.h"

@implementation AppDelegate (EaseMob)

static const NSString *apnsCerName = @"";

- (void)easemobApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (launchOptions) {
        NSDictionary *userInfo = [launchOptions objectForKey:@"UIApplecationLaunchOptionRemoteNotificationKey"];
        if (userInfo) {

        }
    }
    [[EaseMob sharedInstance]application:application
           didFinishLaunchingWithOptions:launchOptions];
 
    [self setupNotifiers];
}
- (void)setupNotifiers
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appDidEnterBackgroundNotification:)
                                                name:UIApplicationDidEnterBackgroundNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appWillEnterForground:)
                                                name:UIApplicationWillEnterForegroundNotification
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(appDidFinishLaunching:)
                                                name:UIApplicationDidFinishLaunchingNotification
                                              object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActiveNotif:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateNotif:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataWillBecomeUnavailableNotif:)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataDidBecomeAvailableNotif:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];

}


#pragma mark - notification

- (void)appDidEnterBackgroundNotification:(NSNotification *)notification
{
    [[EaseMob sharedInstance]applicationDidEnterBackground:notification.object];
}
- (void)appWillEnterForground:(NSNotification *)notification
{
    [[EaseMob sharedInstance]applicationWillEnterForeground:notification.object];
}

- (void)appDidFinishLaunching:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidFinishLaunching:notif.object];
}

- (void)appDidBecomeActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidBecomeActive:notif.object];
}

- (void)appWillResignActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillResignActive:notif.object];
}

- (void)appDidReceiveMemoryWarning:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidReceiveMemoryWarning:notif.object];
}

- (void)appWillTerminateNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillTerminate:notif.object];
}

- (void)appProtectedDataWillBecomeUnavailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataWillBecomeUnavailable:notif.object];
}

- (void)appProtectedDataDidBecomeAvailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataDidBecomeAvailable:notif.object];
}

//将得到的deviceToKen 传给SDK
- (void)application:(UIApplication *)application
            didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{
    [[EaseMob sharedInstance]application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)registerRemoteNotifaction
{
    UIApplication *applcation = [UIApplication sharedApplication];
    applcation.applicationIconBadgeNumber = 0;
    if ([applcation respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType notificationType = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationType categories:nil];
        [applcation registerUserNotificationSettings:settings];
    }
}

#pragma mark - registerEaseMobNotification

-(void)registerEaseMobNotification
{
    [self unRegisterEaseMobNotification];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
}
- (void)unRegisterEaseMobNotification
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

#pragma mark - chat manager delegate

- (void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    UIAlertController *alertController = nil;
    if (error) {
        alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"提示" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"loginStateChange" object:@NO];
    } else {
        alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"等待自动登录" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"提示" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        
        [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
    }
    [alertController presentViewController:alertController animated:YES completion:nil];
}


























@end
