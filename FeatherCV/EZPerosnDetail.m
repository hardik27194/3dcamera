//
//  EZ.m
//  FeatherCV
//
//  Created by xietian on 14-3-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

//#import
#import "EZPersonDetail.h"
#import "EZPerson.h"
#import "EZDataUtil.h"
#import "EZClickImage.h"
#import "EZExtender.h"
#import "EZCoreAccessor.h"
#import "EZMessageCenter.h"

@implementation EZPersonDetail

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"index:%i", buttonIndex);
    if(buttonIndex == 2){
        return;
    }
    
    __weak EZPersonDetail* weakSelf = self;
    [[EZUIUtility sharedEZUIUtility] raiseCamera:buttonIndex controller:self completed:^(UIImage* image){
        EZDEBUG(@"will upload image:%@", NSStringFromCGSize(image.size));
        [weakSelf updateImage:[image resizedImageWithMinimumSize:CGSizeMake(90, 90) antialias:YES]];
        
    } allowEditing:YES];
    
}

- (void) updateImage:(UIImage*)image
{
    [_uploadAvatar setImage:image];
    [[EZDataUtil getInstance] uploadAvatar:image success:^(NSString* url){
        EZDEBUG(@"avatar url:%@", url);
        _person.avatar = url;
        _avatarURL = url;
        [[EZMessageCenter getInstance] postEvent:EZUserEditted attached:_person];
    } failure:^(id err){
        [[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Upload avatar failed") info:@"Please try avatar upload later"];
    }];
}

- (id) initWithPerson:(EZPerson*)person
{
    self = [super initWithNibName:nil bundle:nil];
    _person  = person;
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _mobile.text = _person.mobile;
    _titleInfo.text = _person.name;
    //[[EZDataUtil getInstance] preloadImage:_person.avatar ]
    [_uploadAvatar loadImageURL:_person.avatar haveThumb:NO loading:NO];
    if([currentLoginID isEqualToString:_person.personID]){
        _quitUser.hidden = NO;
    }else{
        _quitUser.hidden = YES;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setupKeyboard];
    
    __weak EZPersonDetail* weakSelf = self;
    
    /**
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    imageView.image = [UIImage imageNamed:@"background.png"]; //createBlurImage:20];
    
    UIView* blackCover = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    blackCover.backgroundColor = RGBA(0, 0, 0, 50);
    [self.view addSubview:imageView];
    [self.view addSubview:blackCover];
    
     **/
    self.view.backgroundColor = [UIColor grayColor];
    //self.view.backgroundColor = VinesGray;
    CGFloat startGap = 0;
    if(!isRetina4){
        startGap = -20.0;
    }
    
    _uploadAvatar = [[EZClickImage alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 64.0)/2.0, 80.0 + startGap, 64.0, 64.0)];
    _uploadAvatar.layer.borderColor = [UIColor whiteColor].CGColor;
    _uploadAvatar.layer.borderWidth = 1.0;
    [_uploadAvatar enableRoundImage];
    _uploadAvatar.pressedBlock = ^(id obj){
        //[weakSelf uploadAvatar];
        EZDEBUG(@"currentLoginID:%@, personID:%@", currentLoginID, weakSelf.person.personID);
        if([currentLoginID isEqualToString:weakSelf.person.personID]){
            UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:macroControlInfo(@"Choose Avatar") delegate:weakSelf cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Album", nil];
            [action showInView:weakSelf.view];
        }
    };
    _uploadAvatar.touchStyle = kEZRandomColor;
    _uploadAvatar.enableTouchEffects = TRUE;

    
    _titleInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 169 + startGap, CurrentScreenWidth, 30)];
    _titleInfo.textAlignment = NSTextAlignmentCenter;
    _titleInfo.textColor = [UIColor whiteColor];
    _titleInfo.font = [UIFont systemFontOfSize:25];
    _titleInfo.text = @"昵称";
    [self.view addSubview:_titleInfo];
    
    _mobile = [[UILabel alloc] initWithFrame:CGRectMake(0, 215 + startGap, CurrentScreenWidth, 30)];
    _mobile.textAlignment = NSTextAlignmentCenter;
    _mobile.textColor = [UIColor whiteColor];
    _mobile.font = [UIFont systemFontOfSize:25];
    _mobile.text = @"手机";
    //[self.view addSubview:_mobile];

    _quitButton = [[EZClickImage alloc] initWithFrame:CGRectMake(CurrentScreenWidth - 60, 30, 44, 44)];
    _quitButton.layer.borderWidth = 1.0;
    _quitButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_quitButton enableRoundImage];
    //_quitButton.touchStyle = kEZWhiteBlur;
    _quitButton.enableTouchEffects = TRUE;
    
    _quitButton.releasedBlock = ^(id obj){
        EZDEBUG(@"Released quite");
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    
    _quitUser = [[UIButton alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 246.0)/2.0, 280 + startGap, 246.0, 40.0)];
    //[_registerButton enableRoundImage];
    _quitUser.layer.cornerRadius = _quitUser.height/2.0;
    _quitUser.backgroundColor =  ButtonWhiteColor;//EZButtonRed;
    [_quitUser setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_quitUser.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_quitUser setTitle:macroControlInfo(@"Quit Login") forState:UIControlStateNormal];
    //[_quitUser enableShadow:[UIColor blackColor]];
    [_quitUser.titleLabel enableShadow:[UIColor blackColor]];
    [_quitUser addTarget:self action:@selector(quitClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_quitUser];
    [self.view addSubview:_quitButton];
    [self.view addSubview:_uploadAvatar];
	// Do any additional setup after loading the view.
}


- (void) quitClicked:(id)obj
{
    [EZDataUtil getInstance].currentPersonID = nil;
    [EZDataUtil getInstance].currentLoginPerson = nil;
    [[EZDataUtil getInstance].pendingUploads removeAllObjects];
    [EZCoreAccessor cleanClientDB];
    [self dismissViewControllerAnimated:YES completion:^(){
        [[EZDataUtil getInstance] triggerLogin:^(EZPerson* ps){} failure:^(id err){} reason:@"请重新登录" isLogin:NO];
    }];
}

@end
