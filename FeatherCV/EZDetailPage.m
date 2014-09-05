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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareClicked:)];
    // Do any additional setup after loading the view.
}

- (void) shareClicked:(id)obj
{
    NSString* url = [NSString stringWithFormat:@"%@p3d/show3d?taskID=%@", baseServiceURL, _task.taskID];
    NSArray *activityItems = @[@"P3D", str2url(url)];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
    
    [activityVC setCompletionHandler:^(NSString *activityType, BOOL completed)
     {
         NSLog(@"Activity = %@",activityType);
         NSLog(@"Completed Status = %d",completed);
         
     }];

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
