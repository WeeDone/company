//
//  LCUserProfileEntity.m
//  LoopChat
//
//  Created by XinJinquan on 2016/2/1.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "LCUserProfileManage.h"
#import "MessageModel.h"

#define CURRENT_USERNAME [[[EaseMob sharedInstance].chatManager loginInfo]objectForKey:USER_NAME]


@implementation UIImage (UIImageExt)

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *socurceImage = self;
    UIImage *newImage = self;
    CGSize imageSize = socurceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaleWidth = targetWidth;
    CGFloat scaleHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
            scaleWidth = widthFactor * scaleFactor;
            scaleHeight = height * scaleFactor;
        }
    }
    UIGraphicsBeginImageContext(targetSize);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaleWidth;
    thumbnailRect.size.height = scaleHeight;
    [socurceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if (newImage == nil) {
        NSLog(@"could not scale image");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

@end

static LCUserProfileManage *sharedInstance = nil;

@interface LCUserProfileManage ()
{
    NSString *_curUsername;
}

@property (nonatomic, strong) NSMutableDictionary *users;
@property (nonatomic, strong) NSString *objectID;
@property (nonatomic, strong) PFACL *defalutACL;

@end


@implementation LCUserProfileManage

#pragma mark - init monthod

+ (instancetype)sharedInstance
{
    static dispatch_once_t oneToKen;
    dispatch_once (&oneToKen, ^{
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _users = [NSMutableDictionary dictionary];
        [_defalutACL setPublicReadAccess:YES];
        [_defalutACL setPublicWriteAccess:YES];
    }
    return self;
}
- (void)initParse
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    id objectID = [ud objectForKey:[NSString stringWithFormat:@"%@%@", LC_RARSE_USER, CURRENT_USERNAME]];
    if ([objectID isKindOfClass:[NSString class]]) {
        self.objectID = objectID;
    }
    _curUsername = CURRENT_USERNAME;
    [self initData];
}
- (void)initData
{
    [self.users removeAllObjects];
    PFQuery *query = [PFQuery queryWithClassName:LC_RARSE_USER];
    [query fromPinWithName:CURRENT_USERNAME];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects && [objects count] > 0) {
            for (id user in objects) {
                if ([user isKindOfClass:[PFObject class]]) {
                    UserProfileEntity *entity = [UserProfileEntity initWithPFObject:user];
                    if (entity.username.length > 0) {
                        [self.users setObject:entity forKey:entity.username];
                    }
                }
            }
        }
    }];
}
- (void)clearParse
{
    self.objectID = nil;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:[NSString stringWithFormat:@"%@%@",LC_RARSE_USER,CURRENT_USERNAME]];
     _curUsername = nil;
     [self.users removeAllObjects];
}

