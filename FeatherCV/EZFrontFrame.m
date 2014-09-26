//
//  EZFrontFrame.m
//  3DCamera
//
//  Created by xietian on 14-9-21.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZFrontFrame.h"
#import "EZExtender.h"


@implementation EZFrontFrame

- (CGRect) shrinkRect:(CGRect)rect  width:(CGFloat)width aspect:(BOOL)aspect
{
    CGFloat halfWidth = width/2.0;
    CGFloat height = aspect?(self.height/self.width)*width:width;
    return CGRectMake(rect.origin.x - halfWidth, rect.origin.y - halfWidth, rect.size.width + width, rect.size.height + height);
}

//Maintain the center
- (CGRect) changeRect:(CGRect)rect size:(CGSize)size
{
    CGFloat delta = size.width - rect.size.width;
    return [self shrinkRect:rect width:delta aspect:YES];
}

- (CGRect) getFinalFrame
{
    return _maskFrame.frame;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _maskFrame = [[UIView alloc] initWithFrame:[self shrinkRect:self.bounds width:-30 aspect:YES]];
        _maskFrame.layer.cornerRadius = 5;
        _maskFrame.layer.borderWidth = 2;
        _maskFrame.layer.borderColor = RGBCOLOR(254, 209, 77).CGColor;
        [self addSubview:_maskFrame];
        _maskFrame.clipsToBounds = true;
        //[self addSubview:_maskFrame];
        _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(paned:)];
        [_maskFrame addGestureRecognizer:_pan];
        _pan.delegate = self;
        
        _pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [self addGestureRecognizer:_pinch];
        _pinch.delegate = self;
        
    }
    
    return self;
}

- (void) pinch:(UIPinchGestureRecognizer*)pinch
{
    //_maskFrame.transform = CGAffineTransformMakeScale(_orgScale * pinch.scale, _orgScale * pinch.scale);
    
    CGSize scaledSize = CGSizeMake(_orgFrame.size.width * pinch.scale, _orgFrame.size.height * pinch.scale);
    _maskFrame.frame = [self changeRect:_orgFrame size:scaledSize];
}

- (void) paned:(UIPanGestureRecognizer*)pg
{
    CGPoint pt = [pg translationInView:self];
    EZDEBUG(@"pt is:%@", NSStringFromCGPoint(pt));
    [_maskFrame setPosition:CGPointMake(_orgPosition.x + pt.x, _orgPosition.y + pt.y)];
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer == _pinch){
        _orgFrame = _maskFrame.frame;
        _orgScale = _maskFrame.transform.a;
        EZDEBUG(@"Original scale is:%f", _orgScale);
    }else{
        _orgPosition = _maskFrame.frame.origin;
    }
    return true;
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
