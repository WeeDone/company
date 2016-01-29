//
//  SQChatVC.m
//  LoopChat
//
//  Created by XinJinquan on 2016/1/18.
//  Copyright © 2016年 XinJinquan. All rights reserved.
//

#import "SQChatVC.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MessageModel.h"
#import "MessageModelManager.h"
#import "EMChatTimeCell.h"
#import "LocationViewController.h"
#import "MessageReadManager.h"
#import "EMChatViewCell.h"
#import "LCChatBarMoreView.h"
#import "ChatSendHelper.h"

#import "CLMessageTooBar.h"


#define LP_PAGECOUNT 20
#define SELF_HEIGHT  self.view.frame.size.height
@interface SQChatVC ()<UITableViewDelegate, UITableViewDataSource,
UINavigationControllerDelegate, IChatManagerDelegate, UITextFieldDelegate ,
UIImagePickerControllerDelegate, EMCallManagerDelegate, LCChatBarMoreViewDelegate,
CLMessageTooBarDelegate, LocationViewDelegate>
{
    UIMenuController *menuController;
    UIMenuItem *copyMenuItem;
    UIMenuItem *deleteItem;
    NSIndexPath *longPressIndexPath;
    NSInteger recordingCound;
    dispatch_queue_t message_quque;
    NSMutableArray *messageSend;
    BOOL isScorllTobtn;
}

@property (strong, nonatomic) IBOutlet UITextField *sendMessageField;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic) BOOL   isChatGroup;
@property (nonatomic, strong) NSDate *chatDate;
@property (nonatomic, strong) NSString *messages;
@property (nonatomic, strong) CLMessageTooBar *chatToolBar;
@property (nonatomic, strong) MessageReadManager *messageRead;
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic) EMConversationType conversationType;
@property (nonatomic, strong) NSMutableArray *messagess;
@property (nonatomic) BOOL   isScollToBtn;
@property (nonatomic) BOOL  isKicked;
@end

@implementation SQChatVC
- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup
{
    EMConversationType type = isGroup ? eConversationTypeGroupChat :eConversationTypeChat;
    self = [self initWithChatter:chatter isGroup:type];
    if (self) {
        //
    }
    return self;
    
}
- (instancetype)initWithNibChatter:(NSString *)chatter conversaionType:(EMConversationType)type
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _chatter = chatter;
        _conversationType = type;
        _messagess = [NSMutableArray array];
        _conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatter conversationType:type];
        [_conversation markAllMessagesAsRead:YES];
    }
    return self;
}
- (BOOL)isChatGroup
{
    return _conversation != eConversationTypeChat;
}
- (void)saveChatRoom:(EMChatroom *)chatRoom
{
    NSString *chatRoomName = chatRoom.chatroomSubject ?chatRoom.chatroomSubject :@"";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"onceJoinedChatRoom_%@",[[[EaseMob sharedInstance].chatManager loginInfo]objectForKey:@"username"]];
    NSMutableDictionary *chatRooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
    if (![chatRooms objectForKey:chatRoom.chatroomId]) {
        [chatRooms setObject:chatRoomName forKey:chatRoom.chatroomId];
        [ud setObject:chatRooms forKey:key];
        [ud synchronize];
    }
}
- (void)hideImagePicker
{
    [self.imagePicker  dismissViewControllerAnimated:YES completion:nil];
    self.inInvisble = YES;
}

