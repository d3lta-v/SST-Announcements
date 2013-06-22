//
//  SSTAMasterViewController.m
//  SST Announcements
//
//  Created by Pan Ziyue on 26/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//
// ***************************************************
// TableViewCell height changed to 55px
// ***************************************************

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
@synthesize searchResults;
@synthesize searchBar;
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

#pragma mark View DID LOAD
- (void)viewDidLoad
{
    [super viewDidLoad];
    //Uncomment the following line to get background colors
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.jpg"]];
    
    //Refresh controlling
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl=refreshControl;
    [refreshControl addTarget:self action:@selector(refreshFeed) forControlEvents:UIControlEventValueChanged];
    
    self.allEntries = [NSMutableArray array];
    self.queue = [[NSOperationQueue alloc] init];
    self.feeds = [NSArray arrayWithObjects:@"http://sst-students2013.blogspot.com/feeds/posts/default",nil]; //Initialise URL of FEED
    [self refresh];
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeGradient];
    
    //Initialise searchResults array as a mutable array
    self.searchResults=[NSMutableArray arrayWithCapacity:[_allEntries count]];
}

#pragma mark Request FINISHED
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    [_queue addOperationWithBlock:^
    {
        NSError *error;
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[request responseData]
                                                               options:0 error:&error];
        if (doc==nil) //Error fallback
        {
            NSLog(@"Failed to parse %@", request.url);
            [SVProgressHUD dismiss];
            [self.refreshControl endRefreshing];
            [SVProgressHUD showErrorWithStatus:@"Check your Internet Connection"]; //Show error
        }
        else
        {
            NSMutableArray *entries = [NSMutableArray array];
            [self parseFeed:doc.rootElement entries:entries];
            
	    //Main NSOperationQueue
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
                    
                    [_allEntries insertObject:entry atIndex:insertIdx]; //Insert objects AT INDEX (insertIdx)
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:insertIdx inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationFade];
                }
                [SVProgressHUD dismiss];
                [self.refreshControl endRefreshing];
            }];
        }        
    }];
}

#pragma mark Request FAILED
- (void)requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    NSLog(@"Error: %@", error); //NSLog type of error to console
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing]; //End refreshing on the refresh controller
    [SVProgressHUD showErrorWithStatus:@"Check your Internet Connection"];
}

#pragma mark Main feed PARSER
- (void)parseFeed:(GDataXMLElement *)rootElement entries:(NSMutableArray *)entries //Detects type of feed
{
    if ([rootElement.name compare:@"feed"] == NSOrderedSame)
    {
        [self parseAtom:rootElement entries:entries];
    }
    else
    {
        NSLog(@"Unsupported root element: %@", rootElement.name);
        [SVProgressHUD showErrorWithStatus:@"Unsupported feed type, please contact developer"];
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
        
        if ([articleTitle isEqual:@""]) //Check if Title==null
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

#pragma mark No. of SECTIONS IN TABLE VIEW
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

#pragma mark No. of ROWS IN SECTION
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //return [_allEntries count];
    if (tableView==self.searchDisplayController.searchResultsTableView)
    {
        return [searchResults count];
    }
    else
    {
        return [_allEntries count];
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes'
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark Filter content FOR SEARCH TXT
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.searchResults removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF.articleTitle contains[c] %@", //articleTitle caseless contains
                                    searchText];
    
    searchResults = [NSMutableArray arrayWithArray:[_allEntries filteredArrayUsingPredicate:resultPredicate]];
}

#pragma mark Cell for ROW AT INDEX PATH
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell"; //Declare Cell Indent
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier]; //Declares styling
    }
    RSSEntry *entry = [_allEntries objectAtIndex:indexPath.row]; //Makes individual entities for the entry
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    //cell config
    NSString *articleDateString = [dateFormatter stringFromDate:entry.articleDate];
    //cell.textLabel.text = entry.articleTitle;
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", articleDateString];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell.textLabel.text = [searchResults objectAtIndex:indexPath.row]; //This is where the app stopped
    }
    else
    {
        cell.textLabel.text = entry.articleTitle;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", articleDateString];
    }
    
    return cell;
}

//*****************************************************
NSURL *url=nil; //Do NOT delete!
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

-(void)refreshFeed //Refresh method
{
    [_allEntries removeAllObjects];
    [self.tableView reloadData];
    [self refresh];
}

#pragma mark Prepare for Segue!
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"MasterToDetail"]) {
        //WebViewController *controller = (WebViewController *)segue.destinationViewController;
        //controller.url1=url;
        if (sender==self.searchDisplayController.searchResultsTableView)
        {
            //NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            WebViewController *controller=(WebViewController *)segue.destinationViewController;
            controller.url1=url;
        }
        else
        {
            WebViewController *controller=(WebViewController *)segue.destinationViewController;
            controller.url1=url;
        }
    }
}

@end
