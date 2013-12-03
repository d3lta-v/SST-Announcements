//
//  DetailViewController.m
//  SST Announcer
//
//  Created by Pan Ziyue on 21/10/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "DetailViewController.h"

#import "WebViewController.h"
#import "RefreshControl.h"
#import "SVProgressHUD.h"

@interface DetailViewController () {
    NSXMLParser *parser;
    
    NSMutableArray *feeds; //Main feeds array
    
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *date;
    NSMutableString *author;
    NSString *element;
    
    NSArray *searchResults;
    
    NSString *category;
}
@end

@implementation DetailViewController

-(NSInteger)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    
    NSInteger year = [components year];
    return year;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.receivedURL;
    
    //Init refresh controls
    RefreshControl *refreshControl=[[RefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl=refreshControl;
    
    //Hide search bar by default
    self.tableView.contentOffset = CGPointMake(0.0, 44.0);
    
    if ([self.navigationController.viewControllers count]) {
        //Feed parsing.
        [SVProgressHUD showWithStatus:@"Loading feeds..." maskType:SVProgressHUDMaskTypeBlack];
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            feeds = [[NSMutableArray alloc] init];
            
            if ([self.receivedURL isEqualToString:@"ADMT"])
                category=@"ADMT";
            else if ([self.receivedURL isEqualToString:@"Announcements"])
                category=@"announcement";
            else if ([self.receivedURL isEqualToString:@"Assessments"])
                category=@"assessment";
            else if ([self.receivedURL isEqualToString:@"Competition"])
                category=@"competition";
            else if ([self.receivedURL isEqualToString:@"Digital Citizenship"])
                category=@"digital%20citizenship";
            else if ([self.receivedURL isEqualToString:@"Email"])
                category=@"email";
            else if ([self.receivedURL isEqualToString:@"GSO"])
                category=@"GSO";
            else if ([self.receivedURL isEqualToString:@"ICT"])
                category=@"ICT";
            else if ([self.receivedURL isEqualToString:@"Info Hub"])
                category=@"InfoHub";
            else if ([self.receivedURL isEqualToString:@"IT"])
                category=@"IT";
            else if ([self.receivedURL isEqualToString:@"Mathematics"])
                category=@"Mathematics";
            else if ([self.receivedURL isEqualToString:@"Official Opening"])
                category=@"Official%20Opening";
            else if ([self.receivedURL isEqualToString:@"Parents Engagement"])
                category=@"Parents%20Engagement";
            else if ([self.receivedURL isEqualToString:@"Performance"])
                category=@"Performance";
            else if ([self.receivedURL isEqualToString:@"Photography"])
                category=@"Photography";
            else if ([self.receivedURL isEqualToString:@"Pre-School Engagement Programme"])
                category=@"Pre-School%20Engagement%20Programme";
            else if ([self.receivedURL isEqualToString:@"Principal's Letter"])
                category=@"Principal's%20Letter";
            else if ([self.receivedURL isEqualToString:@"Sec 1 Registration"])
                category=@"Sec%201%20Registration";
            else if ([self.receivedURL isEqualToString:@"School Reopen"])
                category=@"School%20Reopen";
            else if ([self.receivedURL isEqualToString:@"Service Learning"])
                category=@"service%20learning";
            else if ([self.receivedURL isEqualToString:@"Student Affairs"])
                category=@"Student%20Affairs";
            else if ([self.receivedURL isEqualToString:@"Student Leadership"])
                category=@"Student%20Leadership";
            else if ([self.receivedURL isEqualToString:@"Support"])
                category=@"support";
            else if ([self.receivedURL isEqualToString:@"Timetable"])
                category=@"TimeTable";
            else if ([self.receivedURL isEqualToString:@"Workshop"])
                category=@"workshop";
            
            //Automatically updating the year of the URL
            NSString *combined=[NSString stringWithFormat:@"%@%@%s", @"http://studentsblog.sst.edu.sg/feeds/posts/default/-/", category,"?alt=rss"];
            
            NSURL *url = [NSURL URLWithString:combined];
            parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
            [parser setDelegate:self];
            [parser setShouldResolveExternalEntities:NO];
            [parser parse];
        });
    }
}

-(void)refresh:(id)sender
{
    //Async refreshing
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self.tableView reloadData];
        feeds = [[NSMutableArray alloc] init];
        NSString *combined=[NSString stringWithFormat:@"%@%@%@%@%s", @"http://sst-students", [NSString stringWithFormat:@"%ld",(long)[self date]], @".blogspot.sg/feeds/posts/default/-/", category,"?alt=rss"];
        
        NSURL *url = [NSURL URLWithString:combined];
        parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        [parser setDelegate:self];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse];
        [(UIRefreshControl *)sender endRefreshing];
    });
    [SVProgressHUD dismiss];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    //Checking for if title contains text and then put them in the array for search listings
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF.title contains[cd] %@",
                                    searchText];
    
    searchResults = [feeds filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; //No of sections, leave as 1
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //If it's the seach display controller's table
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [searchResults count];
    }
    else
    {
        return [feeds count];
    }
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
 cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] objectForKey: @"title"];
 return cell;
 }
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"title"];
    } else {
        if (feeds.count!=0) {
            cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] objectForKey:@"title"];
            NSString *detailText = [NSString stringWithFormat:@"%@ %@", [[feeds objectAtIndex:indexPath.row] objectForKey:@"date"], [[feeds objectAtIndex:indexPath.row]objectForKey:@"author"]];
            cell.detailTextLabel.text = detailText;
        }
    }
    
    return cell;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict //Parser didStartElement function
{
    element = elementName;
    
    if ([element isEqualToString:@"item"])
    {
        
        item    = [[NSMutableDictionary alloc] init];
        title   = [[NSMutableString alloc] init];
        link    = [[NSMutableString alloc] init];
        date    = [[NSMutableString alloc] init];
        author  = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName //Parser didEndElement function
{
    if ([elementName isEqualToString:@"item"])
    {
        
        [item setObject:title forKey:@"title"];
        [item setObject:link forKey:@"link"];
        [item setObject:date forKey:@"date"];
        [item setObject:author forKey:@"author"];
        
        [feeds addObject:[item copy]];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string //Finding elements...
{
    
    if ([element isEqualToString:@"title"]) {
        [title appendString:string];
    } else if ([element isEqualToString:@"link"]) {
        [link appendString:string];
    } else if ([element isEqualToString:@"pubDate"]) {
        [date appendString:string];
        //This will remove the last string in the date (:00 +0000)
        date = [[date stringByReplacingOccurrencesOfString:@":00 +0000"withString:@""]mutableCopy];
    }
    else if ([element isEqualToString:@"author"]) {
        [author appendString:string];
        author = [[author stringByReplacingOccurrencesOfString:@"noreply@blogger.com " withString:@""]mutableCopy];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser //Basically, did finish loading the whole feed
{
    [self.tableView reloadData]; //Reload table view data
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [SVProgressHUD dismiss];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError //Errors?
{
    [SVProgressHUD dismiss];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [SVProgressHUD showErrorWithStatus:@"Check your Internet Connection"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"detailToWeb" sender:self]; //Perform the segue
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //Deselect the row manually
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"detailToWeb"])
    {
        NSIndexPath *indexPath;
        
        if ([self.searchDisplayController isActive])
        {
            indexPath=[self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            NSString *string = [searchResults[indexPath.row] objectForKey: @"link"];
            [[segue destinationViewController] setReceivedURL:string];
        }
        else
        {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSString *string = [feeds[indexPath.row] objectForKey: @"link"];
            [[segue destinationViewController] setReceivedURL:string];
        }
    }
}

@end