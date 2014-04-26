//
//  MBHomeViewController.m
//  GoGoGithub
//
//  Created by iC on 4/24/14.
//  Copyright (c) 2014 Michael Babiy. All rights reserved.
//

#import "MBHomeViewController.h"
#import "MBGithubOAuthClient.h"

@interface MBHomeViewController ()

- (IBAction)loginButtonSelected:(id)sender;
- (IBAction)showTokenButtonSelected:(id)sender;

@end

@implementation MBHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action Methods

- (IBAction)loginButtonSelected:(id)sender
{
    [[MBGithubOAuthClient sharedClient]oauthRequestWithParameters:@{ @"client_id" : kGithubClientID, @"scope" : @"email,user" }];
}

- (IBAction)showTokenButtonSelected:(id)sender
{
    NSLog(@"%@", [[MBGithubOAuthClient sharedClient]accessToken]);
}

@end