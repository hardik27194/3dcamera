//
//  EZMainPage.m
//  Feather
//
//  Created by xietian on 13-9-17.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZMainPage.h"
#import "EZMessageCenter.h"
#import "EZPhotoCell.h"
#import "EZPhoto.h"
#import "EZCombinedPhoto.h"
#import "EZPerson.h"
#import "EZFileUtil.h"
#import "EZConversation.h"
#import "EZClickView.h"


@interface EZMainPage ()

@end

@implementation EZMainPage

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}


- (void) zoomOut:(UIPinchGestureRecognizer*)obj
{
    EZDEBUG(@"scale:%f, velocity:%f", obj.scale, obj.velocity);
    //__weak EZMainPage* weakSelf = self;
    if(obj.scale < 0.9 && obj.velocity < -1.5){
        [[EZMessageCenter getInstance] postEvent:EZZoomoutAlbum attached:^(id obj){
            EZDEBUG(@"Zoom out completion called");
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //_combinedPhotos = [self getDummyPhotos];//@[@"One", @"two", @"Three"];
    self.view.backgroundColor = [UIColor yellowColor];
    EZDEBUG(@"Before register view");
    [self.tableView registerClass:[EZPhotoCell class] forCellReuseIdentifier:@"PhotoCell"];
    EZDEBUG(@"After register a cell");
    UIGestureRecognizer* zoomOut = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomOut:)];
    [self.view addGestureRecognizer:zoomOut];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 360;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _combinedPhotos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    EZCombinedPhoto* cp = [_combinedPhotos objectAtIndex:indexPath.row];
    EZPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    __weak EZPhotoCell* weakCell = cell;
    /**
    cell.imageClick.releasedBlock = ^(id sender){
        EZDEBUG(@"Image get clicked");
        if(cp.isFront){
            [weakCell switchImageTo:cp.otherPhoto.url];
        }else{
            [weakCell switchImageTo:cp.selfPhoto.url];
        }
        cp.isFront = !cp.isFront;
    };
    if(cp.isFront){
        [cell displayPhoto:cp.selfPhoto.url];
        cell.name.text = @"我自己";
    }else{
        [cell displayPhoto:cp.otherPhoto.url];
        cell.name.text = @"我的朋友";
    }
    cell.flippedCompleted = ^(id obj){
        if(cp.isFront){
            weakCell.name.text = @"我自己";
        }else{
            weakCell.name.text = @"我的朋友";
        }
    };
    
    **/
    return cell;
}


@end
