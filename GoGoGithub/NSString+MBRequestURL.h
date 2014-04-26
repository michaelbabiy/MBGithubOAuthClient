//
//  NSString+MBRequestURL.h
//  GoGoGithub
//
//  Created by iC on 4/25/14.
//  Copyright (c) 2014 Michael Babiy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MBGithubOAuthClientCompletionHandler)(BOOL success, NSError *error);

typedef enum {
    kMBSaveOptionUserDefaults,
    kMBSaveOptionKeychain
} kMBSaveOption;

@import ObjectiveC;

// OAuth
static NSString * const kGithubClientID = @"7aa1fb9eea938a7509fb";
static NSString * const kGithubClientSecret = @"d64c182d9797b11c91126a3ae2ca4fe8e83bb68c";

static NSString * const kOAuthBaseURLString = @"https://github.com/login/oauth/";
static NSString * const kOAuthAuthorizeComponent = @"authorize";
static NSString * const kOAuthAccessTokenComponent = @"access_token";

// Requests

@interface NSString (MBRequestURL)

- (NSString *)temporaryCodeFromCallbackURL:(NSURL *)callbackURL;

- (void)saveOAuthToken:(NSString *)token options:(kMBSaveOption)option completionHandler:(MBGithubOAuthClientCompletionHandler)completionHandler;

- (NSString *)oauthRequestWithStringComponent:(NSString *)component parameters:(NSDictionary *)parameters;
- (NSString *)requestURLWithStringComponent:(NSString *)component parameters:(NSDictionary *)parameters;

@property (strong, nonatomic) NSString *temporaryCode;

@end
