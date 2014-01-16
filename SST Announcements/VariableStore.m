//
//  VariableStore.m
//  SST Announcer
//
//  Created by Pan Ziyue on 12/1/14.
//  Copyright (c) 2014 Pan Ziyue. All rights reserved.
//

#import "VariableStore.h"

@implementation VariableStore

+(VariableStore *)sharedInstance
{
    static VariableStore *myInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myInstance = [[VariableStore alloc]init];
    });
    return myInstance;
}

@end
