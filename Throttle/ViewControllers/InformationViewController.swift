//
//  InformationViewController.swift
//  Throttle
//
//  Created by Marco Ledesma on 5/4/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	@IBAction func closeButtonTapped() {
		self.dismissViewControllerAnimated(true, completion: nil);
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
