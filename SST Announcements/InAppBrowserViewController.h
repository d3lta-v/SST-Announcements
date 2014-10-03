//
//  InAppBrowserViewController.h
//  SST Announcer
//
//  Created by Pan Ziyue on 2/10/14.
//  Copyright (c) 2014 Pan Ziyue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NJKWebViewProgress.h"

@interface InAppBrowserViewController : UIViewController <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *mainWebView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *exportButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *flexSpace1;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixedSpace2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixedSpace3;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fixedSpace4;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *flexSpace5;

@property (copy, nonatomic) NSURL *urlString;

-(IBAction)exitNavigationVC:(id)sender;

- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;
- (IBAction)exportAction:(id)sender;
- (IBAction)refreshOrStop:(id)sender;

@end
