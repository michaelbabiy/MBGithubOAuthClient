//
//  NSString+MBRequestURL.m
//  GoGoGithub
//
//  Created by iC on 4/25/14.
//  Copyright (c) 2014 Michael Babiy. All rights reserved.
//

#import "NSString+MBRequestURL.h"

static NSString * const kMBTemporaryCodeKey = @"com.michaelbabiy.NSString+MBRequestURL.m.temporaryToken";
static NSString * const kMBRegexPattern = @"access_token=([^&]+)";
static NSString * const kMBAccessTokenKey = @"kMBAccessTokenKey";

@implementation NSString (MBRequestURL)

- (NSString *)oauthRequestWithStringComponent:(NSString *)component parameters:(NSDictionary *)parameters
{
    __block NSString *parametersString = nil;
    
    if (parameters) {
        
        [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            if ([obj isKindOfClass:[NSString class]]) {
                
                parametersString = [[NSString alloc]init];
                NSString *parameter = (NSString *)obj;
                parametersString = [parametersString stringByAppendingString:parameter];
                
            } else {
                
                [self throwException];
                
            }
        }];
    }
        
    if ([component isEqualToString:kOAuthAuthorizeComponent]) {
        
        if (parametersString) {
            
            return [NSString stringWithFormat:@"%@%@?client_id=%@&scope=%@", kOAuthBaseURLString, kOAuthAuthorizeComponent, kGithubClientID, parametersString];
            
        }
        
    } else if ([component isEqualToString:kOAuthAccessTokenComponent]) {
        
        return [NSString stringWithFormat:@"%@%@?client_id=%@&client_secret=%@&code=%@",
                kOAuthBaseURLString,
                kOAuthAccessTokenComponent,
                kGithubClientID,
                kGithubClientSecret,
                self.temporaryCode];
        
    }
    
    return nil;
}

- (NSString *)requestURLWithStringComponent:(NSString *)component parameters:(NSDictionary *)parameters
{
    return nil;
}

#pragma mark - Helper Methods

- (void)throwException
{
    [NSException raise:@"EXCEPTION: INVALID OBJECT TYPE" format:@"Please make sure your parameters dictionary contains strings only. Thanks!"];
}

- (NSString *)temporaryCodeFromCallbackURL:(NSURL *)callbackURL
{
    return self.temporaryCode = [[[callbackURL absoluteString] componentsSeparatedByString:@"="] lastObject];
}

- (void)saveOAuthToken:(NSString *)token options:(kMBSaveOption)option completionHandler:(MBGithubOAuthClientCompletionHandler)completionHandler
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kMBRegexPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:token options:0 range:NSMakeRange(0, token.length)];
    
    if (!error && [matches count] > 0) {
        
        [matches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSRange matchRange = [(NSTextCheckingResult *)obj rangeAtIndex:1];
            NSString *accessToken = [token substringWithRange:matchRange];
            
            switch (option) {
                case kMBSaveOptionUserDefaults:[self saveOAuthTokenToUserDefaults:accessToken];
                    break;
                case kMBSaveOptionKeychain:[self saveOAUthTokenToKeychain:accessToken];
                    break;
            }
        }];
    }
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

#pragma mark - Keychain

- (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            service, (__bridge id)kSecAttrService, 
            service, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible,
            nil];
}

#pragma mark - Associated Objects

- (void)setTemporaryCode:(NSString *)temporaryCode
{
    objc_setAssociatedObject(self, &kMBTemporaryCodeKey, temporaryCode, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)temporaryCode
{
    return objc_getAssociatedObject(self, &kMBTemporaryCodeKey);
}

@end
