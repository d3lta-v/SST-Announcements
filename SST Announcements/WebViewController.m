//
//  WebViewController.m
//  SST Announcements
//
//  Created by Pan Ziyue on 27/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "WebViewController.h"
#import "RSSEntry.h"
#import "SVProgressHUD.h"

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
    //[SVProgressHUD showWithStatus:@"Loading..."];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus:@"Loading..."];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code] != NSURLErrorCancelled)
    {
        [SVProgressHUD dismiss];
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"Loading Failed!"];
    }
}

-(IBAction)actionSheet:(id)sender
{
    UIActionSheet *as_1 = [[UIActionSheet alloc]initWithTitle:nil delegate:nil cancelButtonTitle:@"Back" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", nil];
    [as_1 setDelegate:self]; //Learn to apply the delegate!
    [as_1 showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[UIApplication sharedApplication] openURL:url1];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
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
