//
//  SSTAnnounceAppDelegate.m
//  SST Announcements
//
//  Created by Pan Ziyue on 26/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "SSTAnnounceAppDelegate.h"
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
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [[UAPush shared] setBadgeNumber:0];
    [[UAPush shared] resetBadge];
    
    //Set Bar Button
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:112.0/255.0 green:138.0/255.0 blue:144.0/255.0 alpha:0.7]];
    
    //Set tab bar looks
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor colorWithRed:158.0/255.0 green:158.0/255.0 blue:158.0/255.0 alpha:1.0] }forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor colorWithRed:132.0/255.0 green:112.0/255.0 blue:255.0/255.0 alpha:1.0] }forState:UIControlStateHighlighted];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
    
    //Set tab bar icons
    self.tabBarController = (UITabBarController*)self.window.rootViewController;
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    [item0 setFinishedSelectedImage:[UIImage imageNamed:@"Feed_Icon_Selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Feed_Icon_Deselected.png"]];
    [item1 setFinishedSelectedImage:[UIImage imageNamed:@"Categories_Icon_Selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Categories_Icon_Deselected.png"]];
    [item2 setFinishedSelectedImage:[UIImage imageNamed:@"Info_Button_Selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Info_Button_Deselected.png"]];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    UALOG(@"APN device token: %@", deviceToken);
    //[[UAPush shared] registerDeviceToken:deviceToken];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    /*PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }*/
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
