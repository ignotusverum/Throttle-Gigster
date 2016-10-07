//
//  EditsNotSavedViewController.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/6/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class EditsNotSavedViewController: UIViewController {

  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var subView: UIView!
  typealias CompletionBlock = (shouldSave:Bool) -> ()
  var completionHandler:CompletionBlock!
  
    override func viewDidLoad() {
        super.viewDidLoad()
      self.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func backButtonPressed(sender: AnyObject) {
    if (self.completionHandler != nil) {
      self.completionHandler(shouldSave: false)
    }
  }

  @IBAction func saveButtonPressed(sender: AnyObject) {
    if (self.completionHandler != nil) {
      self.completionHandler(shouldSave: true)
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    let touch = event?.allTouches()?.first
    if (touch!.view != self.subView) {
      // cancel
      self.completionHandler(shouldSave:false)
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
