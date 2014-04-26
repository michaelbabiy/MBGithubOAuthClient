//
//  MBGithubOAuthClient.h
//  GoGoGithub
//
//  Created by iC on 4/25/14.
//  Copyright (c) 2014 Michael Babiy. All rights reserved.
//

#import <Foundation/Foundation.h>

#warning Please Enter your GitHub Client ID and Secret.
static NSString * const kGithubClientID = @"";
static NSString * const kGithubClientSecret = @"";

static NSString * const kMBAccessTokenKey = @"kMBAccessTokenKey";

typedef void(^MBGithubOAuthClientCompletionHandler)(BOOL success, NSError *error);

typedef enum {
    
    kMBSaveOptionsUserDefaults,
    kMBSaveOptionsKeychain
    
} kMBSaveOptions;

@interface MBGithubOAuthClient : NSObject

+ (instancetype)sharedClient;

- (void)oauthRequestWithParameters:(NSDictionary *)parameters;

- (void)tokenRequestWithCallbackURL:(NSURL *)url
                        saveOptions:(kMBSaveOptions)options
                         completion:(MBGithubOAuthClientCompletionHandler)completionHandler;

@property (strong, nonatomic, readonly) NSString *accessToken;

@end
