//
//  RootTabBarController.h
//  Hubanghu
//
//  Created by  striveliu on 14-10-9.
//  Copyright (c) 2014年 striveliu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FirstViewController;
@class SecondViewController;
@class ThirdViewController;
@class FourthViewController;
@class FifthViewController;

@interface RootTabBarController : UITabBarController<UITabBarControllerDelegate,UITabBarDelegate>

- (void)registerEaseMob;
@end
