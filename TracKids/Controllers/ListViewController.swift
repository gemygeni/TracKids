//
//  ViewController.swift
//  TracKids
//
//  Created by AHMED GAMAL  on 1/25/21.
//

import UIKit
import Firebase
import SwiftOTP

class ListViewController: UIViewController {
    private var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.user?.uid == nil{
            self.childsButton.isHidden = true
        }
        fetchUserInfo()
    }
    
    func fetchUserInfo(){
        DataHandler.shared.fetchUserInfo {[weak self] (user) in
            self?.user = user
            if user.accountType == 1{
                self?.childsButton.isHidden = true
            }
            else if user.accountType == 0 {
                self?.childsButton.isHidden = false
            }
        }
    }
    var AuthHandler : AuthStateDidChangeListenerHandle?
    
    @IBOutlet weak var childsButton: UIButton!
    
    
    @IBOutlet weak var signInButton: UIButton!{
        didSet{
            signInButton.isHidden = Auth.auth().currentUser?.uid != nil
        }
    }
    
    @IBOutlet weak var RemoveAccountButton: UIButton!{
        didSet{
            RemoveAccountButton.isHidden = Auth.auth().currentUser?.uid == nil
        }
    }
    @IBAction func signOutPressed(_ sender: UIButton) {
                   handleSignOut()
        TrackingViewController.trackedChildUId = nil
        navigationItem.title = ""
                   }
    
    @IBOutlet weak var signOutButton: UIButton!{
        didSet{
            signOutButton.isHidden = Auth.auth().currentUser?.uid == nil
        }
    }
    
    private func handleSignOut(){
        do {
            try! Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)
            if let TrackingVC = self.navigationController?.rootViewController as? TrackingViewController{
                TrackingVC.IsLoggedIn = false
                TrackingVC.mapView.removeAnnotations( TrackingVC.mapView.annotations)
                TrackingVC.centerMapOnUserLocation()
                TrackingVC.tabBarItem.title = ""
                TrackingVC.navigationItem.title = ""
                
                if var tabVC = tabBarController?.viewControllers{
                    tabVC.removeAll()
                }
            }
            print("signed out successfully")
        }
    }
    
    
    @IBAction func removeAccountPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "are you sure you want to remove account", message: "caution: you will lose all data related to this account", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] action in
            self?.removeAccount()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
       }

    func removeAccount(){
        let user = Auth.auth().currentUser
       guard  let userId = user?.uid else {return}
        DataHandler.shared.removeAccount(for: userId) {
            user?.delete {[weak self] error in
            if let error = error {
            print(error.localizedDescription)
            } else {
                print("Debug: Removed completed")
                self?.navigationController?.popToRootViewController(animated: true)
                if let TrackingController = self?.navigationController?.rootViewController as? TrackingViewController{
                    TrackingController.IsLoggedIn = false
                    TrackingController.mapView.removeAnnotations( TrackingController.mapView.annotations)
                    TrackingController.centerMapOnUserLocation()
                    self?.handleSignOut()
                }
             }
          }
        }
     }
    
    
    @IBAction func childsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "ChildsListSegue", sender: self)
    }
    
    
    @IBAction func shareAppPressed(_ sender: UIButton) {
        configureDynamicLink()
    }
    
    
    
    func configureDynamicLink(){
        var components = URLComponents()
        components.scheme = "https"
        components.host = "apps.apple.com/app/1600337105"
        guard let linkParameter = components.url else { return }
        print("I am sharing \(linkParameter.absoluteString)")
        let domain = "https://trackids.page.link"
        guard let linkBuilder = DynamicLinkComponents
          .init(link: linkParameter, domainURIPrefix: domain) else {
            return
        }
        if let myBundleId = Bundle.main.bundleIdentifier {
          linkBuilder.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
        }
        linkBuilder.iOSParameters?.appStoreID = "1600337105"
        linkBuilder.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder.socialMetaTagParameters?.title = "Join kid buddy with this link"
        linkBuilder.socialMetaTagParameters?.descriptionText = "install kid buddy to share your location info with your parents"
        guard let longURL = linkBuilder.url else { return }
        print("sharing The long dynamic link is \(longURL.absoluteString)")
        linkBuilder.shorten {[weak self] url, warnings, error in
          if let error = error {
            print("Oh no! Got an error in sharing! \(error)")
            return
          }
          if let warnings = warnings {
            for warning in warnings {
              print("Warning: \(warning)")
            }
          }
          guard let shortenUrl = url else { return }
          print("I have a short url to sharing ! \(shortenUrl.absoluteString)")
            let items: [Any] = ["join trackids via this Link: ", shortenUrl]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self?.present(ac, animated: true)
        }
    }
    
    
    @IBAction func SOSButtonPressed(_ sender: Any) {
       // sendCriticalAlert()
        let deviceToken = "fp_dvU8a8El6tclf1m6L2g:APA91bGJxFslu-FkhBHxv-ZWf9ffE64itZTByMgxfoEVXJ1NU9L8m_Y4Wv5904pSapGvUeWVERGsDdnQ55tVnEcZhgJK9SwPMoFkwNxOVb3f4Ij8m5jTD7xkjKL6FSzvF0njoSPb3iwL"
        
        DataHandler.shared.sendCriticalAlert(to: deviceToken, sender: "sender", body: "respond to call ")

          }
    
    func sendCriticalAlert(){
        DataHandler.shared.fetchUserInfo { user in
            let sender = user.name
            if user.accountType == 0 {
                if let childId = TrackingViewController.trackedChildUId{
                    DataHandler.shared.fetchDeviceID(for: childId) { deviceToken in
                    DataHandler.shared.sendCriticalAlert(to: deviceToken, sender: sender, body: "respond to \(sender) call ")
                    }
                }
            }
            else  if user.accountType == 1 {
                guard let parentId = user.parentID  else{return}
                DataHandler.shared.fetchDeviceID(for: parentId) { deviceToken in
                DataHandler.shared.sendCriticalAlert(to: deviceToken, sender: sender, body: " \(sender) NEEDS HELP ")
                }
            }
        }
    }
}
