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

#define CELL_ID @"cellID"
@interface EZRecordMain ()

@end



@implementation EZRecordMain

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (EZRecordMain*) initPage:(NSArray*)arr
{
    UICollectionViewFlowLayout* grid = [[UICollectionViewFlowLayout alloc] init];
    grid.itemSize = CGSizeMake(116.0, 114.0);
    //grid.sectionInset = UIEdgeInsetsMake(1, 1, 0, 0);
    grid.minimumInteritemSpacing = 1;
    grid.minimumLineSpacing = 1;
    _recorders = arr;
    //self.collectionView.backgroundColor = [UIColor whiteColor];
    return [self initWithCollectionViewLayout:grid];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    //self.collectionView.
    
}

-(id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout])
    {
        [self.collectionView registerClass:[EZRecorderCell class] forCellWithReuseIdentifier:CELL_ID];
    }
    //self.title = @"朋友";
    //_contacts =  [EZDataUtil getInstance].contacts; //[[NSMutableArray alloc] init];
    //self.collectionView.alwaysBounceVertical = true;
    self.collectionView.bounces = false;
    //[self createHiddenButton];
    //UISwipeGestureRecognizer* swiper = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipped:)];
    //swiper.direction = UISwipeGestureRecognizerDirectionLeft;
    //[self.collectionView addGestureRecognizer:swiper];
    //self.collectionView.backgroundColor = [UIColor whiteColor];
    UIImageView* backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    backgroundView.image = [[UIImage imageNamed:@"headerbg"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 0, 0, 20)];
    backgroundView.contentMode = UIViewContentModeScaleToFill;
    self.collectionView.backgroundView = backgroundView;
    return self;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EZRecorderCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    EZRecordTypeDesc* desc = [_recorders objectAtIndex:indexPath.row];
    cell.name.text = desc.name;
    [cell.iconButton setImageForState:UIControlStateNormal withURL:str2url(desc.iconURL)];
    NSMutableAttributedString* attrStr = [[NSMutableAttributedString alloc] initWithString:@"coolguy"];
    
    [attrStr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} range:NSMakeRange(0, 4)];
    [attrStr addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} range:NSMakeRange(5, 6)];
    
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