- (void)sendImageMessage:(UIImage *)image
{
    NSDictionary *ext = nil;
    EMMessage *tempMessage = [ChatSendHelper sendImageMessageWithImage:image
                                                            toUsername:_conversation.chatter
                                                           messageType:YES
                                                     requireEncryption:NO
                                                                   ext:ext];
    [self addMessage:tempMessage];
}
- (void)joinChatRoom:(NSString *)charRoomId
{
    __weak typeof (self) weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncJoinChatroom:charRoomId
                                                 completion:^(EMChatroom *chatroom, EMError *error) {
    if (weakSelf) {
         SQChatVC *strongSelf = weakSelf;
        if (error && (error.errorCode != EMErrorChatroomJoined)) {
            NSLog(@"error %@",strongSelf);
        } else {
            [strongSelf saveChatRoom:chatroom];
        }
    } else {
        if (!error || (error.errorCode == EMErrorChatroomJoined)) {
            [[EaseMob sharedInstance].chatManager asyncLeaveChatroom:charRoomId
                                                          completion:^(EMChatroom *chatroom, EMError *error) {
                                                              [[EaseMob sharedInstance].chatManager
                                                               removeConversationByChatter:charRoomId
                                                                            deleteMessages:YES
                                                                               append2Chat:YES];
                                                          }];
                }
            }
                                                 }];
}

