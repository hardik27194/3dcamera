//
//  EZEraserPage.m
//  3DCamera
//
//  Created by xietian on 14-9-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZEraserPage.h"
#import "EZBackgroundEraser.h"
#import "EZDataUtil.h"
#import "EZStoredPhoto.h"
#import "EZFileUtil.h"
#import "UIImageView+AFNetworking.h"
#import "EZImageUtil.h"
#import "EZMessageCenter.h"

@interface EZEraserPage ()

@end

@implementation EZEraserPage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id) initWithPhoto:(EZStoredPhoto*)photo orgImage:(UIImage*)img
{
    self = [super initWithNibName:nil bundle:nil];
    _orgImage = img;
    _photo = photo;
    //[[[UIImageView alloc] init] preloadImageURL:str2url(_photo.originalURL) success: failed:
    
    if([_photo.photoID isNotEmpty]){
        _orgImage = nil;
        [[EZImageUtil sharedEZImageUtil] preloadImageURL:str2url(_photo.originalURL) success:^(UIImage* img){
            _orgImage = img;
            _eraserView.orgImage = img;
            _eraserView.imageView.image = img;
            EZDEBUG(@"image loaded");
        } failed:^(id err){
            EZDEBUG(@"Error to loading image:%@", err);
        }];
    }
    
    
    _eraserView = [[EZBackgroundEraser alloc] initWithFrame:CGRectMake(0, 44, CurrentScreenWidth, CurrentScreenHeight - 44) image:_orgImage];
    [self.view addSubview:_eraserView];
    //_photo.frontRegion = CGRectMake(20, 20, 100, 100);
    if(_photo.frontRegion.size.width > 0){
        [_eraserView addFrontFrame:_photo.frontRegion];
    }

    EZDEBUG(@"Background eraser started");
    return self;
    
}

- (void) viewWillLayoutSubviews
{
    //_eraserView.frame = self.view.bounds;
}

- (void) cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) confirm
{
    [self.navigationController popViewControllerAnimated:YES];
    if(_eraserView.curImage){
         _photo.localFileURL =[NSString stringWithFormat:@"file://%@", [EZFileUtil saveImageToDocument:_eraserView.curImage]];
        if([_photo.photoID isNotEmpty]){
            [[EZDataUtil getInstance] uploadStoredPhoto:_photo isOriginal:NO success:^(id obj){
                EZDEBUG(@"upload success");
                if(_confirmed){
                    _confirmed(_photo);
                }
                [[EZMessageCenter getInstance] postEvent:EZPhotoUpdated attached:_photo.taskID];
            } failure:^(id error){
                EZDEBUG(@"Failed to upload");
            }];
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(confirm)];
    // Do any additional setup after loading the view.
   
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
