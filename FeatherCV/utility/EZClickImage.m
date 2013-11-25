//
//  EZClickImage.m
//  ShowHair
//
//  Created by xietian on 13-3-24.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import "EZClickImage.h"
#import <QuartzCore/QuartzCore.h>


@implementation EZClickImage

- (void) config
{
    self.userInteractionEnabled = true;
    _enableTouchEffects = TRUE;
}

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

- (id) initWithImage:(UIImage *)image
{
    self = [super initWithImage:image];
    [self config];
    return self;
}

- (void) pressed
{
    if(self.highlightedImage){
        _backupImage = self.image;
        self.image = self.highlightedImage;
    }else{
        
    }
    /**
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        //[UIView setAnimationRepeatCount:1];
        self.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
    } completion:^(BOOL finished) {
        
    }];
     **/
   
}
//Mean the touch ended, doesn't mean a effective click
- (void) unpressed
{
    
    if(self.highlightedImage){
        self.image = _backupImage;
    }else{
        
    }
    /**
    [UIView animateWithDuration:0.2 animations:^(){
        //view.layer.shadowOpacity = 0.0f;
        self.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
     **/
}


- (id) initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage
{
    self = [super initWithImage:image highlightedImage:highlightedImage];
    [self config];
    return self;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self pressed];
    UITouch* touch = [touches anyObject];
    if(_pressedBlock){
        _pressedBlock(touch);
    }
   
}
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    [self unpressed];
    if(_enableTouchEffects){
        UIImageView* imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"flash-light"]];
        CGPoint touchPT = [touch locationInView:self];
        [imgView setCenter:touchPT];
        [self addSubview:imgView];
        
        [UIView animateWithDuration:0.4 animations:^(){
            imgView.transform = CGAffineTransformMakeScale(2, 2);
            imgView.alpha = 0;
        } completion:^(BOOL completed){
            [imgView removeFromSuperview];
        }];
    }
    //EZDEBUG(@"Touch ended");
    if(_releasedBlock){
        //EZDEBUG(@"Will call release block");
        _releasedBlock(touch);
    }else{
        //EZDEBUG(@"Release block is nil");
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
