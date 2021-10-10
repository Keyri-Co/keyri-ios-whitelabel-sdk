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
        Keyri *keyri = [Keyri shared];

        [keyri initializeWithAppkey:@"raB7SFWt27VoKqkPhaUrmWAsCJIO8Moj"
                        rpPublicKey:@"00uVMpjv0sxLPMovInfRCB5kSX3WPKpx9RKNe3HFnTE="
                        callbackUrl:[NSURL URLWithString:@"http://18.234.201.114:5000/users/session-mobile"]];
        
        [keyri onReadSessionId:@"" completion:^(Session * _Nullable session, NSError * _Nullable error) {
            
        }];
        
        Service *service = [[Service alloc] init];
        [keyri signUpWithUsername:@"" service:service custom:@"" completion:^(NSError * _Nullable error) {
            
        }];
        
        PublicAccount *account = [[PublicAccount alloc] initWithUsername:@"" custom:@""];
        [keyri loginWithAccount:account service:service custom:@"" completion:^(NSError * _Nullable error) {
            
        }];
        
        [keyri mobileSignUpWithUsername:@"" custom:@"" extendedHeaders:@{} completion:^(NSDictionary<NSString *,id> * _Nullable json, NSError * _Nullable error) {
            
        }];
        
        [keyri mobileLoginWithAccount:account custom:@"" extendedHeaders:@{} completion:^(NSDictionary<NSString *,id> * _Nullable json, NSError * _Nullable error) {
            
        }];
        
        [keyri accountsWithCompletion:^(NSArray<PublicAccount *> * _Nullable accounts, NSError * _Nullable error) {
            
        }];
        
        UIViewController *vc = [[UIViewController alloc] init];
        [keyri authWithScannerFrom:vc custom:@"" completion:^(NSError * _Nullable error) {
            
        }];
    }
    
    return self;
}

@end
