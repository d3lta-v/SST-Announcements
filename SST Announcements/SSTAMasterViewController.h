//
//  SSTAMasterViewController.h
//  SST Announcements
//
//  Created by Pan Ziyue on 26/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSTAMasterViewController : UITableViewController {
    NSMutableArray *_allEntries;
    NSOperationQueue *_queue;
    NSArray *_feeds;
}

@property (retain) NSMutableArray *allEntries;
@property (retain) NSOperationQueue *queue;
@property (retain) NSArray *feeds;

@end
