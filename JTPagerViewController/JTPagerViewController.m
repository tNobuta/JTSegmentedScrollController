//
//  JTPagerViewController.m
//  JTPagerViewControllerDemo
//
//  Created by tmy on 15/2/9.
//  Copyright (c) 2015年 tmy. All rights reserved.
//

#import "JTPagerViewController.h"

#define CELL_IDENTIFIER @"PagerCell"
#define CELL_CONTENT_TAG 1999

@interface JTPagerViewController ()

@end

@implementation JTPagerViewController
{
    NSArray             *_viewControllers;
    NSArray             *_titles;
    DZNSegmentedControl *_segmentedControl;
    UICollectionView    *_pagerCollectionView;
    NSUInteger          _currentPageIndex;
    CGFloat             _lastOffsetX;
    CGFloat             _segmentItemWidth;
    BOOL                _hasInitiedViews;
    BOOL                _initCellForFirst;
}

- (NSArray *)contentViewControllers {
    return _viewControllers;
}

- (id)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles{
    if (self = [super init]) {
        _viewControllers = viewControllers;
        _titles = titles;
        self.isSplit = NO;
        self.showHairline = YES;
        self.swipeEnabled = YES;
        self.segmentHighlightColor = [UIApplication sharedApplication].keyWindow.tintColor;
        self.segmentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 44);
        self.contentViewSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.segmentSize.height);
        
        for (UIViewController *controller in viewControllers) {
            [self addChildViewController:controller];
            [controller didMoveToParentViewController:self];
        }
    }
    
    return self;
}

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.segmentSize.width > self.contentViewSize.width ? self.segmentSize.width : self.contentViewSize.width, self.segmentSize.height + self.contentViewSize.height)];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!_hasInitiedViews) {
        _hasInitiedViews = YES;
        
        if (!self.isSplit) {
             self.contentViewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - self.segmentSize.height);
        }else {
            self.contentViewSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        }
        
        UICollectionView *pagerView = [self pagerView];
        [self.view addSubview:pagerView];
        
        if (!self.isSplit) {
            DZNSegmentedControl *segmentedControl = [self segmentedControl];
            [self.view addSubview:segmentedControl];
        }
    }
    
    if (!self.isSplit) {
        DZNSegmentedControl *segmentedControl = [self segmentedControl];
        UICollectionView *pagerView = [self pagerView];
        
        CGRect segmentFrame = segmentedControl.frame;
        segmentFrame.origin.x = (self.view.frame.size.width - self.segmentSize.width) / 2;
        segmentFrame.origin.y = 0;
        segmentedControl.frame = segmentFrame;
        
        
        CGRect pagerFrame = pagerView.frame;
        pagerFrame.origin.y = segmentedControl.frame.size.height;
        pagerView.frame = pagerFrame;
    }else {
        UICollectionView *pagerView = [self pagerView];
        pagerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
}

- (NSInteger)currentPage {
    return _currentPageIndex;
}

- (void)setSegmentSize:(CGSize)segmentSize {
    _segmentSize = segmentSize;
    _segmentItemWidth = _segmentSize.width / _titles.count;
}

- (void)setShowHairline:(BOOL)showHairline {
    _showHairline = showHairline;
    
    if (_segmentedControl) {
        _segmentedControl.hairline.hidden = !showHairline;
    }
}

- (DZNSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        [self initSegmentedControl];
    }
    
    return _segmentedControl;
}


- (UICollectionView *)pagerView {
    if (!_pagerCollectionView) {
        [self initPagerView];
    }
    
    return _pagerCollectionView;
}


