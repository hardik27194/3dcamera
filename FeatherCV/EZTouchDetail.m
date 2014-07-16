//
//  EZTouchDetail.m
//  FeatherCV
//
//  Created by xietian on 14-7-13.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZTouchDetail.h"
#import "EZLineDrawingView.h"
#import "EZPerson.h"
#import "EZDataUtil.h"
#import "EZTouch.h"

@interface EZTouchDetail ()

@end

@implementation EZTouchDetail

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
    __weak EZTouchDetail* weakSelf = self;
    _rotateContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    [self.view addSubview:_rotateContainer];
    _drawView = [[EZLineDrawingView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    _imageDetail = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    _imageDetail.contentMode = UIViewContentModeScaleAspectFill;
    _icon = [[UIImageView alloc] initWithFrame:CGRectMake(CurrentScreenWidth - 57, 35, 45, 45)];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    [_icon enableRoundImage];
    [_rotateContainer addSubview:_imageDetail];
    [_rotateContainer addSubview:_drawView];
    _drawView.collectBlock = ^(NSArray* collectTouches){
        if(collectTouches.count < 2){
            return;
        }
        [weakSelf sendTouch:collectTouches];
    };
    [_rotateContainer addSubview:_icon];
    
    _touchName = [[UILabel alloc] initWithFrame:CGRectMake(22, 35, 200, 13)];
    _touchName.font = [UIFont boldSystemFontOfSize:12];
    _touchName.textColor = [UIColor whiteColor];
    _touchTime = [[UILabel alloc] initWithFrame:CGRectMake(22, 48, 200, 13)];
    _touchTime.font= [UIFont systemFontOfSize:12];
    _touchTime.textColor = [UIColor whiteColor];
    _touchTime.text = formatRelativeTime([NSDate date]);
    [_rotateContainer addSubview:_touchName];
    [_rotateContainer addSubview:_touchTime];
    
    _touchIndication = [[UILabel alloc] initWithFrame:CGRectMake(0, CurrentScreenHeight/2.0 - 23, CurrentScreenWidth, 23)];
    _touchIndication.textColor = RGBA(1.0, 1.0, 1.0, 0.4);
    _touchIndication.textAlignment = NSTextAlignmentCenter;
    _touchIndication.font = [UIFont boldSystemFontOfSize:23];
    [self.touchIndication addSubview:_touchIndication];
    
    _backButton = [[UIButton alloc] initWithFrame:CGRectMake(CurrentScreenWidth - 35 -25, CurrentScreenHeight - 35 - 25, 35, 35)];
    _backButton.backgroundColor = randBack(nil);
    _backButton.showsTouchWhenHighlighted = YES;
    [_backButton addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backButton];
    
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:tapRec];
    self.view.userInteractionEnabled = YES;
    
    // Do any additional setup after loading the view.
}

- (void) sendTouch:(NSArray*)arr
{
    [[EZDataUtil getInstance] sendTouches:_touchPerson touches:arr success:^(id info){
        EZDEBUG(@"success uploaded touch");
    } failed:^(id err){
        EZDEBUG(@"err detail:%@", err);
    }];
}

/**
- (void) switchToPerson:(EZPerson*)person
{
    //dispatch_later(0.15, ^(){
        
    
    //});
}
**/

//- (void) showTouchSign:

- (void) tapped:(id)sender
{
    EZDEBUG(@"tapped clicked");
    if(_touch){
        //[self switchToPerson:_touchPerson];
        
    }else{
        EZDEBUG(@"no touch");
    }
}

- (void) backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
