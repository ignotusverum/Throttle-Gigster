//
//  CalendarViewController.swift
//  Throttle
//
//  Created by Kaitlyn Lee on 3/9/16.
//  Copyright © 2016 Gigster. All rights reserved.
//

import UIKit
import RealmSwift
import TSMessages

class CalendarViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var totalDueLabel: UILabel!
  @IBOutlet weak var totalDueAmountLabel: UILabel!
  @IBOutlet weak var unpaidLabel: UILabel!
  
  var currentIndexCentered = 2
  var numSectionsVisible:NSInteger!
  var halfwayPoint:NSInteger!
  var selectedMonth = 0
  var selectedRow = 0
  var firstView = true
  
  var allAccounts = [UserAccountEntity]()
  let kCalendarAccountDetailSegue = "calendarAccountDetailSegue"
  let kMonthCollectionCellIdentifier = "monthCollectionCellIdentifier"
  let kMonthAccountsCellIdentifier = "monthAccountsCellIdentifier"
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    do {
      let realm = try Realm.getEncryptedInstance();
      let realmAccounts = realm.objects(UserAccountEntity)
      allAccounts = Array(realmAccounts)
      
      print(allAccounts.count , "accounts")
      print(allAccounts)
    }
    catch {
      print(error)
      allAccounts = [UserAccountEntity]()
    }
    self.tableView.reloadData()
    if (self.firstView == true) {
      self.selectMonth(self.getCurrentMonth())
      self.firstView = false
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.tableView.reloadData()
  }
  
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    self.hideBanner()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.numSectionsVisible = self.numberOfSectionsVisible()
    self.halfwayPoint = (self.numSectionsVisible - 1) / 2
  }
  
  @IBAction func menuButtonTapped(sender: AnyObject) {
    NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.presentSideBar.rawValue, object: nil);
  }
  
  @IBAction func leftButtonPressed(sender: AnyObject) {
    if (--currentIndexCentered < self.halfwayPoint) {
      currentIndexCentered = self.halfwayPoint
    }
    
    let scrollTo = NSIndexPath(forRow: currentIndexCentered, inSection: 0)
    self.collectionView.scrollToItemAtIndexPath(scrollTo, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
  }
  
  @IBAction func rightButtonPressed(sender: AnyObject) {
    if (++currentIndexCentered >= self.collectionView.numberOfItemsInSection(0) - halfwayPoint) {
      currentIndexCentered = self.collectionView.numberOfItemsInSection(0) - 1 - halfwayPoint
    }
    let scrollTo = NSIndexPath(forRow: currentIndexCentered, inSection: 0)
    self.collectionView.scrollToItemAtIndexPath(scrollTo, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
  }
  
  func showBanner(message:String) {
    // Displays starting at the bottom of the nav bar, but overlaps
    TSMessage.setDefaultViewController(self.navigationController)
    // Without it, displays from the very top
    TSMessage.showNotificationWithTitle(message, type: TSMessageNotificationType.Success)
  }
  
  func hideBanner() {
    TSMessage.dismissActiveNotification()
  }
  
  func showAccountDeletedBanner() {
    self.showBanner("Account was deleted successfully")
  }
  
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    if (segue.identifier == kCalendarAccountDetailSegue) {
      let detailViewController = segue.destinationViewController as! AccountDetailViewController
      detailViewController.source = .SourceCalendar
      
      let account = arrayOfAccountsForMonth(self.selectedMonth)[self.selectedRow]
      detailViewController.setUserAccount(account)
    }
  }
}

extension CalendarViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 12;
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(kMonthCollectionCellIdentifier, forIndexPath: indexPath) as! MonthCollectionViewCell
    cell.monthLabel.text = AccountsData.sharedAccountsData.months[indexPath.row]
    
    if (self.selectedMonth == indexPath.row) {
      cell.backgroundColor = tableViewCellDarkerBlue()
      cell.monthLabel.textColor = UIColor.whiteColor()
    } else {
      cell.backgroundColor = UIColor.whiteColor()
      cell.monthLabel.textColor = UIColor.blackColor()
    }
    cell.layoutIfNeeded()
    return cell
  }
  
  func isAscending(cell1:UICollectionViewCell, cell2:UICollectionViewCell) -> Bool {
    let indexPath1 = self.collectionView.indexPathForCell(cell1)
    let indexPath2 = self.collectionView.indexPathForCell(cell2)
    return (indexPath1!.row < indexPath2!.row)
  }
  
  func numberOfSectionsVisible() -> NSInteger {
    return self.collectionView.visibleCells().count
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    updateCurrentCellIndex()
  }
  
  func updateCurrentCellIndex() {
    let visibleCells = self.collectionView.visibleCells().sort(isAscending)
    let centerCell = visibleCells[halfwayPoint] as! MonthCollectionViewCell
    self.currentIndexCentered = (self.collectionView.indexPathForCell(centerCell)?.row)!
    print(self.currentIndexCentered)
    print(centerCell.monthLabel.text)
  }
}

