//
//  RACollectionViewTripletLayout.m
//  RACollectionViewTripletLayout-Demo
//
//  Created by Ryo Aoyama on 5/25/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

#import "RACollectionViewTripletLayout.h"

@interface RACollectionViewTripletLayout()

@property (nonatomic, assign) NSInteger numberOfCells;
@property (nonatomic, assign) CGFloat numberOfLines;
@property (nonatomic, assign) CGFloat itemSpacing;
@property (nonatomic, assign) CGFloat lineSpacing;
@property (nonatomic, assign) CGFloat sectionSpacing;
@property (nonatomic, assign) CGSize collectionViewSize;
@property (nonatomic, assign) UIEdgeInsets insets;
@property (nonatomic, assign) CGRect oldRect;
@property (nonatomic, strong) NSArray *oldArray;
//@property (nonatomic, strong) NSMutableArray *largeCellSizeArray;
//@property (nonatomic, strong) NSMutableArray *smallCellSizeArray;

@end

@implementation RACollectionViewTripletLayout

#pragma mark - Over ride flow layout methods

- (void)prepareLayout
{
    [super prepareLayout];

    //delegate
    self.delegate = (id<RACollectionViewDelegateTripletLayout>)self.collectionView.delegate;
    //collection view size
    _collectionViewSize = self.collectionView.bounds.size;
    //some values
    _itemSpacing = 0;
    _lineSpacing = 0;
    _sectionSpacing = 0;
    _insets = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingForCollectionView:)]) {
        _itemSpacing = [self.delegate minimumInteritemSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(minimumLineSpacingForCollectionView:)]) {
        _lineSpacing = [self.delegate minimumLineSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(sectionSpacingForCollectionView:)]) {
        _sectionSpacing = [self.delegate sectionSpacingForCollectionView:self.collectionView];
    }
    if ([self.delegate respondsToSelector:@selector(insetsForCollectionView:)]) {
        _insets = [self.delegate insetsForCollectionView:self.collectionView];
    }
    CGFloat cellSize = [self calCellSize];
    _smallCellSize = CGSizeMake(cellSize, cellSize);
}

- (CGFloat)contentHeight
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    if ([self.delegate respondsToSelector:@selector(insetsForCollectionView:)]) {
        insets = [self.delegate insetsForCollectionView:self.collectionView];
    }
    CGFloat sectionSpacing = 0;
    if ([self.delegate respondsToSelector:@selector(sectionSpacingForCollectionView:)]) {
        sectionSpacing = [self.delegate sectionSpacingForCollectionView:self.collectionView];
    }
    CGFloat itemSpacing = 0;
    if ([self.delegate respondsToSelector:@selector(minimumInteritemSpacingForCollectionView:)]) {
        itemSpacing = [self.delegate minimumInteritemSpacingForCollectionView:self.collectionView];
    }
    CGFloat lineSpacing = 0;
    if ([self.delegate respondsToSelector:@selector(minimumLineSpacingForCollectionView:)]) {
       lineSpacing = [self.delegate minimumLineSpacingForCollectionView:self.collectionView];
    }
    EZDEBUG(@"contentHeight get called");
    return [self collectionViewContentSize].height;
}

- (id<RACollectionViewDelegateTripletLayout>)delegate
{
    return (id<RACollectionViewDelegateTripletLayout>)self.collectionView.delegate;
}

- (CGSize)collectionViewContentSize
{
    
    CGSize contentSize = CGSizeMake(_collectionViewSize.width, 0);
    NSInteger totalItems = [self.collectionView numberOfItemsInSection:0];
    NSInteger rows = totalItems / 3;
    NSInteger remain = totalItems % 3?rows + 1:rows;
    NSInteger lineNum = remain - 1 > 0?remain - 1:0;
    contentSize.height =  remain * [self calCellSize] + lineNum * _lineSpacing + _insets.top + _insets.bottom;
    NSLog(@"the content size is:%@, total items:%i", NSStringFromCGSize(contentSize), totalItems);
    return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    BOOL shouldUpdate = [self shouldUpdateAttributesArray];
    if (CGRectEqualToRect(_oldRect, rect) && !shouldUpdate) {
        return _oldArray;
    }
    _oldRect = rect;
    NSMutableArray *attributesArray = [NSMutableArray array];
    for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
        NSInteger numberOfCellsInSection = [self.collectionView numberOfItemsInSection:i];
        for (NSInteger j = 0; j < numberOfCellsInSection; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            if (CGRectIntersectsRect(rect, attributes.frame)) {
                [attributesArray addObject:attributes];
            }
        }
    }
    _oldArray = attributesArray;
    return  attributesArray;
}

//needs override
- (BOOL)shouldUpdateAttributesArray
{
    return NO;
}

- (CGFloat) calCellSize
{
    return (_collectionViewSize.width - _insets.left - _insets.right - 2 * _itemSpacing)/3.f;
}



- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];

    //cellSize
    CGFloat largeCellLength = [self calCellSize];
       CGFloat sectionHeight = 0;
    NSInteger line = indexPath.item / 3; //+ (indexPath.item % 3?1:0);
    //line = (line - 1) > 0?line - 1:0;
    CGFloat lineSpaceForIndexPath = _lineSpacing * line;
    CGFloat lineOriginY = largeCellLength * line + sectionHeight + lineSpaceForIndexPath + _insets.top;
    NSInteger col = indexPath.item % 3;
    attribute.frame = CGRectMake(_insets.left + col * (largeCellLength+_itemSpacing), lineOriginY, largeCellLength, largeCellLength);
    EZDEBUG(@"%i attribute frame:%@",indexPath.item, NSStringFromCGRect(attribute.frame));
    return attribute;
}

@end
