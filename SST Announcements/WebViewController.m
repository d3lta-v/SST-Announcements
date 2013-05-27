//
//  WebViewController.m
//  SST Announcements
//
//  Created by Pan Ziyue on 27/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "WebViewController.h"
#import "RSSEntry.h"

@class RSSEntry;

@interface WebViewController () {
    UIWebView *_webView;
    RSSEntry *_entry;
}

@property (retain) IBOutlet UIWebView *webView;
@property (retain) RSSEntry *entry;

@end

@implementation WebViewController

@synthesize webView = _webView;
@synthesize entry = _entry;
@synthesize url1;

- (void)viewWillAppear:(BOOL)animated
{
    [_webView loadRequest:[NSURLRequest requestWithURL:url1]];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title=@"Article";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
