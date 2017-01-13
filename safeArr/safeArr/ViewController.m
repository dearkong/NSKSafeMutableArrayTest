//
//  ViewController.m
//  safeArr
//
//  Created by cheyipai.com on 17/1/9.
//  Copyright © 2017年 kong. All rights reserved.
//

#import "ViewController.h"
#import "NSKSafeMutableArray.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSKSafeMutableArray *safeArr = [[NSKSafeMutableArray alloc] init];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    for ( int i = 0; i < 5; i ++) {
        dispatch_async(queue, ^{
            
            NSLog(@"添加第%d个",i);
            [safeArr addObject:[NSString stringWithFormat:@"%d",i]];
            
        });
        
        dispatch_async(queue, ^{
            
            NSLog(@"删除第%d个",i);
            [safeArr removeObjectAtIndex:i];
            
        });
    }
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
