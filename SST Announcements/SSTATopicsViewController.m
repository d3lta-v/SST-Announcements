//
//  SSTATopicsViewController.m
//  SST Announcements
//
//  Created by Pan Ziyue on 28/5/13.
//  Copyright (c) 2013 Pan Ziyue. All rights reserved.
//

#import "SSTATopicsViewController.h"

@interface SSTATopicsViewController ()

@end

@implementation SSTATopicsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
