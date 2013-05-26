//
//  GDataXMLElement-Extras.m
//  SST Announcements
//
//  Created by Pan Ziyue on 26/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "GDataXMLElement-Extras.h"

@implementation GDataXMLElement(Extras)

- (GDataXMLElement *)elementForChild:(NSString *)childName {
    NSArray *children = [self elementsForName:childName];
    if (children.count > 0) {
        GDataXMLElement *childElement = (GDataXMLElement *) [children objectAtIndex:0];
        return childElement;
    } else return nil;
}

- (NSString *)valueForChild:(NSString *)childName {
    return [[self elementForChild:childName] stringValue];
}

@end