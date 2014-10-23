//
//  EZCompleteSetting.m
//  3DCamera
//
//  Created by xietian on 14-10-11.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZCompleteSetting.h"
#import "EZInputItem.h"
#import "EZConfigure.h"
#import "EZDataUtil.h"
#import "EZPerson.h"

@implementation EZCompleteSetting

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.confirmBtn.hidden = YES;
    self.cancelBtn.hidden = YES;
    return self;
}

- (NSArray*) createItems
{
    __weak EZCompleteSetting* weakSelf = self;
    
    EZInputItem* taskName = [[EZInputItem alloc] initWithName:BIINFO(@"作品名称") type:kStringValue defaultValue:@""];
    taskName.isFocused = true;
    
    
    
    EZInputItem* authorName = [[EZInputItem alloc] initWithName:BIINFO(@"作者名称") type:kStringValue defaultValue:currentLoginUser.joined?currentLoginUser.name:@"匿名用户"];
    if(!currentLoginUser.joined){
        authorName.focusedBlock = ^(EZInputItem* item){
            [[EZDataUtil getInstance] triggerLogin:^(id person){
                item.textField.text = currentLoginUser.name;
                item.focusedBlock = ^(id obj){
                    EZDEBUG(@"do nothing");
                };
            } failure:^(id err){
                EZDEBUG(@"Login failed:%@", err);
            } reason:@"" isLogin:YES];
        };
    }
    
    
    EZInputItem* publized = [[EZInputItem alloc] initWithName:BIINFO(@"是否广场可见") type:kBoolValue defaultValue:@(![EZConfigure sharedEZConfigure].isPrivate)];
    
    
    
    EZInputItem* confirmBtn = [[EZInputItem alloc] initWithName:BIINFO(@"生成3D图片") type:kSingleButton defaultValue:nil];
    confirmBtn.btnTextColor = [UIColor whiteColor];
    confirmBtn.btnBackground = [EZColorScheme sharedEZColorScheme].confirmBtnColor;
    
    confirmBtn.btnClicked = ^(id obj){
        EZConfigure* configure = [EZConfigure sharedEZConfigure];
        configure.isPrivate = ![publized.changedValue boolValue];
        //configure.shotDelay = [[shotDelay getChangedValue] integerValue];
        
        //configure.shotCount = [[shotCount getChangedValue] integerValue];
        EZDEBUG(@"before save, taskName:%@,authorName:%@, public:%i ", taskName.changedValue, authorName.changedValue, configure.isPrivate);
        [configure saveToDefault];
        [weakSelf dismiss:YES];
        if(weakSelf.confirmed){
            weakSelf.confirmed(@[taskName.changedValue, authorName.changedValue]);
        }
        
    };
    return @[taskName, authorName, publized, confirmBtn];
}



@end
