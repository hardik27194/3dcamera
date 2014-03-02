//
//  EZChatUnit.m
//  FeatherCV
//
//  Created by xietian on 14-3-1.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZChatUnit.h"
#import "EZClickImage.h"
#import "EZExtender.h"

#define chatTextLength 230

@implementation EZChatUnit

- (id) init
{
    return [self initWithFrame:CGRectMake(0, 0, 320, DefaultChatUnitHeight)];
}

//Will adjust the time according to needs.
- (void) setTimeStr:(NSString*)timeStr
{
    _textDate.text = timeStr;
    CGSize textSize =  [_textDate sizeThatFits:CGSizeMake(999, 12)];
    _textDate.width = textSize.width + 6;
    _textDate.center = CGPointMake(self.center.x, _textDate.center.y);
}

- (void) setChatStr:(NSString*)chatStr
{
    _chatText.text = chatStr;
    CGSize textSize = [_chatText sizeThatFits:CGSizeMake(999, 35)];
    CGSize textHeight = [_chatText sizeThatFits:CGSizeMake(chatTextLength, 999)];
    //[_chatText setSize:textSize];
    CGFloat width = textSize.width + 6;
    if(width > chatTextLength){
        width = chatTextLength;
    }
    _chatText.width = width;
    _chatText.x = chatTextLength - _chatText.width + 10;
    if(textHeight.height > _chatText.height){
        _chatText.height = textHeight.height + 10;
    }
    EZDEBUG(@"chat:%@, height:%f, width:%f", chatStr, width, textHeight.height);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 21)];
        _textDate.font = [UIFont systemFontOfSize:13];
        _textDate.textAlignment = NSTextAlignmentCenter;
        _textDate.textColor = [UIColor whiteColor];
        _textDate.backgroundColor = lightGrayBackground;
        [self addSubview:_textDate];
        _textDate.layer.cornerRadius = 3.0;
        
        _chatText = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, 245, 35)];
        _chatText.layer.cornerRadius = 3.0;
        _chatText.font = [UIFont systemFontOfSize:15];
        _chatText.textAlignment = NSTextAlignmentLeft;
        _chatText.textColor = darkTextColor;
        _chatText.backgroundColor = RGBCOLOR(230, 230, 234);
        _chatText.lineBreakMode = NSLineBreakByWordWrapping;
        _chatText.numberOfLines = 0;
        [self addSubview:_chatText];
        
        _authorIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(260, 34, smallIconRadius, smallIconRadius)];
        _authorIcon.contentMode = UIViewContentModeScaleAspectFill;
        _authorIcon.backgroundColor = randBack(nil);
        [_authorIcon enableRoundImage];
        [self addSubview:_authorIcon];
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
