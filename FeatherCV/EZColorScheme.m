//
//  EZColorScheme.m
//  3DCamera
//
//  Created by xietian on 14-10-8.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZColorScheme.h"

@implementation EZColorScheme

- (id) init
{
    self = [super init];
    _mainNavSelectedColor = RGBCOLOR(255, 119, 86);
    _mainNavNormalColor = RGBCOLOR(70, 70, 70);
    _generalBackgroundColor = RGBCOLOR(239, 239, 243);
    _infoTextColor = RGBCOLOR(0, 0, 0);
    _systemTextColor = RGBCOLOR(102, 102, 102);
    _cancelBtnColor = RGBCOLOR(134, 140, 148);
    _confirmBtnColor = RGBCOLOR(255, 119, 86);
    _dangerousBtnColor = RGBCOLOR(255, 159, 17);
    _warningTintColor = RGBCOLOR(255, 159, 17);
    _navBtnTextColor = RGBCOLOR(62, 192, 216);
    _toolBarTintColor = RGBCOLOR(92, 92, 92);
    _mainCellNameColor = RGBCOLOR(60, 60, 60);
    _mainCellTimeColor = RGBCOLOR(102, 102, 102);
    return self;
}

SINGLETON_FOR_CLASS(EZColorScheme);

@end
