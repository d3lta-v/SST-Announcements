//
//  SIMUXParser.m
//  XMLSinglePostParser
//
//  Created by Pan Ziyue on 14/9/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "SIMUXCRParser.h"
#import "SVProgressHUD.h"

@implementation SIMUXCRParser {
    NSXMLParser *parser;
    
    NSMutableArray *feeds; //Main feeds array
    
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *description;
    NSString *description2;
    NSString *element;
    
    NSArray *searchResults;
}

//This is the main function of the SIMUXCR, built on the ClearRead HTML Parser
-(NSMutableArray*)convertHTML:(NSString*)HTMLString
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    feeds = [[NSMutableArray alloc] init];
    
    NSString *firstPart=@"http://api.thequeue.org/v1/clear?url=";
    NSString *secondPart=@"&format=xml";
    NSString *combined=[firstPart stringByAppendingString:[HTMLString stringByAppendingString:secondPart]];
    
    NSURL *url = [NSURL URLWithString:combined];
    parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:self];
    [parser setShouldResolveExternalEntities:NO];
    [parser parse];
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    [returnArray addObject:title];
    [returnArray addObject:description];
    
    return returnArray; //Return a combined string
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict //Parser didStartElement function
{
    element = elementName;
    
    if ([element isEqualToString:@"item"])
    {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        description= [[NSMutableString alloc] init];
        
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName //Parser didEndElement function
{
    if ([elementName isEqualToString:@"item"])
    {
        [item setObject:title forKey:@"title"];
        [item setObject:description forKey:@"link"];
        
        [feeds addObject:[item copy]];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string //Finding elements...
{
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"description"]) {
        [description appendString:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser //Basically, did finish loading the whole feed
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [SVProgressHUD dismiss];
}

@end
