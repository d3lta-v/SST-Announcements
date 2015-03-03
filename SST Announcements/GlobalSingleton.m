//
//  GlobalSingleton.m
//  SST Announcer
//
//  Created by Pan Ziyue on 1/3/15.
//  Copyright (c) 2015 Pan Ziyue. All rights reserved.
//

#import "GlobalSingleton.h"

@implementation GlobalSingleton

static GlobalSingleton *_sharedInstance;

-(id)init {
    return self;
}

+(GlobalSingleton *)sharedInstance {
    if (!_sharedInstance) {
        _sharedInstance = [GlobalSingleton new];
    }
    return _sharedInstance;
}

-(NSString *)getRemoteNotificationURL {
    return remoteNotificationURL;
}

-(void)setRemoteNotificationURLWithString:(NSString *)string {
    remoteNotificationURL = string;
}

-(bool)didReceivePushNotification {
    return didReceivePushNotification;
}

-(void)setDidReceivePushNotification:(bool)boolean {
    didReceivePushNotification = boolean;
}

@end
