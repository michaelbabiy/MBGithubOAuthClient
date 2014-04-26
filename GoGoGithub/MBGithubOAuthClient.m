//
//  MBGithubOAuthClient.m
//  GoGoGithub
//
//  Created by iC on 4/25/14.
//  Copyright (c) 2014 Michael Babiy. All rights reserved.
//

#import "MBGithubOAuthClient.h"

static NSString * const kOAuthBaseURLString = @"https://github.com/login/oauth/";

static NSString * const kMBRegexPattern = @"access_token=([^&]+)";

@interface MBGithubOAuthClient ()

@end

@implementation MBGithubOAuthClient

+ (instancetype)sharedClient
{
    static MBGithubOAuthClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedClient = [[MBGithubOAuthClient alloc]init];
        
    });
    
    return sharedClient;
}

- (void)oauthRequestWithParameters:(NSDictionary *)parameters
{
    __weak typeof(self) weakSelf = self;
    __block NSString *parametersString = nil;
    
    if (parameters) {
        
        [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            if ([obj isKindOfClass:[NSString class]]) {
                
                parametersString = [[NSString alloc]init];
                NSString *parameter = (NSString *)obj;
                parametersString = [parametersString stringByAppendingString:parameter];
                
            } else {
                
                [weakSelf throwException];
                
            }
        }];
        
    }
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@?client_id=%@&scope=%@",
                                                                    kOAuthBaseURLString,
                                                                    kOAuthAuthorizeComponent,
                                                                    kGithubClientID,
                                                                    parametersString]]];
}

- (void)tokenRequestWithCallbackURL:(NSURL *)url saveOptions:(kMBSaveOptions)options completion:(MBGithubOAuthClientCompletionHandler)completionHandler
{
    NSString *requestString = [NSString stringWithFormat:@"%@%@?client_id=%@&client_secret=%@&code=%@",
                               kOAuthBaseURLString,
                               kOAuthAccessTokenComponent,
                               kGithubClientID,
                               kGithubClientSecret,
                               [self temporaryCodeFromCallbackURL:url]];
    
    __weak typeof(self) weakSelf = self;
    __block NSString *accessTokenData = nil;
    
    NSURLSessionConfiguration *sessionConficuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConficuration];
    
    [[session dataTaskWithURL:[NSURL URLWithString:requestString]
            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (!error) {
                    
                    switch (options) {
                        case kMBSaveOptionsUserDefaults:
                            
                            accessTokenData = [self accessTokenFromString:[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding]];
                            [weakSelf saveOAuthTokenToUserDefaults:accessTokenData];
                            
                            break;
                        case kMBSaveOptionsKeychain:
                            
                            accessTokenData = [self accessTokenFromString:[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding]];
                            [weakSelf saveOAUthTokenToKeychain:accessTokenData];
                            
                            break;
                    }
                    
                    completionHandler(YES, nil);
                    
                } else {
                    
                    completionHandler(NO, error);
                    
                }
                
            }]resume];
}

#pragma mark - Saving 

- (NSString *)accessTokenFromString:(NSString *)string
{
    __block NSString *accessToken = nil;
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kMBRegexPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    if (!error && [matches count] > 0) {
        
        [matches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSRange matchRange = [(NSTextCheckingResult *)obj rangeAtIndex:1];
            accessToken = [string substringWithRange:matchRange];
            
        }];
    }
    
    return accessToken;
}

- (void)saveOAuthTokenToUserDefaults:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults]setObject:token forKey:kMBAccessTokenKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)saveOAUthTokenToKeychain:(NSString *)token
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:kMBAccessTokenKey];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:token] forKey:(__bridge id)kSecValueData];
    SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
}

- (id)loadAccessTokenFromKeychain
{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:kMBAccessTokenKey];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        }
        @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", kMBAccessTokenKey, e);
        }
        @finally {}
    }
    if (keyData) CFRelease(keyData);
    return ret;
}

- (NSMutableDictionary *)getKeychainQuery:(NSString *)query {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            query, (__bridge id)kSecAttrService,
            query, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible,
            nil];
}

#pragma mark - Helper Methods 

- (NSString *)accessToken
{
    NSString *accessToken = [[NSUserDefaults standardUserDefaults]objectForKey:kMBAccessTokenKey];
    
    if (!accessToken) {
        accessToken = [self loadAccessTokenFromKeychain];
    }
    
    return accessToken;
}

- (NSString *)temporaryCodeFromCallbackURL:(NSURL *)callbackURL
{
    return [[[callbackURL absoluteString] componentsSeparatedByString:@"="] lastObject];
}

- (void)throwException
{
    [NSException raise:@"EXCEPTION: INVALID OBJECT TYPE" format:@"Please make sure your parameters dictionary contains strings only. Thanks!"];
}

@end