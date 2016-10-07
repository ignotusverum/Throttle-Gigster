//
//  DeleteAccountViewController.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/6/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import MBProgressHUD;
import RealmSwift

class DeleteAccountViewController: UIViewController {

  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var deleteButton: UIButton!
  @IBOutlet weak var subView: UIView!
  typealias CompletionBlock = (shouldDelete:Bool) -> ()
  var completionHandler:CompletionBlock!
  var userAccount:UserAccountEntity!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func deleteButtonPressed(sender: AnyObject) {
    let auth = ConfigFactory.getAuth();
    let deleteAccountService = DeleteAccountService(auth: auth, account: self.userAccount)
    self.deleteButton.enabled = false
    MBProgressHUD.showHUDAddedTo(self.view, animated: true);
    UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    deleteAccountService.execute { (success) in
      do {
        let realm = try Realm.getEncryptedInstance();
        realm.deleteAccount(self.userAccount)
        
      } catch {
        print(error)
      }
      if (self.completionHandler != nil) {
        self.completionHandler(shouldDelete: true)
      }
      UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
        if let view = self.parentViewController?.view {
            
            MBProgressHUD.hideAllHUDsForView(view, animated: true);
        }
    }
  }

  @IBAction func cancelButtonPressed(sender: AnyObject) {
    if (self.completionHandler != nil) {
      self.completionHandler(shouldDelete: false)
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    let touch = event?.allTouches()?.first
    if (touch!.view != self.subView) {
      // cancel
      self.completionHandler(shouldDelete:false)
    }
  }
  
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
