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
#import "Crittercism.h"

#import "WebViewController.h"

@implementation SSTAnnounceAppDelegate

@synthesize tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Crittercism enableWithAppID: @"52c184d68b2e3313c5000004"];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
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
        if (iOSDeviceScreenSize.height == 568) // iPhone 5S screen sizes
        {
            UIStoryboard *iPhone5Storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard-568h" bundle:nil];
            UIViewController *initialViewController = [iPhone5Storyboard instantiateInitialViewController];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.window.rootViewController  = initialViewController;
            [self.window makeKeyAndVisible];
        }
        if (iOSDeviceScreenSize.height==736) // iPhone 6+ screen size
        {
            UIStoryboard *iPhone6Storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard-iPhone6Plus" bundle:nil];
            UIViewController *initialViewController = [iPhone6Storyboard instantiateInitialViewController];
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.window.rootViewController  = initialViewController;
            [self.window makeKeyAndVisible];
        }
        if (iOSDeviceScreenSize.height==667)
        {
            UIStoryboard *iPhone6Storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard-iPhone6" bundle:nil];
            UIViewController *initialViewController = [iPhone6Storyboard instantiateInitialViewController];
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
    
    // Push notification code goes here
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // use registerUserNotificationSettings
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        // use registerForRemoteNotifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }

    //Set title font
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]
                                                           }];
    
    if (application.applicationIconBadgeNumber>0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *devToken = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    devToken = [devToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.statixind.net/deploy/registerDevice.php?appId=1&deviceToken=%@&feedUrl=http://studentsblog.sst.edu.sg/feeds/posts/default?alt=rss&feedEnable=1", devToken]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *returnedValue = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnedValue);
    }];
    
    [dataTask resume];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if(application.applicationState == UIApplicationStateInactive) {
        
        //NSLog(@"Inactive");
        
        //Show the view with the content of the push
        //WebViewController *viewctrl = [[WebViewController alloc]init];
        
        
    } else if (application.applicationState == UIApplicationStateBackground) {
        
        //NSLog(@"Background");
        
        //Refresh the local model
        
        
    } else {
        //Show an in-app banner
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Post!" message:[[NSString alloc]initWithFormat:@"%@", (NSString *)[userInfo objectForKey:@"alert"]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Post!" message:[[userInfo valueForKeyPath:@"aps.alert"] substringFromIndex:10] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
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

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
