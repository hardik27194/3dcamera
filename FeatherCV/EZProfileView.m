//
//  EZProfileView.m
//  FeatherCV
//
//  Created by xietian on 14-7-7.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZProfileView.h"
#import "EZClickImage.h"
#import "EZToolStripe.h"

#define leftPadding 25


@implementation EZProfileView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}

- (id) init
{
    return [self initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZProfileImageHeight + EZToolStripeHeight)];
}


- (void) setupView
{
    
    _headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZProfileImageHeight)];
    [self addSubview:_headIcon];
    _name = [[UITextField alloc] initWithFrame:CGRectMake(leftPadding, 238, CurrentScreenWidth - 2 * leftPadding, 43)];
    _name.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:43];
    _name.textColor = [UIColor whiteColor];
    [self addSubview:_name];
    _signature = [[UITextField alloc] initWithFrame:CGRectMake(leftPadding, 293, CurrentScreenWidth - 2 * leftPadding, 13)];
    _signature.font = [UIFont boldSystemFontOfSize:13];
    _signature.textColor = [UIColor whiteColor];
    [self addSubview:_signature];
    
    _touchIcon = [[UIImageView alloc] initWithFrame:CGRectMake(leftPadding, 318, 25, 25)];
    _touchIcon.contentMode = UIViewContentModeScaleAspectFill;
    _touchIcon.clipsToBounds = YES;
    _touchIcon.image = [UIImage imageNamed:@"demo_avatar_cook"];
    [self addSubview:_touchIcon];
    
    _touchCount = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding + 25 + 3, 318, 100, 12)];
    _touchCount.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:12];
    _touchCount.textColor = [UIColor whiteColor];
    [self addSubview:_touchCount];
    
    
    _toolStripe = [[EZToolStripe alloc] initWithFrame:CGRectMake(0, EZProfileImageHeight, CurrentScreenWidth, EZToolStripeHeight)];
    [self addSubview:_toolStripe];
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
