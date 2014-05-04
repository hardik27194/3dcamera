//
//  EZDummyPage.m
//  Feather
//
//  Created by xietian on 13-11-6.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZDummyPage.h"
#import "EZClickView.h"

@interface EZDummyPage ()

@end

@implementation EZDummyPage

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
    
    __weak EZDummyPage* weakSelf = self;
    self.view.backgroundColor = [UIColor redColor];
    EZClickView* clickView = [[EZClickView alloc] initWithFrame:CGRectMake(100, 200, 100, 100)];
    clickView.backgroundColor = [UIColor whiteColor];
    clickView.releasedBlock = ^(id obj){
        EZDEBUG(@"release get clicked");
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self.view addSubview:clickView];
	// Do any additional setup after loading the view.
}

- (void) dealloc
{
    EZDEBUG(@"dealloc dummy page");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
