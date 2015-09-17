//
//  XYPHScrollContainerView.h
//  Halo
//
//  Created by Jason Tang on 15/7/17.
//  Copyright (c) 2015年 XingIn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTScrollContainerView : UIScrollView<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic) BOOL isSegmentViewPinned;
@property (nonatomic, strong) void(^segmentViewDidPinBlock)(BOOL isPinned);
 
- (id)initWithFrame:(CGRect)frame headerView:(UIView *)headerView pagerView:(UIView *)pagerView;

- (void)observeScrollView:(UIScrollView *)scrollView;

@end