- (CLMessageTooBar *)chatToolBar
{
    if (!_chatToolBar) {
        _chatToolBar = [[CLMessageTooBar alloc]initWithFrame:CGRectMake(0
                                                                       , SELF_HEIGHT - [CLMessageTooBar defalutHeight],
                                                                       _chatToolBar.frame.size.width
                                                                        , 80)];
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _chatToolBar.delagate = self;
        ChatMoreType type = self.isChatGroup == YES ? ChatMoreTypeGroupChat : ChatMoreTypeChat;
        _chatToolBar.moreView = [[LCChatBarMoreView alloc]initWithFrame:CGRectMake(0
                                                                                  , (VERTICAL_PADDING * 2 + INPUT_TEXTVIEW_MIN_HEIGHT)
                                                                                  , _chatToolBar.frame.size.width,
                                                                                   80) type:type];
        _chatToolBar.moreView.backgroundColor  = RGB_COLOR(240, 242, 247, 1);
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    return  _chatToolBar;
    
}
- (void)keyboardHidden
{
    [self.chatToolBar endEditing:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB_COLOR(248, 248, 248, 1);
    if ([[[UIDevice currentDevice]systemName]floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
//    [[EaseMob sharedInstance].chatManager removeDelegate:self];
//    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
//    [[EaseMob sharedInstance].callManager removeDelegate:self];
//    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
    isScorllTobtn = YES;
    [self.view addSubview:self.chatToolBar];
    [self setupBarButtonItem];
    if ([self.chatToolBar.moreView isKindOfClass:[LCChatBarMoreView class]]) {
        [(LCChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(keyboardHidden)];
    [self.view addGestureRecognizer:tap];
    //通过会话接受管理者已发送的消息
   // long long timeTamp = [[NSDate date]timeIntervalSince1970] * 1000 +1;
   // [self loadMoreMessageFrom:timeTamp count:LP_PAGECOUNT apped:NO];
    
 
    // 通知
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(removeAllMessage:)
                                                name:@"RemoveAllMessage"
                                              object:self];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(insertCallMessage:)
                                                name:@"insertCallMessage"
                                              object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground"
                                               object:nil];
    
    message_quque = dispatch_queue_create("easemob.com", NULL);
    isScorllTobtn = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlerCallNotification:)
                                                name:@"callOutChatter"
                                              object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(handlerCallNotification:)
                                                name:@"callControllerClose"
                                              object:nil];
    
    if (_conversationType == eConversationTypeChatRoom) {
        [self joinCharRoom:_chatter];
    }
        self.chatTableView.separatorStyle = NO;
    // Do any additional setup after loading the view.
}

- (void)handlerCallNotification:(NSNotification *)notification
{
    id obj = notification.object;
    if ([obj isKindOfClass:[NSDictionary class]]) {
        self.inInvisble = YES;
    } else {
        self.inInvisble = NO;
    }
    
}
- (void)setupBarButtonItem
{
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    [clearButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(removeAllMessage:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    

}
#pragma mark - hepler
- (NSURL *)convert2Mp4:(NSURL *)movURL
{
    NSURL *mp4URL = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4URL = [movURL copy];
        mp4URL = [mp4URL URLByDeletingPathExtension];
        mp4URL = [mp4URL URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4URL;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                    case AVAssetExportSessionStatusFailed:
                    NSLog(@"failed error.%@",exportSession.error);
                    break;
                    case AVAssetExportSessionStatusCancelled:
                    NSLog(@"canceled.");
                    case AVAssetExportSessionStatusCompleted:
                    NSLog(@"completed.");
                default:
                    NSLog(@"others");
                    break;
                    
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        } if (wait) {
            wait = NULL;
        }

    }
    return mp4URL;
}

#pragma mark - Getter mothd

- (NSMutableArray *)dataSource
{
    if ((_dataSource = nil)) {
        _dataSource = [[NSMutableArray alloc]init];
    }
    return _dataSource;
}
- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}
- (void)saveCharRoom:(EMChatroom *)chatroom
{
    NSString *charRoomName = chatroom.chatroomSubject ? chatroom.chatroomSubject :@"";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@",
                     [[[EaseMob sharedInstance].chatManager loginInfo]
                      objectForKey:@"username"]];
    NSMutableDictionary *chatRooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
    if (![chatRooms objectForKey:chatroom.chatroomId]) {
        [chatRooms setObject:charRoomName forKey:chatroom.chatroomId];
        [ud setObject:chatRooms forKey:key];
        [ud synchronize];
    }
    
}

- (MessageReadManager *)messaageRead
{
    if (_messageRead == nil) {
        _messageRead = [MessageReadManager defaultManager];
    }
    return _messageRead;
    
}
- (NSDate *)chatTagDate
{
    if (_chatDate == nil) {
        _chatDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    return _chatDate;
}
- (void)addMessage:(EMMessage *)message
{
    [_messagess addObject:message];
    __weak SQChatVC *weakSelf = self;
    dispatch_sync(message_quque, ^{
#warning dismiss message for Array
     dispatch_sync(dispatch_get_main_queue(), ^{

         [weakSelf.dataSource addObjectsFromArray:(NSArray *)message];
         [weakSelf.chatTableView reloadData];
         [weakSelf.chatTableView scrollToRowAtIndexPath:[NSIndexPath
                                        indexPathForRow:[weakSelf.dataSource count] - 1
                                              inSection:0]
                                       atScrollPosition:UITableViewScrollPositionBottom
                                               animated:YES];
     });
    });
}
- (void)scrollViewToButtom:(BOOL)animated
{
    if (self.chatTableView.contentSize.height > self.chatTableView.frame.size.height) {
        CGPoint offset = CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height);
        [self.chatTableView setContentOffset:offset];
    }
}

#pragma mark - GesturRecognizer

- (void)reloadData
{
    _chatDate = nil;
    [self.chatTableView reloadData];
    if (!self.inInvisble) {
        NSMutableArray *unreadMessage = [NSMutableArray array];
        for (EMMessage *message in self.messagess) {
            if ([self shouldAckMessage:message read:NO]) {
                [unreadMessage addObject:message];
            }
        }
        if ([unreadMessage count]) {
            [self sendHasReadResponseForMessages:unreadMessage];
        }
        [_conversation markAllMessagesAsRead:YES];
    }
}
#pragma mark - TableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.chatTableView = tableView;
    
    if (indexPath.row < [self.dataSource count]) {
       // id obj = [self.dataSource objectAtIndex:indexPath.row];
        id obj = self.sendMessageField.text;
        if ([obj isKindOfClass:[NSString class]]) {
            EMChatTimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"chatMessageCell"];
            if (timeCell == nil) {
                timeCell = [[EMChatTimeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatMessageCell"];
                timeCell.backgroundColor = [UIColor clearColor];
                timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            timeCell.textLabel.text = (NSString *)obj;
            return timeCell;
        } else {
            MessageModel *model = (MessageModel *)obj;
            NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
            EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[EMChatViewCell alloc]initWithMessageModel:model reuseIdentifier:cellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
    }
    return nil;
}


#pragma mark - Table view delgate 
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 40;
    } else {
        return [EMChatViewCell tableView:tableView
                 heightForRowAtIndexPath:indexPath
                              withObject:(MessageModel *)obj];
    }
}

- (void)joinCharRoom:(NSString *)chatroomId
{
    __weak  typeof (self) weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncJoinChatroom:chatroomId
completion:^(EMChatroom *chatroom, EMError *error) {
    if (weakSelf) {
    SQChatVC *StrongSelf= weakSelf;
    if (error && (error.errorCode != EMErrorChatroomJoined)) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"加入失败" preferredStyle:UIAlertControllerStyleAlert];
        [alert showViewController:self sender:nil];
    } else {
        [StrongSelf saveCharRoom:chatroom];
            }
    }
    else {
        if (!error || (error.errorCode == EMErrorChatroomJoined)) {
            [[EaseMob sharedInstance].chatManager asyncJoinChatroom:chatroomId completion:^(EMChatroom *chatroom, EMError *error) {
                [[EaseMob sharedInstance].chatManager removeConversationByChatter:chatroomId deleteMessages:YES append2Chat:YES];
            }];
        }
    }
    }];
}

