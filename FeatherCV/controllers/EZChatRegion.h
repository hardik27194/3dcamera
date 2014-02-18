//
//  EZChatRegion.h
//  FeatherCV
//
//  Created by xietian on 14-2-18.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EZClickView.h"

@interface EZChatRegion : UIView<UITextFieldDelegate>

//Sort by time. the length are determined by time
//I guess use UIWebView will be a good way to achieve this.
@property (nonatomic, strong) NSArray* conversations;

@property (nonatomic, strong) EZEventBlock ownerClicked;

@property (nonatomic, strong) EZEventBlock otherClicked;

@property (nonatomic, strong) EZEventBlock chatCompleted;

@property (nonatomic, strong) EZEventBlock externalAnimateBlock;

@property (nonatomic, strong) UITextField* chatInput;

//The owner ID will determine who on the left of the screen
@property (nonatomic, strong) NSString* ownerID;

@property (nonatomic, strong) UIFont* textFont;

@property (nonatomic, strong) UIColor* fontColor;

@property (nonatomic, strong) NSMutableArray* chatLabel;

@property (nonatomic, strong) NSMutableArray* headIcons;

@property (nonatomic, strong) EZClickView* container;

@property (nonatomic, assign) BOOL isChatShow;


//What's the algorithm to get this done.
- (CGFloat) calculateHeight:(NSArray*)conversations;

- (void) insertChat:(NSDictionary*)chat;

- (void) render;

@end
