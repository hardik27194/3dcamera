//
//  EZImageAdder.h
//  BabyCare
//
//  Created by xietian on 14-10-9.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZImageAdder : UIScrollView<UIActionSheetDelegate>

- (id) initWithFrame:(CGRect)frame padding:(CGSize)padding markSize:(CGSize)markSize limit:(CGSize)limit controller:(UIViewController*)controller;

@property (nonatomic, assign) CGSize padding;

@property (nonatomic, assign) CGSize markSize;

@property (nonatomic, assign) CGSize limit;

@property (nonatomic, strong) UIButton* addImageMark;

@property (nonatomic, strong) NSMutableArray* uploadImages;

@property (nonatomic, strong) NSMutableArray* imageBtns;

@property (nonatomic, strong) UIViewController* controller;

@end