#pragma mark -Send message
- (void)sendHasReadResponseForMessages:(NSArray*)messages
{
    dispatch_async(message_quque, ^{
        for (EMMessage *message in messages)
        {
            [[EaseMob sharedInstance].chatManager sendReadAckForMessage:message];
        }
    });
}
- (BOOL)shouldAckMessage:(EMMessage *)message read:(BOOL)read
{
    NSString *account = [[EaseMob sharedInstance].chatManager loginInfo][kSDKUsername];
    if (message.messageType != eMessageTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || self.inInvisble)
    {
        return NO;
    }
    
    id<IEMMessageBody> body = [message.messageBodies firstObject];
    if (((body.messageBodyType == eMessageBodyType_Video) ||
         (body.messageBodyType == eMessageBodyType_Voice) ||
         (body.messageBodyType == eMessageBodyType_Image)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
#pragma mark - IChatManagerDelegate
- (void)didSendMessage:(EMMessage *)message error:(EMError *)error
{
    [self.dataSource enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[MessageModel class]]) {
            MessageModel *model = (MessageModel *)obj;
            if ([model.messageId isEqualToString:message.messageId]) {
                model.message.deliveryState = message.deliveryState;
                *stop = YES;
            }
        }
    }];
    [self.chatTableView reloadData];
}
- (void)didReceiveHasDeliveredResponse:(EMReceipt *)resp
{
    [self.dataSource enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        if ([obj isKindOfClass:[MessageModel class]]) {
            MessageModel *model = (MessageModel *)obj;
            if ([model.messageId isEqualToString:resp.chatId]) {
                model.message.isReadAcked = YES;
                *stop = YES;
            }
        }
    }];
    [self.chatTableView reloadData];
}
- (void)reloadTableViewDataWithMessage:(EMMessage *)message
{
    __weak SQChatVC *weakSelf = self;
    dispatch_async(message_quque, ^{
        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter]) {
            for (int i = 0 ; i < weakSelf.dataSource.count; i++) {
                id object = [weakSelf.dataSource objectAtIndex:i];
                if ([object isKindOfClass:[MessageModel class]]) {
                    MessageModel *model = (MessageModel *)object;
                    if ([message.messageId isEqualToString:model.messageId]) {
                        MessageModel *cellModel = [MessageModelManager modelWithMessage:message];
                        if ([self.delegate respondsToSelector:@selector(nickNameWithChatter:)]) {
                            NSString *showName = [self.delegate nickNameWithChatter:model.nickName];
                            cellModel.nickName = showName ? showName :cellModel.username;
                        } else {
                            cellModel.nickName = cellModel.username;
                        } if ([self.delegate respondsToSelector:@selector(avatarWtihChatter:)]) {
                            cellModel.headImageURL = [NSURL URLWithString:[self.delegate avatarWtihChatter:cellModel.username]];
                            
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.chatTableView beginUpdates];
                            [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                            [weakSelf.chatTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]
                                                          withRowAnimation:UITableViewRowAnimationNone];
                        });
                        break;
                    }
                }
            }
        }
    });
    
}
- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error
{
    if (!error) {
        id<IEMFileMessageBody>fileBody = (id <IEMFileMessageBody>)[message.messageBodies firstObject];
        if ([fileBody messageBodyType] == eMessageBodyType_Image) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed) {
                [self reloadTableViewDataWithMessage:message];
            } else if ([fileBody messageBodyType] == eMessageBodyType_Video) {
                EMVideoMessageBody *videioBody = (EMVideoMessageBody *)fileBody;
                if ([videioBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed) {
                [self reloadTableViewDataWithMessage:message];
                }
            } else if ([fileBody messageBodyType] == eMessageBodyType_Voice) {
                if ([fileBody attachmentDownloadStatus] == EMAttachmentDownloadSuccessed) {
                    [self reloadTableViewDataWithMessage:message];
                }
            }
        }
        
    }
}
#pragma  mark - delegate for IChatManager 登录变化
- (void)didLoginFromOtherDevice
{
    if ([self.imagePicker.mediaTypes count] > 0 &&
        [[self.imagePicker.mediaTypes objectAtIndex:0]isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}
- (void)didRemovedFromServer
{
    if ([self.imagePicker.mediaTypes count] > 0 &&
        [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}



#warning miss method for LCChatBarMoreView


- (void)didReceiveCmdMessage:(EMMessage *)cmdMessage
{
    if ([self.conversation.chatter isEqualToString:cmdMessage.conversationChatter]) {
        
    }
}
- (void)didReceiveMessageId:(NSString *)messageId
                    chatter:(NSString *)conversationChatter
                      error:(EMError *)error
{
    if (error && [self.conversation.chatter isEqualToString:conversationChatter]) {
        __weak SQChatVC *weakSelf = self;
        for (int i = 0; i < self.dataSource.count; i ++) {
            id object = [self.dataSource objectAtIndex:i];
            if ([object isKindOfClass:[MessageModel class]]) {
            MessageModel *currentModel = [self.dataSource objectAtIndex:i];
            EMMessage *currMsg = [currentModel message];
            if ([messageId isEqualToString:currMsg.messageId]) {
                currMsg.deliveryState = eMessageDeliveryState_Failure;
                MessageModel *cellModel = [MessageModelManager modelWithMessage:currMsg];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.chatTableView beginUpdates];
                    [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                    [weakSelf.chatTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]
                                                  withRowAnimation:UITableViewRowAnimationNone];
                });
                if (error && error.errorCode == EMErrorMessageContainSensitiveWords) {
                  //  CGRect frame = self.chatTableView.frame;

                }
                break;
                }
            }
        }
    }
}
- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    if (![offlineMessages count]) {
        return;
    } if ([self shouldMarMessageAsRead]) {
        [_conversation markAllMessagesAsRead:YES];
    }
    _chatDate  = nil;
    // con't use value
    // long long timesTamp = [[NSDate date]timeIntervalSince1970] *1000 +1;
    
}

