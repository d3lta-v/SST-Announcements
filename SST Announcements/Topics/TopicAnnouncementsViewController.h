//
//  TopicAnnouncementsViewController.h
//  SST Announcements
//
//  Created by Pan Ziyue on 28/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WebViewController;

@interface TopicAnnouncementsViewController : UITableViewController {
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