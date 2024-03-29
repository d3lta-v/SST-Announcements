//
//  TopicGSOViewController.m
//  SST Announcements
//
//  Created by Pan Ziyue on 10/7/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "TopicGSOViewController.h"
#import "WebViewController.h"
#import "SVProgressHUD.h"
#import "RefreshControl.h"

@interface TopicGSOViewController () {
    NSXMLParser *parser;
    
    NSMutableArray *feeds; //Main feeds array
    
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *date;
    NSMutableString *author;
    NSString *element;
    
    NSArray *searchResults;
}
@end

@implementation TopicGSOViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)viewDidDisappear:(BOOL)animated {
    [SVProgressHUD dismiss];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Init refresh controls
    RefreshControl *refreshControl=[[RefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl=refreshControl;
    
    //Hide search bar by default
    self.tableView.contentOffset = CGPointMake(0.0, 44.0);
    
    UISwipeGestureRecognizer *mSwipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goToPrevious:)];
    [mSwipeUpRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:mSwipeUpRecognizer];
    
    if ([self.navigationController.viewControllers count]) {
        //Feed parsing
        [SVProgressHUD showWithStatus:@"Loading feeds..."];
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            feeds = [[NSMutableArray alloc] init];
            NSURL *url = [NSURL URLWithString:@"http://sst-students2013.blogspot.sg/feeds/posts/default/-/GSO?alt=rss"];
            parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
            [parser setDelegate:self];
            [parser setShouldResolveExternalEntities:NO];
            [parser parse];
        });
    }
}

-(void)goToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refresh:(id)sender
{
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData];
        feeds = [[NSMutableArray alloc] init];
        NSURL *url = [NSURL URLWithString:@"http://sst-students2013.blogspot.sg/feeds/posts/default/-/GSO?alt=rss"];
        parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        [parser setDelegate:self];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse];
        [(UIRefreshControl *)sender endRefreshing];
    });
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
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
    
    //NSString *articleDateString = [dateFormatter stringFromDate:entry.articleDate];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [[searchResults objectAtIndex:indexPath.row] objectForKey:@"title"];
    } else {
        if (feeds.count!=0) {
            cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] objectForKey:@"title"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [[feeds objectAtIndex:indexPath.row] objectForKey:@"date"], [[feeds objectAtIndex:indexPath.row]objectForKey:@"author"]];
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
    [SVProgressHUD dismiss];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError //Errors?
{
    [SVProgressHUD dismiss];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [SVProgressHUD showErrorWithStatus:@"Check your Internet Connection"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"GSOToDetail" sender:self]; //Perform the segue
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; //Deselect the row automatically
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"EmailsToDetail"])
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