- (BOOL)shouldMarMessageAsRead
{
    if (([UIApplication sharedApplication].applicationState
         == UIApplicationStateBackground)  || self.inInvisble) {
        return NO;
    }
    return YES;
}
- (EMMessageType)messageType
{
    EMMessageType type = eMessageTypeChat;
    switch (_conversationType) {
        case eConversationTypeChat:
            type = eMessageTypeChat;
            break;
            
        default:
            break;
    }
    return type;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)removeAllMessage:(id)sender
{
    if (_dataSource.count == 0) {
        return;
    }
    if ([sender isKindOfClass:[NSNotification class]]) {
        [_conversation removeAllMessages];
        [messageSend removeLastObject];
        _chatDate = nil;
        [_dataSource removeAllObjects];
        [_chatTableView reloadData];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                       message:@"请确认要删除的内容"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [alert showViewController:self sender:nil];
        
    }
}

- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(MessageBodyType)messageType
{
    if (menuController == nil) {
        menuController = [UIMenuController sharedMenuController];
    } if (menuController == nil) {
        copyMenuItem = [[UIMenuItem alloc]initWithTitle:@"copy" action:@selector(copyMenuAction:)];
    } if (deleteItem == nil) {
        deleteItem = [[UIMenuItem alloc]initWithTitle:@"delete" action:@selector(deleteMenuAction:)];
    } if (messageType == eMessageBodyType_Text) {
        [menuController setMenuItems:@[copyMenuItem, deleteItem]];
    } else {
        [menuController setMenuItems:@[deleteItem]];
    }
    [menuController setTargetRect:showInView.frame inView:showInView.superview];
    [menuController setMenuVisible:YES animated:nil];
}
#pragma mark - MenuItem Actions
- (void)deleteMenuAction:(id)sender
{
    if (longPressIndexPath && longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:longPressIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:longPressIndexPath.row];
        [messageSend removeObject:model.message];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:longPressIndexPath, nil];
        if (longPressIndexPath.row -1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataSource objectAtIndex:(longPressIndexPath.row -1)];
            if (longPressIndexPath.row + 1 <[self.dataSource count]) {
                nextMessage = [self.dataSource objectAtIndex:(longPressIndexPath.row + 1)];
            } if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) &&
                  [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:longPressIndexPath.row -1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(longPressIndexPath.row) -1 inSection:0]];
                
            }
        }
        [self.dataSource removeObjectsAtIndexes:indexs];
        [self.chatTableView beginUpdates];
        [self.chatTableView deleteRowsAtIndexPaths:indexPaths
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.chatTableView endUpdates];
    }
    longPressIndexPath = nil;
}
- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (longPressIndexPath.row > 0 ) {
        MessageModel *model = [self.dataSource objectAtIndex:longPressIndexPath.row];
        pasteboard.string = model.content;
    }
    longPressIndexPath = nil;
}
#pragma  mark - Notification mothod
 - (void)applicationDidEnterBackground
{
    [_conversation markAllMessagesAsRead:YES];
}
- (void)insertCallMessage:(NSNotification *)notification
{
    id obj = notification.object;
    if (obj) {
        EMMessage *message = (EMMessage *)obj;
        [[EaseMob sharedInstance].chatManager insertMessageToDB:message append2Chat:YES];
    }
    
}
#pragma mark - private mothod
- (BOOL)P_canRecord
{
    __block BOOL canBeRecord = YES;
    if ([[[UIDevice currentDevice]systemVersion]compare:@"9.1"] != NSOrderedAscending) {
        AVAudioSession *audioSeeion = [AVAudioSession sharedInstance];
        if ([audioSeeion respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSeeion performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                canBeRecord = granted;
            }];
        }
    }
    return canBeRecord;
}
- (void)markMessageAsRead:(NSArray *)messageReads
{
    EMConversation *conversation = _conversation;
    dispatch_async(message_quque, ^{
        for (EMMessage *message in messageReads) {
            [conversation markMessageWithId:message.messageId asRead:YES]; }
    });
}
- (void)sendHasReadResPonseForMessage:(NSArray *)messages
{
    dispatch_async(message_quque, ^{
        for (EMMessage *message in messages) {
            [[EaseMob sharedInstance].chatManager sendReadAckForMessage:message];
        }
    });
}
- (void)loadMoreMessageFrom:(long long)timeStamp
                      count:(NSInteger)count
                      apped:(BOOL)append
{
    __weak typeof(self) weakSelf = self;
    dispatch_sync(message_quque, ^{
        NSArray *message = [weakSelf.conversation loadNumbersOfMessages:count before:timeStamp];
        if ([message count]) {
            NSInteger currentCount = 0;

            if (append) {
                [weakSelf.messagess insertObjects:message
                                        atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [message count])]];
                id model = [weakSelf.dataSource firstObject];
                NSArray *formated = message;
                if ([model isKindOfClass:[NSString class]]) {
                    NSString *timeStamp = model;
                    [formated enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[NSString class]] && [timeStamp isEqualToString:obj]) {
                            [weakSelf.dataSource removeObjectAtIndex:0];
                            *stop = YES;
                        }
                    }];
                }
                currentCount = [weakSelf.dataSource count];
                [weakSelf.dataSource insertObjects:formated
                                         atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
                EMMessage *latest = [weakSelf.messagess lastObject];
                weakSelf.chatDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)latest.timestamp];
            } else {
                weakSelf.messagess = [message mutableCopy];
                weakSelf.dataSource = [[weakSelf messagess]mutableCopy];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.chatTableView reloadData];
                [weakSelf.chatTableView scrollToRowAtIndexPath:
                                  [NSIndexPath indexPathForRow:[weakSelf.dataSource count] - currentCount -1 inSection:0]
                                              atScrollPosition:UITableViewScrollPositionNone
                                                      animated:NO];
            });
        }
    });
}
#pragma mark - ChatViewDelegate
- (void)moreViewAudioCallAction:(LCChatBarMoreView *)moreView
{
    [self keyboardHidden];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"callOutWithChatter"
                                                       object:@{@"chatter":self.chatter,
                                                                  @"type":[NSNumber numberWithInt:eCallSessionTypeAudio]}];

}
- (void)moreViewLocationAction:(LCChatBarMoreView *)moreView
{
    [self keyboardHidden];


    LocationViewController *location = [[LocationViewController alloc]initWithNibName:nil bundle:nil];
    location.delegate = self;
    [self.navigationController pushViewController:location animated:YES];
    
}

