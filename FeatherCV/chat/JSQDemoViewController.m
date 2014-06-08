//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "JSQDemoViewController.h"
#import "EZDataUtil.h"
#import "EZPhotoChat.h"
#import "EZDataUtil.h"
#import "EZFileUtil.h"
#import "EZMessageCenter.h"

static NSString * const kJSQDemoAvatarNameCook = @"Tim Cook";
static NSString * const kJSQDemoAvatarNameJobs = @"Jobs";
static NSString * const kJSQDemoAvatarNameWoz = @"Steve Wozniak";


@implementation JSQDemoViewController

#pragma mark - Demo setup

- (void)setupTestModel
{
    /**
     *  Load some fake messages for demo.
     *
     *  You should have a mutable array or orderedSet, or something.
     */
    
    self.messages = [[NSMutableArray alloc] initWithObjects:
                     [[EZPhotoChat alloc] initWithSpeaker:_otherPhoto.personID text:@"我爱说话" date:[NSDate distantPast] chatID:nil],
                     [[EZPhotoChat alloc] initWithSpeaker:_ownPhoto.personID text:@"Welcome to JSQMessages: A messaging UI framework for iOS." date:[NSDate distantPast] chatID:@""],
                     [[EZPhotoChat alloc] initWithSpeaker:_otherPhoto.personID text:@"我也爱说话" date:[NSDate distantPast] chatID:nil],
                     [[EZPhotoChat alloc] initWithSpeaker:_otherPhoto.personID text:@"我最爱说话" date:[NSDate date] chatID:nil],
                     [[EZPhotoChat alloc] initWithSpeaker:_otherPhoto.personID text:@"不吐不快" date:[NSDate date] chatID:nil],
                     nil];
    
    /**
     *  Create avatar images once.
     *
     *  Be sure to create your avatars one time and reuse them for good performance.
     *
     *  If you are not using avatars, ignore this.
     */
    
    /**
    UIImage *jsqImage = [JSQMessagesAvatarFactory avatarWithUserInitials:@"JSQ"
                                                         backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                               textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                                    font:[UIFont systemFontOfSize:14.0f]
                                                                diameter:outgoingDiameter];
    
    CGFloat incomingDiameter = self.collectionView.collectionViewLayout.incomingAvatarViewSize.width;
    
    UIImage *cookImage = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageNamed:@"demo_avatar_cook"]
                                                          diameter:incomingDiameter];
    
    UIImage *jobsImage = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageNamed:@"demo_avatar_jobs"]
                                                          diameter:incomingDiameter];
    
    UIImage *wozImage = [JSQMessagesAvatarFactory avatarWithImage:[UIImage imageNamed:@"demo_avatar_woz"]
                                                         diameter:incomingDiameter];
    **/
}



//Try to get the photo from the main photo.
- (id) initWithPhoto:(EZPhoto*)ownPhoto otherPhoto:(EZPhoto*)otherPhoto
{
    self = [super init];
    _ownPhoto = ownPhoto;
    _otherPhoto = otherPhoto;
    //self.sender = currentLoginID;
    return self;
}

#pragma mark - View lifecycle



- (void) queryPhotoChat
{
    __weak typeof(self) weakSelf = self;
    
    [[EZDataUtil getInstance]queryPhotoChat:_ownPhoto otherPhoto:_otherPhoto success:^(NSArray* arr){
        [weakSelf.messages addObjectsFromArray:arr];
        [weakSelf.collectionView reloadData];
    } failure:^(id err){
        EZDEBUG(@"query chat error:%@", err);
    }];
}

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _messages = [[NSMutableArray alloc] init];
    _barBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, 64)];
    UILabel* friendTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CurrentScreenWidth, 30)];
    friendTitle.font = EZTitleFontCN;
    friendTitle.textAlignment = NSTextAlignmentCenter;
    friendTitle.textColor = [UIColor whiteColor];
    friendTitle.text = macroControlInfo(@"朋友");
    _barBackground.backgroundColor = RGBA(0, 0, 0, 60);
    [_barBackground addSubview:friendTitle];
    
    //__weak typeof(self) weakSelf = self;
    EZPerson* ps = pid2personCall(_otherPhoto.personID, ^(EZPerson* person){
        friendTitle.text = person.name;
    });

    
    //self.view.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundColor = RGBA(255, 255, 255, 30);
    
    //self.title = @"朋友";
    
    self.sender = currentLoginID;
    
    //[self setupTestModel];
    [self queryPhotoChat];
    
    
    //filter out.
    __weak typeof(self) weakSelf = self;
    _recievedChat = ^(EZPhotoChat* chat){
        //for(EZPhotoChat* pc in chats){
        [weakSelf recievedMessage:chat];
        //}
    };
      /**
     *  Remove camera button since media messages are not yet implemented
     *
     *   self.inputToolbar.contentView.leftBarButtonItem = nil;
     *
     *  Or, you can set a custom `leftBarButtonItem` and a custom `rightBarButtonItem`
     */
    
    /**
     *  Create bubble images.
     *
     *  Be sure to create your avatars one time and reuse them for good performance.
     *
     */
    self.outgoingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.incomingBubbleImageView = [JSQMessagesBubbleImageFactory
                                    incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    self.collectionView.frame = CGRectMake(0, 64, CurrentScreenWidth, CurrentScreenHeight - 64);
    /**
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"typing"]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(receiveMessagePressed:)];
    **/
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _barBackground.y = - _barBackground.frame.size.height;
    [TopView addSubview:_barBackground];
    [UIView animateWithDuration:0.3 animations:^(){
        _barBackground.y = 0;
    } completion:^(BOOL completed){
        [self.view addSubview:_barBackground];
    }];

    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }
    
    [[EZMessageCenter getInstance] registerEvent:EZRecievedChat block:_recievedChat];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is YES.
     *  For best results, toggle from `viewDidAppear:`
     */
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    //[EZUIUtility sharedEZUIUtility].stopRotationRaise = false;
    //[TopView addSubview:_barBackground];
    [UIView animateWithDuration:0.3 animations:^(){
        _barBackground.y = - _barBackground.frame.size.height;
    } completion:^(BOOL completed){
        //[self.view addSubview:_barBackground];
        [_barBackground removeFromSuperview];
    }];
    [[EZMessageCenter getInstance] unregisterEvent:EZRecievedChat forObject:_recievedChat];
}


