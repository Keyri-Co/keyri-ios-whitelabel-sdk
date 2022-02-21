//
//  KeyriHeader.m
//  keyri-pod_Example
//
//  Created by Andrii Novoselskyi on 10.10.2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

#import "KeyriHeader.h"
#import "keyri_pod-Swift.h"
#import <UIKit/UIKit.h>

@implementation KeyriHeader

- (instancetype)init {
    if (self = [super init]) {
        [Keyri initializeWithAppkey:@"raB7SFWt27VoKqkPhaUrmWAsCJIO8Moj"
                        rpPublicKey:@"00uVMpjv0sxLPMovInfRCB5kSX3WPKpx9RKNe3HFnTE="
                        callbackUrl:[NSURL URLWithString:@"http://18.234.201.114:5000/users/session-mobile"]];
        
        Keyri *keyri = [[Keyri alloc] init];
        
        [keyri handleSessionId:@"" completion:^(Session * _Nullable session, NSError * _Nullable error) {
            
        }];
        
        Service *service = [[Service alloc] initWithId:@"" name:@"" logo:nil];
        [keyri sessionSignupWithUsername:@"" service:service custom:@"" completion:^(NSError * _Nullable error) {
            
        }];
        
        PublicAccount *account = [[PublicAccount alloc] initWithUsername:@"" custom:@""];
        [keyri sessionLoginWithAccount:account service:service custom:@"" completion:^(NSError * _Nullable error) {
            
        }];
        
        [keyri directSignupWithUsername:@"" custom:@"" extendedHeaders:@{} completion:^(AuthMobileResponse * _Nullable response, NSError * _Nullable error) {
            
        }];
        
        [keyri directLoginWithAccount:account custom:@"" extendedHeaders:@{} completion:^(AuthMobileResponse * _Nullable response, NSError * _Nullable error) {
            
        }];
        
        [keyri getAccountsWithCompletion:^(NSArray<PublicAccount *> * _Nullable accounts, NSError * _Nullable error) {
            
        }];
        
        UIViewController *vc = [[UIViewController alloc] init];
        [keyri easyKeyriAuthFrom:vc custom:@"" completion:^(NSError * _Nullable error) {
            
        }];
    }
    
    return self;
}

@end
