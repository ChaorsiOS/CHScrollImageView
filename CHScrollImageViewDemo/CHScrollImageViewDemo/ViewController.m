//
//  ViewController.m
//  CHScrollImageViewDemo
//
//  Created by qianfeng on 16/6/23.
//  Copyright © 2016年 chaors. All rights reserved.
//

#import "ViewController.h"
#import "CHScrollImageView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    NSArray *images = @[@"http://pic.qyer.com/public/mobileapp/homebanner/2016/06/22/14665900349853/w800", @"http://pic.qyer.com/public/mobileapp/homebanner/2016/06/22/14665840871627/w800", @"http://pic.qyer.com/public/mobileapp/homebanner/2016/06/22/14665902191465/w800", @"http://pic.qyer.com/public/mobileapp/homebanner/2016/06/20/14663948632980/w800", @"http://pic.qyer.com/public/mobileapp/homebanner/2016/06/21/14664990505844/w800"];
    
    NSArray *image1 = @[@"美女01.jpg", @"美女02.jpg", @"美女03.jpg", @"美女04.jpg"];
    
    CHScrollImageView *scrollImgV = [[CHScrollImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/3) urlImages:images placeHolderImages:image1];
    
    //[self.view addSubview:scrollImgV];
    
    UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width,  self.view.frame.size.height)];
    
    [self.view addSubview:tb];
    tb.tableHeaderView = scrollImgV;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
