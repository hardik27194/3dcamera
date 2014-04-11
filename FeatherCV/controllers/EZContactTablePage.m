//
//  EZContactTablePage.m
//  FeatherCV
//
//  Created by xietian on 13-12-12.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZContactTablePage.h"
#import "EZDataUtil.h"
#import "EZContactTableCell.h"
#import "EZClickView.h"
#import "EZClickImage.h"
#import "EZMessageCenter.h"
#import "EZUIUtility.h"
#import "EZCenterButton.h"
#import "UIImageView+AFNetworking.h"
#import "EZPersonDetail.h"
#import "EZDisplayPhoto.h"
@interface EZContactTablePage ()

@end

@implementation EZContactTablePage

- (void) loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.userInteractionEnabled = TRUE;
    self.view.autoresizesSubviews = YES;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, CurrentScreenWidth, CurrentScreenHeight - 64) style:UITableViewStylePlain];
    self.tableView.contentInset = UIEdgeInsetsMake(-44, 0, 0, 0);
    //self.tableView
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    //self.tableView.backgroundColor = RGBA(255, 255, 255, 128);
    self.tableView.backgroundColor = RGBA(0, 0, 0, 40);
    [self.view addSubview:self.tableView];
    _barBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, 64)];
    UILabel* friendTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CurrentScreenWidth, 30)];
    friendTitle.font = EZTitleFontCN;
    friendTitle.textAlignment = NSTextAlignmentCenter;
    friendTitle.textColor = [UIColor whiteColor];
    friendTitle.text = @"朋友";
    _barBackground.backgroundColor = RGBA(0, 0, 0, 60);
    [_barBackground addSubview:friendTitle];
    //_barBackground.hidden = YES;
    
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor clearColor];
        //self.title = @"朋友";
        [self.tableView registerClass:[EZContactTableCell class] forCellReuseIdentifier:@"Cell"];
        //_contacts = [[NSMutableArray alloc] init];
        //_contacts = [EZDataUtil getInstance].contacts;
    }
    return self;
}


- (void) viewDidAppear:(BOOL)animated
{
    EZDEBUG(@"View did appear");
    [super viewDidAppear:animated];
    //[self.view addSubview:_barBackground];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Pervent the camera from raising again
    [EZUIUtility sharedEZUIUtility].stopRotationRaise = true;
    [EZDataUtil getInstance].centerButton.hidden = YES;
    //[TopView addSubview:_barBackground];
    
    _barBackground.y = - _barBackground.frame.size.height;
    [TopView addSubview:_barBackground];
    [UIView animateWithDuration:0.3 animations:^(){
        _barBackground.y = 0;
    } completion:^(BOOL completed){
        [self.view addSubview:_barBackground];
    }];
    //[[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [EZUIUtility sharedEZUIUtility].stopRotationRaise = false;
    [TopView addSubview:_barBackground];
    [UIView animateWithDuration:0.3 animations:^(){
        _barBackground.y = - _barBackground.frame.size.height;
    } completion:^(BOOL completed){
        //[self.view addSubview:_barBackground];
        [_barBackground removeFromSuperview];
    }];
    //[EZDataUtil getInstance].centerButton.hidden = NO;
}

- (void) loadPersonInfos
{
    //Make sure this photo all appear the first
    [[EZDataUtil getInstance] getSortedPersons:^(NSArray* arr){
        //if(currentLoginUser){
        //    [_contacts addObject:currentLoginUser];
        //}
        if(arr){
            [_contacts insertObjects:arr];
            
            /**
            //Remvoe this code when we quit the debug mode
            EZPerson* tiange = [[EZPerson alloc] init];
            tiange.name = @"Tiange";
            tiange.personID = @"532585b321ae7a2e53522fa0";
            tiange.joined = TRUE;

            EZPerson* p123 = [[EZPerson alloc] init];
            p123.name = @"123";
            p123.personID = @"5325944f21ae7a427d586ae7";
            p123.joined = TRUE;

            if([currentLoginID isEqualToString:tiange.personID]){
                [_contacts insertObject:p123 atIndex:1];
            }else{
                [_contacts insertObject:tiange atIndex:1];
            }
            **/
            [self.tableView reloadData];
        }
    }];
    //[_contacts insertObject:currentLoginUser atIndex:0];
    
    //if(_contacts.count){
    //    [self.tableView reloadData];
    //}
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    _photoCountMap = [[NSMutableDictionary alloc] init];
   
    NSArray* allPhotos = [NSArray arrayWithArray:[EZDataUtil getInstance].mainPhotos];
    for(EZDisplayPhoto* ph in allPhotos){
        EZPhoto* matchedPh = [ph.photo.photoRelations objectAtIndex:0];
        EZPerson* ps = pid2person(matchedPh.personID);
        NSNumber* count = [_photoCountMap objectForKey:ps.personID];
        //if(count){
        //    count.integerValue += 1;
        //}
        [_photoCountMap setValue:@(count.integerValue + 1) forKey:ps.personID];
    }
    [_photoCountMap setValue:@(allPhotos.count) forKey:currentLoginID];
    
    _contacts = [[NSMutableArray alloc] init];
    NSArray* arrs = [[EZDataUtil getInstance] getStoredPersonLists];
    EZDEBUG(@"after person");
    [_contacts addObjectsFromArray:arrs];
    __weak EZContactTablePage* weakSelf = self;
    EZDEBUG(@"Stored person count:%i, arrs:%i", _contacts.count, arrs.count);
    if(![EZDataUtil getInstance].contacts.count){
        [[EZDataUtil getInstance] loadPhotoBooks];
        [[EZMessageCenter getInstance] registerEvent:EZContactsReaded block:^(NSArray* contacts) {
            EZDEBUG(@"loaded persons:%i", contacts.count);
            //[[EZDataUtil getInstance] checkAndUpload:contacts];
            [weakSelf.contacts addObjectsFromArray:contacts];
            [weakSelf.tableView reloadData];
        } once:YES];
    }else{
        [_contacts addObjectsFromArray:[EZDataUtil getInstance].contacts];
    }
    [self.tableView reloadData];
    //});
    
}

