//
//  EZShotSetting.h
//  3DCamera
//
//  Created by xietian on 14-10-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EZInputItem;

@interface EZShotSetting : UIView

@property (nonatomic, strong) NSArray* configureItems;

@property (nonatomic, strong) UIView* container;

@property (nonatomic, strong) UIView* coverView;

@property (nonatomic, strong) EZEventBlock confirmed;

//- (id) initWithFrame:(CGRect)frame items:(EZInputItem*)item;
//@property (nonatomic, strong) EZIN* shotBtn;

//@property (nonatomic, strong) UILabel* musicMute;
- (NSArray*) createItems;

- (void) showInView:(UIView*)view aniamted:(BOOL)aniamted confirmed:(EZEventBlock)block;

- (void) dismiss:(BOOL)aniamted;


@end
