//
//  EZToolStripe.m
//  FeatherCV
//
//  Created by xietian on 14-7-7.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZToolStripe.h"
#import "EZInfoButton.h"

@implementation EZToolStripe

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupView];
    }
    return self;
}


- (void) setupView
{
    _infoButtons = [[NSMutableArray alloc] init];
    self.backgroundColor = [UIColor whiteColor];
    CGFloat beginPos = 30;
    CGFloat buttonWidth = 70;
    for(int i = 0; i < 4; i++){
        EZInfoButton* infoBtn = [[EZInfoButton alloc] initWithFrame:CGRectMake(beginPos + i * buttonWidth, 0, buttonWidth, EZToolStripeHeight)];
        if(i == 0){
            infoBtn.infoCount.text = int2str(0);
            infoBtn.infoType.text = macroControlInfo(@"friend tab");
            [_infoButtons addObject:infoBtn];
            //[self addSubview:infoBtn];
        }else if(i == 1){
            infoBtn.infoCount.text = int2str(0);
            infoBtn.infoType.text = macroControlInfo(@"activity tab");
            [_infoButtons addObject:infoBtn];
            //[self addSubview:infoBtn];
        }else if(i == 2){
            infoBtn.infoCount.text = int2str(0);
            infoBtn.infoType.text = macroControlInfo(@"message tab");
            [_infoButtons addObject:infoBtn];
            //[self addSubview:infoBtn];
        }else if(i == 3){
            //infoBtn.infoCount.text = int2str(0);
            infoBtn.infoIcon.image = [UIImage imageNamed:@"setting_icon"];
            infoBtn.infoType.text = macroControlInfo(@"setting tab");
            [_infoButtons addObject:infoBtn];
            //[self addSubview:infoBtn];
        }
        [infoBtn addTarget:self action:@selector(clicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:infoBtn];
    }
}

- (void) clicked:(id)sender
{
    int pos = [_infoButtons indexOfObject:sender];
    EZDEBUG(@"button clicked:%i, sender", pos);
    if(_clicked){
        _clicked(@(pos));
    }
}

- (id) init
{
    return [self initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZToolStripeHeight)];
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
