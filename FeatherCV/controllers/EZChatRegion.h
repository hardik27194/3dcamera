//
//  EZChatRegion.h
//  FeatherCV
//
//  Created by xietian on 14-2-18.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EZChatRegion : UIView

//Sort by time. the length are determined by time
//I guess use UIWebView will be a good way to achieve this.
@property (nonatomic, strong) NSArray* conversations;

@property (nonatomic, strong) EZEventBlock ownerClicked;

@property (nonatomic, strong) EZEventBlock otherClicked;

//The owner ID will determine who on the left of the screen
@property (nonatomic, strong) NSString* ownerID;

//What's the algorithm to get this done.
- (CGFloat) calculateHeight:(NSArray*)conversations;

- (void) render;

@end
