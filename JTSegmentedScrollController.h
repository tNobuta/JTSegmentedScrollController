//
//  JTSegmentedScrollController.h
//  JTSegmentedScrollControllerDemo
//
//  Created by Jason Tang on 15/7/21.
//  Copyright (c) 2015年 Jason Tang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTPagerViewController.h"

@protocol JTSegmentedScrollControllerDelegate;

typedef id<JTSegmentedScrollControllerDelegate, JTPagerViewControllerDelegate> JTSegmentedScrollControllerDelegate;

@class JTScrollContainerView;

@interface JTSegmentedScrollController : UIViewController

@property (nonatomic, weak) JTSegmentedScrollControllerDelegate delegate;
@property (nonatomic, readonly) JTPagerViewController *pagerController;
@property (nonatomic, readonly) UIView *headerView;
@property (nonatomic, readonly) JTScrollContainerView *scrollContainerView;

- (id)initWithHeaderView:(UIView *)headerView
           segmentTitles:(NSArray *)segmentTitles
      contentControllers:(NSArray *)contentControllers;

@end

@protocol JTSegmentedScrollControllerDelegate <NSObject>

- (void)JTSegmentedScrollController:(JTSegmentedScrollController *)controller didPinSegmentTitle:(BOOL)isPinned;

@end


@protocol JTSegmentedContentControllerProtocol <NSObject>
@optional
- (void)JTSegmentedContentControllerShouldScrollToTop:(BOOL)scrollToTop;

@end