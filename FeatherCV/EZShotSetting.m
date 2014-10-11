//
//  EZShotSetting.m
//  3DCamera
//
//  Created by xietian on 14-10-10.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZShotSetting.h"
#import "EZInputItem.h"
#import "EZColorScheme.h"
#import "EZConfigure.h"

@implementation EZShotSetting

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    //_container = [[UIView alloc] initWithFrame:self.bounds];
    //_configureItems = items;
    _container = self;
    self.backgroundColor = RGBACOLOR(255, 255, 255, 220);
    self.layer.cornerRadius = 5;
    _configureItems = [self createItems];
    [self renderItems:_configureItems];
    return self;
}

- (NSArray*) createItems
{
    __weak EZShotSetting* weakSelf = self;
    NSArray* availableCounts = [EZConfigure sharedEZConfigure].availableCount;
    NSInteger settingCount = [EZConfigure sharedEZConfigure].shotCount;
    NSUInteger defaultPos = [availableCounts indexOfObject:int2str(settingCount)];
    if(defaultPos == NSNotFound){
        defaultPos = 0;
    }
    
    EZInputItem* shotCount = [[EZInputItem alloc] initWithName:BIINFO(@"拍摄张数") type:kNumberPicker values:availableCounts defaultPos:defaultPos];
    
    
    
    NSArray* availableDelays = [EZConfigure sharedEZConfigure].shotDelays;
    NSInteger settingDelay = [EZConfigure sharedEZConfigure].shotDelay;
    defaultPos = [availableDelays indexOfObject:int2str(settingDelay)];
    if(defaultPos == NSNotFound){
        defaultPos = 2;
    }
    EZInputItem* shotDelay = [[EZInputItem alloc] initWithName:BIINFO(@"拍摄延时（秒）") type:kNumberPicker values:availableDelays defaultPos:defaultPos];
    
    BOOL isMute = [EZConfigure sharedEZConfigure].isMute;
    
    EZInputItem* isMuteSound = [[EZInputItem alloc] initWithName:BIINFO(@"拍摄延时提示音") type:kBoolValue defaultValue:@(!isMute)];
    
    
    EZInputItem* confirmBtn = [[EZInputItem alloc] initWithName:BIINFO(@"开始拍摄") type:kSingleButton defaultValue:nil];
    confirmBtn.btnTextColor = [UIColor whiteColor];
    confirmBtn.btnBackground = [EZColorScheme sharedEZColorScheme].confirmBtnColor;
    
    confirmBtn.btnClicked = ^(id obj){
        EZConfigure* configure = [EZConfigure sharedEZConfigure];
        configure.isMute = ![isMuteSound.changedValue boolValue];
        configure.shotDelay = [[shotDelay getChangedValue] integerValue];
        
        configure.shotCount = [[shotCount getChangedValue] integerValue];
        EZDEBUG(@"before save, the value is:shotDelay:%f, shotCount:%i", configure.shotDelay, configure.shotCount);
        
        [configure saveToDefault];
        [weakSelf dismiss:YES];
        if(weakSelf.confirmed){
            weakSelf.confirmed(nil);
        }
        
    };
    return @[shotCount, shotDelay, isMuteSound, confirmBtn];
}

- (void) coverTapped:(UIView*)tapped
{
    [self dismiss:YES];
}

- (void) showInView:(UIView*)view aniamted:(BOOL)aniamted confirmed:(EZEventBlock)block
{
    self.alpha = 0.0;
    self.transform = CGAffineTransformMakeScale(0, 0);
    _coverView = [view createCoverView:2015 color:RGBACOLOR(0, 0, 0, 80) below:nil tappedTarget:self action:@selector(coverTapped:)];
    _coverView.alpha = 0.0;
    _confirmed = block;
    [view addSubview:self];
    [UIView animateWithDuration:0.5 animations:^(){
        _coverView.alpha = 1.0;
        self.alpha = 1.0;
        self.transform = CGAffineTransformIdentity;
    }];
}

- (void) dismiss:(BOOL)aniamted
{
    [UIView animateWithDuration:0.5 animations:^(){
        _coverView.alpha = 0.0;
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.0, 0.0);
    } completion:^(BOOL completed){
        [self removeFromSuperview];
    }];
}

- (void) renderItems:(NSArray*)items
{
    //[_container removeAllSubviews];
    [self removeAllSubviews];
    CGFloat currentPosY = 0;
    for(EZInputItem* item in items){
        UIView* view = [item renderToView:CGRectMake(0, 0, self.width, 50) titleFont:[UIFont boldSystemFontOfSize:14] titleColor:[EZColorScheme sharedEZColorScheme].systemTextColor inputFont:[UIFont boldSystemFontOfSize:15] inputColor:[UIColor blackColor]];
        [view setPosition:CGPointMake(0, currentPosY)];
        [_container addSubview:view];
        currentPosY += view.height;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
