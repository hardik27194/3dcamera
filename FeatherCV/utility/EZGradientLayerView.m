//
//  EZGradientLayerView.m
//  FeatherCV
//
//  Created by xietian on 13-12-30.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZGradientLayerView.h"

//For the purpose to solve the gradient layer change the size with the UIView.
@implementation EZGradientLayerView

+(Class) layerClass {
    return [CAGradientLayer class];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
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
