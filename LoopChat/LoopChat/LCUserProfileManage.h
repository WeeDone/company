

//
//  LCUserProfileEntity.h
//  LoopChat
//
//  Created by XinJinquan on 2016/2/1.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LC_RARSE_USER @"hxuser"
#define LC_PARSE_USERNAME @"username"
#define LC_PARSE_NICKNAME @"nickname"
#define LC_PARSE_USER_AVATAR @"avatar"

@class MessageModel;
@class PFObject;
@class UserProfileEntity;




@interface LCUserProfileManage : NSObject

+ (instancetype)sharedInstance;
- (void)initParse;
- (void)clearParse;
// 上传个人头像
- (void)uploadUserHeadImageProfileInBackground:(UIImage *)image
                                    completion:(void (^)(BOOL success, NSError *error))completion;

//上传个人信息
- (void)updateUserProfileInBackground:(NSDictionary *)param
                           completion:(void (^)(BOOL success, NSError *error))completion;
//获取用户信息
- (void)loadUserProfileInBackground:(NSArray *)buddyList
                        saveToLocal:(BOOL)save
                         completion:(void(^)(BOOL success, NSError *error))completion;
//获取用户信息 by username
- (void)loadUserProfileInbackground:(NSArray *)username
                       saveToLoacal:(BOOL)save
                         completion:(void (^)(BOOL success, NSError *error))completion;
//获取本地用户信息
- (UserProfileEntity *)getUserProfileByUsername:(NSString *)username;
// 获取当前用户信息
- (UserProfileEntity *)getCulUserProfile;
//获取用户名昵称
- (NSString *)getNickNmaeWithUsername:(NSString *)username;


@end

@interface UserProfileEntity: NSObject

+ (instancetype)initWithPFObject:(PFObject *)object;

@property (nonatomic, strong) NSString *objectID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *imageURL;

@end