- (void)initSegmentedControl {
    _segmentedControl = [[DZNSegmentedControl alloc] initWithItems:_titles];
    _segmentedControl.height = self.segmentSize.height;
    _segmentedControl.width = self.segmentSize.width;
    _segmentedControl.selectionIndicatorHeight = 1;
    _segmentedControl.hairLineHeight = 1;
    _segmentedControl.delegate = self;
    _segmentedControl.autoAdjustSelectionIndicatorWidth = NO;
    _segmentedControl.animationDuration = 0.45f;
    _segmentedControl.bouncySelectionIndicator = NO;
    _segmentedControl.showsCount = NO;
    _segmentedControl.hairlineColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    _segmentedControl.backgroundColor = [UIColor clearColor];
    _segmentedControl.tintColor = self.segmentHighlightColor;
    [_segmentedControl addTarget:self action:@selector(segmentedControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    _segmentedControl.hairline.hidden = !self.showHairline;
}

- (void)initPagerView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = self.contentViewSize;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    
    _pagerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.contentViewSize.width, self.contentViewSize.height) collectionViewLayout:layout];
    _pagerCollectionView.delegate = self;
    _pagerCollectionView.dataSource = self;
    _pagerCollectionView.backgroundColor = [UIColor clearColor];
    _pagerCollectionView.pagingEnabled = YES;
    _pagerCollectionView.showsHorizontalScrollIndicator = NO;
    _pagerCollectionView.showsVerticalScrollIndicator = NO;
    _pagerCollectionView.bounces = NO;
    _pagerCollectionView.scrollsToTop = NO;
    _pagerCollectionView.scrollEnabled = self.swipeEnabled;
    [_pagerCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier: CELL_IDENTIFIER];
}

- (void)segmentedControlDidChangeValue:(DZNSegmentedControl *)control {
    if (!self.pagerView.isDragging && !self.pagerView.isDecelerating) {
        _currentPageIndex = control.selectedSegmentIndex;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(JTPagerViewController:didSelectSegmentIndex:)]) {
            [self.delegate JTPagerViewController:self didSelectSegmentIndex:control.selectedSegmentIndex];
        }
        
        
        [self.pagerView setContentOffset:CGPointMake(self.contentViewSize.width * _currentPageIndex, 0) animated:NO];
    }
}

- (void)scrollToPageIndex:(NSInteger)pageIndex{
    if (pageIndex >= 0 && pageIndex < self.contentViewControllers.count) {
        [self.segmentedControl setSelectedSegmentIndex:pageIndex];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    
    if (!self.pagerView.isDragging && !self.pagerView.isDecelerating){
        _lastOffsetX = currentOffsetX;
        return;
    };
    
    if (_lastOffsetX == 0) {
        _lastOffsetX = currentOffsetX;
    }else {
        CGFloat offset = currentOffsetX - _lastOffsetX;
        CGFloat segmentIndicatorOffsetX = _segmentItemWidth / self.contentViewSize.width * offset;
        CGRect currentIndicatorFrame = self.segmentedControl.selectionIndicator.frame;
        currentIndicatorFrame.origin.x += segmentIndicatorOffsetX;
        self.segmentedControl.selectionIndicator.frame = currentIndicatorFrame;
        _lastOffsetX = currentOffsetX;
    }
    
    NSUInteger pageIndex = (NSUInteger)roundf(currentOffsetX / scrollView.frame.size.width);
    if (pageIndex != _currentPageIndex) {
        _currentPageIndex = pageIndex;
        
        [_segmentedControl setSelectedSegmentIndexWithoutMovingIndicator:_currentPageIndex];
        if (self.delegate && [self.delegate respondsToSelector:@selector(JTPagerViewController:didScrollToPageIndex:)]) {
            [self.delegate JTPagerViewController:self didScrollToPageIndex:_currentPageIndex];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGRect currentIndicatorFrame = self.segmentedControl.selectionIndicator.frame;
    currentIndicatorFrame.origin.x = _currentPageIndex * _segmentItemWidth;
    self.segmentedControl.selectionIndicator.frame = currentIndicatorFrame;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _viewControllers? _viewControllers.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *loadedContentView = [cell.contentView viewWithTag:CELL_CONTENT_TAG];
    if (loadedContentView) {
        [loadedContentView removeFromSuperview];
    }
    
    UIViewController *contentViewController = _viewControllers[indexPath.row];
    contentViewController.view.frame = CGRectMake(0, 0, self.contentViewSize.width, self.contentViewSize.height);
    contentViewController.view.tag = CELL_CONTENT_TAG;
    [cell.contentView addSubview:contentViewController.view];
    
    if (!_initCellForFirst) {
        _initCellForFirst = YES;
        if (self.contentViewControllers.count > 0) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(JTPagerViewController:didSelectSegmentIndex:)]) {
                [self.delegate JTPagerViewController:self didSelectSegmentIndex:0];
            }
        }
    }
    
    return cell;
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)view
{
    return UIBarPositionBottom;
}

@end
