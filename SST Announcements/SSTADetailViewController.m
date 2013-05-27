//
//  SSTADetailViewController.m
//  SST Announcements
//
//  Created by Pan Ziyue on 26/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "SSTADetailViewController.h"
#import "RSSEntry.h"

@interface SSTADetailViewController ()

@end

@implementation SSTADetailViewController

@synthesize webView;
@synthesize entry=_entry;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    /*self.title = @"Details";
    NSURL *url = [NSURL URLWithString:_entry.articleUrl];
    NSLog(@"%@", [url absoluteString]);*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
