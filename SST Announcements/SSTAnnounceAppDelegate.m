//
//  SSTAnnounceAppDelegate.m
//  SST Announcements
//
//  Created by Pan Ziyue on 26/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "SSTAnnounceAppDelegate.h"
#import "SSTAMasterViewController.h"
#import "WebViewController.h"
#import "GlobalSingleton.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#include <asl.h>
#import <Parse/Parse.h>

#define IS_IOS8_AND_UP ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

@implementation SSTAnnounceAppDelegate

@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[CrashlyticsKit]];
    [Parse setApplicationId:@"5OtbHnpgcIWBOOBSDsN75dbLGYyD1zYrbK1NtUsI"
                  clientKey:@"c3KRrAwmvY8GGLR7iNh9WwhNRMLKiew0YOa5gqv6"];
    
    // Push notification code goes here
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
#ifdef __IPHONE_8_0
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge |UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
#endif
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    // User interface (custom storyboard) code goes here
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        
        if (iOSDeviceScreenSize.height == 480)
        {
            UIStoryboard *iPhone35Storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UIViewController *initialViewController = [iPhone35Storyboard instantiateInitialViewController];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.window.rootViewController  = initialViewController;
            [self.window makeKeyAndVisible];
        }
    }
    
    // Some UI code for the tab bar controller
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
                                                           NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]
                                                           }];
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if(notificationPayload) {
        asl_log(NULL, NULL, ASL_LEVEL_NOTICE, [[NSString stringWithFormat:@"Cold launched app with notification: %@", notificationPayload] UTF8String], nil);
        GlobalSingleton *singleton = [GlobalSingleton sharedInstance];
        
        [singleton setRemoteNotificationURLWithString:[notificationPayload objectForKey:@"url"]];
        [singleton setDidReceivePushNotification:true];
    }
    
    if (application.applicationIconBadgeNumber>0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    return YES;
}

#ifdef IS_IOS8_AND_UP
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
        asl_log(NULL, NULL, ASL_LEVEL_ERR, "User has declined to accept push notifications. Too bad.");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"You disabled Push Notifications!" message:@"Push notifications form the main functionality of the Announcer app. If you disable push notifications, this app will only be a feed reader for the Student's Blog. If you want to enable push later on, go to Settings > Notifications and enable Announcer." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    else if ([identifier isEqualToString:@"answerAction"]){
        asl_log(NULL, NULL, ASL_LEVEL_NOTICE, "User accepted push notifications request. Good.");
    }
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    asl_log(NULL, NULL, ASL_LEVEL_NOTICE, [[deviceToken description] UTF8String],nil);
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    asl_log(NULL, NULL, ASL_LEVEL_ERR, [[error localizedDescription] UTF8String],nil);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    asl_log(NULL, NULL, ASL_LEVEL_NOTICE, [[NSString stringWithFormat:@"Launched app with notification: %@", userInfo] UTF8String], nil);
    GlobalSingleton *singleton = [GlobalSingleton sharedInstance];
    
    [singleton setRemoteNotificationURLWithString:[userInfo objectForKey:@"url"]];
    [singleton setDidReceivePushNotification:true];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushReceived" object:self];
    
    if (application.applicationState == UIApplicationStateInactive) {
        // The application was just brought from the background to the foreground,
        // so we consider the app as having been "opened by a push notification."
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
