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
        _graySep = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 1, 32)];
        _graySep.backgroundColor = RGBCOLOR(180, 180, 180);
        [self addSubview:_graySep];
        
        _infoCount = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 70, 20)];
        _infoCount.font = [UIFont boldSystemFontOfSize:19];
        _infoCount.textColor = RGBCOLOR(70, 70, 70);
        [self addSubview:_infoCount];
        
        _infoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12,  27, 27)];
        _infoIcon.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_infoIcon];

        _infoType = [[UILabel alloc] initWithFrame:CGRectMake(10, 42, 70, 12)];
        _infoType.font = [UIFont systemFontOfSize:12];
        _infoType.textColor = ToolBarTextColor;
        [self addSubview:_infoType];
        [self addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _triangle = [[UIImageView alloc] initWithFrame:CGRectMake(10, frame.size.height, 12 , 6)];
        _triangle.contentMode = UIViewContentModeScaleAspectFill;
        _triangle.image = [UIImage imageNamed:@"triangle"];
        [self addSubview:_triangle];
        _triangle.hidden = YES;
        //self.enableTouchEffects = true;
    }
    return self;
}

- (void) setSelected:(BOOL)selected
{
    EZDEBUG(@"info selected:%i", selected);
    if(selected){
        _graySep.backgroundColor = ClickedColor;
        _triangle.hidden = NO;
    }else{
        _graySep.backgroundColor = RGBCOLOR(180, 180, 180);
        _triangle.hidden = YES;
    }
}

- (void) setCount:(int) count
{
    if(count){
        _infoIcon.hidden = true;
        _infoCount.hidden = false;
        _infoCount.text = int2str(count);
    }else{
        _infoIcon.hidden = false;
        _infoCount.hidden = true;
    }
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
