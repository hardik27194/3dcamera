//
//  EZViewContainer.m
//  Feather
//
//  Created by xietian on 13-10-7.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZViewContainer.h"
#import "EZMessageCenter.h"

@interface EZViewContainer ()

@end

@implementation EZViewContainer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView
{
    EZDEBUG(@"loadView get called:%@",[NSThread callStackSymbols]);
    CGRect r = [[UIScreen mainScreen] bounds];
    //mean I will occupy the whole screen?
    self.view = [[UIView alloc] initWithFrame:r];
    self.contentView = [[UIView alloc] initWithFrame:r];
    self.contentView.opaque = TRUE;
    //self.contentView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_contentView];
    self.view.opaque = TRUE;
}

- (void) showView:(UIViewController*)ctrl
{
    //Dummy call to make sure the view get initialized.
    if(self.view != nil){
        [self addChildViewController:ctrl];
        [ctrl beginAppearanceTransition:YES animated:YES];
        [self.contentView addSubview:ctrl.view];
        [self hideView:_currentView];
        _currentView = ctrl;
    }
}

- (void) hideView:(UIViewController*)ctrl
{
    EZDEBUG(@"hide view get called");
    if(ctrl){
        EZDEBUG(@"actually hide??");
        [ctrl.view removeFromSuperview];
        [ctrl endAppearanceTransition];
        [ctrl removeFromParentViewController];
    }
}

//Currently I will call this before the view have switched in
- (void) completeShowEvent:(UIViewController*)ctrl animated:(BOOL)animated
{
    [self addChildViewController:ctrl];
    [ctrl beginAppearanceTransition:YES animated:animated];
}

//I will call after the view have disappeared.
- (void) completeHideEvent:(UIViewController*)ctrl animated:(BOOL)animated
{
    [ctrl endAppearanceTransition];
    [ctrl removeFromParentViewController];
}


//This will make sure the children under my management live a happy and fulfilling life.
- (void)viewWillAppear:(BOOL)animated
{
    //UIViewController* visiableCtrl = [_controllers objectAtIndex:_currentIndex];
    [_currentView beginAppearanceTransition:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    //UIViewController* visiableCtrl = [_controllers objectAtIndex:_currentIndex];
    [_currentView beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    //UIViewController* visiableCtrl = [_controllers objectAtIndex:_currentIndex];
    [_currentView endAppearanceTransition];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //UIViewController* visiableCtrl = [_controllers objectAtIndex:_currentIndex];
    [_currentView endAppearanceTransition];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    EZEventBlock zoomOutBlock = ^(id obj){
        [self completeShowEvent:_zoomOutView animated:NO];
        [UIView transitionFromView:_zoomInView.view toView:_zoomOutView.view duration:1 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];
        _currentView = _zoomOutView;
        [self completeHideEvent:_zoomInView animated:NO];
    };
    EZEventBlock zoomInBlock = ^(id obj){
        [self completeShowEvent:_zoomInView animated:NO];
        [UIView transitionFromView:_zoomOutView.view toView:_zoomInView.view duration:1 options:UIViewAnimationOptionTransitionCrossDissolve completion:nil];
        _currentView = _zoomInView;
        [self completeHideEvent:_zoomOutView animated:NO];
    };
    
    [[EZMessageCenter getInstance] registerEvent:EZZoomoutAlbum block:zoomOutBlock];
    [[EZMessageCenter getInstance] registerEvent:EZZoominAlbum block:zoomInBlock];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
