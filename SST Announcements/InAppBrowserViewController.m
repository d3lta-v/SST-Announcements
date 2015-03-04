//
//  InAppBrowserViewController.m
//  SST Announcer
//
//  Created by Pan Ziyue on 2/10/14.
//  Copyright (c) 2014 Pan Ziyue. All rights reserved.
//

#import "InAppBrowserViewController.h"
#import "NJKWebViewProgressView.h"
#import "TUSafariActivity.h"
#import "MRProgress.h"

@interface InAppBrowserViewController ()
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    NSArray *toolbarItems;
    
    bool stopBool; //stop means true, refresh means false
}

@end

@implementation InAppBrowserViewController

@synthesize urlString;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // Initialize NJKWebViewProgress
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _mainWebView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.5f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    
    // Start loading
    [_mainWebView loadRequest:[NSURLRequest requestWithURL:self.urlString]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO];
    toolbarItems = [NSArray arrayWithObjects:_flexSpace1,_backButton,_fixedSpace2,_forwardButton,_fixedSpace3,_refreshButton,_fixedSpace4,_exportButton,_flexSpace5, nil];
    [self setToolbarItems:toolbarItems animated:NO];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_progressView removeFromSuperview];
}

-(IBAction)exitNavigationVC:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goBack:(id)sender {
    [_mainWebView goBack];
}

- (IBAction)goForward:(id)sender {
    [_mainWebView goForward];
}

- (IBAction)exportAction:(id)sender {
    TUSafariActivity *activity = [[TUSafariActivity alloc] init];
    UIActivityViewController *actViewCtrl=[[UIActivityViewController alloc]initWithActivityItems:@[urlString] applicationActivities:@[activity]];
    [self presentViewController:actViewCtrl animated:YES completion:nil];
}

- (IBAction)refreshOrStop:(id)sender {
    if (stopBool) {
        [_mainWebView stopLoading];
    } else {
        [_mainWebView reload];
    }
}

-(void)refreshAction
{
    [_mainWebView reload];
}

-(void)stopAction
{
    [_mainWebView stopLoading];
}

#pragma mark - UIWebViewDelegate
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (error.code!=-999) {
        [MRProgressOverlayView showOverlayAddedTo:self.tabBarController.view title:@"Error Loading!" mode:MRProgressOverlayViewModeCross animated:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    
    if (progress<1.0f) {
        UIBarButtonItem *bttn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopAction)];
        _refreshButton = bttn;
        stopBool = true;
    }
    else if (progress==1.0f) { // finished loading
        UIBarButtonItem *bttn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
        _refreshButton = bttn;
        stopBool = false;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    
    self.navigationItem.title = [_mainWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [_backButton setEnabled:[_mainWebView canGoBack]];
    [_forwardButton setEnabled:[_mainWebView canGoForward]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
