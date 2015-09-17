//
//  JTSegmentedScrollController.m
//  JTSegmentedScrollControllerDemo
//
//  Created by Jason Tang on 15/7/21.
//  Copyright (c) 2015年 Jason Tang. All rights reserved.
//

#import "JTSegmentedScrollController.h"
#import "JTPagerViewController.h"
#import "JTScrollContainerView.h"

@interface JTSegmentedScrollController ()<JTPagerViewControllerDelegate>

@end

@implementation JTSegmentedScrollController
{
    NSArray         *_segmentTitles;
    NSArray         *_contentControllers;
}


- (id)initWithHeaderView:(UIView *)headerView
           segmentTitles:(NSArray *)segmentTitles
      contentControllers:(NSArray *)contentControllers {
    if (self = [super init]) {
        _headerView = headerView;
        _segmentTitles = segmentTitles;
        _contentControllers = contentControllers;
        _pagerController = [[JTPagerViewController alloc] initWithViewControllers:_contentControllers titles:_segmentTitles];
        _pagerController.delegate = self;
    }
    
    return self;
}

- (void)loadView {
     _scrollContainerView = [[JTScrollContainerView alloc] initWithFrame:[UIScreen mainScreen].bounds headerView:_headerView pagerView:_pagerController.view];
    
    __weak typeof(self) __self = self;
    [_scrollContainerView setSegmentViewDidPinBlock:^(BOOL isPinned) {
        [__self notifySegmentDidViewPin:isPinned];
    }];
    
    self.view = _scrollContainerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)notifySegmentDidViewPin:(BOOL)isPinned {
    BOOL shouldScrollToTop = isPinned;
    _scrollContainerView.scrollsToTop = !shouldScrollToTop;
    
    UIViewController *currentContentController = self.pagerController.contentViewControllers[self.pagerController.currentPage];
    if ([currentContentController respondsToSelector:@selector(JTSegmentedContentControllerShouldScrollToTop:)]) {
        [(id<JTSegmentedContentControllerProtocol>)currentContentController JTSegmentedContentControllerShouldScrollToTop:shouldScrollToTop];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(JTSegmentedScrollController:didPinSegmentTitle:)]) {
        [self.delegate JTSegmentedScrollController:self didPinSegmentTitle:isPinned];
    }
}

#pragma mark JTPagerViewControllerDelegate 
- (void)JTPagerViewController:(JTPagerViewController *)controller didScrollToPageIndex:(NSUInteger)pageIndex {
    BOOL shouldScrollToTop = _scrollContainerView.isSegmentViewPinned;
    
    UIViewController *currentContentController = self.pagerController.contentViewControllers[self.pagerController.currentPage];
    if ([currentContentController respondsToSelector:@selector(JTSegmentedContentControllerShouldScrollToTop:)]) {
        [(id<JTSegmentedContentControllerProtocol>)currentContentController JTSegmentedContentControllerShouldScrollToTop:shouldScrollToTop];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(JTPagerViewController:didScrollToPageIndex:)]) {
        [self.delegate JTPagerViewController:controller didScrollToPageIndex:pageIndex];
    }
}

- (void)JTPagerViewController:(JTPagerViewController *)controller didSelectSegmentIndex:(NSUInteger)segmentIndex {
    BOOL shouldScrollToTop = _scrollContainerView.isSegmentViewPinned;
    
    UIViewController *currentContentController = self.pagerController.contentViewControllers[self.pagerController.currentPage];
    if ([currentContentController respondsToSelector:@selector(JTSegmentedContentControllerShouldScrollToTop:)]) {
        [(id<JTSegmentedContentControllerProtocol>)currentContentController JTSegmentedContentControllerShouldScrollToTop:shouldScrollToTop];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(JTPagerViewController:didSelectSegmentIndex:)]) {
        [self.delegate JTPagerViewController:controller didSelectSegmentIndex:segmentIndex];
    }
}

@end
