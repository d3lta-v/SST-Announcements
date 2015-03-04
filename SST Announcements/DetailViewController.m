//
//  DetailViewController.m
//  SST Announcer
//
//  Created by Pan Ziyue on 21/10/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "DetailViewController.h"

#import "WebViewController.h"
#import "MRProgress.h"

@interface DetailViewController () {
    NSXMLParser *parser;
    
    NSMutableArray *feeds; //Main feeds array
    
    NSMutableDictionary *item;
    NSMutableString *title;
    NSMutableString *link;
    NSMutableString *date;
    NSMutableString *author;
    NSMutableString *description;
    NSString *element;
    
    NSArray *searchResults;
    
    NSString *category;
    
    NSDateFormatter *dateFormatter;
}
@end

@implementation DetailViewController

-(void)viewWillAppear:(BOOL)animated {
    // Initialize date formatter
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm"];
    
    // Start parsing here
    //NSLog(@"%lu",(unsigned long)[self.navigationController.viewControllers count]);
    if ([self.navigationController.viewControllers count]==2) {
        //Feed parsing.
        [MRProgressOverlayView showOverlayAddedTo:self.tabBarController.view title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminateSmall animated:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            feeds = [[NSMutableArray alloc] init];
            
            self.receivedURL=[self.receivedURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            //Automatically updating the year of the URL
            NSString *combined=[NSString stringWithFormat:@"%@%@%s", @"http://studentsblog.sst.edu.sg/feeds/posts/default/-/", self.receivedURL,"?alt=rss"];
            
            category = self.receivedURL;
            
            NSURL *url = [NSURL URLWithString:combined];
            parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
            [parser setDelegate:self];
            [parser setShouldResolveExternalEntities:NO];
            [parser parse];
            if (!title) {
                dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                    [MRProgressOverlayView showOverlayAddedTo:self.tabBarController.view title:@"Error Loading!" mode:MRProgressOverlayViewModeCross animated:YES];
                    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                });
            }
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.receivedURL;
    
    //Init refresh controls
    UIRefreshControl *refreshControl=[[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl=refreshControl;
}

-(void)refresh:(id)sender
{
    self.tableView.userInteractionEnabled=NO;
    //Async refreshing
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        [self.tableView reloadData];
        feeds = [[NSMutableArray alloc] init];
        NSString *combined=[NSString stringWithFormat:@"%@%@%@",@"http://studentsblog.sst.edu.sg/feeds/posts/default/-/", category,@"?alt=rss"];
                
        NSURL *url = [NSURL URLWithString:combined];
        parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
        [parser setDelegate:self];
        [parser setShouldResolveExternalEntities:NO];
        [parser parse];
        
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [(UIRefreshControl *)sender endRefreshing];
            self.tableView.userInteractionEnabled=YES;
        });
    });
    [MRProgressOverlayView dismissOverlayForView:self.tabBarController.view animated:YES];
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
            if ([[[feeds objectAtIndex:indexPath.row]objectForKey:@"title"]  isEqual: @""]) {
                cell.textLabel.text = @"<No Title>";
            } else {
                cell.textLabel.text = [[feeds objectAtIndex:indexPath.row] objectForKey:@"title"];
            }
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
        description = [[NSMutableString alloc] init];
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
        [item setObject:description forKey:@"description"];
        
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
        string = [string stringByReplacingOccurrencesOfString:@":00 +0000"withString:@""];
        NSDate *newDate = [dateFormatter dateFromString:string];
        newDate = [newDate dateByAddingTimeInterval:(8*60*60)]; // 8 hours
        string = [dateFormatter stringFromDate:newDate];
        [date appendString:string];
    }
    else if ([element isEqualToString:@"author"]) {
        [author appendString:string];
        author = [[author stringByReplacingOccurrencesOfString:@"noreply@blogger.com " withString:@""]mutableCopy];
    } else if ([element isEqualToString:@"description"]) {
        [description appendString:string];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser //Basically, did finish loading the whole feed
{
    dispatch_sync(dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData]; //Reload table view data
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [MRProgressOverlayView dismissOverlayForView:self.tabBarController.view animated:YES];
    });
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError //Errors?
{
    dispatch_sync(dispatch_get_main_queue(), ^(void){
        [MRProgressOverlayView dismissOverlayForView:self.tabBarController.view animated:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [MRProgressOverlayView showOverlayAddedTo:self.tabBarController.view title:@"Error Loading!" mode:MRProgressOverlayViewModeCross animated:YES];
    });
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
            NSString *string = [NSString stringWithFormat:@"{%@}[%@]%@", [feeds[indexPath.row] objectForKey: @"title"],[feeds[indexPath.row] objectForKey:@"link"] , [feeds[indexPath.row] objectForKey: @"description"]];
            [[segue destinationViewController] setReceivedURL:string];
        }
        else
        {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSString *string = [NSString stringWithFormat:@"{%@}[%@]%@", [feeds[indexPath.row] objectForKey: @"title"],[feeds[indexPath.row] objectForKey:@"link"] , [feeds[indexPath.row] objectForKey: @"description"]];
            [[segue destinationViewController] setReceivedURL:string];
        }
    }
}

@end
