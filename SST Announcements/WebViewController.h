//
//  WebViewController.h
//  SST Announcements
//
//  Created by Pan Ziyue on 27/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTCoreText.h"
#import "NJKWebViewProgress.h"

@interface WebViewController : UIViewController <DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, NJKWebViewProgressDelegate, UIWebViewDelegate>
{
    IBOutlet DTAttributedTextView *textView;
    IBOutlet UIWebView *webView;
}

@property (strong, nonatomic) IBOutlet DTAttributedTextView *textView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *receivedURL;
@property (nonatomic) NSString *actualURL;

@end
