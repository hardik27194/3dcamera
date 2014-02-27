//
//  EZKeyboadUtility.m
//  ShowHair
//
//  Created by xietian on 13-4-5.
//  Copyright (c) 2013年 xietian. All rights reserved.
//

#import "EZKeyboadUtility.h"
#import "EZConstants.h"
#import "EZMessageCenter.h"

static EZKeyboadUtility* instance;

@implementation EZKeyboadUtility

+ (EZKeyboadUtility*) getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EZKeyboadUtility alloc] init];
    });
    return instance;
}

- (id) init
{
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillRaise:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidRaise:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    return  self;
}

- (void) keyboardDidHide:(id) sender
{
    EZDEBUG(@"keyboardDidHide");
    [[EZMessageCenter getInstance] postEvent:EventKeyboardDidHide attached:self];
}

- (void) keyboardDidRaise:(id) sender
{
    EZDEBUG(@"keyboardDidRaised");
    [[EZMessageCenter getInstance] postEvent:EventKeyboardDidRaise attached:self];
}

- (void) keyboardWillHide:(id) sender
{
    //if(keyboardHide)
    [[EZMessageCenter getInstance] postEvent:EventKeyboardWillHide attached:self];
}

- (CGRect) keyboardFrameToView:(UIView*)dest
{
    return [dest convertRect:_keyboardFrame fromView:[UIApplication sharedApplication].keyWindow];
}

- (void) keyboardWillRaise:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    NSValue* keyboardFrameEnd = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    CGRect keyboardFrameEndRect = [keyboardFrameEnd CGRectValue];
    
    //
    _gapHeight = keyboardFrameBeginRect.size.height - keyboardFrameEndRect.size.height;
    
    
    _keyboardFrame = keyboardFrameEndRect;
    
    //CGRect  adjustedRect = [self.view convertRect:keyboardFrameEndRect fromView:[UIApplication sharedApplication].keyWindow];
    
    //CGFloat boardY = keyboardFrameBeginRect.size.height == 216 ? 252:216;
    
    EZDEBUG(@"KeyBoard frame:%@,adjustedFrame:%@, endFrame:%@, gapHeight:%f", NSStringFromCGRect(keyboardFrameBeginRect),NSStringFromCGRect(_keyboardFrame), NSStringFromCGRect(keyboardFrameEndRect), _gapHeight);

    [[EZMessageCenter getInstance] postEvent:EventKeyboardWillRaise attached:self];
    //EZDEBUG(@"About to raise the index:%i", _messages.count -1);
    //[self moveContentUp:adjustedRect inputBarY:_chatBar.frame.size.height];
}


@end
