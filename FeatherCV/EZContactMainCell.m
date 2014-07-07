//
//  EZContactCell.m
//  FeatherCV
//
//  Created by xietian on 14-6-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZContactMainCell.h"
#import "EZLineDrawingView.h"


@implementation EZContactMainCell


- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        
        _paintTouchView = [[EZLineDrawingView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZPersonCellHeight)];
        [self.contentView addSubview:_paintTouchView];
        _name = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 40)];
        _name.font = [UIFont systemFontOfSize:17];
        _name.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_name];
        
        
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
