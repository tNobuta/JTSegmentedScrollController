//
//  XYPHScrollContainerView.m
//  Halo
//
//  Created by Jason Tang on 15/7/17.
//  Copyright (c) 2015年 XingIn. All rights reserved.
//

#import "JTScrollContainerView.h"

#define ObserveKeyPath @"contentOffset"

static void *SelfScrollContext = &SelfScrollContext;

@implementation JTScrollContainerView
{
    BOOL    _inited;
    BOOL     _observeLocked;
    BOOL     _selfScrollLocked;
    CGFloat  _scrollContentHeight;
    NSMutableArray      *_observedScrollViews;
    
    UIView  *_headerView;
    UIView  *_pagerView;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:ObserveKeyPath];
    
    [self clearObservedScrollViews];
}

- (id)initWithFrame:(CGRect)frame headerView:(UIView *)headerView pagerView:(UIView *)pagerView {
    if (self = [super initWithFrame:frame]) {
        self.alwaysBounceVertical = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.directionalLockEnabled = YES;
        self.delegate = self;
        _observedScrollViews = [[NSMutableArray alloc] init];
        
        [self setHeaderView:headerView];
        
        [self setPageContentView:pagerView];
        
        self.contentSize = CGSizeMake(frame.size.width, _scrollContentHeight);
        
        [self addObserver:self forKeyPath:ObserveKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:SelfScrollContext];
    }
    
    return self;
}

- (void)setIsSegmentViewPinned:(BOOL)isSegmentViewPinned{
    if (_isSegmentViewPinned != isSegmentViewPinned) {
        _isSegmentViewPinned = isSegmentViewPinned;
        
        if (self.segmentViewDidPinBlock) {
            self.segmentViewDidPinBlock(_isSegmentViewPinned);
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_inited) {
        _inited = YES;
        self.contentSize = CGSizeMake(self.frame.size.width, _scrollContentHeight + 10);
        
        _headerView.frame = CGRectMake((self.frame.size.width - _headerView.frame.size.width) / 2, 0, _headerView.frame.size.width, _headerView.frame.size.height);
        
        _pagerView.frame = CGRectMake((self.frame.size.width - _pagerView.frame.size.width) / 2, CGRectGetMaxY(_headerView.frame), _pagerView.frame.size.width, _pagerView.frame.size.height);

        self.contentOffset = CGPointZero;
    }
}

- (BOOL)isScrollLocked {
    return _selfScrollLocked;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((self.contentOffset.y > _headerView.frame.size.height)) {
        self.contentOffset = CGPointMake(self.contentOffset.x, _headerView.frame.size.height);
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

}

- (void)setHeaderView:(UIView *)headerView {
    _headerView = headerView;
    
    _scrollContentHeight += headerView.frame.size.height;
    [self addSubview:headerView];
}

- (void)setPageContentView:(UIView *)contentView {
    _pagerView = contentView;
    
    _scrollContentHeight += _pagerView.frame.size.height;
    
    [self addSubview:_pagerView];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer  isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *panGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint velocity = [panGestureRecognizer velocityInView:self];
        CGFloat absX = fabs(velocity.x);
        CGFloat absY = fabs(velocity.y);
        
        if (absX > absY) {
            return NO;
        }
        else if (absX < absY) {
            return YES;
        }
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIView *view = otherGestureRecognizer.view;
        if (view != self && [view isKindOfClass:[UIScrollView class]]) {
            [self observeScrollView:(UIScrollView *)view];
        }
    }
    return YES;
}

- (void)observeScrollView:(UIScrollView *)scrollView {
    if(!scrollView) return;
    
    if (![_observedScrollViews containsObject:scrollView]) {
        [_observedScrollViews addObject:scrollView];
        [scrollView addObserver:self forKeyPath:ObserveKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:SelfScrollContext];
    }
}

- (void)clearObservedScrollViews {
    for (UIScrollView *scrollView in _observedScrollViews) {
        @try {
            [scrollView removeObserver:self forKeyPath:ObserveKeyPath];
        }
        @catch (NSException *exception) {}
    }
    
    [_observedScrollViews removeAllObjects];
}

- (void)scrollView:(UIScrollView*)scrollView setContentOffset:(CGPoint)offset {
    _observeLocked = YES;
    scrollView.contentOffset = offset;
    _observeLocked = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(![keyPath isEqualToString:ObserveKeyPath] || context != SelfScrollContext) return;
    
    CGPoint old = [change[NSKeyValueChangeOldKey] CGPointValue];
    CGPoint new = [change[NSKeyValueChangeNewKey] CGPointValue];
    CGFloat oldValue = old.y;
    CGFloat newValue = new.y;
    if(oldValue == newValue) return;
    
    if (object == self) {
        if (!_observeLocked) {
            if ( _selfScrollLocked && (oldValue - newValue) > 0) {
                [self scrollView:object setContentOffset:old];
            }
        }
    }else if([object isKindOfClass:[UIScrollView class]]){
        if (!_observeLocked) {
            UIScrollView *scrollView = object;
            CGFloat currentOffsetY = self.contentOffset.y;
            CGFloat maxHeaderHeight = _headerView.frame.size.height;
            _selfScrollLocked = scrollView.contentOffset.y > -scrollView.contentInset.top;
            if(currentOffsetY < maxHeaderHeight && _selfScrollLocked && (oldValue - newValue < 0)) {
                [self scrollView:scrollView setContentOffset:old];
            }
            
            if(!_selfScrollLocked) {
                [self scrollView:scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, - scrollView.contentInset.top)];
            }
        }
    }
 
}

@end
