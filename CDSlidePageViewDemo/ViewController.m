//
//  ViewController.m
//  CDSlidePageViewDemo
//
//  Created by cd on 2017/10/26.
//  Copyright © 2017年 cd. All rights reserved.
//

#import "ViewController.h"
#import "CDSlidePageView.h"

@interface ViewController ()<CDSlidePageViewDataSource,CDSlidePageViewDelegate>

@property (nonatomic, strong) CDSlidePageView *slidePageView;
@property (nonatomic, copy) NSArray *arrTitle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    CDSlidePageHeaderView可以单独使用
    [self.view addSubview:self.slidePageView];
}

- (NSArray *)arrTitle{
    if (!_arrTitle) {
        _arrTitle=[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12", nil];//
    }
    return _arrTitle;
}

- (CDSlidePageView *)slidePageView{
    if (!_slidePageView) {
        CGFloat barHeight=64;
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && (CGSizeEqualToSize(screenSize, CGSizeMake(375.0, 812.0)) || CGSizeEqualToSize(screenSize, CGSizeMake(812.0, 375.0)))) {
            barHeight=88;
        }
        _slidePageView = [[CDSlidePageView alloc] initWithFrame:CGRectMake(0, barHeight, self.view.frame.size.width, self.view.frame.size.height-barHeight)];
        _slidePageView.dataSource = self;
        _slidePageView.delegate = self;
        _slidePageView.headerViewHeight=40;
        _slidePageView.headerView.itemWidth=54;
        _slidePageView.headerView.sliderSize=CGSizeMake(28, 2);
        _slidePageView.headerView.fontSize = 14;
        _slidePageView.headerView.normalColor=[UIColor colorWithRed:109.0/255.0 green:109.0/255.0 blue:109.0/255.0 alpha:109.0/255.0];
        _slidePageView.headerView.selectedColor=[UIColor colorWithRed:53.0/255.0 green:145.0/255.0 blue:252.0/255/0 alpha:1.0];
    }
    return _slidePageView;
}

#pragma mark - CDSlidePageViewDataSource
- (NSUInteger)numberOfPagesInSlidePageView:(CDSlidePageView *)slidePageView{
    return self.arrTitle.count;
}

- (UIView *)slidePageView:(CDSlidePageView *)slidePageView contentViewAtPageIndex:(NSUInteger)index{
    return [self createSubViewWithIndex:index];
}

- (NSString *)slidePageView:(CDSlidePageView *)slidePageView headerTitleAtPageIndex:(NSUInteger)index{
    return [self.arrTitle objectAtIndex:index];
}

#pragma mark - CDSlidePageViewDelegate
- (void)slidePageView:(CDSlidePageView *)slidePageView didMoveToPageAtIndex:(NSUInteger)index{
    NSLog(@"%lu",(unsigned long)index);
}

#pragma mark - private
- (UILabel *)createSubViewWithIndex:(NSInteger)index{
    UILabel *label=[[UILabel alloc]init];
    label.textAlignment=NSTextAlignmentCenter;
    label.backgroundColor=[UIColor colorWithRed:(CGFloat)(arc4random()%255)/255.0 green:(CGFloat)(arc4random()%255)/255.0 blue:(CGFloat)(arc4random()%255)/255.0 alpha:1.0];
    label.text=[NSString stringWithFormat:@"第%ld个页面",(long)index];
    return label;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
