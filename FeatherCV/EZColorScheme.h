//
//  EZColorScheme.h
//  3DCamera
//
//  Created by xietian on 14-10-8.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 What's the purpose of this class?
 All the color will read from here, so that when something need to change, simply change this color is good enough. 
 When the color scheme changed, the callback will get called to inform the Control something important happened.
 I love this game.
 **/
@interface EZColorScheme : NSObject

SINGLETON_FOR_HEADER(EZColorScheme);

@property (nonatomic, strong) UIColor* mainNavSelectedColor;

@property (nonatomic, strong) UIColor* mainNavNormalColor;

@property (nonatomic, strong) UIColor* navBarTintColor;

@property (nonatomic, strong) UIColor* generalBackgroundColor;

//All the button text on the tool bar
@property (nonatomic, strong) UIColor* navBtnTextColor;

//Input by user
@property (nonatomic, strong) UIColor* infoTextColor;


@property (nonatomic, strong) UIColor* mainCellNameColor;

@property (nonatomic, strong) UIColor* mainCellTimeColor;

//System title color
@property (nonatomic, strong) UIColor* systemTextColor;


@property (nonatomic, strong) UIColor* cancelBtnColor;

@property (nonatomic, strong) UIColor* confirmBtnColor;

@property (nonatomic, strong) UIColor* dangerousBtnColor;

@property (nonatomic, strong) UIColor* warningTintColor;

@property (nonatomic, strong) UIColor* toolBarTintColor;

@property (nonatomic, strong) NSArray* colors;

@property (nonatomic, strong) NSArray* randomColors;

@end
