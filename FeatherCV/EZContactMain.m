//
//  EZViewController.m
//  FeatherCV
//
//  Created by xietian on 14-6-25.
//  Copyright (c) 2014年 tiange. All rights reserved.
//

#import "EZContactMain.h"
#import "EZContactMainCell.h"
#import "EZPerson.h"
#import "EZLineDrawingView.h"
#import "EZProfileView.h"
#import "EZNote.h"
#import "EZMessageCenter.h"
#import "EZDataUtil.h"
#import "EZAddFriendCell.h"
#import "EZToolStripe.h"
#import "EZProfileView.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"


@interface EZContactMain ()

@end

@implementation EZContactMain


- (NSArray*) adjustTouchPosition:(NSArray*)touches
{
    NSMutableArray* res = [[NSMutableArray alloc] init];
    BOOL isFirst = true;
    CGFloat startY = 0;
    for(NSValue* touch in touches){
        CGPoint pt = [touch CGPointValue];
        if(isFirst){
            isFirst = false;
            startY = pt.y;
            pt.y = 20;
            [res addObject:[NSValue valueWithCGPoint:pt]];
        }else{
            pt.y = pt.y - startY + 20;
            [res addObject:[NSValue valueWithCGPoint:pt]];
        }
    }
    return res;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    EZDEBUG(@"preferredStatusBarStyle");
    return UIStatusBarStyleDefault;
}


- (void) viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:true animated:YES];
    if(_profileStatus != kFullProfile){
        [self.navigationController setNavigationBarHidden:true animated:YES];
    }else{
        [self.navigationController setNavigationBarHidden:false animated:YES];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (UITableViewCell*) createPersonCell:(UITableView*)tableView index:(NSIndexPath*)indexPath
{
    EZContactMainCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"contactCell"];
    
    EZPerson* person = [_persons objectAtIndex:indexPath.row];
    EZDEBUG(@"person name:%@", person.name);
    cell.name.text = person.name;
    //cell.contentView.backgroundColor = randBack(nil);
    [cell.photoView setImageWithURL:str2url(person.avatar)];
    __weak EZContactMain* weakContact = self;
    cell.paintTouchView.collectBlock = ^(NSArray* points){
        //EZDEBUG(@"The points:%@", points);
        if(points.count > 1){
            [weakContact movePersonTop:person animated:YES];
        }
    };
    return cell;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    EZDEBUG(@"index:%i", buttonIndex);
    if(buttonIndex == 2){
        return;
    }
    
    __weak  EZContactMain* weakSelf = self;
    [[EZUIUtility sharedEZUIUtility] raiseCamera:buttonIndex controller:self completed:^(UIImage* image){
        EZDEBUG(@"will upload image:%@", NSStringFromCGSize(image.size));
        image = [image resizedImageWithMinimumSize:image.size antialias:YES];
        //image = [image changeOriention:UIImageOrientationUp];
        [[EZDataUtil getInstance] uploadAvatarImage:image success:^(NSString* url){
            EZDEBUG(@"avatar url:%@", url);
            currentLoginUser.avatar = url;
            //_avatarURL = url;
            //_uploadingAvatar = false;
            //if(_registerBlock){
            //    _registerBlock(nil);
            //}
            [weakSelf.profileView.headIcon setImageWithURL:str2url(url)];
            
        } failed:^(id sender){
            //[[EZUIUtility sharedEZUIUtility] raiseInfoWindow:macroControlInfo(@"Upload avatar failed") info:@"Please try avatar upload later"];
            //_uploadingAvatar = false;
        }];

    } allowEditing:NO];
    
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row < _persons.count){
        return [self createPersonCell:tableView index:indexPath];
    }else{
        EZAddFriendCell* friendCell = [_tableView dequeueReusableCellWithIdentifier:@"addFriendCell"];
        friendCell.addClicked = ^(id sender){
            EZDEBUG(@"Add clicked");
        };
        return friendCell;
    }
    
    //return cell;
}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        EZDEBUG(@"Will delete indexPath %i", indexPath.row);
    }
}


- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    EZDEBUG(@"can edit indexPath:%i", indexPath.row);
    if(!tableView.isEditing){
        return false;
    }
    if(indexPath.row < _persons.count){
        return true;
    }else{
        return false;
    }
}




