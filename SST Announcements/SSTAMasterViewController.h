//
//  SSTAMasterViewController.h
//  SST Announcements
//
//  Created by Pan Ziyue on 26/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebViewController;

@interface SSTAMasterViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *_allEntries;
    NSOperationQueue *_queue;
    NSArray *_feeds;
    
    WebViewController *_webViewController;
}

@property (retain) NSMutableArray *allEntries;
@property (retain) NSOperationQueue *queue;
@property (retain) NSArray *feeds;

@property (retain) WebViewController *webViewController;

@end
