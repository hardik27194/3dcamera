//
//  EZRecordMain.m
//  BabyCare
//
//  Created by xietian on 14-7-27.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZRecordMain.h"
#import "EZRecorderCell.h"
#import "EZRecordTypeDesc.h"
#import "EZTrackRecord.h"
#import "UIButton+AFNetworking.h"
#import "EZDataUtil.h"
#import "EZCustomButton.h"
#import "UIImageView+AFNetworking.h"
#import "EZProfile.h"
#import "EZMessageCenter.h"
#import "EZGraphDetail.h"



#define CELL_ID @"cellID"
@interface EZRecordMain ()

@end



@implementation EZRecordMain

- (BOOL)calendar:(CKCalendarView *)calendar willSelectDate:(NSDate *)date
{
    if([date compareByDay:[NSDate date]] == NSOrderedDescending){
        return false;
    }
    return true;
}
- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date
{
    EZDEBUG(@"will show the right date:%@", date);
    _dateLabel.text = [[EZDataUtil getInstance].titleFormatter stringFromDate:date];
    [calendar dismiss:YES delay:0.3];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (EZRecordMain*) initPage:(NSArray*)arr records:(NSArray*)record mode:(EZOperationMode)mode
{
    UICollectionViewFlowLayout* grid = [[UICollectionViewFlowLayout alloc] init];
    grid.itemSize = CGSizeMake(106.0, 114.0);
    //grid.sectionInset = UIEdgeInsetsMake(1, 1, 0, 0);
    grid.minimumInteritemSpacing = 0;
    grid.minimumLineSpacing = 1;
    _descs = arr;
    _recorders = record;
       //self.collectionView.backgroundColor = [UIColor whiteColor];
    _mode = mode;
    _date = [NSDate date];
    //if(_mode == kAdjustSetting){
    for(EZRecordTypeDesc* rd in arr){
        rd.tmpSelected = rd.selected;
        if(rd.selected){
            _selectedCount ++;
        }
    }
    //}
    return [self initWithCollectionViewLayout:grid];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.collectionView.frame = CGRectMake(0, 110, self.view.bounds.size.width, self.view.bounds.size.height - 110);
    [self.view viewWithTag:1975].frame = CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight);
    
}

- (void) backClicked:(id)obj
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) starClicked:(id)obj
{
    EZDEBUG(@"star clicked");
    
    if(_mode == kInputMode){
        EZRecordMain* rm = [[EZRecordMain alloc] initPage:_descs records:_recorders  mode:kAdjustSetting];
        [self.navigationController pushViewController:rm animated:YES];
    }else{
        EZDEBUG(@"save get called");
        for (EZRecordTypeDesc* desc in _descs) {
            desc.selected = desc.tmpSelected;
            [[EZDataUtil getInstance] saveTypeSelectedStatus:desc.type selected:desc.selected];
        }
        [[EZMessageCenter getInstance] postEvent:EZUpdateSelection attached:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}

- (void) invokeCalendar:(id)obj
{
    EZDEBUG(@"calendar clicked");
    CKCalendarView* calender = [CKCalendarView createCalendar:CGRectMake(0, 20, CurrentScreenWidth, 320) delegate:self];
    [calender showInView:self.navigationController.view animated:YES];
}

- (void) viewDidLoad
{

    UIImageView* backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    backgroundView.image = [[UIImage imageNamed:@"headerbg"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 0, 0, 20)];
    backgroundView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:backgroundView];
    backgroundView.tag = 1975;
    
    UIView* navView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, CurrentScreenWidth, 90)];
    navView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:navView];
    
    
    EZCustomButton* backBtn = [EZCustomButton createButton:CGRectMake(0, 0, 44, 44) image:_mode==kAdjustSetting?[UIImage imageNamed:@"header_btn_back"]:[UIImage imageNamed:@"nav_drawer"]];
    //UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_drawer"]];
    //backBtn.showsTouchWhenHighlighted = true;
    //[backBtn addSubview:imageView];
    [navView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    //backBtn.clicked = ^(id obj){
    //    self.n
    //};
    if(_mode == kAdjustSetting){
        UIView* whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, CurrentScreenWidth, 45)];
        whiteView.backgroundColor = [UIColor whiteColor];
        [navView addSubview:whiteView];
        [self setupSetting:navView];
    }else{
        [self setupInput:navView];
    }
    
    UIImageView* headerIcon = [[UIImageView alloc] initWithFrame:CGRectMake((CurrentScreenWidth - 52)/2.0, 4, 52, 52)];
    headerIcon.contentMode = UIViewContentModeScaleAspectFill;
    headerIcon.layer.borderWidth = 2;
    headerIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    [headerIcon enableRoundImage];
    EZProfile* profile = [[EZDataUtil getInstance] getCurrentProfile];
    [headerIcon setImageWithURL:str2url(profile.avartar)];
    [navView addSubview:headerIcon];
    
    EZCustomButton* starBtn = [EZCustomButton createButton:CGRectMake(CurrentScreenWidth - 44, 0, 44, 44) image:_mode==kAdjustSetting?[UIImage imageNamed:@"header_btn_save"]:[UIImage imageNamed:@"header_btn_star"]];
    [navView addSubview:starBtn];
    [starBtn addTarget:self action:@selector(starClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZRecordTypeDesc* rd = [_descs objectAtIndex:indexPath.row];
    if(_mode == kAdjustSetting){
        //EZRecordTypeDesc* rd = [_descs objectAtIndex:indexPath.row];
        bool oldTmp = rd.tmpSelected;
        rd.tmpSelected = !rd.tmpSelected;
        EZDEBUG(@"select:%i, tmpSelected:%i", indexPath.row, rd.tmpSelected);
        if(rd.tmpSelected){
            _selectedCount ++;
            if(_selectedCount > 4){
                rd.tmpSelected = false;
                _selectedCount = 4;
            }else{
            }
        }else{
            _selectedCount --;
        }
        
        if(oldTmp != rd.tmpSelected){
            [_collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }else{
        EZGraphDetail* graphDetail = [[EZGraphDetail alloc] initWith:rd date:_date];
        [self.navigationController pushViewController:graphDetail animated:YES];
    }
}

- (void) setupSetting:(UIView*)navView
{
    UILabel* operationLabel = [UILabel createLabel:CGRectMake(20, 60, 280, 16) font:[UIFont boldSystemFontOfSize:14] color:RGBCOLOR(54, 193, 191)];
    operationLabel.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:operationLabel];
    operationLabel.text = @"最多选择4个做为首页快捷";
}

- (void) setupInput:(UIView*)navView
{
    
    EZCustomButton* calBtn = [EZCustomButton createButton:CGRectMake(CurrentScreenWidth - 44, 48, 44, 44) image:[UIImage imageNamed:@"header_btn_calendar"]];
    [navView addSubview:calBtn];
    [calBtn addTarget:self action:@selector(invokeCalendar:) forControlEvents:UIControlEventTouchUpInside];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 280, 24)];
    _dateLabel.textAlignment = NSTextAlignmentCenter;
    _dateLabel.textColor = [UIColor whiteColor];
    _dateLabel.font = [UIFont boldSystemFontOfSize:22];
    //_dateLabel.text =
    _dateLabel.text = [[EZDataUtil getInstance].titleFormatter stringFromDate:_date];
    [navView addSubview:_dateLabel];
}