extension CalendarViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    self.selectedMonth = indexPath.row
    let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! MonthCollectionViewCell
    cell.backgroundColor = tableViewCellDarkerBlue()
    cell.monthLabel.textColor = UIColor.whiteColor()
    collectionView.reloadData()
    self.tableView.reloadData()
    self.updateTitle()
  }
  
  func selectMonth(month:Int) {
    self.selectedMonth = month
    
    let indexPath = NSIndexPath(forRow: month, inSection: 0)
    collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: false)
    collectionView.reloadData()
    self.tableView.reloadData()
    self.updateTitle()
  }
  
  func updateTitle() {
    self.totalDueLabel.text = "Total due in " + AccountsData.sharedAccountsData.monthTitles[self.selectedMonth]
    
    let monthArray = self.arrayOfAccountsForMonth(self.selectedMonth)
    var total = 0.0
    // accumulate the minimum monthly payments for the month
    for account in monthArray {
      total += account.minimumPayment
    }
    
    if total > 0 {
      unpaidLabel.hidden = false
      let currentMonthlyPayment = NSUserDefaults.getTotalMonthlyMinimumPayment();
      
      let numberFormatter = NSNumberFormatter();
      numberFormatter.numberStyle = .CurrencyStyle;
      
      self.totalDueAmountLabel.text = numberFormatter.stringFromNumber(
        Int.convertToCurrency(currentMonthlyPayment)
      );
    } else {
      unpaidLabel.hidden = true
      self.totalDueAmountLabel.text = "$0.00"
    }
  }
  
  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! MonthCollectionViewCell
    cell.backgroundColor = UIColor.whiteColor()
    cell.monthLabel.textColor = UIColor.blackColor()
  }
}

extension CalendarViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.arrayOfAccountsForMonth(self.selectedMonth).count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(kMonthAccountsCellIdentifier) as! DebtsTableViewCell
    
    cell.backgroundColor = (indexPath.row % 2 != 0) ? tableViewCellDarkerBlue() : tableViewCellLighterBlue()
    let monthArray = self.arrayOfAccountsForMonth(self.selectedMonth)
    let account = monthArray[indexPath.row]
    cell.accountCardLabel.text = account.accountName
    cell.balanceLabel.text = String(format: "$%.02f", account.totalBalance)
    if (account.dayOfMonthWhenDue > 0) {
      cell.monthLabel.text = AccountsData.sharedAccountsData.months[self.selectedMonth]
      cell.dayLabel.text = String(format:"%i", account.dayOfMonthWhenDue)
    } else {
      cell.dayLabel.text = ""
      cell.monthLabel.text = ""
    }
    return cell
  }
  
  func arrayOfAccountsForMonth(month:Int) -> Array<UserAccountEntity> {
    var monthArray = self.allAccounts.filter({
      let monthIndex = self.monthForDate($0.dayOfMonthWhenDue)
      // currently only displays for the current and future months
      return ($0.dayOfMonthWhenDue != 0) && (monthIndex <= month)
    })
    monthArray = monthArray.sort { (account1, account2) -> Bool in
      return account1.dayOfMonthWhenDue < account2.dayOfMonthWhenDue
    }
    return monthArray
  }
  
  func monthForDate(day:Int) -> Int {
    let today = NSDate()
    
    let todayComponents = NSCalendar.currentCalendar().components([.Month, .Day], fromDate: today)
    var month = todayComponents.month - 1 // 0 index for the month titles
    // If this day has already passed this month
    if (day < todayComponents.day) {
      // advance to the enxt month
      month += 1
    }
    return month
  }
  
  func getCurrentMonth() -> Int {
    let today = NSDate()
    let todayComponents = NSCalendar.currentCalendar().components([.Month, .Day], fromDate: today)
    return todayComponents.month - 1
  }
}

extension CalendarViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.selectedRow = indexPath.row
    self.performSegueWithIdentifier(kCalendarAccountDetailSegue, sender: nil)
    self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }
}
