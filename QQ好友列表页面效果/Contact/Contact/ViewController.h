//
//  ViewController.h
//  Contact
//
//  Created by 周剑 on 15/12/19.
//  Copyright © 2015年 bukaopu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ViewControllerDelegate <NSObject>

- (void)deleteActionBtnDidClicked;

@end

@interface ViewController : UIViewController

@property (nonatomic, assign)id<ViewControllerDelegate>delegate;

@end

