//
//  EZKeyboardController.m
//  FeatherCV
//
//  Created by xietian on 14-3-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZKeyboardController.h"
#import "EZKeyboadUtility.h"
#import "EZMessageCenter.h"


@interface EZKeyboardController ()

@end

@implementation EZKeyboardController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupKeyboard];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[[EZKeyboadUtility getInstance] add]
    [super viewWillAppear:animated];
    [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillRaise block:_keyboardRaiseHandler];
    [[EZMessageCenter getInstance] registerEvent:EventKeyboardWillHide block:_keyboardHideHandler];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[EZMessageCenter getInstance] unregisterEvent:EventKeyboardWillRaise forObject:_keyboardRaiseHandler];
    [[EZMessageCenter getInstance] unregisterEvent:EventKeyboardWillHide forObject:_keyboardHideHandler];
}


- (UIView*) createWrap:(CGRect)frame
{
    UIView* wrapView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x - 19.0, frame.origin.y + 1.0, frame.size.width + 38.0, 38)];
    wrapView.backgroundColor = [UIColor clearColor];
    //wrapView.layer.cornerRadius = 19;
    wrapView.layer.borderColor = [UIColor whiteColor].CGColor;
    wrapView.layer.borderWidth = 1.0;
    //[wrapView enableRoundImage];
    wrapView.layer.cornerRadius = wrapView.height/2.0;
    return wrapView;
}

- (UILabel*) createPlaceHolder:(UITextField*)textField
{
    UILabel* placeHolder = [[UILabel alloc] initWithFrame:textField.frame];
    placeHolder.textAlignment = textField.textAlignment;
    placeHolder.textColor = textField.textColor;
    placeHolder.font = textField.font;
    return placeHolder;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField{
    _currentFocused = textField;
}
//--- Screen raise logic
- (void) setupKeyboard
{
    __weak EZKeyboardController* weakSelf = self;
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    EZClickView* cancelKeyboard = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 320, appFrame.size.height)];
    cancelKeyboard.backgroundColor = [UIColor clearColor];//RGBA(128, 0, 0, 128);
    cancelKeyboard.enableTouchEffects = false;
    cancelKeyboard.releasedBlock = ^(id obj){
        EZDEBUG(@"cancel clicked");
        //weakSelf.hideTextInput = false;
        //[weakSelf.textField resignFirstResponder];
        //[self hideKeyboard:NO];
        [_currentFocused resignFirstResponder];
    };
    _keyboardRaiseHandler = ^(id obj){
        
        EZKeyboadUtility* keyUtil = [EZKeyboadUtility getInstance];
        CGRect keyFrame = [keyUtil keyboardFrameToView:weakSelf.view];
        CGFloat smallGap = keyUtil.gapHeight;
        EZDEBUG(@"keyboard raised:%@, appFrame:%@, smallGap:%f",NSStringFromCGRect(keyFrame), NSStringFromCGRect(appFrame), smallGap);
        
        if(abs(smallGap) > 0){
            //[weakSelf lift:smallGap time:0.3 complete:nil];
            //[weakSelf ]
            [weakSelf liftWithBottom:smallGap isSmall:YES time:0.3 complete:nil];
        }else{
            //weakSelf.toolBarRegion.hidden = TRUE;
            [weakSelf.view addSubview:cancelKeyboard];
            [weakSelf liftWithBottom:keyFrame.size.height isSmall:NO  time:0.3 complete:nil];
        }
        //[EZDataUtil getInstance].centerButton.alpha = 0.0;
    };
    
    _keyboardHideHandler = ^(id obj){
        [cancelKeyboard removeFromSuperview];
        //[weakSelf liftWithBottom:-keyFrame.size.height time:0.6];
        [weakSelf hideKeyboard:nil];
        //[EZDataUtil getInstance].centerButton.alpha = 1.0;
        
    };
    //[[EZMessageCenter getInstance] registerEvent:EZ block:
    //_centerButtonY = [EZDataUtil getInstance].centerButton.frame.origin.y;
    
}

//I will check if have the text field or not.
- (void) hideKeyboard:(EZEventBlock)complete
{
    
    [UIView animateWithDuration:0.4  animations:^(){
        self.view.y = 0;
    } completion:^(BOOL completed){
        if(complete){
            complete(nil);
        }
    }];
}


- (void) liftWithBottom:(CGFloat)deltaGap isSmall:(BOOL)small time:(CGFloat)timeval complete:(EZEventBlock)complete
{
    if(small){
        CGFloat viewY = self.view.frame.origin.y;
        CGFloat relativeDelta = deltaGap + viewY;
        EZDEBUG(@"small gap get called, old y:%f, gap:%f, relative delta:%f", _prevKeyboard, deltaGap, relativeDelta);
        if(relativeDelta > 0){
            relativeDelta = 0;
        }
        if(viewY < 0.0){
            [UIView animateWithDuration:0.3 animations:^(){
                [self.view setY:relativeDelta];
            } completion:^(BOOL completed){
                if(complete){
                    complete(nil);
                }
            }];
        }else if(deltaGap < 0.0){
            CGRect focusFrame = _currentFocused.frame;
            CGFloat leftGap = self.view.height - focusFrame.origin.y - focusFrame.size.height;
            CGFloat delta = leftGap - _prevKeyboard - abs(deltaGap);
            EZDEBUG(@"Will raise keyboard to:%f, prevKeyboard:%f", delta, _prevKeyboard);
            if(delta < 0){
                [UIView animateWithDuration:timeval delay:0.0 options:UIViewAnimationOptionCurveLinear  animations:^(){
                    [self.view setY:delta];
                } completion:^(BOOL completed){
                    if(complete){
                        complete(nil);
                    }
                }];
            }
            
        }
        
    }else{
        CGRect focusFrame = _currentFocused.frame;
        CGFloat leftGap = self.view.height - focusFrame.origin.y - focusFrame.size.height;
        EZDEBUG(@"The focused frame is:%@, leftGap:%f", NSStringFromCGRect(focusFrame), leftGap);
        CGFloat delta = leftGap - deltaGap;
        _prevKeyboard = deltaGap;
        if(delta < 0){
            //textFieldShouldReturn
            [UIView animateWithDuration:timeval delay:0.0 options:UIViewAnimationOptionCurveLinear  animations:^(){
                [self.view setY:delta];
            } completion:^(BOOL completed){
                if(complete){
                    complete(nil);
                }
            }];
        }
    }
}



@end
