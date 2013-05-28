//
//  SSTAMasterViewController.m
//  SST Announcements
//
//  Created by Pan Ziyue on 26/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "SSTAMasterViewController.h"
#import "RSSEntry.h"
#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"
#import "GDataXMLElement-Extras.h"
#import "NSDate+InternetDateTime.h"
#import "NSArray+Extras.h"
#import "SVProgressHUD.h"
//*****************************************************
#import "WebViewController.h"
//*****************************************************

@interface SSTAMasterViewController ()

@end

@implementation SSTAMasterViewController

@synthesize allEntries=_allEntries;
@synthesize feeds = _feeds;
@synthesize queue = _queue;
//****************************************************
@synthesize webViewController=_webViewController;
//****************************************************

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

#pragma mark Refresh!
- (void)refresh
{
    for (NSString *feed in _feeds)
    {
        NSURL *url = [NSURL URLWithString:feed];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [_queue addOperation:request];
    }
}

/*#pragma mark View WILL APPEAR
-(void)viewWillAppear:(BOOL)animated
{
    self.title = @"SST Announcements";
    self.allEntries = [NSMutableArray array];
    self.queue = [[NSOperationQueue alloc] init];
    self.feeds = [NSArray arrayWithObjects:@"http://sst-students2013.blogspot.com/feeds/posts/default",nil];
    [self refresh];
    [SVProgressHUD showWithStatus:@"Loading feeds..." maskType:SVProgressHUDMaskTypeGradient];
}*/

#pragma mark View DID LOAD
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"SST Announcements";
    self.allEntries = [NSMutableArray array];
    self.queue = [[NSOperationQueue alloc] init];
    self.feeds = [NSArray arrayWithObjects:@"http://sst-students2013.blogspot.com/feeds/posts/default",nil];
    [self refresh];
    [SVProgressHUD showWithStatus:@"Loading feeds..." maskType:SVProgressHUDMaskTypeGradient];
}

#pragma mark Request FINISHED
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    [_queue addOperationWithBlock:^
    {
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[request responseData]
                                                               options:0 error:&error];
        if (doc == nil) {
            NSLog(@"Failed to parse %@", request.url);
        } else {
            
            NSMutableArray *entries = [NSMutableArray array];
            [self parseFeed:doc.rootElement entries:entries];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^
            {
                
                for (RSSEntry *entry in entries)
                {
                    //int insertIdx=0;
                    int insertIdx = [_allEntries indexForInsertingObject:entry sortedUsingBlock:^(id a, id b)
                    {
                        RSSEntry *entry1 = (RSSEntry *) a;
                        RSSEntry *entry2 = (RSSEntry *) b;
                        return [entry1.articleDate compare:entry2.articleDate];
                    }];
                    
                    [_allEntries insertObject:entry atIndex:insertIdx];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationRight];
                }
                
            }];
            
        }        
    }];
    [SVProgressHUD dismiss];
}

#pragma mark Request FAILED
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", error);
    [SVProgressHUD dismiss];
}

#pragma mark Main feed PARSER
- (void)parseFeed:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries
{
    if ([rootElement.name compare:@"rss"] == NSOrderedSame)
    {
        [self parseRss:rootElement entries:entries];
    }
    else if ([rootElement.name compare:@"feed"] == NSOrderedSame)
    {
        [self parseAtom:rootElement entries:entries];
    }
    else
    {
        NSLog(@"Unsupported root element: %@", rootElement.name);
    }
}

#pragma mark Parse RSS
- (void)parseRss:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries
{
    
    NSArray *channels = [rootElement elementsForName:@"channel"];
    for (GDataXMLElement *channel in channels)
    {
        NSString *blogTitle = [channel valueForChild:@"title"];
        
        NSArray *items = [channel elementsForName:@"item"];
        for (GDataXMLElement *item in items)
        {
            
            NSString *articleTitle = [item valueForChild:@"title"];
            NSString *articleUrl = [item valueForChild:@"link"];
            NSString *articleDateString = [item valueForChild:@"pubDate"];
            NSDate *articleDate = [NSDate dateFromInternetDateTimeString:articleDateString formatHint:DateFormatHintRFC822];
            
            RSSEntry *entry = [[RSSEntry alloc] initWithBlogTitle:blogTitle
                                                      articleTitle:articleTitle
                                                        articleUrl:articleUrl
                                                       articleDate:articleDate];
            [entries addObject:entry];
            
        }
    }
    
}

#pragma mark Parse ATOM
- (void)parseAtom:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries {
    
    NSString *blogTitle = [rootElement valueForChild:@"title"];
    
    NSArray *items = [rootElement elementsForName:@"entry"];
    for (GDataXMLElement *item in items) {
        
        NSString *articleTitle = [item valueForChild:@"title"];
        NSString *articleUrl = nil;
        NSArray *links = [item elementsForName:@"link"];
        for(GDataXMLElement *link in links) {
            NSString *rel = [[link attributeForName:@"rel"] stringValue];
            NSString *type = [[link attributeForName:@"type"] stringValue];
            if ([rel compare:@"alternate"] == NSOrderedSame &&
                [type compare:@"text/html"] == NSOrderedSame)
            {
                articleUrl = [[link attributeForName:@"href"] stringValue];
            }
        }
        
        NSString *articleDateString = [item valueForChild:@"updated"];
        NSDate *articleDate = [NSDate dateFromInternetDateTimeString:articleDateString formatHint:DateFormatHintRFC3339];
        if ([articleTitle isEqual:@""])
        {
            articleTitle=@"<No Title>";
            RSSEntry *entry = [[RSSEntry alloc] initWithBlogTitle:blogTitle
                                                     articleTitle:articleTitle
                                                       articleUrl:articleUrl
                                                      articleDate:articleDate];
            [entries addObject:entry];
        }
        else
        {
            RSSEntry *entry = [[RSSEntry alloc] initWithBlogTitle:blogTitle
                                                     articleTitle:articleTitle
                                                       articleUrl:articleUrl
                                                      articleDate:articleDate];
            [entries addObject:entry];
        }
    }      
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_allEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    RSSEntry *entry = [_allEntries objectAtIndex:indexPath.row];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString *articleDateString = [dateFormatter stringFromDate:entry.articleDate];
    
    cell.textLabel.text = entry.articleTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", articleDateString, entry.blogTitle];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

//*****************************************************
NSURL *url=nil; //Do NOT delete!!! (class limited global variable)
#pragma mark Did select ROW AT INDEX PATH
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_webViewController == nil) {
        self.webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]];
    }
    RSSEntry *entry = [_allEntries objectAtIndex:indexPath.row];
    //_webViewController.entry = entry;
    url = [NSURL URLWithString:entry.articleUrl];
    [self performSegueWithIdentifier:@"MasterToDetail" sender:nil];
}
//*****************************************************

#pragma mark Prepare for Segue!
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MasterToDetail"]) {
        WebViewController *controller = (WebViewController *)segue.destinationViewController;
        controller.url1=url;
    }
}

@end
