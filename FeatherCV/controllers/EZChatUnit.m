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
    return [self initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, DefaultChatUnitHeight)];
}

//Will adjust the time according to needs.
- (void) setTimeStr:(NSString*)timeStr
{
    _textDate.text = timeStr;
    CGSize textSize =  [_textDate sizeThatFits:CGSizeMake(999, 12)];
    _textDate.width = textSize.width + 6;
    _textDate.center = CGPointMake(self.center.x, _textDate.center.y);
    if([timeStr isEmpty]){
        _textDate.hidden = YES;
    }else{
        _textDate.hidden = NO;
    }
}

- (void) setChatStr:(NSString*)chatStr name:(NSString*)name
{
    _chatText.text = chatStr;
    //CGSize textSize = [_chatText sizeThatFits:CGSizeMake(999, 35)];
    CGSize textHeight = [_chatText sizeThatFits:CGSizeMake(chatTextLength, 999)];
    //[_chatText setSize:textSize];
    //CGFloat width = textSize.width + 6;
    //if(width > chatTextLength){
    //    width = chatTextLength;
    //}
    //_chatText.width = width;
    //_chatText.x = chatTextLength - _chatText.width + 10;
    if(textHeight.height > _chatText.height){
        _chatText.height = textHeight.height + 10;
    }
    if([chatStr isEmpty]){
        _textDate.hidden = YES;
    }else{
        _textDate.hidden = NO;
    }
    [self setAttributeString:name chatText:chatStr label:_chatText];
    //EZDEBUG(@"chat:%@, height:%f, width:%f", chatStr, width, textHeight.height);
}

- (void) setAttributeString:(NSString*)name chatText:(NSString*)chatText label:(UILabel*)label
{
   /**
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: label.textColor,
                              NSFontAttributeName: [UIFont boldSystemFontOfSize:15]
                              };
    NSString* appendedStr = [NSString stringWithFormat:@"%@:%@", name,chatText];
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:appendedStr
                                           attributes:attribs];
    
    // Red text attributes
    //UIColor *redColor = [UIColor redColor];
    NSRange bodyTextRange =  [appendedStr rangeOfString:chatText];//[chatText rangeOfString:chatText];// * Notice that usage of rangeOfString in this case may cause some bugs - I use it here only for demonstration
    [attributedText setAttributes:@{NSForegroundColorAttributeName:label.textColor,
                                    NSFontAttributeName:[UIFont systemFontOfSize:15]
                                    }
                            range:bodyTextRange];
    
    // Green text attributes
   **/
   //[attributedText setAttributes:@{NSForegroundColorAttributeName:greenColor} range:greenTextRange];
    label.text = chatText;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _textDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 21)];
        _textDate.font = [UIFont systemFontOfSize:13];
        _textDate.textAlignment = NSTextAlignmentCenter;
        _textDate.textColor = [UIColor whiteColor];
        _textDate.backgroundColor = [UIColor clearColor];
        //[self addSubview:_textDate];
        [_textDate enableShadow:[UIColor blackColor]];
        _textDate.layer.cornerRadius = 3.0;
        
        _chatText = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, 245, 35)];
        _chatText.layer.cornerRadius = 3.0;
        _chatText.font = [UIFont systemFontOfSize:15];
        _chatText.textAlignment = NSTextAlignmentLeft;
        _chatText.textColor = [UIColor whiteColor];
        _chatText.backgroundColor = [UIColor clearColor];
        _chatText.lineBreakMode = NSLineBreakByWordWrapping;
        _chatText.numberOfLines = 0;
        [_chatText enableShadow:[UIColor blackColor]];
        [self addSubview:_chatText];
        
        //_authorIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(260, 34, smallIconRadius, smallIconRadius)];
        //_authorIcon.contentMode = UIViewContentModeScaleAspectFill;
        //_authorIcon.backgroundColor = randBack(nil);
        //[_authorIcon enableRoundImage];
        //[self addSubview:_authorIcon];
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