-(id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    if (self = [super init])
    {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.collectionView registerClass:[EZRecorderCell class] forCellWithReuseIdentifier:CELL_ID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_collectionView];
    }
    
    
    //self.title = @"朋友";
    //_contacts =  [EZDataUtil getInstance].contacts; //[[NSMutableArray alloc] init];
    //self.collectionView.alwaysBounceVertical = true;
    //self.collectionView.bounces = false;
    //[self createHiddenButton];
    //UISwipeGestureRecognizer* swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipped:)];
    //swiper.direction = UISwipeGestureRecognizerDirectionLeft;
    //[self.collectionView addGestureRecognizer:swiper];
    //self.collectionView.backgroundColor = [UIColor whiteColor];
    __weak EZRecordMain* weakSelf = self;
    if(!_recorders.count){
        [[EZDataUtil getInstance] queryRecordByList:_descs success:^(NSArray* records){
            weakSelf.recorders = records;
            [weakSelf.collectionView reloadData];
            EZDEBUG(@"_descs:%i, records:%i", _descs.count, _recorders.count);
        } failure:^(id err){
            EZDEBUG(@"Error detail:%@", err);
        }];
    }
    if(_mode == kInputMode){
        [[EZMessageCenter getInstance] registerEvent:EZUpdateSelection block:^(id err){
            [_collectionView reloadData];
        }];
    }
    //Image can be stretched automatically
   
    //self.collectionView.backgroundView = backgroundView;
    return self;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZRecorderCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    EZDEBUG(@"load cell:%i", indexPath.row);
    //NSDate* curDate = _date;
    EZRecordTypeDesc* desc = [_descs objectAtIndex:indexPath.row];
    //if(desc.tmpSelected){
    cell.starImg.hidden = !desc.tmpSelected;
    //}
    if(_mode == kAdjustSetting){
        [cell enableTapView];
    }
    EZTrackRecord* record = [_recorders objectAtIndex:indexPath.row];
    [cell.name setTitle:desc.name forState:UIControlStateNormal];
    __weak EZRecordMain* weakSelf = self;
    cell.nameClicked = ^(id obj){
        EZGraphDetail* graphDetail = [[EZGraphDetail alloc] initWith:desc date:weakSelf.date];
        [weakSelf.navigationController pushViewController:graphDetail animated:YES];
    };
    [cell.iconButton setImageForState:UIControlStateNormal withURL:str2url(desc.blueIconURL)];
    NSMutableAttributedString* attrStr = nil;
    if(record.formattedStr){
        attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", record.formattedStr, null2Empty(desc.unitName)]];
        
    }else{
        //attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%f", record.measures]];
        attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%f %@", record.measures, null2Empty(desc.unitName)]];
    }
    
    int len = desc.unitName.length;
    
    EZDEBUG(@"before attr string %i, %i", attrStr.length, len);
    if(len > 0){
        [attrStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} range:NSMakeRange(0, attrStr.length - len)];
        [attrStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(attrStr.length - len, len)];
    }else{
        [attrStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]}  range:NSMakeRange(0, attrStr.length)];
    }
    EZDEBUG(@"after attr string");
    
    cell.measurement.attributedText = attrStr;
    return cell;
}




- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _recorders.count;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
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
