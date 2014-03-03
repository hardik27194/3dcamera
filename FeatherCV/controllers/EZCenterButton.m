//
//  EZCenterButton.m
//  FeatherCV
//
//  Created by xietian on 14-3-3.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZCenterButton.h"

@implementation EZCenterButton

/**
+ (Class)layerClass {
    return [CAShapeLayer class];
}
**/

- (void)layoutSubviews {
    //[self setLayerProperties];
    //[self attachAnimations];
}

- (void)setLayerProperties {
    EZDEBUG(@"setLayerProperties get called");
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    //[layer setMasksToBounds:YES];
    [layer setFillRule:kCAFillRuleEvenOdd];
    //layer.lineWidth = _lineWidth;
    //layer.strokeColor = _cycleColor.CGColor;
    layer.fillColor = _cycleColor.CGColor;
    layer.path = [self createPath:_lineWidth radius:_radius].CGPath;
    _shapeLayer = layer;
    //layer.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
    //layer.fillColor = [UIColor colorWithHue:0 saturation:1 brightness:.8 alpha:1].CGColor;
}



- (UIBezierPath*) createPath:(CGFloat)lineWidth radius:(CGFloat)radius
{
    CGFloat center = self.width/2.0 - radius;
    CGFloat diameter = _radius * 2.0;
    //CGFloat innerDelta = center + _lineWidth/2.0;
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(center - lineWidth, center - lineWidth, diameter + 2.0 * lineWidth, diameter + 2.0 * lineWidth)];
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(center, center, diameter, diameter)];//[UIBezierPath bezierPathWithRoundedRect:CGRectMake(center,center, _radius, _radius) cornerRadius:_radius/2.0];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    return path;
}

- (void) innerAnimation:(UIBezierPath*)path duration:(CGFloat)interval beginTime:(CGFloat)time
{
    CABasicAnimation *animation = [self animationWithKeyPath:@"path"];
    //CAShapeLayer* layer = (CAShapeLayer*) self.layer;
    animation.delegate = self;
    animation.duration = interval;
    animation.repeatCount = 1;
    animation.removedOnCompletion = YES;
    animation.autoreverses = FALSE;
    //animation.cumulative = true;
    //animation.additive = true;
    //animation.fromValue = (__bridge id)layer.path;
    //layer.path = path.CGPath;
    animation.toValue = (__bridge id)path.CGPath;
    //animation.toValue =  @(20.0);//[UIColor colorWithHue:0 saturation:.9 brightness:.9 alpha:1].CGColor;
    [self.layer addAnimation:animation forKey:animation.keyPath];
}

- (void)animationDidStopOld:(CAAnimation *)theAnimation2 finished:(BOOL)flag{
    EZDEBUG(@"Animation stopped, status:%i", _animStatus);
    if(_animStatus == kAnimateStart){
        _animStatus = kAnimateMiddle;
        UIBezierPath* path = [self createPath:_lineWidth radius:_radius + 20.0 - _lineWidth];
        [self innerAnimation:path duration:1.0 beginTime:0];
        _shapeLayer.path = path.CGPath;
    }else
    
    if(_animStatus == kAnimateMiddle){
        _animStatus = kAnimateSecond;
        UIBezierPath* path = [self createPath:20.0 radius:_radius];
        [self innerAnimation:path duration:1.0 beginTime:0];
        _shapeLayer.path = path.CGPath;
    }else
    
    if(_animStatus == kAnimateSecond){
        _animStatus = kAnimateFinal;
        UIBezierPath* path = [self createPath:_lineWidth radius:_radius];
        [self innerAnimation:path duration:1.0 beginTime:0];
        _shapeLayer.path = path.CGPath;
    }else
    
    if(_animStatus == kAnimateFinal){
        _animStatus = kAnimateInit;
    }
    
}


- (void) animateAllPaths:(NSArray*)paths duration:(CGFloat)duration
{
    CAKeyframeAnimation* pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    pathAnimation.values = paths;
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.delegate = self;
    //pathAnimation.duration = interval;
    pathAnimation.duration = duration;
    //pathAnimation.repeatCount = 1;
    //pathAnimation.removedOnCompletion = YES;
    //pathAnimation.autoreverses = FALSE;
    //This key is not necessary
    [self.layer addAnimation:pathAnimation forKey:@"KeyFrame"];
}