- (void)dealloc
{
    EZDEBUG(@"Contacts Dealloced");
}


- (void) reloadPersons
{
    __weak EZContactTablePage* weakSelf = self;
    [[EZDataUtil getInstance] getAllContacts:^(NSArray* persons){
        [weakSelf.contacts addObjectsFromArray:persons];
        EZDEBUG(@"Loaded person:%i, exist persons:%i", persons.count, weakSelf.contacts.count);
        [weakSelf.tableView reloadData];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _contacts.count;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    __weak EZContactTablePage* weakSelf = self;
    static NSString *CellIdentifier = @"Cell";
    EZContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    EZPerson* person = [_contacts objectAtIndex:indexPath.row];
    if(indexPath.row == 0){
        cell.name.text = @"所有照片";
        EZDEBUG(@"current user id:%@, this id:%@", currentLoginID, person.personID);
    }else{
        cell.name.text = person.name;
    }
    
    if(person.pendingEventCount > 0){
        //cell.notesNumber.alpha = 1.0;
        //cell.notesNumber.text = int2str(person.pendingEventCount);
        cell.photoCount.textColor = [UIColor redColor];
    }else{
        //cell.notesNumber.alpha = 0.0;
        cell.photoCount.textColor = [UIColor whiteColor];
    }
    
    NSNumber* photoCount = [_photoCountMap objectForKey:person.personID];
    if(photoCount){
        cell.photoCount.text = int2str(photoCount.integerValue);
    }else{
        cell.photoCount.text = nil;
    }
    //[(UIImageView*)cell.headIcon setImageWithURL:str2url(person.avatar)];
    cell.headIcon.backgroundColor = randBack(nil);
    cell.clickRegion.releasedBlock = ^(id object){
        EZDEBUG(@"region clicked");
        //[[EZMessageCenter getInstance]postEvent:EZScreenSlide attached:@(1)];
        EZPerson* person = [weakSelf.contacts objectAtIndex:indexPath.row];
        EZDEBUG(@"Person name:%@, %@", person.name, person.personID);
        if(person.joined){
            [weakSelf.navigationController popViewControllerAnimated:YES];
            [[EZMessageCenter getInstance] postEvent:EZSetAlbumUser attached:person];
        }
    };
    if(person.joined){
        cell.inviteButton.hidden = YES;
        cell.headIcon.hidden = NO;
    }else{
        cell.inviteButton.hidden = false;
        cell.inviteClicked = ^(id obj){
            //EZDEBUG(@"SEND SMS");
            [[EZUIUtility sharedEZUIUtility] sendMessge:person.mobile content:[NSString stringWithFormat: macroControlInfo(@"%@, this app is cool"), person.name] presenter:weakSelf completed:nil];
        };
        cell.headIcon.hidden = YES;
    }
    
    if(person.avatar){
        //[cell.headIcon setImageWithURL:str2url(person.avatar)];
        [cell.headIcon loadImageURL:person.avatar haveThumb:NO loading:NO];
    }else{
        cell.headIcon.image = nil;
    }
    cell.headIcon.releasedBlock = ^(id object){
        EZDEBUG(@"Header clicked");
        [weakSelf.navigationController popToRootViewControllerAnimated:NO];
        dispatch_later(0.1,^(){
            [[EZMessageCenter getInstance] postEvent:EZRaisePersonDetail attached:person];
        });
        //[self.navigationController pushViewController:pd animated:YES];
    };
    
    [cell fitLine];
    EZDEBUG(@"I will show the person:%@, pos:%i", person.name, indexPath.row);
    return cell;
}

//Change the height of the cell.
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
