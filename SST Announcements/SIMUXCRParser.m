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
    NSMutableArray *returnArray;
    
    NSArray *searchResults;
    
    BOOL error;
}

@synthesize useWeb;

//This is the main function of the SIMUXCR, built on the ClearRead HTML Parser
-(NSMutableArray*)convertHTML:(NSString*)HTMLString
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    feeds = [[NSMutableArray alloc] init];
    
    NSString *firstPart;
    NSString *secondPart;
    NSString *combined;
    
    // This section automatically detects my new self hosted version of the ClearRead API, and if the HTML response code is 200, use the API.
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.statixind.net/v1/clear.php/"]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:30.0];
    NSHTTPURLResponse *response = nil;
    NSError *errorResponse;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&errorResponse];
    if (!responseData||errorResponse) {
        responseData=nil;
        error=YES;
    }
    else if ([response statusCode]!=200) {
        firstPart=@"https://simux.org/v1/clear?url=";
        secondPart=@"&format=xml";
    }
    else {
        firstPart=@"https://api.statixind.net/v1/clear?url=";
        secondPart=@"&format=xml";
        NSLog(@"%li", (long)[response statusCode]);
    }
    
    if ([HTMLString isEqual: [NSNull null]]) {
        error=YES;
    }
    else {
        if (firstPart!=nil || secondPart!=nil) {
            combined=[firstPart stringByAppendingString:[HTMLString stringByAppendingString:secondPart]];
            NSURL *url = [NSURL URLWithString:combined];
            parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
            [parser setDelegate:self];
            [parser setShouldResolveExternalEntities:NO];
            [parser parse];
            returnArray = [[NSMutableArray alloc]init];
        } else {
            error=YES;
        }
    }
    
    if (error||!title) {
        [SVProgressHUD showErrorWithStatus:@"Please check your Internet connection"];
        [returnArray addObject:@"Error"];
        [returnArray addObject:@"<p align=\"center\">There was a problem loading this article, please check your Internet connection, or try opening the URL in Safari via the share button above.</p>"];
    } else {
        [returnArray addObject:title];
        [returnArray addObject:description];
    }
    
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
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError //Errors?
{
    error++;
    [SVProgressHUD dismiss];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [SVProgressHUD showErrorWithStatus:@"Check your Internet Connection"];
}

@end