- (void)uploadUserHeadImageProfileInBackground:(UIImage *)image
                                    completion:(void (^)(BOOL, NSError *))completion
{
    UIImage *img = [image imageByScalingAndCroppingForSize:CGSizeMake(120.f, 120.f)];
    if (_objectID && _objectID.length > 0) {
        PFObject *object = [PFObject objectWithoutDataWithClassName:LC_RARSE_USER objectId:_objectID];
        NSData *imageData = UIImageJPEGRepresentation(img, 0.5);
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        object[LC_RARSE_USER] = imageFile;
        __weak PFObject *weakObj = object;
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (completion) {
                if (succeeded) {
                    [self P_SavePFUserInDisk:weakObj];
                }
                completion(succeeded, error);
            }
        }];
    } else {

    }
    
}
- (void)updateUserProfileInBackground:(NSDictionary *)param
                           completion:(void (^)(BOOL, NSError *))completion
{
    if (_objectID && _objectID.length > 0) {
        PFObject *object = [PFObject objectWithoutDataWithClassName:LC_RARSE_USER objectId:_objectID];
        if (param != nil && [[param allKeys] count] > 0) {
            for (NSString *key in param) {
                [object setObject:[param objectForKey:key] forKey:key];
            }
        }
        __weak PFObject *weakObj = object;
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (completion) {
                if (succeeded) {
                    [self P_SavePFUserInDisk:weakObj];
                }
                completion(succeeded, error);
            }
        }];
    } else {
        [self queryPFObjectWithComlpetion:^(PFObject *object, NSError *error) {
            if (object) {
            if (param != nil && [[param allKeys]count] > 0) {
                for (NSString *key in param) {
                    [object setObject:[param objectForKey:key] forKey:key];
                }
            }
                __weak PFObject *weakObj = object;
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (completion) {
                        if (succeeded) {
                            [self P_SavePFUserInDisk:weakObj];
                        }
                        completion(succeeded, error);
                    }
                    
                }];
            } else {
                if (completion) {
                    completion(NO, error);
                }
            }
        }];
    }
         
}
- (void)loadUserProfileInBackground:(NSArray *)buddyList
                        saveToLocal:(BOOL)save
                         completion:(void (^)(BOOL, NSError *))completion
{
    NSMutableArray *username = [NSMutableArray array];
    for (EMBuddy *buddy in buddyList) {
        if ([buddy.username length]) {
            if (![self getUserProfileByUsername:buddy.username]) {
                [username addObject:buddy.username];
            }
        }
    } if ([username count] == 0) {
        if (completion) {
            completion(YES, nil);
        }
        return;
    }

}
- (void)loadUserProfileInbackground:(NSArray *)username
                       saveToLoacal:(BOOL)save
                         completion:(void (^)(BOOL, NSError *))completion
{
    PFQuery *query = [PFQuery queryWithClassName:LC_PARSE_USERNAME];
    [query whereKey:LC_PARSE_USERNAME containedIn:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            for (id user in objects) {
                if ([user isKindOfClass:[PFObject class]]) {
                    PFObject *pfUser = (PFObject *)user;
                    if (save) {
                        [self P_SavePFUserInDisk:pfUser];
                    } else {
                        [self P_SavePFUserInMemory:pfUser];
                    }
                }
            } if (completion) {
                completion(YES, nil);
            }
        }   else {
                if (completion) {
                    completion(NO, error);
                }

            }
    }];
}
- (UserProfileEntity *)getUserProfileByUsername:(NSString *)username
{
    if ([_users objectForKey:username]) {
        return [_users objectForKey:username];
    }
    return nil;
}
- (UserProfileEntity *)getCulUserProfile
{
    if ([_users objectForKey:LC_PARSE_USERNAME]) {
        return [_users objectForKey:LC_PARSE_USERNAME];
    }
    return nil;
}

- (NSString *)getNickNmaeWithUsername:(NSString *)username
{
    UserProfileEntity *entity = [self getUserProfileByUsername:username];
    if (entity.nickName && entity.nickName.length >0 ) {
        return entity.nickName;
    } else {
        return username;
    }
}

#pragma mark - private 

- (void)P_SavePFUserInDisk:(PFObject *)object
{
    if (object) {
        [object pinInBackgroundWithName:CURRENT_USERNAME];
        [self P_SavePFUserInMemory:object];
    }
}
- (void)P_SavePFUserInMemory:(PFObject *)object
{
    if (object) {
        UserProfileEntity *entity = [UserProfileEntity initWithPFObject:object];
        [_users setObject:entity forKey:entity.username];
    }
}

- (void)queryPFObjectWithComlpetion:(void(^)(PFObject *object, NSError *error))completion
{
    PFQuery *query = [PFQuery queryWithClassName:LC_RARSE_USER];
    [query whereKey:LC_PARSE_USERNAME equalTo:CURRENT_USERNAME];
    __weak typeof (self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            if (objects && [objects count] > 0) {
                PFObject *object = [objects objectAtIndex:0];
                [object setACL:weakSelf.defalutACL];
                weakSelf.objectID = object.objectId;
                
            }
        }
    }];
    
}


@end


@implementation UserProfileEntity

+ (instancetype) initWithPFObject:(PFObject *)object
{
    UserProfileEntity *entity = [[UserProfileEntity alloc]init];
    entity.username = object[LC_PARSE_USERNAME];
    entity.nickName = object[LC_PARSE_NICKNAME];
    PFFile *userImageFile = object[LC_PARSE_USER_AVATAR];
    if (userImageFile) {
        entity.imageURL = userImageFile.url;
    }
    return entity;
}

@end


