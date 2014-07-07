//
//  EZPaintRecognizer.m
//  FeatherCV
//
//  Created by xietian on 14-7-6.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZPaintRecognizer.h"

@implementation EZPaintRecognizer

-(id)initWithTarget:(id)target action:(SEL)action{
    if ((self = [super initWithTarget:target action:action])){
        // so simple there's no setup
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if ([touch locationInView:self.view].x < CGRectGetMidX(self.view.bounds))
        self.state = UIGestureRecognizerStateFailed;
    else if ([touch locationInView:self.view].y > CGRectGetMidY(self.view.bounds))
        self.state = UIGestureRecognizerStateFailed;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if([touch locationInView:self.view].x < CGRectGetMidX(self.view.bounds))
        self.state = UIGestureRecognizerStateFailed;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if ([touch locationInView:self.view].x < CGRectGetMidX(self.view.bounds))
        self.state = UIGestureRecognizerStateFailed;
    else if ([touch locationInView:self.view].y < CGRectGetMidY(self.view.bounds))
        self.state = UIGestureRecognizerStateFailed;
    else {
        // setting the state to recognized fires the target/action pair of the recognizer
        self.state = UIGestureRecognizerStateRecognized;
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    self.state = UIGestureRecognizerStateCancelled;
}
-(void)reset{
    // so simple there's no reset
}

@end
