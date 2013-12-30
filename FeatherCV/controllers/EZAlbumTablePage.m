//
//  EZAlbumTablePage.m
//  Feather
//
//  Created by xietian on 13-11-13.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#import "EZAlbumTablePage.h"
#import "EZPhotoCell.h"
#import "EZDisplayPhoto.h"
#import "EZThreadUtility.h"
#import "EZMessageCenter.h"
#import "EZFileUtil.h"
#import "EZClickView.h"


static int photoCount = 1;
@interface EZAlbumTablePage ()

@end

@implementation EZAlbumTablePage


-(id)initWithQueryBlock:(EZQueryBlock)queryBlock
{
    self = [super initWithStyle:UITableViewStylePlain];
    self.title = @"嘻嘻的圣诞节";
    _queryBlock = queryBlock;
    [self.tableView registerClass:[EZPhotoCell class] forCellReuseIdentifier:@"PhotoCell"];
    return self;
}


- (void) addPhoto:(EZDisplayPhoto*)photo
{
    [_combinedPhotos insertObject:photo atIndex:0];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]withRowAnimation:UITableViewRowAnimationFade];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _combinedPhotos = [[NSMutableArray alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    __weak EZAlbumTablePage* weakSelf = self;
    EZDEBUG(@"Query block is:%i",(int)_queryBlock);
    /**
    _queryBlock(0, 100, ^(NSArray* arr){
        EZDEBUG(@"Query completed:%i, I will reload", arr.count);
        weakSelf.combinedPhotos = [[NSMutableArray alloc] initWithArray:arr];
        [weakSelf.tableView reloadData];
    },^(NSError* err){
        EZDEBUG(@"Error detail:%@", err);
    });
    **/
    //The right thing to do here.
    //Maybe the whole thing already get triggered.
    //I can use simple thing to do this.s
    [[EZMessageCenter getInstance] registerEvent:EZTakePicture block:^(EZDisplayPhoto* dp){
        EZDEBUG(@"A photo get generated");
        [_combinedPhotos insertObject:dp atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    [[EZMessageCenter getInstance] registerEvent:EZAlbumImageReaded block:^(EZDisplayPhoto* dp){
        EZDEBUG(@"Recieved a image from album");
        [_combinedPhotos insertObject:dp atIndex:0];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    EZDisplayPhoto* cp = [_combinedPhotos objectAtIndex:indexPath.row];
    EZDEBUG(@"calculate the height, is front:%i", cp.isFront);
    CGFloat imageHeight;
    if(cp.turningAnimation){
        imageHeight = cp.turningImageHeight;
    }else{
    if(cp.isFront){
        imageHeight = floorf((cp.photo.size.height/cp.photo.size.width) * 320.0);
        EZDEBUG(@"The row height is:%f, width:%f, %f", imageHeight, cp.photo.size.width, cp.photo.size.height);
    }else{
        CGSize imgSize = [UIImage imageNamed:cp.randImage].size;
        imageHeight =  floorf((imgSize.height/imgSize.width) * 320.0);
        EZDEBUG(@"Column count is:%f, width:%f, %f", imageHeight, cp.photo.size.width, cp.photo.size.height);
    }
    }
    //EZDEBUG(@"image width:%f, height:%f, final height:%f", cp.myPhoto.size.width, cp.myPhoto.size.height, imageHeight);
    return imageHeight;
    //return 400;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _combinedPhotos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoCell";
    EZPhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    //[cell backToOriginSize];
    cell.isLarge = false;
    EZDisplayPhoto* cp = [_combinedPhotos objectAtIndex:indexPath.row];
    
    //This is for later update purpose. great, let's get whole thing up and run.
    cell.currentPos = indexPath.row;
    //EZCombinedPhoto* curPhoto = [cp.combinedPhotos objectAtIndex:cp.selectedCombinePhoto];
    EZPhoto* myPhoto = cp.photo;
    // Configure the cell...
    //[cell displayImage:[myPhoto getLocalImage]];
    if(cp.turningAnimation){
        EZDEBUG(@"Turning animation get called");
        [cell adjustCellSize:cp.oldTurnedImage.size];
        [cell displayImage:cp.oldTurnedImage];
        EZEventBlock animBlock = cp.turningAnimation;
        animBlock(cell);
        cp.turningAnimation = nil;
    }else{
    if(cp.isFront){
        [cell adjustCellSize:myPhoto.size];
        [cell displayImage:[myPhoto getThumbnail]];
        /**
        if(_isScrolling){
            [cell displayImage:[myPhoto getThumbnail]];
        }else{
            cell.isLarge = true;
            //[cell displayImage:[myPhoto getLocalImage]];
            //[cell displayEffectImage:[myPhoto getLocalImage]];
            [cell displayImage:[myPhoto getLocalImage]];
        }
         **/
    }else{//Display the back
        UIImage* img = [UIImage imageNamed:cp.randImage];
        [cell adjustCellSize:img.size];
        [cell displayImage:img];
    }
    }
    __weak EZPhotoCell* weakCell = cell;
    cell.container.releasedBlock = ^(id obj){
        cp.isFront = !cp.isFront;
        /**
        UIView* testAnimation = [[UIView alloc] initWithFrame:CGRectMake(50, 200, 200, 400)];
        [testAnimation makeImageShadow];
        [self.view addSubview:testAnimation];
        [UIView animateWithDuration:0.6 animations:^(){
            [testAnimation setSize:CGSizeMake(320, 500)];
        } completion:^(BOOL finished){
            [testAnimation removeFromSuperview];
        }];
         **/
        EZEventBlock complete = ^(id sender){
            EZDEBUG(@"Complete get called");
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        };
        if(cp.isFront){
            //[weakCell displayImage:[myPhoto getLocalImage]];
            [weakCell switchImage:[myPhoto getLocalImage] photo:cp complete:complete];
        }else{
            EZDEBUG(@"The container size:%f, %f", weakCell.container.frame.size.width, weakCell.container.frame.size.height);
            if(!cp.randImage){
            int imagePos = rand()%17;
                ++imagePos;
                NSString* randFile = [NSString stringWithFormat:@"santa_%i.jpg", imagePos];
                EZDEBUG(@"Random File name:%@", randFile);
                cp.randImage = randFile;
            }
            [weakCell switchImage:[UIImage imageNamed:cp.randImage] photo:cp complete:complete];
        }
    };
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    EZDEBUG(@"Begin dragging");
    _isScrolling = true;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    EZDEBUG(@"End dragging:%i", decelerate);
    if (!decelerate) {
        _isScrolling = false;
        [self replaceLargeImage];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    EZDEBUG(@"End Decelerating");
    _isScrolling = false;
    [self replaceLargeImage];
}

- (void) replaceLargeImage
{
    NSArray* cells = [self.tableView visibleCells];
    EZDEBUG(@"Scroll stopped:%i", cells.count);
    
    for(EZPhotoCell* pcell in cells){
        EZDisplayPhoto* cp = [_combinedPhotos objectAtIndex:pcell.currentPos];
        
        if(cp.isFront && !pcell.isLarge){
            pcell.isLarge = true;
            //[[EZThreadUtility getInstance] executeBlockInQueue:^(){
            //[pcell displayEffectImage:[cp.photo getLocalImage]];
            [pcell displayImage:[cp.photo getLocalImage]];
            //}];
        }
    }
    
}

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
