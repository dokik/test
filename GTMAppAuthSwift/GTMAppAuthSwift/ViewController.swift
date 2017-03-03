//
//  ViewController.swift
//  GTMAppAuthSwift
//
//  Created by doki on 2016/11/21.
//  Copyright © 2016年 RDG. All rights reserved.
//

import UIKit
import GoogleAPIClient
import AppAuth
import GTMAppAuth

class ViewController: UIViewController {
    
    // Google Developer Consloeから取得
//    private let kClientID = "YourClientID.apps.googleusercontent.com"
//    private let kRedirectURI = "com.googleusercontent.apps.YourClientID:/oauthredirect"
    
    private let kClientID = "141270343744-4dnk0ib1pu6dlv9e7t0fpm981ucemulg.apps.googleusercontent.com"
    private let kRedirectURI = "com.googleusercontent.apps.141270343744-4dnk0ib1pu6dlv9e7t0fpm981ucemulg:/oauthredirect"
    
    private let kIssuer = "https://accounts.google.com"
    
    private let scopes = ["https://www.googleapis.com/auth/drive", "https://www.googleapis.com/auth/spreadsheets"]
    
    private let service = GTLService()
    
    var authorization: GTMAppAuthFetcherAuthorization?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadState()
        
        if authorization == nil {
            authOID()
        } else {
            service.authorizer = authorization
        }
    }
    
    func authOID() {
        let issuer = URL(string: kIssuer)
        let redirectURI = URL(string: kRedirectURI)
        
        // discovers endpoints
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer!, completion: {
            (configuration, error) in
            if configuration == nil {
                print("Error retrieving discovery document: \(error?.localizedDescription)")
                self.setGtmAuthorization(stauthorization: nil)
                return
            }
            
            print("Got configuration: \(configuration!)")
            
            // builds authentication request
            let request: OIDAuthorizationRequest = OIDAuthorizationRequest.init(
                configuration: configuration!,
                clientId: self.kClientID,
                scopes: self.scopes,
                redirectURL: redirectURI!,
                responseType: OIDResponseTypeCode,
                additionalParameters: nil)
            
            // performs authentication request
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            print("Initiating authorization request with scope: \(request.scope!)")
            
            appDelegate.currentAuthorizationFlow = OIDAuthState.authState(
                byPresenting: request,
                presenting: self,
                callback: {
                    (authState, error) in
                    if authState != nil {
                        let gauthorization: GTMAppAuthFetcherAuthorization = GTMAppAuthFetcherAuthorization(authState: authState!)
                        self.setGtmAuthorization(stauthorization: gauthorization)
                        print("Got authorization tokens. Access token: \(authState?.lastTokenResponse?.accessToken)")
                    } else {
                        self.setGtmAuthorization(stauthorization: nil)
                        print("Authorization error: \(error?.localizedDescription)")
                    }
            })
        })
    }
    
    func saveState() {
        if authorization != nil {
            if (authorization?.canAuthorize())! {
                GTMAppAuthFetcherAuthorization.save(authorization!, toKeychainForName: "authorization")
            } else {
                GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: "authorization")
            }
        } else {
            GTMAppAuthFetcherAuthorization.removeFromKeychain(forName: "authorization")
        }
    }
    
    func loadState() {
        if GTMAppAuthFetcherAuthorization(fromKeychainForName: "authorization") != nil {
            let lauthorization: GTMAppAuthFetcherAuthorization = GTMAppAuthFetcherAuthorization(fromKeychainForName: "authorization")!
            self.setGtmAuthorization(stauthorization: lauthorization)
        }
    }
    
    func setGtmAuthorization(stauthorization: GTMAppAuthFetcherAuthorization?) {
        if authorization == stauthorization {
            return
        }
        authorization = stauthorization
        stateChanged()
        service.authorizer = authorization
    }
    
    func stateChanged() {
        self.saveState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

