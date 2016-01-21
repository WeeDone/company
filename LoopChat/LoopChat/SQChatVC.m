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
#import "MessageReadManager.h"
#import "EMChatViewCell.h"
#import "LCChatBarMoreView.h"
@class MessageModelManager;

@interface SQChatVC ()<UITableViewDelegate, UITableViewDataSource,
UINavigationControllerDelegate, IChatManagerDelegate, UIImagePickerControllerDelegate
, EMCallManagerDelegate, LCChatBarMoreViewDelegate>
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

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSDate *chatDate;
@property (nonatomic, strong) NSString *messages;
@property (nonatomic, strong) MessageReadManager *messageRead;
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic) EMConversationType conversationType;
@property (nonatomic, strong) NSMutableArray *messagess;
@property (nonatomic) BOOL   isScollToBtn;
@end

@implementation SQChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB_COLOR(248, 248, 248, 1);
    if ([[[UIDevice currentDevice]systemName]floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
    
    
    
    
    
    
    
    
    
    //通过会话接受管理者已发送的消息
    long long timeTamp = [[NSDate date]timeIntervalSince1970] * 1000 +1;
    
    
    
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

    
    self.chatTableView.separatorStyle = NO;
    // Do any additional setup after loading the view.
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
     dispatch_sync(dispatch_get_main_queue(), ^{
         [weakSelf.dataSource addObjectsFromArray:message];
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
        id obj = [self.dataSource objectAtIndex:indexPath.row];
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

- (void)moreViewPhotoAction:(LCChatBarMoreView *)moreView
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
#warning hidden keybord
    //弹出照片
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    self.inInvisble = YES;
}
- (void)moreViewTakePicAction:(LCChatBarMoreView *)moreView
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:YES] forKey:@"isShowPicker"];
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    self.inInvisble = YES;
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
- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages
{
    if (![offlineMessages count]) {
        return;
    } if ([self shouldMarMessageAsRead]) {
        [_conversation markAllMessagesAsRead:YES];
    }
    _chatDate  = nil;
    long long timesTamp = [[NSDate date]timeIntervalSince1970] *1000 +1;
    
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
