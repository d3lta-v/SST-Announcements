//
//  SSTADetailViewController.h
//  SST Announcements
//
//  Created by Pan Ziyue on 26/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSSEntry;

@interface SSTADetailViewController : UIViewController
{
    UIWebView *_webView;
    RSSEntry *_entry;
}

@property (strong) IBOutlet UIWebView *webView;
@property (strong) RSSEntry *entry;

@end
