//
//  EZClickView.m
//  ShowHair
//
//  Created by xietian on 13-3-24.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import "EZClickView.h"
#import "EZUIUtility.h"

@implementation EZClickView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self config];
    return self;
}

- (void) config
{
    //EZDEBUG(@"Configure get called");
    _enableTouchEffects = true;
}

- (void) pressed
{
    EZDEBUG(@"Pressed clicked");
    if(!_pressedView){
        _pressedView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_pressedView];
    }else{
        [_pressedView setFrame:self.bounds];
    }
    //Then my code will be very strong.
    if(_enableTouchEffects){
        [self bringSubviewToFront:_pressedView];
        _pressedView.backgroundColor = randBack(_pressedColor);
        _pressedView.hidden = false;
    }
    /**
    [UIView animateWithDuration:0.2f animations:^{
        //[UIView setAnimationRepeatCount:1];
        self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    } completion:^(BOOL finished) {
        
    }];
     **/
}
//Mean the touch ended, doesn't mean a effective click
- (void) unpressed
{
    _pressedView.hidden = true;
    /**
    [UIView animateWithDuration:0.2 animations:^(){
        //view.layer.shadowOpacity = 0.0f;
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
     **/
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    [self pressed];
    if(_pressedBlock){
        _pressedBlock(touch);
    }
    
}
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    if(_enableTouchEffects){
        UIImageView* imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flash-light"]];
        CGPoint touchPT = [touch locationInView:self];
        //EZDEBUG(@"touched ended at:%@", NSStringFromCGPoint(touchPT));
        [imgView setCenter:touchPT];
        [self addSubview:imgView];
        
        [UIView animateWithDuration:0.4 animations:^(){
            imgView.transform = CGAffineTransformMakeScale(2, 2);
            imgView.alpha = 0;
        } completion:^(BOOL completed){
            [imgView removeFromSuperview];
        }];
    }
    [self unpressed];
    if(_releasedBlock){
        _releasedBlock(touch);
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self unpressed];
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
