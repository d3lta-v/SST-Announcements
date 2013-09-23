//
//  SSTAnnounceAppDelegate.m
//  SST Announcements
//
//  Created by Pan Ziyue on 26/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "SSTAnnounceAppDelegate.h"
#import "SSTAMasterViewController.h"

#import "SVProgressHUD.h"
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"


@implementation SSTAnnounceAppDelegate

@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    // or set runtime properties here.
    UAConfig *config = [UAConfig defaultConfig];
    
    // Call takeOff (which creates the UAirship singleton)
    [UAirship takeOff:config];
    // Request a custom set of notification types
    [UAPush shared].notificationTypes = (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert);
    [[UAPush shared] setPushEnabled:YES];
    [UAirship setLogging:YES];
    
    //Reset badges
    [[UAPush shared] resetBadge];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {    // The iOS device = iPhone or iPod Touch
        
        
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 480)
        {   // iPhone 3GS, 4, and 4S and iPod Touch 3rd and 4th generation: 3.5 inch screen (diagonally measured)
            
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone35
            UIStoryboard *iPhone35Storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            
            // Instantiate the initial view controller object from the storyboard
            UIViewController *initialViewController = [iPhone35Storyboard instantiateInitialViewController];
            
            // Instantiate a UIWindow object and initialize it with the screen size of the iOS device
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            
            // Set the initial view controller to be the root view controller of the window object
            self.window.rootViewController  = initialViewController;
            
            // Set the window object to be the key window and show it
            [self.window makeKeyAndVisible];
        }
        
        if (iOSDeviceScreenSize.height == 568)
        {   // iPhone 5 and iPod Touch 5th generation: 4 inch screen (diagonally measured)
            
            // Instantiate a new storyboard object using the storyboard file named Storyboard_iPhone4
            UIStoryboard *iPhone4Storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard-568h" bundle:nil];
            
            // Instantiate the initial view controller object from the storyboard
            UIViewController *initialViewController = [iPhone4Storyboard instantiateInitialViewController];
            
            // Instantiate a UIWindow object and initialize it with the screen size of the iOS device
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            
            // Set the initial view controller to be the root view controller of the window object
            self.window.rootViewController  = initialViewController;
            
            // Set the window object to be the key window and show it
            [self.window makeKeyAndVisible];
        }
        
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        
    {   // The iOS device = iPad
        
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
        
    }
    
    self.tabBarController = (UITabBarController*)self.window.rootViewController;
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    item0.selectedImage=[UIImage imageNamed:@"TabBar1Selected"];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    item1.selectedImage=[UIImage imageNamed:@"TabBar2Selected"];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    item2.selectedImage=[UIImage imageNamed:@"TabBar3Selected"];
    
    //Set title font
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0],
                                                           NSForegroundColorAttributeName: [UIColor whiteColor]
                                                           }];
    
    //Setting button colors universally
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithWhite:1 alpha:1]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithWhite:1 alpha:1]];
    //ecf0f1
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNS device token: %@", deviceToken);
    [[UAPush shared] registerDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (application.applicationIconBadgeNumber>0) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [[UAPush shared] setBadgeNumber:0];
        [[UAPush shared] resetBadge];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
