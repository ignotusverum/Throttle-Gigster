//
//  ChooseAccountViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-12-19.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit

class ChooseAccountViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var accounts: [Account]? = nil
    var selectedIndexPaths: [NSIndexPath] = []
	let chooseAccountCellIdentifier = "chooseAccountCellIdentifier";
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        populateAccounts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

    // MARK: - Helper
    func populateAccounts() {
    
        // TODO: get accounts from server
        accounts = []
        for index in 1...5 {
            let account = Account()
            account.name = "Account \(index)"
            accounts?.append(account)
        }
    }
}

extension ChooseAccountViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return accounts?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(chooseAccountCellIdentifier, forIndexPath: indexPath)
        
        cell.imageView?.image = (selectedIndexPaths.contains(indexPath) == true) ? UIImage(named: "checkbox-active"): UIImage(named: "checkbox-inactive")
        cell.textLabel?.text = accounts![indexPath.row].name
        
        return cell
    }
}

extension ChooseAccountViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let selected = selectedIndexPaths.contains(indexPath)
        if selected {
        
            selectedIndexPaths.removeAtIndex(selectedIndexPaths.indexOf(indexPath)!)
        } else {
        
            selectedIndexPaths.append(indexPath)
        }
        
        tableView.reloadData()
    }
}