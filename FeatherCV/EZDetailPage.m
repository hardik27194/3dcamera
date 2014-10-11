//
//  EZDetailPage.m
//  3DCamera
//
//  Created by xietian on 14-8-19.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZDetailPage.h"
#import "EZShotTask.h"
#import "EZStoredPhoto.h"
#import "EZImageCache.h"
#import "EZDataUtil.h"
#import "EZMessageCenter.h"
#import "EZPhotoEditPage.h"

@interface EZDetailPage ()

@end

@implementation EZDetailPage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithTask:(EZShotTask *)task
{
    self = [super init];
    _task = task;
    return  self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    EZDEBUG(@"will layoutSubviews, parent bound:%@", NSStringFromCGRect(self.view.bounds));
    _webView.frame = self.view.bounds;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_webView];
    _webView.delegate = self;
    NSString* url = [NSString stringWithFormat:@"%@p3d/show3d?taskID=%@", baseServiceURL, _task.taskID];
    EZDEBUG(@"final url is:%@", url);
    [_webView loadRequest:[NSURLRequest requestWithURL:str2url(url)]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete:)]; //[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareClicked:)];
    
    UIToolbar* toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, CurrentScreenHeight - 44, CurrentScreenWidth, 44)];
    
    toolBar.tintColor = [EZColorScheme sharedEZColorScheme].toolBarTintColor;
    
    UIImage* editImg = [UIImage imageNamed:@"edit2"];
    EZDEBUG(@"Edit size:%@", NSStringFromCGSize(editImg.size));
    
    UIButton* editButton = [UIButton createButton:CGRectMake(0, 0, 44, 44) image:editImg imageRect:CGRectMake(9, 4, 25, 25) title:@"编辑" font:[UIFont boldSystemFontOfSize:10] color:[EZColorScheme sharedEZColorScheme].toolBarTintColor align:NSTextAlignmentCenter textFrame:CGRectMake(0, 31, 44, 11)];
    
    [editButton addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* editBtn = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    
    
    
    UIButton* shareButton = [UIButton createButton:CGRectMake(0, 0, 44, 44) image:[UIImage imageNamed:@"share2"] imageRect:CGRectMake(9, 4, 25, 25) title:@"分享" font:[UIFont boldSystemFontOfSize:10] color:[EZColorScheme sharedEZColorScheme].toolBarTintColor align:NSTextAlignmentCenter textFrame:CGRectMake(0, 31, 44, 11)];
    
    [shareButton addTarget:self action:@selector(shareClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* shareBtn = [[UIBarButtonItem alloc] initWithCustomView:shareButton];

    
    UIButton* deleteButton = [UIButton createButton:CGRectMake(0, 0, 44, 44) image:[UIImage imageNamed:@"trash"] imageInset:UIEdgeInsetsMake(3, 4, 3, 4) title:@"删除" font:[UIFont boldSystemFontOfSize:10] color:[EZColorScheme sharedEZColorScheme].toolBarTintColor align:NSTextAlignmentCenter textFrame:CGRectMake(0, 31, 44, 11)];
    
    [deleteButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _switchTitle = [UILabel createLabel:CGRectMake(10, CurrentScreenHeight - 100, 100, 44) font:[UIFont boldSystemFontOfSize:14] color:[EZColorScheme sharedEZColorScheme].toolBarTintColor];
    _switchTitle.text = @"是否广场可见:";
    
    _switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(120, CurrentScreenHeight - 100, 60, 44)];
    [_switchBtn addTarget:self action:@selector(switched:) forControlEvents:UIControlEventValueChanged];
    
    [self.view addSubview:_switchTitle];
    [self.view addSubview:_switchBtn];
    
    _switchBtn.on = !_task.isPrivate;
    ///UIButton* showPublic = [UIButton createButton:CGRectMake(0, 0, 44, 44) image:[UIImage imageNamed:@"trash"] imageInset:UIEdgeInsetsMake(3, 4, 3, 4) title:@"广场可见" font:[UIFont boldSystemFontOfSize:10] color:[EZColorScheme sharedEZColorScheme].toolBarTintColor align:NSTextAlignmentCenter textFrame:CGRectMake(0, 31, 44, 11)];
    
    //[deleteButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* deleteBtn = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
     
    UIBarButtonItem* sepBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
     
    UIBarButtonItem* sepBar2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    toolBar.items  = @[sepBar,editBtn, sepBar, shareBtn, sepBar];
    
    [self.view addSubview:toolBar];
    // Do any additional setup after loading the view.
}

- (void) switched:(UISwitch*)sw
{
    _task.isPrivate = !sw.on;
    EZDEBUG(@"switch is:%i", sw.on);
    [[EZDataUtil getInstance] updateTask:_task success:^(id obj){
        EZDEBUG(@"update Task private success:%@", obj);
        [[EZMessageCenter getInstance] postEvent:EZUpdatePhotoTask attached:_task];
    } failure:^(id err){
        EZDEBUG(@"Update task failed:%@",err);
    }];
    
}


- (void) deleteConfirmed:(id)sender
{
    EZDEBUG(@"delete confirm get called:%@", _task.taskID);
    if([_task.taskID isNotEmpty]){
        [[EZDataUtil getInstance] deletePhotoTask:_task.taskID success:^(id obj){
            [_task deleteLocal];
            [[EZMessageCenter getInstance] postEvent:@"EZDeletePhotoTask" attached:_task];
            [self.navigationController popViewControllerAnimated:YES];
        } failed:^(id err){
            EZDEBUG(@"failed to delete");
        }];
    }else{
        [_task deleteLocal];
        [[EZMessageCenter getInstance] postEvent:@"EZDeletePhotoTask" attached:_task];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"button index:%i", buttonIndex);
    //if(alertView == _deleteAlert){
    if(buttonIndex == 1){
        [self deleteConfirmed:nil];
    }
}
- (void) delete:(id)sender
{
    //url2fullpath()
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"确认删除" message:@"删除照片" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    
    [alertView show];
}


- (void) edit
{
    EZDEBUG(@"Edit get clicked");
    EZPhotoEditPage* editPage = [[EZPhotoEditPage alloc] initWithTask:_task pos:0];
    [self.navigationController pushViewController:editPage animated:YES];
    
}

- (void) shareClicked:(id)obj
{

    //NSArray *activityItems = @[@"P3D", str2url(url)];
    NSString* url = [NSString stringWithFormat:@"%@p3d/show3d?taskID=%@", baseServiceURL, _task.taskID];
    NSString *shareText = @"来看看我分享的三维图片吧";// [NSString stringWithFormat:@"来看看我分享了三维    UIImage* image = nil;
    UIImage* image = nil;
    if(_task.photos.count){
        EZStoredPhoto* sp = [_task.photos objectAtIndex:0];
        image = [[EZImageCache sharedEZImageCache] getImage:sp.remoteURL];
    }
    
    [[EZDataUtil getInstance]shareContent:shareText image:image url:url controller:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    EZDEBUG(@"start loading");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    EZDEBUG(@"finish loading");
}


/**
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
