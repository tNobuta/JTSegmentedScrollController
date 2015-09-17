//
//  JTPagerViewController.h
//  JTPagerViewControllerDemo
//
//  Created by tmy on 15/2/9.
//  Copyright (c) 2015年 tmy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DZNSegmentedControl.h"

@protocol JTPagerViewControllerDelegate;

@interface JTPagerViewController : UIViewController<DZNSegmentedControlDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) CGSize segmentSize;
@property (nonatomic, strong) UIColor *segmentHighlightColor;
@property (nonatomic) BOOL isSplit;
@property (nonatomic) BOOL showHairline;
@property (nonatomic) BOOL swipeEnabled;
@property (nonatomic) CGSize contentViewSize;
@property (nonatomic, readonly) NSInteger currentPage;

@property (nonatomic, weak) id<JTPagerViewControllerDelegate> delegate;
@property (nonatomic, readonly) DZNSegmentedControl *segmentedControl;
@property (nonatomic, readonly) UICollectionView    *pagerView;
@property (nonatomic, readonly) NSArray *contentViewControllers;

- (id)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;
- (void)scrollToPageIndex:(NSInteger)pageIndex;

@end

@protocol JTPagerViewControllerDelegate <NSObject>

@optional
- (void)JTPagerViewController:(JTPagerViewController *)controller didScrollToPageIndex:(NSUInteger)pageIndex;
- (void)JTPagerViewController:(JTPagerViewController *)controller didSelectSegmentIndex:(NSUInteger)segmentIndex;

@end