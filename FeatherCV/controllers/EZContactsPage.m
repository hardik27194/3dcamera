//
//  EZContactsPage.m
//  Feather
//
//  Created by xietian on 13-10-15.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZContactsPage.h"
#import "EZUIUtility.h"
#import "EZClickView.h"
#import "EZContactCell.h"
#import "EZPerson.h"
#import "AFNetworking.h"
#import "EZDataUtil.h"
#import "EZExtender.h"

@interface EZContactsPage ()

@end

#define CELL_ID @"ContactCell"

@implementation EZContactsPage

- (EZContactsPage*) initPage
{
    UICollectionViewFlowLayout* grid = [[UICollectionViewFlowLayout alloc] init];
    grid.itemSize = CGSizeMake(320.0, 75.0);
    grid.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    grid.minimumInteritemSpacing = 0;
    grid.minimumLineSpacing = 0;
    //self.collectionView.backgroundColor = [UIColor whiteColor];
    return [self initWithCollectionViewLayout:grid];
}

- (void) loadedFriends:(NSArray*)array
{
    [_contacts addObjectsFromArray:array];
    [self.collectionView reloadData];
}


- (void) swipped:(UISwipeGestureRecognizer*) recog
{
    EZDEBUG(@"swipe direction:%i", recog.direction);
    if(recog.direction == UISwipeGestureRecognizerDirectionLeft){
        EZDEBUG(@"back");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout])
    {
        [self.collectionView registerClass:[EZContactCell class] forCellWithReuseIdentifier:CELL_ID];
    }
    self.title = @"朋友";
    _contacts =  [EZDataUtil getInstance].contacts; //[[NSMutableArray alloc] init];
    self.collectionView.alwaysBounceVertical = true;
    [self createHiddenButton];
    //UISwipeGestureRecognizer* swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipped:)];
    //swiper.direction = UISwipeGestureRecognizerDirectionLeft;
    //[self.collectionView addGestureRecognizer:swiper];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    __weak EZContactsPage* weakSelf = self;
    [[EZDataUtil getInstance] loadFriends:^(NSArray* friends){
        [weakSelf loadedFriends:friends];
    } failure:^(id error){
        EZDEBUG("Failed to contacts");
    }];
    
    return self;
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"selected %i",buttonIndex);
    if(buttonIndex == 0){
        [self takePhoto:YES];
    }else if(buttonIndex == 1){
        [self takePhoto:NO];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}

- (void) takePhoto:(bool)isAlbum
{
    [[EZUIUtility sharedEZUIUtility] raiseCamera:isAlbum controller:self.navigationController completed:^(UIImage* image){
        EZDEBUG(@"Get photo image");
    }];
}


