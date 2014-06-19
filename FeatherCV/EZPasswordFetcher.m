//
//  EZPasswordFetcher.m
//  FeatherCV
//
//  Created by xietian on 14-6-16.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZPasswordFetcher.h"

@interface EZPasswordFetcher ()

@end

@implementation EZPasswordFetcher

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
    // Do any additional setup after loading the view.
    EZDEBUG(@"start view did load");
    self.view.backgroundColor = VinesGray;
    CGFloat startGap = 0;
    if(!isRetina4){
        startGap = -40.0;
    }
    //__weak EZRegisterCtrl* weakSelf = self;
    _titleInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 65.0 + startGap, CurrentScreenWidth, 40)];
    _titleInfo.textAlignment = NSTextAlignmentCenter;
    _titleInfo.textColor = [UIColor whiteColor];
    _titleInfo.font = [UIFont systemFontOfSize:35];
    _titleInfo.text = macroControlInfo(@"羽毛");
    
    _introduction = [[UITextView alloc] initWithFrame:CGRectMake(30, 110.0 + startGap, CurrentScreenWidth - 30.0 * 2, 55)];
    _introduction.textAlignment = NSTextAlignmentCenter;
    _introduction.textColor = [UIColor whiteColor];
    //_introduction.font = [UIFont systemFontOfSize:8];
    _introduction.backgroundColor = [UIColor clearColor];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //paragraphStyle.lineHeightMultiple = 15.0f;
    paragraphStyle.maximumLineHeight = 15.0f;
    paragraphStyle.minimumLineHeight = 15.0f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSString *content =  EZSetPasswordInfo; //macroControlInfo(@"Feather is a flying organ. Imagination can free you from the physical limitation");
    NSDictionary *attribute = @{
                                NSParagraphStyleAttributeName : paragraphStyle,
                                NSForegroundColorAttributeName: [UIColor whiteColor],
                                NSFontAttributeName:[UIFont systemFontOfSize:12]
                                };
    
    //[_introduction enableTextWrap];
    _introduction.attributedText = [[NSAttributedString alloc] initWithString:content attributes:attribute];
    [self.view addSubview:_titleInfo];
    [self.view addSubview:_introduction];
    _introduction.editable = FALSE;
    
    _scrollContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    _scrollContainer.backgroundColor = [UIColor clearColor];
    _scrollContainer.pagingEnabled = YES;
    _scrollContainer.delegate = self;
    
    _scrollContainer.contentSize = CGSizeMake(CurrentScreenWidth* 2, CurrentScreenHeight);
    _scrollContainer.showsHorizontalScrollIndicator = NO;
    _scrollContainer.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollContainer];
    
    //[_scrollContainer addSubview:_smsCodeView];
    
    _smsCodeView = [self createSMSCodeView:startGap];
    [_scrollContainer addSubview:_smsCodeView];
    
    _passwordView = [self createPasswordView:startGap];
    [_scrollContainer addSubview:_passwordView];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CurrentScreenHeight - 30.0, CurrentScreenWidth, 10.0)];
    [self.view addSubview:_pageControl];
    _pageControl.numberOfPages = 2;
    _pageControl.currentPage = 0;

}

- (UIView*) createSMSCodeView:(CGFloat)startGap
{
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 180.0 + startGap, CurrentScreenWidth, CurrentScreenHeight - 175.0 - startGap)];
    containerView.backgroundColor = [UIColor greenColor];
    
    return containerView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int pos = scrollView.contentOffset.x/CurrentScreenWidth;
    EZDEBUG(@"Position %i", pos);
    _pageControl.currentPage = pos;
}

- (UIView*) createPasswordView:(CGFloat)startGap
{
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(CurrentScreenWidth, 180.0 + startGap, CurrentScreenWidth, CurrentScreenHeight - 175.0 - startGap)];
    containerView.backgroundColor = [UIColor yellowColor];
    return containerView;
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
