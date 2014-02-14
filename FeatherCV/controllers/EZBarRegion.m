//
//  EZBarRegion.m
//  FeatherCV
//
//  Created by xietian on 14-2-13.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZBarRegion.h"

@implementation EZBarRegion

- (id) init
{
    return [self initWithFrame:CGRectMake(0, 0, 300, 80)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _location = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 200, 20)];
        _location.textColor = lightTextColor;
        _time = [[UILabel alloc] initWithFrame:CGRectMake(210, 5, 90, 20)];
        _time.textColor = lightTextColor;
        _time.textAlignment = NSTextAlignmentLeft;
        _selfIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(5, 30+8, 35, 35)];
        [_selfIcon enableRoundImage];
        _selfIcon.backgroundColor  = RGBCOLOR(255, 128, 0);
        
        _otherIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(80, 30+8, 35, 35)];
        [_otherIcon enableRoundImage];
        _otherIcon.backgroundColor = RGBCOLOR(0, 128, 255);
        _unlockButton = [[UIButton alloc] initWithFrame:CGRectMake(180, 30, 120, 50)];
        [_unlockButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_unlockButton setTitle:@"私人" forState:UIControlStateNormal];
        _unlockButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_unlockButton setTitleColor:defaultDarkColor forState:UIControlStateNormal];
        [self addSubview:_location];
        [self addSubview:_time];
        [self addSubview:_selfIcon];
        [self addSubview:_otherIcon];
        [self addSubview:_unlockButton];
    }
    self.backgroundColor = [UIColor whiteColor];
    return self;
}

- (void) buttonClicked:(id)obj
{
    EZDEBUG(@"Touch clicked");
    if(_buttonClicked){
        _buttonClicked(obj);
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
