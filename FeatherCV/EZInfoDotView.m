//
//  EZInfoDotView.m
//  3DCamera
//
//  Created by xietian on 14-8-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZInfoDotView.h"
#import "EZExtender.h"

@implementation EZInfoDotView

+ (EZInfoDotView*)create:(CGPoint)point
{
    EZInfoDotView* res = [[EZInfoDotView alloc] initWithFrame:CGRectMake(point.x - 60/2.0, point.y - 60/2.0, 60, 60) dotDiameter:15 color:RGBCOLOR(64, 64, 255)];
    return res;
}

- (id)initWithFrame:(CGRect)frame dotDiameter:(CGFloat)diameter color:(UIColor *)color
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    if (self) {
        _dotView = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - diameter)/2,(frame.size.height - diameter)/2 , diameter, diameter)];
        [self addSubview:_dotView];
        _dotView.backgroundColor = color;
        [_dotView enableRoundImage];
        [_dotView enableShadow:[UIColor blackColor]];
        [self enableRoundImage];
    }
    return self;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _pressed = true;
    UITouch* touch = [touches anyObject];
    _startPoint = [touch locationInView:self.superview];
    [UIView animateWithDuration:0.15 animations:^(){
        //_dotView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        _dotView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    }];
    self.backgroundColor = RGBACOLOR(255, 255, 255, 60);
    dispatch_later(0.25, ^(){
        if(_pressed){
            _movingState = true;
        }
    });
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //if(_movingState){
        UITouch* touch = [touches anyObject];
        CGPoint movedPoint = [touch locationInView:self.superview];
        CGPoint delta = CGPointMake(movedPoint.x - _startPoint.x, movedPoint.y - _startPoint.y);
        CGPoint finalPoint = CGPointMake(self.frame.origin.x + delta.x, self.frame.origin.y + delta.y);
        if(finalPoint.x < 0){
            finalPoint.x = 0;
        }
        if(finalPoint.x > self.superview.width - self.width){
            finalPoint.x = self.superview.width - self.width;
        }
        
        if(finalPoint.y < 0){
            finalPoint.y = 0;
        }
        if(finalPoint.y > self.superview.height - self.height){
            finalPoint.y = self.superview.height - self.height;
        }
        _startPoint = movedPoint;
        _finalPosition = CGPointMake(100 * (finalPoint.x + self.width/2.0)/self.superview.width, 100 * (finalPoint.y + self.height/2.0)/self.superview.height);
        [self setPosition:finalPoint];
    //}else{
        
    //}
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
    if(_movingState){
        if (_moveCompleted) {
            _moveCompleted(self);
        }
    }else{
        if(_clicked){
            _clicked(self);
        }
    }
    [UIView animateWithDuration:0.15 animations:^(){
        _dotView.transform = CGAffineTransformIdentity;
    }];
    self.backgroundColor = [UIColor clearColor];
    _pressed = false;
    _movingState = false;
    
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