#pragma mark - Actions

- (void)receiveMessagePressed:(UIBarButtonItem *)sender
{
    /**
     *  The following is simply to simulate received messages for the demo.
     *  Do not actually do this.
     */
    
    
    /**
     *  Show the tpying indicator
     */
    self.showTypingIndicator = !self.showTypingIndicator;
    
    EZPhotoChat *copyMessage = [[self.messages lastObject] copy];
    
    if (!copyMessage) {
        return;
    }
    
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //NSMutableArray *copyAvatars = [[self.avatars allKeys] mutableCopy];
        //[copyAvatars removeObject:self.sender];
        //copyMessage.sender = [copyAvatars objectAtIndex:arc4random_uniform((int)[copyAvatars count])];
        
        /**
         *  This you should do upon receiving a message:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */

    //});
}



- (void) recievedMessage:(EZPhotoChat*)photoChat
{
    EZDEBUG(@"recieved chat:%@", photoChat.text);
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    [self.messages addObject:photoChat];
    [self finishReceivingMessage];
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissJSQDemoViewController:self];
}




#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                    sender:(NSString *)sender
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    EZPhotoChat *message = [[EZPhotoChat alloc] initWithSpeaker:currentLoginID text:text date:[NSDate date] chatID:nil];
    EZDEBUG(@"ownPhoto:%@, otherPhoto:%@", _ownPhoto.photoID, _otherPhoto.photoID);
    message.photos = @[_ownPhoto.photoID, _otherPhoto.photoID];
    [self.messages addObject:message];
    
    [[EZDataUtil getInstance] addPhotoChat:message success:^(id obj){
        EZDEBUG(@"successfully send the chat:%@", obj);
    } failure:^(id obj){
        EZDEBUG(@"failed to send the chat text");
    }];
    
    [self finishSendingMessage];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    NSLog(@"Camera pressed!");
    /**
     *  Accessory button has no default functionality, yet.
     */
}



#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     */
    
    /**
     *  Reuse created bubble images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and bubbles would disappear from cells
     */
    
    EZPhotoChat *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.sender isEqualToString:currentLoginID]) {
        return [[UIImageView alloc] initWithImage:self.outgoingBubbleImageView.image
                                 highlightedImage:self.outgoingBubbleImageView.highlightedImage];
    }
    
    return [[UIImageView alloc] initWithImage:self.incomingBubbleImageView.image
                             highlightedImage:self.incomingBubbleImageView.highlightedImage];
}

- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Reuse created avatar images, but create new imageView to add to each cell
     *  Otherwise, each cell would be referencing the same imageView and avatars would disappear from cells
     *
     *  Note: these images will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    //JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    //UIImage *avatarImage = [self.avatars objectForKey:message.sender];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, smallIconRadius, smallIconRadius)];
    EZPhotoChat* pc = [_messages objectAtIndex:indexPath.row];
    
    pid2personCall(pc.sender, ^(EZPerson* ps){
        EZDEBUG(@"person is:%@", ps.name);
        [[EZDataUtil getInstance] preloadImage:ps.avatar success:^(NSString* imagepath){
            imageView.image = path2image(imagepath);
        } failed:^(id obj){
            EZDEBUG(@"Error loading the icon");
        }];
    });
    [imageView enableRoundImage];
    return imageView;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        
        EZPhotoChat *message = [self.messages objectAtIndex:indexPath.item];
        EZDEBUG(@"message date:%@", message.date);
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    EZPhotoChat *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.sender isEqualToString:currentLoginID]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        EZPhotoChat *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([previousMessage.sender isEqualToString:message.sender]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    EZPerson* ps = pid2person(message.sender);
    return [[NSAttributedString alloc] initWithString:ps.name];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *  
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *  
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    EZPhotoChat *msg = [self.messages objectAtIndex:indexPath.item];
    
    if ([msg.sender isEqualToString:currentLoginID]) {
        cell.textView.textColor = [UIColor blackColor];
    }
    else {
        cell.textView.textColor = [UIColor whiteColor];
    }
    
    cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    EZPhotoChat *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage sender] isEqualToString:currentLoginID]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        EZPhotoChat *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([previousMessage.sender isEqualToString:currentMessage.sender]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

@end
