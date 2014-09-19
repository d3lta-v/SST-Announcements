//
//  VariableStore.h
//  SST Announcer
//
//  Created by Pan Ziyue on 12/1/14.
//  Copyright (c) 2014 Pan Ziyue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VariableStore : NSObject

+(VariableStore *)sharedInstance;

@property BOOL useWebView;

@end
