//
//  FacebookProvider.swift
//  Inclusive
//
//  Created by Sam Furlong on 11/17/17.
//  Copyright © 2017 Sam Furlong. All rights reserved.
//

import Foundation
import AWSCognito

class FacebookProvider: NSObject, AWSIdentityProviderManager {
    
    func logins() -> AWSTask<NSDictionary> {
        if let token = AccessToken.current?.authenticationToken {
            return AWSTask(result: [AWSIdentityProviderFacebook:token])
        }
        return AWSTask(error:NSError(domain: "Facebook Login", code: -1 , userInfo: ["Facebook" : "No current Facebook access token"]))
    }
}
