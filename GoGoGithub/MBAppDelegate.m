//
//  MBAppDelegate.m
//  GoGoGithub
//
//  Created by iC on 4/24/14.
//  Copyright (c) 2014 Michael Babiy. All rights reserved.
//

#import "MBAppDelegate.h"
#import "MBGithubOAuthClient.h"

@implementation MBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[MBGithubOAuthClient sharedClient]tokenRequestWithCallbackURL:url
                                                       saveOptions:kMBSaveOptionsUserDefaults
                                                        completion:^(BOOL success, NSError *error) {
                                                            
                                                            if (!error) {
                                                                // Saved to user defaults...
                                                            }
                                                            
                                                        }];
    
    return YES;
}

@end
