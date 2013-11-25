//
//  EZCrossHair.m
//  MotionGraphs
//
//  Created by xietian on 13-11-6.
//
//

#import "EZCrossHair.h"
#import <QuartzCore/QuartzCore.h>
#import "EZMotionUtility.h"

@implementation EZCrossHair

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIColor* crossColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
        CGFloat shortEnd = 5;
        CGFloat shortSide = frame.size.height > frame.size.width ? frame.size.width:frame.size.height;
        CGFloat longEnd = shortSide * 0.85;
        UIView* horizon = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - longEnd)/2, (frame.size.height - shortEnd)/2, longEnd, shortEnd)];
        UIView* vertical = [[UIView alloc] initWithFrame:CGRectMake((frame.size.width - shortEnd)/2, (frame.size.height - longEnd)/2 , shortEnd, longEnd)];
        horizon.backgroundColor = crossColor;
        vertical.backgroundColor = crossColor;
        [self addSubview:horizon];
        [self addSubview:vertical];
        __weak EZCrossHair* weakSelf = self;
        [[EZMotionUtility getInstance] registerHandler:^(EZMotionData* md){
            CGFloat angle = atan2f(md.y, md.x);
            angle += 3.1415926/2;
            angle = -angle;
            [weakSelf adjustAngle:angle];
        } key:[NSString stringWithFormat:@"CrossHair:%i",(int)self] type:kEZGravity];
    }
    
    return self;
}


- (void) dealloc
{
    EZDEBUG(@"dealloc get called");
    [[EZMotionUtility getInstance] unregisterHandler:[NSString stringWithFormat:@"CrossHair:%i",(int)self]];
}


- (void) adjustAngle:(CGFloat)angle
{
    [UIView animateWithDuration:0.2 animations:^(){
        self.transform = CGAffineTransformRotate(CGAffineTransformIdentity, angle);
        //CATransform3D adjust = CATransform3DMakeRotation(angle, 0, 0, 1);
        //self.layer.transform = adjust;
    }];
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
