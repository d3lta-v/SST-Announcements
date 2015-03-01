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
    bool pushNotificationTriggered;
}

+(GlobalSingleton *)sharedInstance;

-(NSString *)getRemoteNotificationURL;
-(bool)pushNotificationTriggered;
-(void)setRemoteNotificationURLWithString:(NSString *)string;
-(void)setPushNotificationTriggeredWithBool:(bool)boolean;

@end
