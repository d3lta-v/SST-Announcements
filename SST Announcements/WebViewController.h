//
//  WebViewController.h
//  SST Announcements
//
//  Created by Pan Ziyue on 27/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate>

@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
