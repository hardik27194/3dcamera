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
    [_tableView setFrame:CGRectMake(0, 253, CurrentScreenWidth, CurrentScreenHeight - 253)];
}

- (NSArray*) currentMenu
{
    if([EZDataUtil getInstance].currentSelected == kMotherStatus){
        return _motherMenus;
    }else{
        return _childMenus;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    [self.tableView registerClass:[EZMainCell class] forCellReuseIdentifier:@"topInfo"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor grayColor];
    //_infoCells = [[NSMutableArray alloc] init];
    
    EZMenuItem* dailyRecord = [[EZMenuItem alloc] initWith:macroControlInfo(@"daily record") iconURL:@"record" action:^(id obj){
        
    }];
    dailyRecord.notesCount = 1;
    EZMenuItem* pregentJournal = [[EZMenuItem alloc] initWith:macroControlInfo(@"pregnant") iconURL:@"dairy" action:^(id obj){
        
    }];
    
    EZMenuItem* relativeCycle = [[EZMenuItem alloc] initWith:macroControlInfo(@"relative cycle") iconURL:@"cycles" action:^(id obj){
    
    }];
    
    EZMenuItem* discussion = [[EZMenuItem alloc] initWith:macroControlInfo(@"discussion") iconURL:@"discussion" action:^(id obj){
    
    }];
    
    EZMenuItem* notification = [[EZMenuItem alloc] initWith:macroControlInfo(@"notification") iconURL:@"notification" action:^(id obj){
    
    }];
    
    EZMenuItem* setting = [[EZMenuItem alloc] initWith:macroControlInfo(@"settings") iconURL:@"settings" action:^(id obj){
        
    }];
    
    
    EZMenuItem* babyJournal = [[EZMenuItem alloc] initWith:macroControlInfo(@"baby journal") iconURL:@"dairy" action:^(id obj){
        EZDEBUG(@"baby journal get called");
    }];
    
    _childMenus = @[dailyRecord, babyJournal, relativeCycle, discussion, notification, setting];
    _motherMenus = @[dailyRecord, pregentJournal, relativeCycle, discussion, notification, setting];
    //[_infoCells addObjectsFromArray:@[@"1",@"2",@"3"]];
    
    
    //[self.tableView addSubview:profile];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) setupMockView
{
    EZProfileHeader* profile = [EZProfileHeader createHeader];
    profile.avatar.image = [UIImage imageNamed:@"demo_avatar_cook"];
    profile.name.text = @"天哥";
    profile.middleInfo.text = @"还没怀上";
    profile.bottomInfo.text = @"顺产之王";
    profile.backgroundColor = [UIColor grayColor];
    
    EZProfileHeader* profile2 = [EZProfileHeader createHeader];
    profile2.avatar.image = [UIImage imageNamed:@"demo_avatar_jobs"];
    profile2.name.text = @"乔班主";
    profile2.middleInfo.text = @"2年9个月";
    profile2.bottomInfo.text = @"好养";
    profile2.backgroundColor = [UIColor grayColor];
    
    EZScrollerView* scrollerView = [[EZScrollerView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, profile2.bounds.size.height)];
    
    scrollerView.views = @[profile, profile2];
    scrollerView.scrolledTo = ^(NSDictionary* dict){
        EZDEBUG(@"scrollTo get called:%@", dict);
    };
    
    EZDetailHeader* dheader = [EZDetailHeader createDetailHeader];
    //[dheader setPosition:CGPointMake(0, profile.bounds.size.height)];
    dheader.countInfo.text = int2str(100);
    dheader.countUnit.text = @"公斤";
    dheader.detailName.text = @"体重";
    dheader.icon.image = [UIImage imageNamed:@"demo_avatar_jobs"];
    
    dheader.graph.image = [UIImage imageNamed:@"demo_avatar_woz"];
    dheader.backgroundColor = [UIColor grayColor];
    
    EZDetailHeader* dheader2 = [EZDetailHeader createDetailHeader];
    //[dheader2 setPosition:CGPointMake(0, 0)];
    dheader2.countInfo.text = int2str(100);
    dheader2.countUnit.text = @"公斤2";
    dheader2.detailName.text = @"体重2";
    dheader2.icon.image = [UIImage imageNamed:@"demo_avatar_jobs"];
    
    dheader2.graph.image = [UIImage imageNamed:@"demo_avatar_woz"];
    dheader2.backgroundColor = [UIColor grayColor];
    
    
    
    EZScrollerView* scrollerView2 = [[EZScrollerView alloc] initWithFrame:CGRectMake(0, scrollerView.bounds.size.height, CurrentScreenWidth, dheader.bounds.size.height)];
    scrollerView2.views = @[dheader, dheader2];
    
    [self.view addSubview:scrollerView];
    [self.view addSubview:scrollerView2];
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupMockView];
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
    cell.icon.image = [UIImage imageNamed:item.iconURL];
    if(!item.notesCount){
        cell.notesCount.hidden = YES;
    }else{
        cell.notesCount.hidden = NO;
        cell.notesCount.text = int2str(item.notesCount);
    }
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
