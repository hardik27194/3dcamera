//
//  EZFrontFrame.h
//  3DCamera
//
//  Created by xietian on 14-9-21.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZFrontFrame : UIView<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView* maskFrame;

@property (nonatomic, strong) UIPanGestureRecognizer* pan;

@property (nonatomic, strong) UIPinchGestureRecognizer* pinch;

@property (nonatomic, assign) CGRect orgFrame;

@property (nonatomic, assign) CGPoint orgPosition;

@property (nonatomic, assign) CGFloat orgScale;
- (CGRect) getFinalFrame;





@end
