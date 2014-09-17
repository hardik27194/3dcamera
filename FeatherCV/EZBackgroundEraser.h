//
//  EZBackgroundEraser.h
//  3DCamera
//
//  Created by xietian on 14-9-4.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

struct EZGrabHandler;

typedef enum {
    kSquareShape,
    kRoundShape,
    kPolygon,
    kStrokeShape
} EZMaskShapeType;


typedef enum{
    kSmartBackground,
    kManualBackground,
    kSmartForeground,
    kManualForeground
} EZMaskMode;

//@class DAScratchPadView;
@class EZCanvas;
@class EZDrawable;
@interface EZBackgroundEraser : UIView{
    //EZGrabCut* gradCut;
    struct EZGrabHandler* grabHandler;
}

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image;

@property (nonatomic, strong) UIImageView* imageView;

@property (nonatomic, strong) UIImage* orgImage;

@property (nonatomic, strong) UIImage* curImage;

@property (nonatomic, assign) EZSelectStatus selectStatus;

//@property (nonatomic, strong) UIView* selectRegion;

@property (nonatomic, assign) BOOL effectiveTouch;

@property (nonatomic, assign) CGPoint touchBegin;

@property (nonatomic, strong) UIView* horizonBar;

@property (nonatomic, strong) UIView* verticalBar;

//@property (nonatomic, strong) DAScratchPadView* scratchView;

@property (nonatomic, strong) EZCanvas* canvas;

@property (nonatomic, strong) EZDrawable* drawable;

@property (nonatomic, strong) UIButton* confirmSelect;

@property (nonatomic, strong) UIToolbar* toolBar;

@property (nonatomic, strong) NSArray* items;

@property (nonatomic, assign) EZMaskMode currentMaskMode;

@property (nonatomic, assign) EZMaskShapeType shapeType;

@property (nonatomic, strong) UIView* strokeWidthDemo;

@property (nonatomic, assign) CGPoint touchPoint;

@property (nonatomic, assign) BOOL pressed;

@property (nonatomic, assign) BOOL notMoved;

@property (nonatomic, assign) CGPoint lastTouch;

@property (nonatomic, strong) UISlider* slider;

//@property (nonatomic, assign) EZMaskMode maskMode;
@property (nonatomic, assign) CGFloat strokeSize;

- (void) startProcessing:(EZEventBlock)success;


@end
