//
//  EZDrawable.h
//  3DCamera
//
//  Created by xietian on 14-9-17.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>

@class EZCanvas;

@interface  EZDrawable: NSObject

@property (nonatomic, weak) EZCanvas* parent;

@property (nonatomic, strong) UIColor* selectedColor;

@property (nonatomic, assign) CGRect boundingRect;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, assign) CGPoint shift;

- (void) drawContext:(CGContextRef)context;

- (void) setParent:(EZCanvas*)canvas;

- (BOOL) pointInSide:(CGPoint)pt;

- (CGRect) shiftRect:(CGRect)rect shift:(CGPoint)shift;

- (CGPoint) shiftPoint:(CGPoint)pt shift:(CGPoint)shift;

- (void) mergeShift:(CGPoint)shift;

- (void) mergeShift;

@end
