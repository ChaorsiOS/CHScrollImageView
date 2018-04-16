//
//  CHScrollImageView.m
//  CHScrollImageViewDemo
//
//  Created by qianfeng on 16/6/23.
//  Copyright © 2016年 chaors. All rights reserved.
//


#import "CHScrollImageView.h"

#import "UIImageView+WebCache.h"

#define kSCROLLV_W  self.scrollView.frame.size.width
#define kSCROLLV_H  self.scrollView.frame.size.height


@interface CHScrollImageView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView  *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSTimer       *timer;
//网络图片数据源
@property (nonatomic, strong) NSArray       *dataSourceUrlImages;
//占位图片数据源
@property (nonatomic, strong) NSArray       *dataSourcePlaceImages;
@property (nonatomic, assign) NSInteger imgCount;

@end


@implementation CHScrollImageView
#pragma mark -- 初始化方法 --
- (instancetype)initWithFrame:(CGRect)frame urlImages:(NSArray *)urlImages placeHolderImages:(NSArray *)placeHolderImages {
    
    self = [self initWithFrame:frame];
    if (self) {
        
        self.dataSourceUrlImages = urlImages;
        self.dataSourcePlaceImages = placeHolderImages;
        //防止两个数组元素个数不一致造成的冲突
        if (_dataSourceUrlImages.count && _dataSourcePlaceImages.count) {
            
            _imgCount = _dataSourceUrlImages.count > _dataSourcePlaceImages.count ? _dataSourcePlaceImages.count:_dataSourceUrlImages.count;
            
        }else if (_dataSourceUrlImages.count && !_dataSourcePlaceImages.count) {
            
            _imgCount = _dataSourceUrlImages.count;
            
        }else if (!_dataSourceUrlImages.count && _dataSourcePlaceImages.count) {
            
            _imgCount = _dataSourcePlaceImages.count;
            NSLog(@"No Network Image!");
            
        }else {
            NSLog(@"Para Error!");
            return nil;
        }

        [self initScrollView];
        [self addTimer];
        
    }
    
    return self;
}


- (void)initScrollView {
    
    //第一张图(图片源的最后一张)
    UIImageView *firstImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kSCROLLV_W, kSCROLLV_H)];
    [self setImgView:firstImgV withPlaceHorderimage:[_dataSourcePlaceImages lastObject] urlImage:[_dataSourceUrlImages lastObject]];
    
    [self.scrollView addSubview:firstImgV];
    
    
    //最后一张图片(图片源的第一张)
    UIImageView *lastImgV = [[UIImageView alloc] initWithFrame:CGRectMake((_imgCount + 1) * kSCROLLV_W, 0, kSCROLLV_W, kSCROLLV_H)];
    [self setImgView:lastImgV withPlaceHorderimage:[_dataSourcePlaceImages firstObject] urlImage:[_dataSourceUrlImages firstObject]];
    
    [self.scrollView addSubview:lastImgV];
    
    
    //第二张图 → 倒数第二张图(数据源的真正全部数据)
    for (NSInteger i = 0; i < _imgCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake(kSCROLLV_W*(i+1), 0, kSCROLLV_W, kSCROLLV_H)];
        
        [self setImgView:imageView withPlaceHorderimage:_dataSourcePlaceImages[i] urlImage:_dataSourceUrlImages[i]];
        
        [self.scrollView addSubview:imageView];
    }
    
    //开始显示第二张(数据源的第一张)
    self.scrollView.contentOffset = CGPointMake(kSCROLLV_W, 0);
}


#pragma mark -- 设置图片 --
- (void)setImgView:(UIImageView *)imgV withPlaceHorderimage:(NSString *)imgName urlImage:(NSString *)urlImg {
    
    if (_dataSourceUrlImages.count && _dataSourcePlaceImages.count) {
        [imgV sd_setImageWithURL:[NSURL URLWithString:urlImg] placeholderImage:[UIImage imageNamed:imgName]];
    }else if (!_dataSourceUrlImages.count && _dataSourcePlaceImages.count){
        imgV.image = [UIImage imageNamed:imgName];
    }
}


