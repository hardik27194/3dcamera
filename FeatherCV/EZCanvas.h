//
//  EZCanvas.h
//  3DCamera
//
//  Created by xietian on 14-9-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>



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


@interface EZCanvas : UIView

@property (nonatomic, strong) NSMutableArray* shapes;
@property (nonatomic, strong) NSMutableArray* redoList;

- (void) addShapeObject:(EZDrawable*)shape;

- (EZDrawable*) getLastDrawable;

- (UIImage*) generateImage;

- (EZDrawable*) getShapeAtPoint:(CGPoint)pt;

- (void) removeShape:(EZDrawable*)drawable;

- (void) insertShape:(EZDrawable*)shape pos:(NSInteger)pos;

- (void) undo;

- (void) redo;

@end



