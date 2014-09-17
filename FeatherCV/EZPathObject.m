//
//  EZPathObject.m
//  3DCamera
//
//  Created by xietian on 14-9-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZPathObject.h"
#import "EZPoint.h"

@implementation EZPathObject

+ (EZPathObject*) createPath:(UIColor*)color width:(CGFloat)lineWidth isFill:(BOOL)isFill
{
    EZPathObject* res = [[EZPathObject alloc] init];
    res.lineWidth = lineWidth;
    res.color = color;
    res.isFill = isFill;
    return res;
}

- (id) init
{
    self = [super init];
    _points = [[NSMutableArray alloc] init];
    return self;
}

- (void) addPoint:(CGPoint)point
{
    EZPoint* pt = [[EZPoint alloc] init];
    pt.point = point;
    [_points addObject:pt];
    if(!CGRectContainsPoint(self.boundingRect, point)){
        CGFloat x = self.boundingRect.origin.x;
        if(point.x < x){
            x = point.x;
        }
        CGFloat y = self.boundingRect.origin.y;
        if(point.y < y){
            y = point.y;
        }
        CGFloat maxX = self.boundingRect.origin.x + self.boundingRect.size.width;
        if(point.x > maxX){
            maxX = point.x;
        }
        
        CGFloat maxY = self.boundingRect.origin.y + self.boundingRect.size.height;
        if(point.y > maxY){
            maxY = point.y;
        }
        self.boundingRect = CGRectMake(x, y, maxX, maxY);
    }
}

- (void) addPoints:(NSArray*)points
{
    for(NSValue* val in points){
        //EZPoint* ep = [[EZPoint alloc] init];
        //ep.point = [val CGPointValue];
        //[_points addObject:ep];
        [self addPoint:[val CGPointValue]];
    }
}

- (void) mergeShift:(CGPoint)shift
{
    NSMutableArray* dupPoints = [NSMutableArray arrayWithArray:_points];
    [_points removeAllObjects];
    for(EZPoint* val in dupPoints){
        //EZPoint* ep = [[EZPoint alloc] init];
        //ep.point = [val CGPointalue];
        //[_points addObject:ep];
        CGPoint pt = [self shiftPoint:val.point shift:self.shift];
        [self addPoint:pt];
        
    }

}


- (void) drawContext:(CGContextRef)ctx
{
    EZDEBUG(@"path length:%i", _points.count);
    if(_points.count < 2){
        return;
    }
    CGContextSetBlendMode(ctx, kCGBlendModeCopy);
    if(!_isFill){
	CGContextSetLineCap(ctx, kCGLineCapRound);
	CGContextSetLineWidth(ctx, _lineWidth);
        CGContextSetStrokeColorWithColor(ctx,self.selected?self.selectedColor.CGColor:_color.CGColor);
        EZPoint* orgPt = [_points objectAtIndex:0];
        CGPoint shiftedPt = [self shiftPoint:orgPt.point  shift:self.shift];
    
    CGContextMoveToPoint(ctx, shiftedPt.x, shiftedPt.y);
    for(int i = 1; i < _points.count; i ++){
        orgPt = [_points objectAtIndex:i];
        CGPoint shiftedPt = [self shiftPoint:orgPt.point shift:self.shift];
        CGContextAddLineToPoint(ctx, shiftedPt.x, shiftedPt.y);
    }
	CGContextStrokePath(ctx);
    }else{
        EZPoint* pt = [_points objectAtIndex:0];
        CGPoint shiftedPt = [self shiftPoint:pt.point shift:self.shift];
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, shiftedPt.x, shiftedPt.y);
        for(int i = 1; i < _points.count; i ++){
            EZPoint* pt1 = [_points objectAtIndex:i];
            shiftedPt = [self shiftPoint:pt1.point shift:self.shift];
            CGPathAddLineToPoint(path, NULL, shiftedPt.x, shiftedPt.y);
        }
        
        //CGPathAddLineToPoint(path, nil, pt.point.x, pt.point.y);
        CGPathCloseSubpath(path);
        CGContextSetFillColorWithColor(ctx,self.selected?self.selectedColor.CGColor:_color.CGColor);
        CGContextAddPath(ctx, path);
        CGContextFillPath(ctx);
    }
	//CGContextFlush(ctx);
}


@end