- (void)moreViewVideoCallAction:(LCChatBarMoreView *)moreView
{
    
}
- (void)moreViewPhotoAction:(LCChatBarMoreView *)moreView
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
    [self keyboardHidden];
    
    //弹出照片

    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    self.inInvisble = YES;
}
- (void)moreViewTakePicAction:(LCChatBarMoreView *)moreView
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
    [self keyboardHidden];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    self.inInvisble = YES;
}
#pragma  mark - LocationContrller Delegate 
- (void)sendLocationLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address
{
    [self keyboardHidden];
    NSDictionary *ext = nil;
    EMMessage *location = [ChatSendHelper sendLocationLatitude:latitude
                                                     longitude:longitude
                                                       address:address
                                                    toUsername:self.conversation.chatter
                                                   messageType:[self messageType]
                                             requireEncryption:NO
                                                           ext:ext];
    
    [self addMessage:location];
}
#pragma  mark - Send text message
- (void)sendTextMessage:(NSString *)textMessage
{
    NSDictionary *ext = nil;
    EMMessage *tempMessage = [ChatSendHelper sendTextMessageWithString:textMessage
                                                            toUsername:_conversation.chatter
                                                           isChatGroup:YES
                                                     requireEncryption:NO
                                                                   ext:ext];
    [self addMessage:tempMessage];
}
#pragma mark - View wll appear & dealloc
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_conversation markAllMessagesAsRead:YES];
    self.inInvisble = YES;
}
- (void)dealloc
{
    _chatTableView.delegate = nil;
    _chatTableView.dataSource = nil;
    _chatTableView = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
    if (_conversation.conversationType == eConversationTypeChatRoom && _isKicked) {
        NSString *chatter = [_chatter copy];
        [[EaseMob sharedInstance].chatManager asyncLeaveChatroom:chatter
    completion:^(EMChatroom *chatroom, EMError *error) {
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:chatter deleteMessages:YES append2Chat:YES];
    }];
    }
    if (_imagePicker) {
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
    }
}
- (void)back
{
    EMMessage *message = [_conversation latestMessage];
    if (message == nil) {
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:_conversation.chatter deleteMessages:NO append2Chat:YES];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - setInvisable

- (void)setInInvisble:(BOOL)inInvisble
{
    _inInvisble = inInvisble;
    if (!_inInvisble) {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messagess) {
            if ([self shouldAckMessage:message read:NO]) {
                [unreadMessages addObject:message];
            }
        } if ([unreadMessages count]) {
            [self sendHasReadResponseForMessages:unreadMessages];
        }
        [_conversation markAllMessagesAsRead:YES];
    }
}

    
#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