- (void) createHiddenButton
{
    __weak UIViewController* weakSelf = self;
    _container = [[UIView alloc] initWithFrame:CGRectMake(0, -208, 320, 208)];
    _container.backgroundColor = [UIColor whiteColor];
    EZClickView* addFriend = [[EZClickView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
    //addFriend.backgroundColor = [UIColor greenColor];
    UIImageView* friendImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_friend"]];
    [friendImage setPosition:CGPointMake((160 - 38)/2, (160 - 38)/2)];
    [addFriend addSubview:friendImage];
    addFriend.releasedBlock = ^(id obj){
        EZDEBUG(@"Add friend get clicked");
        //EZAlbumCollectionPage* allPage = [EZAlbumCollectionPage createGridAlbumPage:YES];
        //[self.navigationController pushViewController:allPage animated:YES];
        EZContactsPage* contactPage = [[EZContactsPage alloc] initPage];
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:contactPage];
        [weakSelf presentViewController:nav animated:YES completion:nil];
    };
    UIView* splitter = [[UIView alloc] initWithFrame:CGRectMake(159, 20, 1, 120)];
    splitter.backgroundColor = RGBCOLOR(220, 220, 224);
    [addFriend addSubview:splitter];
    __weak UIView* cv = self.view;
    EZClickView* shootPhoto = [[EZClickView alloc] initWithFrame:CGRectMake(160, 0, 160, 160)];
    //shootPhoto.backgroundColor = [UIColor yellowColor];
    UIImageView* shootImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"take_photo"]];
    [shootImage setPosition:CGPointMake((160 - 38)/2, (160 - 38)/2)];
    [shootPhoto addSubview:shootImage];
    shootPhoto.releasedBlock = ^(id obj){
        //EZDEBUG(@"Shoot photo get clicked");
        UIActionSheet* ah = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"相册",@"拍照", nil];
        [ah showInView:cv];
    };
    
    [_container addSubview:addFriend];
    [_container addSubview:shootPhoto];
    UIView* sep = [[UIView alloc] initWithFrame:CGRectMake(0, 202, 320, 1)];
    sep.backgroundColor = RGBCOLOR(220, 220, 224);
    [_container addSubview:sep];
    _totalEntries = [[UILabel alloc] initWithFrame:CGRectMake(25, 160, 60, 18)];
    _totalEntries.font = [UIFont systemFontOfSize:17];
    _totalEntries.textColor = RGBCOLOR(127, 127, 127);
    _totalEntries.text = @"0";
    UILabel* entryTitle = [[UILabel alloc] initWithFrame:CGRectMake(25, 177, 80, 18)];
    entryTitle.font = [UIFont systemFontOfSize:17];
    entryTitle.textColor = RGBCOLOR(220, 220, 224);
    entryTitle.text = @"ENTRIES";
    [_container addSubview:_totalEntries];
    [_container addSubview:entryTitle];
    
    
    _monthCount = [[UILabel alloc] initWithFrame:CGRectMake(105, 160, 50, 18)];
    _monthCount.font = [UIFont systemFontOfSize:17];
    _monthCount.textColor = RGBCOLOR(127, 127, 127);
    _monthCount.text = @"0";
    entryTitle = [[UILabel alloc] initWithFrame:CGRectMake(105, 177, 80, 18)];
    entryTitle.font = [UIFont systemFontOfSize:16];
    entryTitle.textColor = RGBCOLOR(220, 220, 224);
    entryTitle.text = @"DAYS";
    [_container addSubview:_monthCount];
    [_container addSubview:entryTitle];
    
    _weekCount = [[UILabel alloc] initWithFrame:CGRectMake(170, 160, 50, 18)];
    _weekCount.font = [UIFont systemFontOfSize:17];
    _weekCount.textColor = RGBCOLOR(127, 127, 127);
    _weekCount.text = @"0";
    entryTitle = [[UILabel alloc] initWithFrame:CGRectMake(170, 177, 80, 18)];
    entryTitle.font = [UIFont systemFontOfSize:16];
    entryTitle.textColor = RGBCOLOR(220, 220, 224);
    entryTitle.text = @"WEEK";
    [_container addSubview:_weekCount];
    [_container addSubview:entryTitle];
    
    
    _dailyCount = [[UILabel alloc] initWithFrame:CGRectMake(235, 160, 50, 18)];
    _dailyCount.font = [UIFont systemFontOfSize:17];
    _dailyCount.textColor = RGBCOLOR(127, 127, 127);
    _dailyCount.text = @"0";
    entryTitle = [[UILabel alloc] initWithFrame:CGRectMake(235, 177, 80, 18)];
    entryTitle.font = [UIFont systemFontOfSize:16];
    entryTitle.textColor = RGBCOLOR(220, 220, 224);
    entryTitle.text = @"TODAY";
    [_container addSubview:_dailyCount];
    [_container addSubview:entryTitle];
    
    [self.collectionView addSubview:_container];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZContactCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    
    //static NSString *CellIdentifier = @"PhotoCell";
    EZPerson* cp = [_contacts objectAtIndex:indexPath.row];
    //__weak EZContactCell* weakCell = cell;
    cell.name.text = cp.name;
    if(cp.joined){
        cell.headIcon.hidden = false;
        cell.inviteButton.hidden = true;
        [cell.headIcon setImageWithURL:str2url(cp.avatar) placeholderImage:PlaceHolderSmall];
    }else{
        cell.headIcon.hidden = true;
        cell.inviteButton.hidden = false;
    }
    cell.inviteButton.releasedBlock = ^(id obj){
        EZDEBUG(@"Invite get clicked");
    };
    cell.headIcon.releasedBlock = ^(id obj){
        EZDEBUG(@"HeadIcon clicked, %i", indexPath.row);
    };
    EZDEBUG(@"Current name:%@", cp.name);
    
    return cell;
}


- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if(velocity.y < -1.5 && targetContentOffset->y == -64){
        //targetContentOffset->y = -224;
        //self.collectionView.contentInsect = [UI]
        [UIView animateWithDuration:0.2 animations:^(){
            self.collectionView.contentInset = UIEdgeInsetsMake(64+_container.frame.size.height, 0, 0, 0);
        }];
    }else{
        //targetContentOffset->y = -64;
        [UIView animateWithDuration:0.2 animations:^(){
            self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        }];
    }
    
    EZDEBUG(@"Velocity x: %f, y:%f, target offset: x:%f, y:%f, top size:%f", velocity.x, velocity.y, targetContentOffset->x, targetContentOffset->y, self.collectionView.contentInset.top);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _contacts.count;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}




@end
