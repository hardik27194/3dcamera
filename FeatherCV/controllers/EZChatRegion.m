//
//  EZChatRegion.m
//  FeatherCV
//
//  Created by xietian on 14-2-18.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZChatRegion.h"
#import "EZPerson.h"
#import "EZClickImage.h"
#import "EZExtender.h"


#define startY  5.0
#define marginX  8.0
#define marginY  5.0
#define levelHeight  35
#define iconDiameter 35

@implementation EZChatRegion

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _fontColor = darkTextColor;
        _textFont = [UIFont systemFontOfSize:14];
        _chatLabel = [[NSMutableArray alloc] init];
        _headIcons = [[NSMutableArray alloc] init];
        _container = [[EZClickView alloc] initWithFrame:self.bounds];
        //_container.backgroundColor = RGBCOLOR(128, 68, 68);
        [self addSubview:_container];
        __weak EZChatRegion* weakSelf = self;
        _container.releasedBlock = ^(id obj){
            [weakSelf showChatField];
        };
        self.clipsToBounds = TRUE;
    }
    return self;
}


- (void) hideChatField
{
    [UIView animateWithDuration:0.3 animations:^(){
        [_container setY:0];
        _chatInput.alpha = 0;
    } completion:^(BOOL completed){
        
    }];
}

- (void) showChatField
{
    
    if(!_isChatShow){
        EZDEBUG(@"I will show the chat region");

        
        if(_chatInput == nil){
            _chatInput = [[UITextField alloc] initWithFrame:CGRectMake(marginX, startY, self.frame.size.width, levelHeight)];
            _chatInput.returnKeyType = UIReturnKeyDone;
            //self addSubview:_chatInput];
            //_chatInput.backgroundColor = [UIColor redColor];
            _chatInput.font = _textFont;
            _chatInput.textColor = _fontColor;
            [self addSubview:_chatInput];
            //_chatInput.canBecomeFirstResponder = YES;
        }
        _chatInput.alpha = 0;
        _chatInput.delegate = self;
        _chatInput.userInteractionEnabled = TRUE;
        if(_externalAnimateBlock){
            _externalAnimateBlock(nil);
        }
        [UIView animateWithDuration:0.3 animations:^(){
            _container.y = startY + levelHeight;
            _chatInput.alpha = 1.0;
        } completion:^(BOOL completed){
            [_chatInput becomeFirstResponder];
        }];
    }else{
        [_chatInput resignFirstResponder];
        [UIView animateWithDuration:0.3 animations:^(){
            _container.y = 0;
        } completion:^(BOOL completed){
            
        }];
    }
    
    _isChatShow = !_isChatShow;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    EZDEBUG(@"Encounter text:%@", textField.text);
    if([@"" isEqualToString:textField.text]){
    }else{
        if(_chatCompleted){
            _chatCompleted(textField.text);
        }
        textField.text = @"";
    }
    [textField resignFirstResponder];
    [self hideChatField];
    return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    EZDEBUG(@"end text field editing");
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    EZDEBUG(@"The text input");
    return TRUE;
}

- (void) insertChat:(NSDictionary*)dict
{
    CGFloat width = self.width;
    CGFloat curPosY = 0;
    EZPerson* person = [dict objectForKey:@"person"];
    NSString* text = [dict objectForKey:@"text"];
    BOOL isOwner = [person.personID  isEqualToString:_ownerID];
    EZClickImage* headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(isOwner?marginX:width - marginX - iconDiameter, curPosY, iconDiameter, iconDiameter)];
    [headIcon enableRoundImage];
    headIcon.backgroundColor = RGBCOLOR(255, 128, 0);
    headIcon.releasedBlock = isOwner?_ownerClicked:_otherClicked;
    UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginX + iconDiameter + marginX, curPosY, width - 2 * iconDiameter - 4 * marginX, levelHeight)];
    textLabel.textAlignment = isOwner?NSTextAlignmentLeft:NSTextAlignmentRight;
    textLabel.textColor = _fontColor;
    textLabel.font = _textFont;
    textLabel.text = text;
    textLabel.numberOfLines = 0;
    textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGRect boundingBox = [text boundingRectWithSize:CGSizeMake(textLabel.width, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textLabel.font} context:nil];
    textLabel.height = boundingBox.size.height;
    if(boundingBox.size.height > levelHeight){
        curPosY += marginY + boundingBox.size.height;
    }else{
        curPosY += marginY + levelHeight;
    }
    [_container addSubview:headIcon];
    [_container  addSubview:textLabel];
    [_chatLabel addObject:textLabel];
    [_headIcons addObject:headIcon];
    CGFloat orgY = headIcon.getY;
    CGFloat orgTextY = textLabel.getY;
    
    [headIcon setY:-headIcon.height];
    [textLabel setY:-textLabel.height];
    [UIView animateWithDuration:0.4 animations:^(){
        [headIcon setY:orgY];
        [textLabel setY:orgTextY];
        for(int i = 0; i < _headIcons.count; i ++){
            UIView* chatLab = [_chatLabel objectAtIndex:i];
            UIView* icon = [_headIcons objectAtIndex:i];
            [chatLab moveY:curPosY];
            [icon moveY:curPosY];
        }
    }];

    
}
//Assume the all the staff have sort as we expected.
- (void) render
{
    CGFloat width = self.frame.size.width;

    CGFloat curPosY = startY;
    
    [_container removeAllSubviews];
    [_chatLabel removeAllObjects];
    [_headIcons removeAllObjects];
    for(NSDictionary* dict in _conversations){
        EZPerson* person = [dict objectForKey:@"person"];
        NSString* text = [dict objectForKey:@"text"];
        BOOL isOwner = [person.personID  isEqualToString:_ownerID];
        EZClickImage* headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(isOwner?marginX:width - marginX - iconDiameter, curPosY, iconDiameter, iconDiameter)];
        [headIcon enableRoundImage];
        headIcon.backgroundColor = RGBCOLOR(255, 128, 0);
        headIcon.releasedBlock = isOwner?_ownerClicked:_otherClicked;
        
        UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginX + iconDiameter + marginX, curPosY, width - 2 * iconDiameter - 4 * marginX, 35)];
        textLabel.textAlignment = isOwner?NSTextAlignmentLeft:NSTextAlignmentRight;
        textLabel.textColor = _fontColor;
        textLabel.font = _textFont;
        textLabel.text = text;
        textLabel.numberOfLines = 0;
        textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGRect boundingBox = [text boundingRectWithSize:CGSizeMake(textLabel.width, 999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:textLabel.font} context:nil];
        textLabel.height = boundingBox.size.height;
        if(boundingBox.size.height > levelHeight){
            curPosY += marginY + boundingBox.size.height;
        }else{
            curPosY += marginY + levelHeight;
        }
        [_container addSubview:headIcon];
        [_container  addSubview:textLabel];
        [_headIcons addObject:headIcon];
        [_chatLabel addObject:textLabel];
    }
    _container.height = curPosY;
    self.height = curPosY;
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
