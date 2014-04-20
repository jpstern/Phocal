//
//  likeView.h
//  test
//
//  Created by Patrick Wilson on 4/6/14.
//  Copyright (c) 2014 Patrick Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LikeGestureView : UIView

@property (nonatomic,strong) NSString * status;
@property (nonatomic,strong) UIImageView *imgview;
@property (nonatomic,strong) UILongPressGestureRecognizer *gestreg;
@property (nonatomic,weak) UIImageView *currectImgView;
@property (nonatomic,weak) id target;
@property (nonatomic,assign) SEL selector;

@end
