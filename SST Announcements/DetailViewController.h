//
//  DetailViewController.h
//  SST Announcer
//
//  Created by Pan Ziyue on 21/10/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UITableViewController <NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate>

@property (copy, nonatomic) NSString *receivedURL;

@end
