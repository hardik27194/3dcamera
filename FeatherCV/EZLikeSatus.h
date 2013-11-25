//
//  EZLikeSatus.h
//  Feather
//
//  Created by xietian on 13-10-29.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import <Foundation/Foundation.h>

//Why do I create this classes?
//Initially, I think EZCombinedPhoto is a  1 to 1 Bind between photo, then I realize it is not the case
//Anymore. I just put the like on that EZCombinedPhoto is good enough.
//Then I realize it is a 1 to M relationship. So what should I do?
//I create a Object to reflect this relationship.
@interface EZLikeSatus : NSObject



@end
