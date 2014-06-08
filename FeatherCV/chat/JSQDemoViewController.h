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

#import "JSQMessages.h"
#import "EZPhoto.h"
#import "EZPerson.h"

@class JSQDemoViewController;


@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(JSQDemoViewController *)vc;

@end




@interface JSQDemoViewController : JSQMessagesViewController

@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;

@property (strong, nonatomic) NSMutableArray *messages;
//@property (copy, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;
@property (strong, nonatomic) EZPerson* person;
@property (strong, nonatomic) EZPhoto* ownPhoto;
@property (strong, nonatomic) EZPhoto* otherPhoto;
@property (strong, nonatomic) UIView* barBackground;
//@property (strong, nonatomic) NSTimer* timer;
@property (strong, nonatomic) EZEventBlock recievedChat;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;

- (void)setupTestModel;

//Try to get the photo from the main photo.
- (id) initWithPhoto:(EZPhoto*)ownPhoto otherPhoto:(EZPhoto*)otherPhoto;

- (id) iniWithPhotoID:(NSArray*)photos;

@end
