//
//  EZInfoButton.m
//  FeatherCV
//
//  Created by xietian on 14-7-8.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZInfoButton.h"

@implementation EZInfoButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.animType = kPressGlow;
        self.showsTouchWhenHighlighted = YES;
        UIView* graySep = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 1, 32)];
        graySep.backgroundColor = RGBCOLOR(180, 180, 180);
        [self addSubview:graySep];
        
        _infoCount = [[UILabel alloc] initWithFrame:CGRectMake(10, 18, 70, 20)];
        _infoCount.font = [UIFont boldSystemFontOfSize:19];
        _infoCount.textColor = RGBCOLOR(70, 70, 70);
        [self addSubview:_infoCount];
        
        _infoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 20, 17, 17)];
        _infoIcon.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_infoIcon];

        _infoType = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 70, 12)];
        _infoType.font = [UIFont systemFontOfSize:12];
        _infoType.textColor = RGBCOLOR(70, 70, 70);
        [self addSubview:_infoType];
        [self addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        //self.enableTouchEffects = true;
    }
    return self;
}

- (void) btnClicked:(id)btn
{
    EZDEBUG(@"Touch clicked");
    if(_clicked){
        _clicked(self);
    }
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