#define frameRate  0.016
#define firstStage 0.25
#define secondStage 0.5
#define thirdStage 0.75
//#define progressStep

- (void) animateButton:(CGFloat)duration lineWidth:(CGFloat)lineWidth completed:(EZEventBlock)completed 
{
    _totalCount = duration/frameRate;
    _srcLineWidth = _lineWidth;
    _targetLineWidth = lineWidth;
    _srcRadius = _radius;
    _isAnimating = true;
    _stopAnimating = false;
    _progress = 0;
    _completed = completed;
    [self tick];
}

- (void) tick
{
    ++_progress;
    if(_stopAnimating){
        _isAnimating = false;
        return;
    }
    if(_progress > _totalCount){
        EZDEBUG(@"completed");
        _radius = _srcRadius;
        _lineWidth = _srcLineWidth;
        [self setNeedsDisplay];
        if(_completed){
            _completed(nil);
        }
        return;
    }
    CGFloat ratio = _progress/_totalCount;
    if(ratio < firstStage){
        CGFloat delta = _targetLineWidth  * (ratio/firstStage);
        _lineWidth = delta;
    }else if(ratio < secondStage){
        CGFloat delta = _targetLineWidth * (ratio - firstStage)/(secondStage - firstStage);
        _lineWidth = _targetLineWidth - delta;
        _radius = _srcRadius + delta;
    }else if(ratio < thirdStage){
        CGFloat delta = _targetLineWidth * (ratio - secondStage)/(thirdStage - secondStage);
        _lineWidth = delta;
        _radius = _srcRadius + (_targetLineWidth - delta);
    }else{
        CGFloat delta = _targetLineWidth * (ratio - secondStage)/(thirdStage - secondStage);
        _lineWidth = _targetLineWidth - delta;
        _radius = _srcRadius;
    }
    [self setNeedsDisplay];
    dispatch_later(frameRate, ^(){
        [self tick];
    });
}



- (void)attachPathAnimation {
    CABasicAnimation *animation = [self animationWithKeyPath:@"path"];
    animation.toValue = (__bridge id)[UIBezierPath bezierPathWithOvalInRect:CGRectInset(self.bounds, 4, 4)].CGPath;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:animation.keyPath];
}

- (void)attachColorAnimation {
    CABasicAnimation *animation = [self animationWithKeyPath:@"fillColor"];
    animation.fromValue = (__bridge id)[UIColor colorWithHue:0 saturation:.9 brightness:.9 alpha:1].CGColor;
    [self.layer addAnimation:animation forKey:animation.keyPath];
}

- (CABasicAnimation *)animationWithKeyPath:(NSString *)keyPath {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;
    animation.duration = 1;
    return animation;
}



- (id)initWithFrame:(CGRect)frame cycleRadius:(CGFloat)radius lineWidth:(CGFloat)width
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self setBackgroundColor:[UIColor clearColor]];
        _radius = radius;
        _lineWidth = width;
        _cycleColor = [UIColor whiteColor];
        self.opaque = NO;
        self.enableTouchEffects = false;
    }
    return self;
}



- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetStrokeColorWithColor(context, _cycleColor.CGColor);
    //CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    CGContextSetLineWidth(context, _lineWidth);
    CGFloat diameter = _radius * 2.0;
    CGFloat center = (self.width - diameter)/2.0;
    CGContextAddEllipseInRect(context, CGRectMake(center, center, diameter, diameter));
    //CGContextAddEllipseInRect(context, CGRectMake(20, 20, 20, 20));
    //CGContextFillPath(context);
    //CGContextStrokePath(context);
    //CGContextSetLineWidth(context, 5.0);
    //CGContextMoveToPoint(context, 100.0,0.0);
    //CGContextAddLineToPoint(context,100.0, 100.0);
    CGContextStrokePath(context);
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
