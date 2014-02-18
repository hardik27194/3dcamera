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

@implementation EZChatRegion

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//Assume the all the staff have sort as we expected.
- (void) render
{
    CGFloat width = self.frame.size.width;
    CGFloat startY = 5.0;
    CGFloat marginX = 5.0;
    CGFloat marginY = 5.0;
    CGFloat curPosY = startY;
    CGFloat iconDiameter = 35;
    for(NSDictionary* dict in _conversations){
        EZPerson* person = [dict objectForKey:@"person"];
        NSString* text = [dict objectForKey:@"text"];
        BOOL isOwner = [person.personID  isEqualToString:_ownerID];
        EZClickImage* headIcon = [[EZClickImage alloc] initWithFrame:CGRectMake(isOwner?marginX:width - marginX - iconDiameter, curPosY, iconDiameter, iconDiameter)];
        [headIcon enableRoundImage];
        headIcon.releasedBlock = isOwner?_ownerClicked:_otherClicked;
        
        UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(marginX + iconDiameter + marginX, curPosY, width - 2 * iconDiameter - 4 * marginX, 35)];
        textLabel.textAlignment = isOwner?NSTextAlignmentLeft:NSTextAlignmentRight;
        textLabel.textColor = darkTextColor;
        textLabel.text = text;
        
        //curPosY +=
    
    }
    
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
