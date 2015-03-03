//
//  GlobalSingleton.h
//  SST Announcer
//
//  Created by Pan Ziyue on 1/3/15.
//  Copyright (c) 2015 Pan Ziyue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalSingleton : NSObject {
    NSString *remoteNotificationURL;
    bool didReceivePushNotification;
}

+(GlobalSingleton *)sharedInstance;

-(NSString *)getRemoteNotificationURL;
-(bool)didReceivePushNotification;
-(void)setRemoteNotificationURLWithString:(NSString *)string;
-(void)setDidReceivePushNotification:(bool)boolean;

@end