- (void) movePersonTop:(EZPerson*)person animated:(BOOL)animated
{
    int pos = [_persons indexOfObject:person];
    EZDEBUG(@"Will start to move object");
    if(pos == 0){
        return;
    }
    [_persons removeObject:person];
    [_persons insertObject:person atIndex:0];
    [_tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:pos inSection:0] toIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void) setPersons:(NSMutableArray *)persons
{
    _persons = persons;
    [_tableView reloadData];
    EZDEBUG(@"tableView pointer:%i", (int)_tableView);
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    EZDEBUG(@"person count:%i, type:%i", _persons.count, _displayType);
    if(_displayType == kOwnPageType){
        return _persons.count + 1;
    }else{
        return _persons.count;
    }
}

- (void) editClicked
{
    if(_tableView.isEditing){
        [_tableView setEditing:NO animated:YES];
        _profileView.isEditing = NO;
    }else{
        [_tableView setEditing:YES animated:YES];
        _profileView.isEditing = YES;
    }
}

- (void) imageClicked:(id) obj{
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:macroControlInfo(@"Choose Avatar") delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Album", nil];
    [action showInView:self.view];
}

- (void) setupProfile:(EZPerson*)person
{
    [_profileView.headIcon setImageWithURL:str2url(person.avatar)];
    _profileView.signature.text = @"昨夜西风凋碧树";//person.signature;
    _profileView.name.text = person.name;
    _profileView.touchCount.text = int2str(person.touchCount);
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    EZDEBUG(@"View did load get called");
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CurrentScreenWidth, CurrentScreenHeight) style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerClass:[EZContactMainCell class] forCellReuseIdentifier:@"contactCell"];
    [_tableView registerClass:[EZAddFriendCell class] forCellReuseIdentifier:@"addFriendCell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    _profileStatus = kFullProfile;
    _tableView.contentInset = UIEdgeInsetsMake(EZProfileImageHeight + EZToolStripeHeight + 64.0, 0, 0, 0);
    _profileView = [[EZProfileView alloc] init];
    [_profileView setPosition:CGPointMake(0, -_profileView.bounds.size.height)];
    [_tableView addSubview:_profileView];
    __weak EZContactMain* weakSelf = self;
    if(_displayType == kOwnPageType){
        self.title = @"羽毛";
        _profileView.toolStripe.clicked = ^(NSNumber* num){
            if(num.integerValue == 3){
                [weakSelf editClicked];
            }else
                if(num.integerValue == 1){
                /**
                [[EZDataUtil getInstance] triggerLogin:^(EZPerson* ps){
                    [[EZDataUtil getInstance] getMatchUsers:nil failure:nil];
                } failure:^(id err){} reason:@"请注册" isLogin:NO];
                 **/
            }
        };
        
        _profileView.headIcon.releasedBlock = ^(id obj){
            [weakSelf imageClicked:nil];
        };
       
        [[EZMessageCenter getInstance] registerEvent:EZUserAuthenticated block:^(id obj){
            weakSelf.person = currentLoginUser;
            [weakSelf setupProfile:currentLoginUser];
        }];
        
        [[EZDataUtil getInstance] getPersonByID:currentLoginID success:^(EZPerson* ps){
            weakSelf.person = ps;
            [weakSelf setupProfile:ps];
        }];
    }
    
    [weakSelf setupProfile:_person];
    
    [[EZMessageCenter getInstance] registerEvent:EZRecievedNotes block:^(EZNote* note){
        BOOL triggerByNotes = [[EZDataUtil getInstance].pushNotes objectForKey:note.noteID] != nil;
        NSString* trigger = [NSString stringWithFormat:@"%@,%i", note.type, triggerByNotes];
        [MobClick event:EZALRecievedNotes label:trigger];
        EZDEBUG(@"Recieved notes:%@, notes:%@, pointer:%i", note.type, note.noteID, (int)note);
        if([@"touched" isEqualToString:note.type]){
            EZDEBUG(@"Recieved touched");
        }else if([@"avatar" isEqualToString:note.type]){
            EZDEBUG(@"Avatar changed");
        }
        else
        if([@"match" isEqualToString:note.type]){
            //EZPhoto* matchedPhoto = note.matchedPhoto;
            //self.title = @"用户合照片";
            
            //[self insertMatch:note];
        }else if([@"like" isEqualToString:note.type]){
            //[self addLike:note];
        }else if([@"upload" isEqualToString:note.type]){
            //[self insertUpload:note];
        }else if([EZNoteJoined isEqualToString:note.type]){
            EZPerson* ps = note.person;
            //[EZDataUtil getInstance].currentQueryUsers
            EZDEBUG(@"adjust the activity for person:%@", ps.personID);
            //[[EZDataUtil getInstance] adjustActivity:ps.personID];
            //_leftMessageCount.hidden = NO;
            /**
            BOOL triggerByNote = [[EZDataUtil getInstance].pushNotes objectForKey:note.noteID] != nil;
            if(triggerByNote){
                EZPersonDetail* pd = [[EZPersonDetail alloc] initWithPerson:ps];
                _isPushCamera = false;
                _leftCyleButton.hidden = YES;
                _rightCycleButton.hidden = YES;
                [self.navigationController pushViewController:pd animated:YES];
            }
             **/
        }else if([@"textSend" isEqualToString:note.type]){
            EZDEBUG(@"received chat:%@", note.rawInfo);
            /**
            EZPhotoChat* pc = [[EZPhotoChat alloc] init];
            [pc fromJson:note.rawInfo];
            //BOOL triggerByNote = [[EZDataUtil getInstance].pushNotes objectForKey:note.noteID] != nil;
            [self handleChatNote:pc isPush:triggerByNotes];
             **/
        }else if([@"deleted" isEqualToString:note.type]){
            //[self processDeleteNote:note];
        }
        else if([EZNoteFriendAdd isEqualToString:note.type]){
            
        }else if([EZNoteFriendKick isEqualToString:note.type]){
            
        }
    }];

    
    // Do any additional setup after loading the view.
}



- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    CGFloat navHeight = 64.0;
    CGFloat offsetY = scrollView.contentOffset.y + _tableView.contentInset.top;
    EZDEBUG(@"end of scroll %f, profileStatus:%i, offsetY:%f", scrollView.contentOffset.y, _profileStatus, offsetY);
    //if(_profileStatus == kStripeShow){
    //}
    if(_profileStatus == kStripeShow && offsetY < -EZToolStripeHeight * 0.5){
        _profileStatus = kFullProfile;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [UIView animateWithDuration:0.3 animations:^(){
            [_tableView setContentInset:UIEdgeInsetsMake(EZProfileImageHeight + EZToolStripeHeight + navHeight, 0, 0, 0)];
        }];
        return;
    }
    
    
    if(offsetY >= 0){
            if(_profileStatus == kNormalPos){
                EZDEBUG(@"Do nothing");
            }else{
                if(offsetY > 5){
                    _profileStatus = kNormalPos;
                    [self.navigationController setNavigationBarHidden:YES animated:YES];
                    [UIView animateWithDuration:0.3 animations:^(){
                        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                    }];
                }
            }
        }else
       if(offsetY < -EZToolStripeHeight * 1.5){
           if(_profileStatus == kFullProfile){
               EZDEBUG(@"already full profile");
           }else{
               _profileStatus = kFullProfile;
               [self.navigationController setNavigationBarHidden:NO animated:YES];
               [UIView animateWithDuration:0.3 animations:^(){
                   [_tableView setContentInset:UIEdgeInsetsMake(EZProfileImageHeight + EZToolStripeHeight + navHeight, 0, 0, 0)];
               }];
           }
           
       }else if(offsetY > -EZToolStripeHeight * 1.5){
           if(_profileStatus == kStripeShow){
               EZDEBUG(@"already strip show");
           }else{
               _profileStatus = kStripeShow;
               [self.navigationController setNavigationBarHidden:YES animated:YES];
               [UIView animateWithDuration:0.3 animations:^(){
                   [_tableView setContentInset:UIEdgeInsetsMake(EZToolStripeHeight, 0, 0, 0)];
               }];
           }
       }
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
