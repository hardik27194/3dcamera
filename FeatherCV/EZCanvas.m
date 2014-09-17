//
//  EZCanvas.m
//  3DCamera
//
//  Created by xietian on 14-9-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZCanvas.h"

@implementation EZDrawable

- (id) init
{
    self = [super init];
    _selectedColor = RGBCOLOR(254, 208, 73);
    return self;
}

- (void) drawContext:(CGContextRef)context
{
    
}

- (void) mergeShift:(CGPoint)shift
{
    _boundingRect = [self shiftRect:_boundingRect shift:_shift];
    _shift = CGPointZero;
}

- (void) mergeShift
{
    [self mergeShift:_shift];
}

- (CGRect) getBoundingRect
{
    return CGRectMake(_boundingRect.origin.x + _shift.x, _boundingRect.origin.y + _shift.y, _boundingRect.size.width, _boundingRect.size.height);
}

- (CGRect) shiftRect:(CGRect)rect shift:(CGPoint)shift
{
    return CGRectMake(rect.origin.x + shift.x, rect.origin.y + shift.y, rect.size.width, rect.size.height);
}

- (CGPoint) shiftPoint:(CGPoint)pt shift:(CGPoint)shift
{
    return CGPointMake(pt.x + shift.x, pt.y + shift.y);
}

- (BOOL) pointInSide:(CGPoint)pt
{
    return CGRectContainsPoint(_boundingRect, pt);
}


- (void) setParent:(EZCanvas*)canvas
{
    _parent = canvas;
}

@end

@implementation EZCanvas

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        _shapes = [[NSMutableArray alloc] init];
        _redoList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) addShapeObject:(EZDrawable*)shape
{
    [shape setParent:self];
    [_shapes addObject:shape];
}

- (EZDrawable*) getLastDrawable
{
    if(_shapes.count){
        return [_shapes objectAtIndex:_shapes.count - 1];
    }
    return nil;
}

- (void) insertShape:(EZDrawable*)shape pos:(NSInteger)pos
{
    [shape setParent:self];
    [_shapes insertObject:shape atIndex:pos];
    
}

- (void) removeShape:(EZDrawable*)drawable
{
    [_shapes removeObject:drawable];
}

- (void) undo
{
    if(_shapes.count){
        EZDrawable* drawAble = [_shapes objectAtIndex:_shapes.count - 1];
        [_shapes removeObjectAtIndex:_shapes.count - 1];
        [_redoList addObject:drawAble];
        [self setNeedsDisplay];
    }
}

- (void) redo
{
    if(_redoList.count){
        EZDrawable* drawAble = [_redoList objectAtIndex:_redoList.count - 1];
        [_shapes addObject:drawAble];
        [_redoList removeObjectAtIndex:_redoList.count - 1];
        [self setNeedsDisplay];
    }
}

- (EZDrawable*) getShapeAtPoint:(CGPoint)pt
{
    
    for(int i = _shapes.count-2; i >= 0; i --){
        EZDrawable* shape = [_shapes objectAtIndex:i];
        EZDEBUG(@"rect:%@, point:%@", NSStringFromCGRect(shape.boundingRect), NSStringFromCGPoint(pt));
        if(CGRectContainsPoint(shape.boundingRect, pt)){
            EZDEBUG(@"find rect");
            return shape;
        }
    }
    return nil;
}

- (UIImage*) generateImage
{
    return [self contentAsImage];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    for(EZDrawable* drawable in _shapes){
        [drawable drawContext:context];
    }
}



@end
