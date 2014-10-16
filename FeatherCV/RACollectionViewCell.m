//
//  RACollectionViewCell.m
//  RACollectionViewTripletLayout-Demo
//
//  Created by Ryo Aoyama on 5/27/14.
//  Copyright (c) 2014 Ryo Aoyama. All rights reserved.
//

#import "RACollectionViewCell.h"

@implementation RACollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        EZDEBUG(@"contentView:%i", (int)self.contentView);
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void) showAdd
{
    _imageView.hidden = true;
    _delBtn.hidden = true;
    _addBtn.hidden = false;
}

- (void) showDelete:(BOOL)animated
{
    if(_addBtn.hidden){
        _delBtn.hidden = false;
        _delBtn.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^(){
            _delBtn.alpha = 1;
        }];
    }
}

- (void) showImage:(BOOL)isDragMode
{
    //if(_addBtn.hidden){
    if(isDragMode){
        _delBtn.hidden = false;
    }else{
        _delBtn.hidden = true;
    }
    _addBtn.hidden = true;
    _imageView.hidden = false;
    //_addBtn.hidden = true;
    //}
}


- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, 5, 5)];
        _imageView.layer.cornerRadius = 5;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _imageView.clipsToBounds = true;
        //EZDEBUG(@"init contentView:%i", (int)self.contentView);
        _delBtn = [UIButton createButton:CGRectMake(0, 0, 25, 25) font:[UIFont systemFontOfSize:14] color:[UIColor blackColor] align:NSTextAlignmentCenter];
        _delBtn.backgroundColor = RGBA(255, 73, 73, 200);
        [_delBtn setTitle:@"x" forState:UIControlStateNormal];
        [_delBtn enableRoundEdge];
        _delBtn.hidden = true;
        [_delBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_delBtn];
        
        
        _addBtn = [[UIButton alloc] initWithFrame:self.bounds];
        UIView* horizon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width - 30, 3)];
        horizon.backgroundColor = [UIColor grayColor];
        UIView* vertical = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 3, self.height - 30)];
        vertical.backgroundColor = [UIColor grayColor];
        horizon.center = _addBtn.center;
        vertical.center = _addBtn.center;
        [_addBtn addSubview:horizon];
        [_addBtn addSubview:vertical];
        [_addBtn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
        _addBtn.hidden = true;
        [self addSubview:_addBtn];
        [self.contentView addSubview:_imageView];
        
        /**
        _delBtn = [UIButton createButton:CGRectMake(frame.size.width - 30, 0, 30, 30) font:[UIFont systemFontOfSize:10] color:[UIColor whiteColor] align:NSTextAlignmentCenter];
        UILabel* delSign = [UILabel createLabel:CGRectMake(0, -2, 30, 30) font:[UIFont boldSystemFontOfSize:28] color:[UIColor whiteColor]];
        delSign.backgroundColor = RGBCOLOR(220, 8, 30);
        delSign.text = @"一";
        delSign.textAlignment = NSTextAlignmentCenter;
        _delBtn.backgroundColor = RGBCOLOR(220, 8, 30);
        [_delBtn enableRoundImage];
        _delBtn.layer.borderColor = [UIColor whiteColor].CGColor;
        _delBtn.layer.borderWidth = 2;
        
        [_delBtn addSubview:delSign];
        [self.contentView addSubview:_delBtn];
        _delBtn.hidden = YES;
        [_delBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        **/
    }
    return self;
}
         
- (void) add:(id)sender
{
    if(_addClicked){
        _addClicked(nil);
    }
}

- (void) delete:(id)sender
{
    if(_deleteClicked){
        _deleteClicked(nil);
        //@"-"
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    //EZDEBUG(@"set highlight called, %@", [NSThread  callStackSymbols]);
    [super setHighlighted:highlighted];
    
    /**
    if (highlighted) {
        _delBtn.hidden = false;
        //_imageView.alpha = .7f;
    }else {
        //_delBtn.hidden = YES;
        //_imageView.alpha = 1.f;
    }
     **/
}

@end
