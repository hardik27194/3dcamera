//
//  EZTextField.h
//  BabyCare
//
//  Created by xietian on 14-7-30.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EZTextField : UITextField

+ (id) creatTextField:(CGRect)frame textColor:(UIColor*)textColor font:(UIFont*)font alignment:(NSTextAlignment)alignment borderColor:(UIColor*)borderColor padding:(CGSize)padding;

@property (nonatomic, assign) CGSize padding;

@end
