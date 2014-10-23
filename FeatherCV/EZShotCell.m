//
//  EZShotCell.m
//  3DCamera
//
//  Created by xietian on 14-10-20.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZShotCell.h"
#import "EZShotButton.h"

@implementation EZShotCell
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    EZShotButton* shotBtn = [EZShotButton createCellShot:(CGRect){0, 0, frame.size.width, frame.size.width}];
    [self.contentView addSubview:shotBtn];
    [shotBtn addTarget:self action:@selector(shotClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return self;
}

- (void) shotClicked:(id)obj
{
    EZDEBUG(@"Shot click get called");
    if(_addClicked){
        _addClicked(nil);
    }
}


@end
