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

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        EZDEBUG(@"init contentView:%i", (int)self.contentView);
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
    if (highlighted) {
        _delBtn.hidden = false;
        //_imageView.alpha = .7f;
    }else {
        //_delBtn.hidden = YES;
        //_imageView.alpha = 1.f;
    }
}

@end
