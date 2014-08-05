//
//  EZTextField.m
//  BabyCare
//
//  Created by xietian on 14-7-30.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZTextField.h"

@implementation EZTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id) creatTextField:(CGRect)frame textColor:(UIColor*)textColor font:(UIFont*)font alignment:(NSTextAlignment)alignment borderColor:(UIColor*)borderColor padding:(CGSize)padding
{
    //CGRectMake(self.bounds.size.width - 110, (EZInputItemHeight - 30)/2.0, 100, 30)
    EZTextField* textField = [[EZTextField alloc] initWithFrame:frame];
    textField.textColor = textColor;
    textField.font = font;
    textField.textAlignment = alignment;
    if(borderColor){
        textField.layer.cornerRadius = 5;
        textField.layer.borderColor = borderColor.CGColor;
        textField.layer.borderWidth = 1.0;
    }
    //textField.padding = CGRectInset(textField.bounds, padding.width, padding.height);
    textField.padding = padding;
    return textField;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, _padding.width, _padding.height);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, _padding.width, _padding.height);
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
