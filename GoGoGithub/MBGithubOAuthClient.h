//
//  MBGithubOAuthClient.h
//  GoGoGithub
//
//  Created by iC on 4/25/14.
//  Copyright (c) 2014 Michael Babiy. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kGithubClientID = @"7aa1fb9eea938a7509fb";
static NSString * const kGithubClientSecret = @"d64c182d9797b11c91126a3ae2ca4fe8e83bb68c";

static NSString * const kOAuthAuthorizeComponent = @"authorize";
static NSString * const kOAuthAccessTokenComponent = @"access_token";

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
