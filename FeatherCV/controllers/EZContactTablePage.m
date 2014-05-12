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
#import "EZEnlargedView.h"
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
    self.tableView.backgroundColor = [UIColor clearColor];//RGBA(0, 0, 0, 40);
    [self.view addSubview:self.tableView];
    _barBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, 64)];
    UILabel* friendTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, CurrentScreenWidth, 30)];
    friendTitle.font = EZTitleFontCN;
    friendTitle.textAlignment = NSTextAlignmentCenter;
    friendTitle.textColor = [UIColor whiteColor];
    friendTitle.text = macroControlInfo(@"朋友");
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
        _filteredMobile = [[NSMutableDictionary alloc] init];
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
            
            [self.tableView reloadData];
        }
    }];

}

- (NSArray*) getAllWaitRequests
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    
    NSArray* srcArr = [EZDataUtil getInstance].mainPhotos;
    if(!srcArr.count){
        srcArr = [[EZDataUtil getInstance] getStoredPhotos];
    }
    for(EZDisplayPhoto* dp in srcArr){
        EZPhoto* otherSide = dp.photo.photoRelations.count?[dp.photo.photoRelations objectAtIndex:0]:nil;
        if(dp.photo.type == kPhotoRequest){
            [res addObject:dp];
        }else if(otherSide.type  == kPhotoRequest){
            [res addObject:dp];
        }
    }
    return res;
}


