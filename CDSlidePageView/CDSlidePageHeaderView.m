//
//  CDSlidePageHeaderView.m
//  CDAppDemo
//
//  Created by cdd on 16/4/28.
//  Copyright © 2016年 Cheng. All rights reserved.
//

#import "CDSlidePageHeaderView.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)


@interface CDSlidePageHeaderView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation CDSlidePageHeaderView
@synthesize sliderView=_sliderView;

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _sliderSize = CGSizeZero;
        _normalColor = [UIColor lightGrayColor];
        _selectedColor = [UIColor colorWithRed:53.0/255.0 green:145.0/255.0 blue:252.0/255.0 alpha:1.0];
        _selectedIndex=0;
        _itemWidth=0;
        _fontSize = 15;
        self.backgroundColor=[UIColor whiteColor];
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.sliderView];
    }
    return self;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView=[[UIScrollView alloc]init];
        _scrollView.showsVerticalScrollIndicator=NO;
        _scrollView.showsHorizontalScrollIndicator=NO;
        _scrollView.bounces=NO;
    }
    return _scrollView;
}

- (NSMutableArray *)buttons{
    if (_buttons==nil) {
        _buttons=[[NSMutableArray alloc]init];
    }
    return _buttons;
}

- (UIView *)sliderView{
    if (_sliderView==nil) {
        _sliderView=[[UIView alloc]init];
    }
    return _sliderView;
}

- (void)setSelectedColor:(UIColor *)selectedColor{
    _selectedColor=selectedColor;
    self.sliderView.backgroundColor=_selectedColor;
}

#pragma mark - override
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [self reload];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.scrollView.frame=self.bounds;
    
    if (self.itemWidth==0) {
        self.itemWidth = self.frame.size.width / self.itemTitles.count;
    }else{
        if (self.itemWidth<self.frame.size.width / self.itemTitles.count) {
            self.itemWidth = self.frame.size.width / self.itemTitles.count;
        }
    }
    CGFloat itemHeight = self.frame.size.height;
    for (int idx = 0; idx < self.itemTitles.count; idx ++) {
        UIButton *button = self.buttons[idx];
        button.frame = CGRectMake(self.itemWidth*idx, 0, self.itemWidth, itemHeight);
    }
    if (CGSizeEqualToSize(_sliderSize, CGSizeZero)) {
        CGRect frame=self.sliderView.frame;
        frame.size=CGSizeMake(self.itemWidth, 2.0);
        self.sliderView.frame=frame;
    } else {
        _sliderSize.width = MIN(_sliderSize.width, self.itemWidth);
        _sliderSize.height = MIN(_sliderSize.height, itemHeight);
        CGRect frame=self.sliderView.frame;
        frame.size=_sliderSize;
        self.sliderView.frame=frame;
    }
    CGRect frame = self.sliderView.frame;
    frame.origin.y = self.frame.size.height - frame.size.height;
    self.sliderView.frame = frame;
    self.sliderView.center = CGPointMake(self.itemWidth * (_selectedIndex+0.5f), self.sliderView.center.y);
    self.scrollView.contentSize=CGSizeMake(self.itemWidth*self.itemTitles.count, itemHeight);
}

#pragma mark - public
- (void)setItemTitles:(NSArray<NSString *> *)itemTitles{
    _itemTitles=[itemTitles copy];
    [self reload];
}

- (CGSize)contentSize{
    return self.scrollView.contentSize;
}

- (void)reload {
    [self.buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.itemTitles.count!=0) {
        for (int idx = 0; idx < self.itemTitles.count; idx++) {
            [self p_createButtonWithIndex:idx];
        }
    }
    [self setNeedsLayout];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex >= self.itemTitles.count) { return; }
    if (_selectedIndex != selectedIndex) {
        _selectedIndex = selectedIndex;
        if (_delegate && [_delegate respondsToSelector:@selector(slidePageHeaderView:willSelectButtonAtIndex:)]) {
            [_delegate slidePageHeaderView:self willSelectButtonAtIndex:_selectedIndex];
        }
        [UIView animateWithDuration:0.25 animations:^{
            for (int idx = 0; idx < self.itemTitles.count; idx ++) {
                UIButton *button = [self.buttons objectAtIndex:idx];
                button.selected = idx == _selectedIndex;
                if (button.selected) {
                    self.sliderView.center = CGPointMake(CGRectGetMidX(button.frame), self.sliderView.center.y);
                    if (self.sliderView.center.x-self.scrollView.contentOffset.x<self.itemWidth) {
                        if (self.sliderView.center.x>=SCREEN_WIDTH*0.5) {
                            [self.scrollView setContentOffset:CGPointMake(self.sliderView.center.x-SCREEN_WIDTH*0.5, 0) animated:YES];
                        }else{
                            [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
                        }
                    }
                    if ((SCREEN_WIDTH-(self.sliderView.center.x-self.scrollView.contentOffset.x))<self.itemWidth) {
                        if ((self.scrollView.contentSize.width-self.sliderView.center.x)>=SCREEN_WIDTH*0.5) {
                            [self.scrollView setContentOffset:CGPointMake((self.sliderView.center.x-SCREEN_WIDTH*0.5), 0) animated:YES];
                        }else{
                            [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width-SCREEN_WIDTH, 0) animated:YES];
                        }
                    }
                }
            }
        } completion:^(BOOL finished) {
            if (_delegate && [_delegate respondsToSelector:@selector(slidePageHeaderView:didSelectButtonAtIndex:)]) {
                [_delegate slidePageHeaderView:self didSelectButtonAtIndex:_selectedIndex];
            }
        }];
    }
}

#pragma mark - private
- (void)p_createButtonWithIndex:(NSInteger)idx{
    UIButton *button=nil;
    if (self.buttons.count!=0 && self.buttons.count>idx) {
        button=[self.buttons objectAtIndex:idx];
    }
    if (!button) {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font=[UIFont systemFontOfSize:self.fontSize];
        if (self.isBoldFont) {
            button.titleLabel.font = [UIFont boldSystemFontOfSize:self.fontSize];
        }
        button.titleLabel.adjustsFontSizeToFitWidth=YES;
        [button addTarget:self action:@selector(p_titleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:_normalColor forState:UIControlStateNormal];
        [button setTitleColor:_selectedColor forState:UIControlStateSelected];
        [self.buttons addObject:button];
    }
    button.selected = (idx == _selectedIndex);
    NSString *title = [self.itemTitles objectAtIndex:idx];
    [button setTitle:title forState:UIControlStateNormal];
    [self.scrollView addSubview:button];
}

- (void)p_titleButtonAction:(UIButton *)button {
    if ([self.buttons containsObject:button]) {
        NSUInteger selectedIndex = [self.buttons indexOfObject:button];
        [self setSelectedIndex:selectedIndex];
    }
}

- (CGSize)sizeForText:(NSString *)text preferHeight:(CGFloat)height attribute:(NSDictionary *)attr{
    CGRect rect=[text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:attr context:nil];
    CGFloat sizeWidth=ceilf(CGRectGetWidth(rect));
    CGFloat sizeHeight=ceilf(CGRectGetHeight(rect));
    return CGSizeMake(sizeWidth, sizeHeight);
}

@end
