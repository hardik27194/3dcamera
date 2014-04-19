//
//  EZEnlargedView.m
//  FeatherCV
//
//  Created by xietian on 14-4-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZEnlargedView.h"
#import "EZClickImage.h"

@implementation EZEnlargedView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) changeColor
{
    if(!self.pressedView){
        if(_clickImage){
            self.pressedView = [[UIView alloc] initWithFrame:_clickImage.bounds];
            [_clickImage addSubview:self.pressedView];
        }else{
            self.pressedView = [[UIView alloc] initWithFrame:_innerView.bounds];
            [_innerView addSubview:self.pressedView];

        }
    }else{
        if(_clickImage){
            [self.pressedView setFrame:_clickImage.bounds];
        }else{
            [self.pressedView setFrame:_innerView.bounds];
        }
    }
    //Then my code will be very strong.
    //if(_enableTouchEffects){
    //[self bringSubviewToFront:self.pressedView];
    self.pressedView.backgroundColor = ClickedColor;//randBack(_pressedColor);
    self.pressedView.hidden = false;
    //}
    
}

- (id) initWithFrame:(CGRect)frame innerView:(UIView*)innerView enlargeRatio:(CGFloat)enlargeRatio
{
    CGFloat realWidth = frame.size.width * enlargeRatio;
    CGFloat realHeight = frame.size.height * enlargeRatio;
    
    CGFloat adjustY = frame.origin.y - (realHeight - frame.size.height)/2.0;
    CGFloat adjustX = frame.origin.x - (realWidth - frame.size.width)/2.0;
    
    
    self = [super initWithFrame:CGRectMake(adjustX, adjustY, realWidth, realHeight)];
    self.backgroundColor = [UIColor clearColor];//RGBA(255, 128, 128, 128);
    if (self) {
        // Initialization code
        //_clickImage = [[UIImageView alloc] initWithFrame:CGRectMake((realWidth - frame.size.width)/2.0, (realHeight - frame.size.height)/2.0, frame.size.width, frame.size.height)];
        _innerView = innerView;
        _innerView.frame = CGRectMake((realWidth - frame.size.width)/2.0, (realHeight - frame.size.height)/2.0, frame.size.width, frame.size.height);
        //_clickImage.userInteractionEnabled = false;
        [self addSubview:_innerView];
        _enlargeRatio = enlargeRatio;
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame enlargeRatio:(CGFloat)enlargeRatio
{
    
    CGFloat realWidth = frame.size.width * enlargeRatio;
    CGFloat realHeight = frame.size.height * enlargeRatio;
    
    CGFloat adjustY = frame.origin.y - (realHeight - frame.size.height)/2.0;
    CGFloat adjustX = frame.origin.x - (realWidth - frame.size.width)/2.0;
    
    
    self = [super initWithFrame:CGRectMake(adjustX, adjustY, realWidth, realHeight)];
    self.backgroundColor = [UIColor clearColor];//RGBA(255, 128, 128, 128);
    if (self) {
        // Initialization code
        _clickImage = [[UIImageView alloc] initWithFrame:CGRectMake((realWidth - frame.size.width)/2.0, (realHeight - frame.size.height)/2.0, frame.size.width, frame.size.height)];
        //_clickImage.userInteractionEnabled = false;
        [self addSubview:_clickImage];
        _enlargeRatio = enlargeRatio;
    }
    return self;
}

- (void) setImage:(UIImage *)image
{
    _clickImage.image = image;
}

- (UIImage*) getImage
{
    return _clickImage.image;
}

- (void) enableRoundImage
{
    [super enableRoundImage];
    [_clickImage enableRoundImage];
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
