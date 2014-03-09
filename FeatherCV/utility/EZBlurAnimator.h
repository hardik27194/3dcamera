//
//  EZBlurAnimator.h
//  FeatherCV
//
//  Created by xietian on 14-3-8.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZClickView.h"

//What's the purpose of this class?
//Keep the buffer so that can animate himself 
@interface EZBlurAnimator : UIView

@property (nonatomic, assign) CGFloat blurRadius;
@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, assign) NSUInteger frameInterval;

@property (nonatomic, assign, readonly) CGSize bufferSize;
@property (nonatomic, assign, readonly) CGSize scaledSize;

@property (nonatomic, assign, readonly) CGContextRef effectInContext;
@property (nonatomic, assign, readonly) CGContextRef effectOutContext;

@property (nonatomic, assign, readonly) vImage_Buffer effectInBuffer;
@property (nonatomic, assign, readonly) vImage_Buffer effectOutBuffer;

@property (nonatomic, assign, readonly) uint32_t precalculatedBlurKernel;

@property (nonatomic, assign, readonly) BOOL shouldLiveBlur;

@property (nonatomic, assign, readonly) NSUInteger currentFrameInterval;

@property (nonatomic, strong) EZAnimateBlock animBlock;

@property (nonatomic, assign) CGFloat startBlurRadius;

@property (nonatomic, assign) CGFloat endBlurRadius;

@property (nonatomic, assign) CGFloat totalFrameCount;

@property (nonatomic, assign) CGFloat currentFrameCount;

@property (nonatomic, strong) UIView* srcView;

@property (nonatomic, strong) EZEventBlock completed;

@property (nonatomic, assign) BOOL bufferCreated;

@property (nonatomic, strong) UIColor* tintColor;

- (int) refresh;

- (void) animateBlur:(CGFloat)from to:(CGFloat)toBlur duration:(CGFloat)duration srcView:(UIView*)srcView completed:(EZEventBlock)completed;

@end
