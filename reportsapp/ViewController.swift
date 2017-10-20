//
//  ViewController.swift
//  reportsapp
//
//  Created by Bryce Johnston on 10/11/17.
//  Copyright © 2017 Crop Quest. All rights reserved.
//

import UIKit
import OAuth2
import Alamofire

class ViewController: UIViewController {
    
    fileprivate var alamofireManager: SessionManager?
    
    var loader: OAuth2DataLoader?
    
    var oauth2 = OAuth2CodeGrant(settings: [
        "client_id": "4bc0217f8c16c52f3eb59d9ff2393508aa060e3cc8adb9367908e7d4038f9478",
        "client_secret": "ed9193161aebd1d0377d48f89f32ae635a6893dd09b474426c1c6446e1e02a27",
        "authorize_uri": "https://reports.cropquest.net/oauth/authorize",
        "token_uri": "https://reports.cropquest.net/oauth/token",
        "redirect_uris": ["reportsoauth://connect/reports/callback"],
        "secret_in_body": false,
        "verbose": true,
        ] as OAuth2JSON)
    
    @IBOutlet weak var signInSafariButton: UIButton!
    @IBOutlet weak var forgetButton: UIButton!
    @IBOutlet weak var jsonOutput: UITextView!
    @IBOutlet weak var getReportsButtpm: UIButton!
    
    @IBAction func signInSafari(_ sender: UIButton!) {
        if oauth2.isAuthorizing {
            oauth2.abortAuthorization()
            return
        }
        sender?.setTitle("Authorizing...", for: UIControlState.normal)
        
        oauth2.authConfig.authorizeEmbedded = false
        let loader = OAuth2DataLoader(oauth2: oauth2)
        self.loader = loader
        
        callReports()
    }
    
    func callReports() {
        let sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2)
        sessionManager.adapter = retrier
        sessionManager.retrier = retrier
        alamofireManager = sessionManager
        
        sessionManager.request("https://reports.cropquest.net/api/v1/reports.json").validate().responseJSON { response in
            debugPrint(response)
            self.jsonOutput.text = response.description
            if let dict = response.result.value as? [String: Any] {
                self.didGetUserdata(dict: dict, loader: nil)
            }
            else {
                self.didCancelOrFail(OAuth2Error.generic("\(response)"))
            }
        }
        sessionManager.request("https://reports.cropquest.net/api/v1/reports.json").validate().responseJSON { response in
            debugPrint(response)
        }
    }
    
    
    @IBAction func getReports(_ sender: UIButton?) {
        callReports()
    }
    
    @IBAction func forgetTokens(_ sender: UIButton?) {
        oauth2.forgetTokens()
        resetButtons()
    }
    
    var userDataRequest: URLRequest {
        var request = URLRequest(url: URL(string: "https://reports.cropquest.net/api/v1/reports.json")!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    func didGetUserdata(dict: [String: Any], loader: OAuth2DataLoader?) {
        DispatchQueue.main.async {
            /***
             if let username = dict["name"] as? String {
             self.signInEmbeddedButton?.setTitle(username, for: UIControlState())
             }
             else {
             self.signInEmbeddedButton?.setTitle("(No name found)", for: UIControlState())
             }
             if let imgURL = dict["avatar_url"] as? String, let url = URL(string: imgURL) {
             self.loadAvatar(from: url, with: loader)
             }
             ***/
            dump(dict)
            self.signInSafariButton?.isHidden = true
            self.forgetButton?.isHidden = false
        }
    }
    
    func didCancelOrFail(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Authorization went wrong: \(error)")
            }
            self.resetButtons()
        }
    }
    
    func resetButtons() {
        signInSafariButton?.setTitle("Sign In (Safari)", for: UIControlState())
        signInSafariButton?.isEnabled = true
        signInSafariButton?.isHidden = false
        forgetButton?.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

