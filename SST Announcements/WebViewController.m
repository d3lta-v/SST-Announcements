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
#import "DTCoreText.h"
#import "SIMUXCRParser.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize textView;

//This is actually an UIActivityView
-(IBAction)actionSheet:(id)sender
{
    TUSafariActivity *activity = [[TUSafariActivity alloc] init];
    UIActivityViewController *actViewCtrl=[[UIActivityViewController alloc]initWithActivityItems:@[[[NSURL alloc]initWithString:url]] applicationActivities:@[activity]]; //We need NSURL alloc initwithstring since we are trying to share a URL here. If it's not a URL I don't think TUSafariActivity would work either
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

NSString *url;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
    url=self.receivedURL;
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //Here comes the SIMUXCR and the DTHTMLAttributedString!
        SIMUXCRParser *simuxParser = [[SIMUXCRParser alloc]init];
        NSMutableArray *crOptimised = [simuxParser convertHTML:self.receivedURL]; //This will return some HTML which we are gonna parse with DTCoreText
        
        //Get the title and descriptions
        NSString *title = [crOptimised objectAtIndex:0];
        NSString *description = [crOptimised objectAtIndex:1];
        
        NSData *htmlData=[description dataUsingEncoding:NSUTF8StringEncoding];
        // Custom options for the builder (currently customising font family and font sizes)
        NSDictionary *builderOptions = @{
                                            DTDefaultFontFamily: @"Helvetica Neue",
                                            DTDefaultFontSize: @"16.5px",
                                            DTDefaultLineHeightMultiplier: @"1.3",
                                            DTDefaultLinkColor: @"#146FDF",
                                            DTDefaultLinkDecoration: @""
                                         };
        DTHTMLAttributedStringBuilder *stringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:htmlData options:builderOptions documentAttributes:nil];
        self.textView.shouldDrawImages = YES;
        self.textView.attributedString = [stringBuilder generatedAttributedString];
        self.textView.contentInset = UIEdgeInsetsMake(85, 15, 21, 15); //Using insets to make the article look better
        
        // Assign our delegate, this is required to handle link events
        self.textView.textDelegate = self;
        
        self.title=title;
    });
}

#pragma mark - DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame
{
    //DTLinkButton is for the links
    DTLinkButton *linkButton = [[DTLinkButton alloc] initWithFrame:frame];
    
    linkButton.URL = url;
    [linkButton addTarget:self
                   action:@selector(linkPushed:)
         forControlEvents:UIControlEventTouchUpInside];
    
    return linkButton;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame
{
	if ([attachment isKindOfClass:[DTImageTextAttachment class]])
	{
		// if the attachment has a hyperlinkURL then this is currently ignored
		DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
		imageView.delegate = self;
		
		// sets the image if there is one
		imageView.image = [(DTImageTextAttachment *)attachment image];
		
		// url for deferred loading
		imageView.url = attachment.contentURL;
		
		// if there is a hyperlink then add a link button on top of this image
		if (attachment.hyperLinkURL)
		{
			// NOTE: this is a hack, you probably want to use your own image view and touch handling
			// also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
			imageView.userInteractionEnabled = YES;
			
			DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:imageView.bounds];
			button.URL = attachment.hyperLinkURL;
			button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
			button.GUID = attachment.hyperLinkGUID;
			
			// use normal push action for opening URL
			[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
			
			[imageView addSubview:button];
		}
		
		return imageView;
	}
	else if ([attachment isKindOfClass:[DTIframeTextAttachment class]])
	{
		DTWebVideoView *videoView = [[DTWebVideoView alloc] initWithFrame:frame];
		videoView.attachment = attachment;
		
		return videoView;
	}
	else if ([attachment isKindOfClass:[DTObjectTextAttachment class]])
	{
		// somecolorparameter has a HTML color
		NSString *colorName = [attachment.attributes objectForKey:@"somecolorparameter"];
		UIColor *someColor = DTColorCreateWithHTMLName(colorName);
		
		UIView *someView = [[UIView alloc] initWithFrame:frame];
		someView.backgroundColor = someColor;
		someView.layer.borderWidth = 1;
		someView.layer.borderColor = [UIColor blackColor].CGColor;
		
		someView.accessibilityLabel = colorName;
		someView.isAccessibilityElement = YES;
		
		return someView;
	}
	
	return nil;
}

#pragma mark DTLazyImageViewDelegate

- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
	NSURL *url = lazyImageView.url;
	CGSize imageSize = size;

    CGSize screensize = CGSizeMake(280, 1136);
    
    //Autoresize if width of picture is bigger than width of the screen
    if (size.width > screensize.width) {
        float ratio = screensize.width/size.width;
        imageSize.width = size.width * ratio;
        imageSize.height = size.height *ratio;
    }
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
	
	BOOL didUpdate = NO;
	
	// update all attachments that matchin this URL (possibly multiple images with same size)
	for (DTTextAttachment *oneAttachment in [self.textView.attributedTextContentView.layoutFrame textAttachmentsWithPredicate:pred])
	{
		// update attachments that have no original size, that also sets the display size
		if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
		{
			oneAttachment.originalSize = imageSize;
			
			didUpdate = YES;
		}
	}
	
	if (didUpdate)
	{
		// layout might have changed due to image sizes
		[self.textView relayoutText];
	}
}

#pragma mark Actions

- (void)linkPushed:(DTLinkButton *)button
{
	NSURL *URL = button.URL;
	
	if ([[UIApplication sharedApplication] canOpenURL:[URL absoluteURL]])
	{
		[[UIApplication sharedApplication] openURL:[URL absoluteURL]];
	}
	else
	{
		if (![URL host] && ![URL path])
		{
			// possibly a local anchor link
			NSString *fragment = [URL fragment];
			
			if (fragment)
			{
				[self.textView scrollToAnchorNamed:fragment animated:NO];
			}
		}
	}
}

//Function for swipeRightRecognizer
-(void)goToPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    //NSLog(@"%@", self.navigationController.topViewController);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
