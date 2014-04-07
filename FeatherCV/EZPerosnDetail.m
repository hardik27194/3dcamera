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
    self.title = person.name;
    return self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    if(![_person.personID isEqualToString:currentLoginID]){
        [[EZMessageCenter getInstance] postEvent:EZRecoverShotButton attached:nil];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _mobile.text = _person.mobile;
    _titleInfo.text = _person.name;
    /**
    if(![_person.personID isEqualToString:currentLoginID]){
        [[EZMessageCenter getInstance] postEvent:EZShowShotButton attached:^(id obj){
            [[EZMessageCenter getInstance] postEvent:EZTriggerCamera attached:_person.personID];
        }];
    }
     **/
    //[[EZDataUtil getInstance] preloadImage:_person.avatar ]
    [_uploadAvatar loadImageURL:_person.avatar haveThumb:NO loading:NO];
    
    EZDEBUG(@"currentID:%@, person:%@", currentLoginID, _person.personID);
    if([currentLoginID isEqualToString:_person.personID]){
        //_quitUser.hidden = NO;
        //_quitButton.hidden = YES;
        [_quitUser setTitle:@"退出登录" forState:UIControlStateNormal];
    }else{
        //_quitUser.hidden = YES;
        //_quitButton.hidden = NO;
        [_quitUser setTitle:[NSString stringWithFormat:@"%i对照片", _person.photoCount] forState:UIControlStateNormal];
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
    self.navigationItem.titleView = [[UIView alloc] init];
    
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

    /**
    _quitButton = [[EZUIUtility sharedEZUIUtility] createShotButton];
    
    _quitButton.releasedBlock = ^(id obj){
        EZDEBUG(@"Trigger camera");
        //[weakSelf dismissViewControllerAnimated:YES completion:nil];
        [[EZMessageCenter getInstance] postEvent:EZTriggerCamera attached:weakSelf.person.personID];
    };
    **/
    
    
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
    //[self.view addSubview:_quitButton];
    [self.view addSubview:_uploadAvatar];
	// Do any additional setup after loading the view.
}


- (void) quitClicked:(id)obj
{
    if([_person.personID isEqualToString:currentLoginID]){
    
    
        
    NSArray* photos = [[EZDataUtil getInstance] getStoredPhotos];
    EZDEBUG(@"Photos after cleaned:%i", photos.count);
    //[[EZDataUtil getInstance] cleanDBPhotos];
    [[EZDataUtil getInstance] cleanAllLoginInfo];
    [self.navigationController popViewControllerAnimated:NO];
    [[EZDataUtil getInstance] triggerLogin:^(EZPerson* ps){
        [[EZDataUtil getInstance] getMatchUsers:^(NSArray* arr){
            EZDEBUG(@"all matched users:%i", arr.count);
            for(EZPerson* ps in arr){
                [[EZDataUtil getInstance].sortedUsers addObject:ps.personID];
            }
        } failure:^(id obj){
            EZDEBUG(@"The error detail:%@", obj);
        }];
    
    } failure:^(id err){} reason:@"请重新登录" isLogin:YES];
    }else{
        [[EZMessageCenter getInstance] postEvent:EZSetAlbumUser attached:_person];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