- (void) loadPersons
{
    NSArray* allPhotos = [NSArray arrayWithArray:[EZDataUtil getInstance].mainPhotos];
    EZPerson* personNew = [[EZPerson alloc] init];
    personNew.name = macroControlInfo(@"新照片");
    personNew.filterType = kPhotoNewFilter;
    personNew.joined = YES;
    
    EZPerson* personBothLike = [[EZPerson alloc] init];
    personBothLike.name = macroControlInfo(@"都喜欢的照片");
    personBothLike.filterType = kPhotoAllLike;
    personBothLike.joined = YES;
    
    EZPerson* personOtherLike = [[EZPerson alloc] init];
    personOtherLike.name = macroControlInfo(@"对方喜欢");
    personOtherLike.filterType = kPhotoOtherLike;
    personOtherLike.joined = YES;
    
    EZPerson* personOwnLike = [[EZPerson alloc] init];
    personOwnLike.name =  macroControlInfo(@"我喜欢的照片");
    personOwnLike.filterType = kPhotoOwnLike;
    personOwnLike.joined = YES;
    
    /**
     EZPerson* personWait = [[EZPerson alloc] init];
     personWait.name = @"待拍摄";
     personWait.joined = YES;
     personWait.filterType = kPhotoWaitFilter;
     **/
    
    EZDEBUG(@"AllPhotos count:%i", allPhotos.count);
    for(EZDisplayPhoto* ph in allPhotos){
        if(ph.isFirstTime){
            personNew.photoCount += 1;
            personNew.pendingEventCount += 1;
        }
        
        BOOL bothAdded = false;
        BOOL otherAdded = false;
        BOOL ownAdded = false;
        for(EZPhoto* matchedPh in ph.photo.photoRelations){
            //EZPhoto* matchedPh = [ph.photo.photoRelations objectAtIndex:0];
            EZPerson* ps = pid2person(matchedPh.personID);
            if(ph.photo.typeUI == kPhotoRequest){
                personNew.photoCount += 1;
                personNew.pendingEventCount += 1;
            }
            if([ph.photo.likedUsers containsObject:matchedPh.personID] && [matchedPh.likedUsers containsObject:currentLoginID]){
                //if(ph.photo.re)
                if(!bothAdded){
                    bothAdded = true;
                    personBothLike.photoCount += 1;
                }
                
            }else if([ph.photo.likedUsers containsObject:matchedPh.personID]){
                if(!otherAdded){
                    otherAdded = true;
                    personOtherLike.photoCount += 1;
                }
            }else if([matchedPh.likedUsers containsObject:currentLoginID]){
                if(!ownAdded){
                    ownAdded = true;
                    personOwnLike.photoCount += 1;
                }
            }
            
            if(!ps.personID){
                continue;
            }
            
            NSNumber* count = [_photoCountMap objectForKey:ps.personID];
            //if(count){
            //    count.integerValue += 1;
            //}
            [_photoCountMap setValue:@(count.integerValue + 1) forKey:ps.personID];
        }
    }
    [_photoCountMap setValue:@(allPhotos.count) forKey:currentLoginID];
    
    _contacts = [[NSMutableArray alloc] init];
    NSArray* arrs = [[EZDataUtil getInstance] getStoredPersonLists];
    EZDEBUG(@"after person");
    for(EZPerson* ps in arrs){
        if(ps.mobile){
            [_filteredMobile setObject:@"" forKey:ps.mobile];
        }
    }
    [_contacts addObjectsFromArray:arrs];
    
    [_contacts insertObject:personNew atIndex:1];
    [_contacts insertObject:personBothLike atIndex:2];
    [_contacts insertObject:personOtherLike atIndex:3];
    [_contacts insertObject:personOwnLike atIndex:4];
    //[_contacts insertObject:personWait atIndex:2];
    __weak EZContactTablePage* weakSelf = self;
    EZDEBUG(@"Stored person count:%i, arrs:%i", _contacts.count, arrs.count);
    if(![EZDataUtil getInstance].contacts.count){
        [[EZDataUtil getInstance] loadPhotoBooks];
        [[EZMessageCenter getInstance] registerEvent:EZContactsReaded block:^(NSArray* contacts) {
            EZDEBUG(@"loaded persons:%i", contacts.count);
            //[[EZDataUtil getInstance] checkAndUpload:contacts];
            if(![[NSUserDefaults standardUserDefaults] boolForKey:@"EZUploadedMobile"]){
                [[EZDataUtil getInstance] uploadMobile:[EZDataUtil getInstance].mobileNumbers success:^(id obj){
                    EZDEBUG(@"upload mobile success");
                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"EZUploadedMobile"];
                }];
            }
            
            for(EZPerson* ps in contacts){
                if(!ps.mobile){
                    continue;
                }
                if(![_filteredMobile objectForKey:ps.mobile]){
                    [_filteredMobile setObject:@"" forKey:ps.mobile];
                    [weakSelf.contacts addObject:ps];
                }
            }
            
            //[weakSelf.contacts addObjectsFromArray:contacts];
            [weakSelf.tableView reloadData];
        } once:YES];
    }else{
        
        if(![[NSUserDefaults standardUserDefaults] boolForKey:@"EZUploadedMobile"]){
            [[EZDataUtil getInstance] uploadMobile:[EZDataUtil getInstance].mobileNumbers success:^(id obj){
                EZDEBUG(@"upload mobile success");
                [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"EZUploadedMobile"];
            }];
        }
        //[_contacts addObjectsFromArray:[EZDataUtil getInstance].contacts];
        for(EZPerson* ps in [EZDataUtil getInstance].contacts){
            if(!ps.mobile){
                continue;
            }
            if(![_filteredMobile objectForKey:ps.mobile]){
                [_filteredMobile setObject:@"" forKey:ps.mobile];
                [weakSelf.contacts addObject:ps];
            }
        }
        
    }
    //[EZDataUtil getInstance].updatedPersons =
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _photoCountMap = [[NSMutableDictionary alloc] init];
   
    //dispatch_later(0.1, ^(){
    [self loadPersons];
    //});
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
        cell.name.text = @"我的所有照片";
        EZDEBUG(@"current user id:%@, this id:%@", currentLoginID, person.personID);
    }else{
        cell.name.text = person.name;
    }
    
    //if(person.pendingEventCount > 0){
        //cell.notesNumber.alpha = 1.0;
        //cell.notesNumber.text = int2str(person.pendingEventCount);
    //    cell.photoCount.textColor = [UIColor redColor];
    //}else{
        //cell.notesNumber.alpha = 0.0;
    //    cell.photoCount.textColor = [UIColor whiteColor];
    //}
    
    NSNumber* photoCount = [_photoCountMap objectForKey:person.personID];
    if(photoCount){
        cell.photoCount.text = int2str(photoCount.integerValue);
    }else{
        cell.photoCount.text = nil;
    }
    
    if(person.filterType){
        cell.photoCount.text = int2str(person.photoCount);
    }
    
    //[(UIImageView*)cell.headIcon setImageWithURL:str2url(person.avatar)];
    [[cell.contentView viewWithTag:2014] removeFromSuperview];
    if(person.filterType){
        cell.headIcon.hidden = YES;
        cell.headIcon.userInteractionEnabled = false;
    }else{
        cell.headIcon.hidden = NO;
        cell.headIcon.userInteractionEnabled = true;
    }
    //cell.headIcon.backgroundColor = randBack(nil);
    
    cell.clickRegion.releasedBlock = ^(id object){
        //EZDEBUG(@"region clicked");
        //[[EZMessageCenter getInstance]postEvent:EZScreenSlide attached:@(1)];
        EZPerson* person = [weakSelf.contacts objectAtIndex:indexPath.row];
        //EZDEBUG(@"Person name:%@, %@", person.name, person.personID);
        if(person.joined){
            [weakSelf.navigationController popViewControllerAnimated:YES];
            [[EZMessageCenter getInstance] postEvent:EZSetAlbumUser attached:person];
        }else{
            [[EZUIUtility sharedEZUIUtility] sendMessge:person.mobile content:[NSString stringWithFormat: macroControlInfo(@"%@, this app is cool"), person.name] presenter:weakSelf completed:nil];
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
     cell.headIcon.image = nil;
    if(indexPath.row == 0){
        cell.headIcon.clickImage.image = [UIImage imageNamed:@"feather_icon"];
    }else if(person.avatar){
        //[cell.headIcon setImageWithURL:str2url(person.avatar)];
        [cell.headIcon.clickImage loadImageURL:person.avatar haveThumb:NO loading:NO];
    
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
    
    if(person.filterType){
        //cell.headIcon.hidden = YES;
        //cell.headIcon.userInteractionEnabled = false;
        if(person.filterType != kPhotoNewFilter){
            UIButton* btn = [[EZUIUtility sharedEZUIUtility] createHeartButton:person.filterType];
            btn.frame = cell.headIcon.frame;
            btn.tag = 2014;
            [cell.contentView addSubview:btn];
        }
    }
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
