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

@interface EZContactTablePage ()

@end

@implementation EZContactTablePage

- (void) loadView
{
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.userInteractionEnabled = TRUE;
    self.view.autoresizesSubviews = YES;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = RGBA(255, 255, 255, 128);
    [self.view addSubview:self.tableView];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = BlurBackground;
        self.title = @"朋友";
        [self.tableView registerClass:[EZContactTableCell class] forCellReuseIdentifier:@"Cell"];
        _contacts = [[NSMutableArray alloc] init];
        //_contacts = [[NSMutableArray alloc] init];
        //_contacts = [EZDataUtil getInstance].contacts;
    }
    return self;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Pervent the camera from raising again
    [EZUIUtility sharedEZUIUtility].stopRotationRaise = true;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [EZUIUtility sharedEZUIUtility].stopRotationRaise = false;
}

- (void) loadPersonInfos
{
    _contacts = (NSMutableArray*)[[EZDataUtil getInstance] getSortedPersons:^(NSArray* arr){
        if(currentLoginUser){
            [_contacts addObject:currentLoginUser];
        }
        if(arr){
            [_contacts addObjectsFromArray:arr];
            [self.tableView reloadData];
        }
    }];
    [_contacts insertObject:currentLoginUser atIndex:0];
    if(_contacts.count){
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self reloadPersons];
    [[EZMessageCenter getInstance] registerEvent:EZGetContacts block:^(NSArray* persons){
        EZDEBUG(@"Get person, count:%i", persons.count);
        //[_contacts addObjectsFromArray:persons];
        _contacts = [EZDataUtil getInstance].contacts;
        [self.tableView reloadData];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZUpdateContacts block:^(id sender){
        EZDEBUG(@"Will update the contacts table");
        _contacts = [EZDataUtil getInstance].contacts;
        [self.tableView reloadData];
    }];
    
    dispatch_later(0.3, ^(){
        [self loadPersonInfos];
    });
    
}



- (void) reloadPersons
{
    [[EZDataUtil getInstance] getAllContacts:^(NSArray* persons){
        [_contacts addObjectsFromArray:persons];
        EZDEBUG(@"Loaded person:%i, exist persons:%i", persons.count, _contacts.count);
        [self.tableView reloadData];
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
    cell.name.text = person.name;
    //[(UIImageView*)cell.headIcon setImageWithURL:str2url(person.avatar)];
    cell.headIcon.backgroundColor = randBack(nil);
    cell.clickRegion.releasedBlock = ^(id object){
        EZDEBUG(@"region clicked");
        //[[EZMessageCenter getInstance]postEvent:EZScreenSlide attached:@(1)];
        EZPerson* person = [_contacts objectAtIndex:indexPath.row];
        EZDEBUG(@"Person name:%@, %@", person.name, person.personID);
        //[self dismissViewControllerAnimated:YES completion:^(){
        
        //}];
        //if(person.joined){
            [weakSelf.navigationController popViewControllerAnimated:YES];
            //if(weakSelf.completedBlock){
            //    weakSelf.completedBlock(person);
            //}
            [[EZMessageCenter getInstance] postEvent:EZSetAlbumUser attached:person];
        //}
    };
    if(person.joined){
        cell.inviteButton.hidden = YES;
    }else{
        cell.inviteButton.hidden = false;
        cell.inviteClicked = ^(id obj){
            EZDEBUG(@"SEND SMS");
        };
    }
    
    cell.headIcon.releasedBlock = ^(id object){
        EZDEBUG(@"Header clicked");
    };
    
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
