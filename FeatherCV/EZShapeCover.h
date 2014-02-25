//
//  EZShapeCover.h
//  FeatherCV
//
//  Created by xietian on 14-2-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZShapeCover : UIView

- (void) digHole:(CGFloat)radius color:(UIColor*)fillColor opacity:(CGFloat)opacity;

@property (nonatomic, strong) CAShapeLayer* fillLayer;

@property (nonatomic, strong) EZEventBlock releaseBlock;

@end
