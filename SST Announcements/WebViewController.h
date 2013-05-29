//
//  WebViewController.h
//  SST Announcements
//
//  Created by Pan Ziyue on 27/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSEntry.h"

@class RSSEntry;

@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

@property (nonatomic) NSURL *url1;

-(IBAction)actionSheet:(id)sender;

@end
