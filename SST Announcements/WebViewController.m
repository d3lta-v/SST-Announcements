//
//  WebViewController.m
//  SST Announcements
//
//  Created by Pan Ziyue on 27/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "WebViewController.h"
#import "SVProgressHUD.h"
#import "TUSafariActivity.h"

@interface WebViewController ()

@end

@implementation WebViewController

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code] != NSURLErrorCancelled)
    {
        [SVProgressHUD dismiss];
        NSLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"Loading Failed!"];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    //Set title text attributes
    CGRect frame = CGRectMake(0, 0, 400, 44);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:49.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0];
    label.text = self.navigationItem.title;
    [label setShadowColor:[UIColor whiteColor]];
    [label setShadowOffset:CGSizeMake(0, -0.5)];
    self.navigationItem.titleView = label;
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}

//This is actually an UIActivityView
-(IBAction)actionSheet:(id)sender
{
    TUSafariActivity *activity = [[TUSafariActivity alloc] init];
    UIActivityViewController *actViewCtrl=[[UIActivityViewController alloc]initWithActivityItems:@[url] applicationActivities:@[activity]];
    [self presentViewController:actViewCtrl animated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

NSURL *url;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title=@"Article";
    NSURL *myURL = [NSURL URLWithString: [self.url stringByAddingPercentEscapesUsingEncoding:
                                          NSUTF8StringEncoding]];
    url=myURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL];
    [self.webView loadRequest:request]; //Load URL
    self.navigationController.navigationBar.topItem.title = @"Back";
    [[UIBarButtonItem appearance] setTintColor:[UIColor grayColor]];
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    UISwipeGestureRecognizer *mSwipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goToPrevious:)];
    
    [mSwipeUpRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    
    [[self view] addGestureRecognizer:mSwipeUpRecognizer];
}

-(void)goToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
