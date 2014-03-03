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

- (void) recieveLongPress:(CGFloat)time callback:(EZEventBlock)block
{
    _longPressBlock = block;
    _longPressTime = time;
}

- (void) changeColor
{
    if(!_pressedView){
        _pressedView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_pressedView];
    }else{
        [_pressedView setFrame:self.bounds];
    }
    //Then my code will be very strong.
    //if(_enableTouchEffects){
    [self bringSubviewToFront:_pressedView];
    _pressedView.backgroundColor = randBack(_pressedColor);
    _pressedView.hidden = false;
    //}

}

- (void) enlargeCycle:(BOOL)enlarge
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat orgBorder = 4.0;
    CGFloat borderWidth = 4.0;
    if(enlarge){
        transform = CGAffineTransformScale(CGAffineTransformIdentity, _enlargeScale, _enlargeScale);
        borderWidth = (self.width * _enlargeScale - self.width) / 2.0;
        [UIView animateWithDuration:0.4 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options: UIViewAnimationOptionCurveLinear animations:^(){
            self.transform = transform;
            self.layer.borderWidth = borderWidth;
        } completion:^(BOOL completed){
            [UIView animateWithDuration:0.3 animations:^(){
                self.layer.borderWidth = orgBorder;
            }];
        }];
    }else{
        borderWidth = (self.width * _enlargeScale - self.width) / 2.0;
        [UIView animateWithDuration:0.3 delay:0.1 options: UIViewAnimationOptionCurveLinear animations:^(){
            self.layer.borderWidth = borderWidth;
        } completion:^(BOOL completed){
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options: UIViewAnimationOptionCurveLinear animations:^(){
                self.transform = transform;
                self.layer.borderWidth = orgBorder;
            } completion:^(BOOL completed){

            }];
        }];
    }
    
   
}

- (void) pressed
{
    EZDEBUG(@"Pressed clicked");
    if(!_enableTouchEffects)
        return;
    
    if(_animType == kPressColorChange){
        [self changeColor];
    }else{
        [self enlargeCycle:YES];
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
- (void) hideColor
{
    [UIView animateWithDuration:0.3 animations:^(){
        _pressedView.alpha = 0;
    } completion:^(BOOL completed){
        _pressedView.hidden = true;
        _pressedView.alpha = 1.0;
    }];
}

- (void) unpressed
{
    //_pressedView.hidden = true;
    if(!_enableTouchEffects){
        return;
    }
    if(_animType == kPressColorChange){
        [self hideColor];
    }else{
        [self enlargeCycle:NO];
    }
}

//Any finger pressed will trigger this event.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    _fingerPressed = true;
    _longPressedCalled = false;
    if(_longPressBlock){
    dispatch_later(_longPressTime, ^(){
        if(_fingerPressed){
            EZDEBUG(@"long press triggered");
            _longPressedCalled = YES;
            _longPressBlock(self);
        }else{
            EZDEBUG(@"long press ignore for released");
        }
    });
    }
    [self pressed];
    if(_pressedBlock){
        _pressedBlock(self);
    }
    
}

- (void) touchFadeEffects:(UITouch*) touch
{
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
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    _fingerPressed = false;
    if(_enableTouchEffects){
        //[self touchFadeEffects:touch];
    }
    [self unpressed];
    if(!_longPressedCalled){
        if(_releasedBlock){
            _releasedBlock(self);
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _fingerPressed = false;
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
