//
//  AppDelegate.m
//  LiveCast
//
//  Created by chaoyang805 on 2016/12/20.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

#import "ZCYAppDelegate.h"
#import "ZCYHomeViewController.h"
#import "ZCYLiveViewController.h"
#import "ZCYVideoViewController.h"
#import "ZCYFocusViewController.h"
#import "ZCYMineViewController.h"
#import "UIViewController+ZCYTabBarItem.h"
#import "UIColor+HexStringColor.h"

@interface ZCYAppDelegate ()

@end

@implementation ZCYAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = [self setupTabBarController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (UITabBarController *)setupTabBarController {
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    
    tabBarController.view.backgroundColor = [UIColor whiteColor];
    tabBarController.tabBar.tintColor = [UIColor colorWithHexString:@"0xFE7703"];
    
    ZCYHomeViewController *homeVC = [[ZCYHomeViewController alloc] initWithNibName:@"ZCYHomeViewController" bundle:nil];
    [homeVC zcy_setTabBarItemWithTitle:@"首页" image:[UIImage imageNamed:@"tabHome"] selectedImage:[UIImage imageNamed:@"tabHomeHL"]];
    
    UINavigationController *homeNC = [[UINavigationController alloc] initWithRootViewController:homeVC];
    
    ZCYLiveViewController *liveVC = [[ZCYLiveViewController alloc] initWithNibName:@"ZCYLiveViewController" bundle:nil];
    [liveVC zcy_setTabBarItemWithTitle:@"直播" image:[UIImage imageNamed:@"tabLiving"] selectedImage:[UIImage imageNamed:@"tabLivingHL"]];
    UINavigationController *liveNC = [[UINavigationController alloc] initWithRootViewController:liveVC];
    
    
    ZCYVideoViewController *videoVC = [[ZCYVideoViewController alloc] initWithNibName:@"ZCYVideoViewController" bundle:nil];
    [videoVC zcy_setTabBarItemWithTitle:@"视频" image:[UIImage imageNamed:@"tabVideo"] selectedImage:[UIImage imageNamed:@"tabVideoHL"]];
    UINavigationController *videoNC = [[UINavigationController alloc] initWithRootViewController:videoVC];
    
    ZCYFocusViewController *focusVC = [[ZCYFocusViewController alloc] initWithNibName:@"ZCYFocusViewController" bundle:nil];
    [focusVC zcy_setTabBarItemWithTitle:@"关注" image:[UIImage imageNamed:@"tabFocus"] selectedImage:[UIImage imageNamed:@"tabFocusHL"]];
    UINavigationController *focusNC = [[UINavigationController alloc] initWithRootViewController:focusVC];
    
    
    ZCYMineViewController *mineVC = [[ZCYMineViewController alloc] initWithNibName:@"ZCYMineViewController" bundle:nil];
    [mineVC zcy_setTabBarItemWithTitle:@"我的" image:[UIImage imageNamed:@"tabMine"] selectedImage:[UIImage imageNamed:@"tabMineHL"]];
    UINavigationController *mineNC = [[UINavigationController alloc] initWithRootViewController:mineVC];
    
    tabBarController.viewControllers = @[homeNC, liveNC, videoNC, focusNC, mineNC];
    
    return tabBarController;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    
}


@end
