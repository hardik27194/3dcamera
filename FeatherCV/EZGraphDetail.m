//
//  EZGraphDetail.m
//  BabyCare
//
//  Created by xietian on 14-7-29.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZGraphDetail.h"
#import "EZCustomButton.h"
#import "EZDataUtil.h"
#import "EZProfile.h"
#import "UIImageView+AFNetworking.h"
#import "EZRecordTypeDesc.h"
#import "EZPopupView.h"
#import "EZPopupInput.h"
#import "EZInputItem.h"

@interface EZGraphDetail ()

@end

@implementation EZGraphDetail

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWith:(EZRecordTypeDesc*)desc date:(NSDate*)date
{
    self = [super init];
    _desc = desc;
    _checkDate = date;
    return self;
}

- (void) backClicked:(id)obj
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) addClicked:(id)obj
{
    //EZDEBUG(@"add clicked");
    //EZPopupView* popView = [[EZPopupView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    //[popView showInView:self.navigationController.view animated:YES];
    EZInputItem* item1 = [[EZInputItem alloc] initWithName:@"奶量超大" type:kFloatValue defaultValue:@(65)];
    EZInputItem* item2 = [[EZInputItem alloc] initWithName:@"疑似病例" type:kFloatValue defaultValue:@"有病没有"];
    
    EZInputItem* item3 = [[EZInputItem alloc] initWithName:@"出生日期" type:kDateValue defaultValue:[NSDate date]];
    
    NSArray* items = @[item1, item2, item3];
    EZPopupInput* popInput = [[EZPopupInput alloc] initWithTitle:@"奶妈" inputItems:items  haveDelete:YES saveBlock:^(id obj){
        //EZDEBUG(@"save called");
        for(EZInputItem* it in items){
            EZDEBUG(@"updated value:%@", it.changedValue);
        }
    }  deleteBlock:^(id obj){
        EZDEBUG(@"delete called");
    }];
    [popInput showInView:self.navigationController.view animated:YES];
}


- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _webView.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);
    _webView.backgroundColor = RGBCOLOR(218, 218, 218);
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    EZDEBUG(@"webView start load");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    EZDEBUG(@"webView complete loadad");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    EZDEBUG(@"webview error:%@", error);
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* fullURL = [[request URL] absoluteString];
    EZDEBUG(@"load request:%@", fullURL);
    if([fullURL hasPrefix:@"ios:"]) {
        [self performSelector:@selector(webToNativeCall)];
        return NO;
    }
    return YES;
}

- (void)webToNativeCall
{
    //Can eveluate the java script code, so that I could have no trouble to implement this.
    NSString *returnvalue =  [_webView stringByEvaluatingJavaScriptFromString:@"getText()"];
    EZDEBUG(@"returned value from Js is:%@", returnvalue);
    //self.valueFromBrowser.text = [NSString stringWithFormat:@"From browser : %@", returnvalue ];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView* backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    backgroundView.image = [[UIImage imageNamed:@"headerbg"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 0, 0, 20)];
    backgroundView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:backgroundView];
    backgroundView.tag = 1975;
    
    UIView* navView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, CurrentScreenWidth, 44)];
    navView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:navView];
    EZCustomButton* backBtn = [EZCustomButton createButton:CGRectMake(0, 0, 44, 44) image:[UIImage imageNamed:@"header_btn_back"]];
    //UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_drawer"]];
    //backBtn.showsTouchWhenHighlighted = true;
    //[backBtn addSubview:imageView];
    [navView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView* operationIcon = [[UIImageView alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 34)/2.0 + 35.0, 2, 34, 34)];
    [operationIcon setImageWithURL:str2url(_desc.headerIcon)];
    
    UIImageView* headerIcon = [[UIImageView alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 52)/2.0, 4, 52, 52)];
    headerIcon.contentMode = UIViewContentModeScaleAspectFill;
    headerIcon.layer.borderWidth = 2;
    headerIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    [headerIcon enableRoundImage];
    EZProfile* profile = [[EZDataUtil getInstance] getCurrentProfile];
    [headerIcon setImageWithURL:str2url(profile.avartar)];
    [navView addSubview:operationIcon];
    [navView addSubview:headerIcon];
    EZCustomButton* addBtn = [EZCustomButton createButton:CGRectMake(CurrentScreenWidth - 44, 0, 44, 44) image:[UIImage imageNamed:@"header_btn_add"]];
    [navView addSubview:addBtn];
    [addBtn addTarget:self action:@selector(addClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webView.delegate = self;
    [self.view insertSubview:_webView belowSubview:navView];
    NSString* url = [[EZDataUtil getInstance] createDetailURL:_desc date:_checkDate];
    EZDEBUG(@"detail url:%@", url);
    //[_webView loadHTMLString:@"" baseURL:str2url(url)];
    [_webView loadRequest:[NSURLRequest requestWithURL:str2url(url)]];
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