#pragma mark -- 定时器自动轮播 --
- (void)addTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    
    /**
     runLoop这个概念比较抽象,在ios中所有的事件都会被放到runLoop中
     这时如果在界面上滚动另一个scrollview，timer会不起作用,因为scrollView滚动的时候，MainRunLoop是处于UITrackingRunLoopMode的模式下，在这个模式是不会处理NSDefaultRunLoopMode的消息
     所以需要手动设置runloopmode, 详细解说请参考:
        http://www.jianshu.com/p/79c17938953f
     */
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
    
    //!!同定时器实现同样功能 
    //!![self performSelector:@selector(nextPage) withObject:nil afterDelay:2];
}


#pragma mark -- 自动轮播事件 --
- (void)nextPage
{
    //[self performSelector:@selector(nextPage) withObject:nil afterDelay:2];
    
    NSInteger index = self.pageControl.currentPage;
    if (index == _imgCount + 1) {
        index = 0;
    }else {
        index ++;
    }
    
    [self.scrollView setContentOffset:CGPointMake((index + 1) * kSCROLLV_W, 0) animated:YES];
}


#pragma mark -- 属性懒加载 --
- (NSArray *)dataSourcePlaceImages {
    if (!_dataSourcePlaceImages) {
        _dataSourcePlaceImages = [[NSArray alloc] init];
    }
    
    return _dataSourcePlaceImages;
}

- (NSArray *)dataSourceUrlImages {
    if (!_dataSourceUrlImages) {
        _dataSourceUrlImages = [[NSArray alloc] init];
    }
    
    return _dataSourceUrlImages;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*(_imgCount+2), _scrollView.frame.size.height);
        
        _scrollView.delegate = self;
        
        [self addSubview:_scrollView];
    }
    
    return _scrollView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((CGRectGetWidth(_scrollView.frame)-100)/2,CGRectGetHeight(_scrollView.frame)-40, 100, 20)];
        _pageControl.numberOfPages = _imgCount;
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPage = 0;
        
        [self addSubview:_pageControl];
    }
    return _pageControl;
}


#pragma mark -- <ScrollViewDelegate> --
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.timer invalidate];
#warning ?????
//    [self.timer setFireDate:[NSDate distantFuture]];
    
    //!![NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextPage) object:nil];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    //[self.timer setFireDate:[NSDate distantPast]];
    [self addTimer];
    
    //!![self performSelector:@selector(nextPage) withObject:nil afterDelay:2];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%lf", scrollView.contentOffset.x);
    
    NSInteger index = self.scrollView.contentOffset.x / kSCROLLV_W;
    if (index == _imgCount + 2) {
        index = 1;
    } else if (index == 0) {
        index = _imgCount;
    }
    self.pageControl.currentPage = index - 1;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger index = self.scrollView.contentOffset.x / kSCROLLV_W;
    if (index == _imgCount + 1) {
        //最后一张再向右滑，跳到第一张  !!!不要加动画,you作you can try
        [self.scrollView setContentOffset:CGPointMake(kSCROLLV_W, 0) animated:NO];
    } else if (index == 0) {
        //同上,第一张继续左滑，跳到最后一张
        [self.scrollView setContentOffset:CGPointMake(_imgCount * kSCROLLV_W, 0) animated:NO];
    }

}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger index = self.scrollView.contentOffset.x / kSCROLLV_W;
    if (index == _imgCount + 1) {
        //最后一张再向右滑，跳到第一张  !!!不要加动画,you作you can try
        [self.scrollView setContentOffset:CGPointMake(kSCROLLV_W, 0) animated:NO];
    } else if (index == 0) {
        //同上,第一张继续左滑，跳到最后一张
        [self.scrollView setContentOffset:CGPointMake(_imgCount * kSCROLLV_W, 0) animated:NO];
    }
}




-(void)dealloc {
    
    [self.timer invalidate];
    self.timer = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
