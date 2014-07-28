//
//  EZMainPage.m
//  BabyCare
//
//  Created by xietian on 14-7-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZMainPage.h"
#import "EZProfileHeader.h"
#import "EZDetailHeader.h"
#import "EZScrollerView.h"
#import "EZMainCell.h"
#import "EZMenuItem.h"
#import "EZFileUtil.h"
#import "EZDataUtil.h"
#import "EZMainCell.h"
#import "EZProfile.h"
#import "EZRecordTypeDesc.h"
#import "UIImageView+AFNetworking.h"
#import "EZTrackRecord.h"
#import "EZRecordMain.h"
#import "EZMessageCenter.h"

@interface EZMainPage ()

@end

@implementation EZMainPage

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (void) viewDidLayoutSubviews
{
    [_tableView setFrame:CGRectMake(0, 273, CurrentScreenWidth, CurrentScreenHeight - 273)];
}

- (NSArray*) currentMenu
{
    return [[EZDataUtil getInstance] getCurrentMenuItems];
}

- (void) addClicked:(id)obj
{
    EZDEBUG(@"add clicked");
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView* background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight)];
    background.image = [UIImage imageNamed:@"drawer_bg"];
    background.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:background];
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [self.tableView registerClass:[EZMainCell class] forCellReuseIdentifier:@"topInfo"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(CurrentScreenWidth - 44, 10, 44, 44)];
    [button setImage:[UIImage imageNamed:@"header_btn_add"] forState:UIControlStateNormal];
    button.showsTouchWhenHighlighted = YES;
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    [button addTarget:self action:@selector(addClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self setupMockView];
    [self.view addSubview:button];
    [[EZDataUtil getInstance] fetchProfilesForID:currentLoginID success:^(NSArray* profiles){
        EZDEBUG(@"successfully load profiles");
        [self showProfiles:profiles];
    } failure:^(id err){
        EZDEBUG(@"failed to load profiles");
    }];
    
    
    [[EZMessageCenter getInstance] registerEvent:EZUpdateSelection block:^(id obj){
        [self showRecordList:[EZDataUtil getInstance].getCurrentProfile];
    }];
    //_infoCells = [[NSMutableArray alloc] init];

    
    //[_infoCells addObjectsFromArray:@[@"1",@"2",@"3"]];
    
    
    //[self.tableView addSubview:profile];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) showProfiles:(NSArray*)profiles
{
    for(UIView* view in _profileScroll.views){
        [view removeFromSuperview];
    }
    [_profileScroll.views removeAllObjects];
    if(!_profileScroll.views){
        _profileScroll.views = [[NSMutableArray alloc] init];
    }
    for(EZProfile* profile in profiles){
        EZProfileHeader* pheader = [EZProfileHeader createHeader];
        [pheader.avatar setImageWithURL:str2url(profile.avartar)];
        EZDEBUG(@"avatar url:%@", profile.avartar);
        pheader.name.text = profile.name;
        pheader.middleInfo.text = @"";
        pheader.bottomInfo.text = @"";
        [_profileScroll.views addObject:pheader];
        //profile.backgroundColor = [UIColor grayColor];
    }
    _profileScroll.views = _profileScroll.views;
    [self showRecordList:[profiles objectAtIndex:0]];
}

- (void) showRecordList:(EZProfile*)profile
{
    NSArray* recordList = [[EZDataUtil getInstance] getPreferredRecords:profile];
    for(UIView* view in _recorderScroll.views){
        [view removeFromSuperview];
    }
    [_recorderScroll.views removeAllObjects];
    if(!_recorderScroll.views){
        _recorderScroll.views = [[NSMutableArray alloc] init];
    }
    for(EZRecordTypeDesc* rd in recordList){
        EZDetailHeader* dheader = [EZDetailHeader createDetailHeader];
        //[dheader setPosition:CGPointMake(0, profile.bounds.size.height)];
        
        dheader.countInfo.text = @"";
        dheader.countUnit.text = rd.unitName;
        dheader.detailName.text = rd.name;
        EZDEBUG(@"will show icon url:%@", rd.iconURL);
        [dheader.icon setImageWithURL:str2url(rd.iconURL)];
        [[EZDataUtil getInstance]fetchCurrentRecord:rd.type profileID:profile.profileID success:^(EZTrackRecord* rc){
            EZDEBUG(@"successfully returned");
            if(rc.formattedStr){
                dheader.countInfo.text = rc.formattedStr;
            }else{
                dheader.countInfo.text = [NSString stringWithFormat:@"%f", rc.measures];
            }
            if(rc.graphURL){
                [dheader.graph setImageWithURL:str2url(rc.graphURL)];
            }
        } failure:^(id err){
            EZDEBUG(@"error:%@", err);
        }];
        [_recorderScroll.views addObject:dheader];
        //dheader.icon.image = [UIImage imageNamed:@"demo_avatar_jobs"];
    }
    
    //trigger the rearrangements.
    _recorderScroll.views = _recorderScroll.views;
}

- (void) switchProfile:(EZProfile*)profile
{
    [self showRecordList:profile];
    [_tableView reloadData];
}

- (void) setupMockView
{
    
    _profileScroll = [[EZScrollerView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, EZProfileCellHeight)];
    __weak EZMainPage* weakSelf = self;
    _profileScroll.scrolledTo = ^(NSDictionary* dict){
        EZDEBUG(@"scrollTo get called:%@", dict);
        NSInteger cur = [[dict objectForKey:@"curr"] intValue];
        [EZDataUtil getInstance].currentProfilePos = cur;
        EZProfile* curProfile = [[EZDataUtil getInstance].currentProfiles objectAtIndex:cur];
        [weakSelf switchProfile:curProfile];
    };
    
    _recorderScroll = [[EZScrollerView alloc] initWithFrame:CGRectMake(0, _profileScroll.bounds.size.height, CurrentScreenWidth, EZRecordDetailHeight)];
    [self.view addSubview:_profileScroll];
    [self.view addSubview:_recorderScroll];
    
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EZDEBUG(@"selectect:%i", indexPath.row);
    if(indexPath.row == 0){
        NSArray* currentOrder = [[EZDataUtil getInstance] getCurrentTotalRecordLists];
        EZRecordMain* rcMain = [[EZRecordMain alloc] initPage:currentOrder records:nil mode:kInputMode];
        [self.navigationController pushViewController:rcMain animated:YES];
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    //dispatch_later(0.1, ^(){
    //    EZDEBUG(@"ViewWill appear get called, topView is:%i", (int)TopView);
    //    [TopView addSubview:profile];
    //    [TopView addSubview:dheader];
    //});
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self currentMenu].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EZMainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"topInfo" forIndexPath:indexPath];
    EZMenuItem* item = [[self currentMenu] objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.title.text = item.menuName;
    //cell.icon.image = [UIImage imageNamed:item.iconURL];
    [cell.icon setImageWithURL:str2url(item.iconURL)];
    if(!item.notesCount){
        cell.notesCount.hidden = YES;
    }else{
        cell.notesCount.hidden = NO;
        cell.notesCount.text = int2str(item.notesCount);
    }
    cell.menuItem = item;
    //cell.textLabel.text = int2str(indexPath.row);
    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
