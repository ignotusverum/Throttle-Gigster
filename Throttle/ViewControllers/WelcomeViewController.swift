//
//  WelcomeViewController.swift
//  Throttle
//
//  Created by Muhammad Hasan on 2015-11-23.
//  Copyright © 2015 Gigster. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics
import MBProgressHUD

class WelcomeViewController: UIViewController {
    @IBOutlet var dashboardContentContainer: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var navigationBarBackgroundView: UIView!
    @IBOutlet var topConstraintOfScrollView2: NSLayoutConstraint!
    @IBOutlet var improvePlanButton: UIBarButtonItem!
    @IBOutlet var welcomeButtonTopLayoutConstraint: NSLayoutConstraint!
    @IBOutlet var welcomePlusButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var welcomePlusbuttonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var welcomeToThrottleYConstraint: NSLayoutConstraint!
    
    let cardTypes = [CardType.TotalInterest, CardType.TotalBalance, CardType.GrandTotal, CardType.TotalMonthlyPayments]
    let auth = ConfigFactory.getAuth()
    
    var addedCards: [DashboardCard] = []
    var sizeOfScrollView: CGSize!
    var alreadyLayedOutSubviews = false
    var refreshControl: UIRefreshControl?
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.alwaysBounceVertical = true
        
        UIApplication.sharedApplication().statusBarHidden = false
        let auth = ConfigFactory.getAuth()
        
        let device = UIDeviceInfo.screenType()
        if (device == .iPhone6Plus || device == nil) {
            self.welcomeButtonTopLayoutConstraint.constant = 385
            self.welcomePlusButtonWidthConstraint.constant = 175
            self.welcomePlusbuttonHeightConstraint.constant = 175
        }
        else if (device == .iPhone6) {
            self.welcomeButtonTopLayoutConstraint.constant = 345
            self.welcomePlusButtonWidthConstraint.constant = 161
            self.welcomePlusbuttonHeightConstraint.constant = 161
        }
        else if (device == .iPhone4) {
            self.welcomeButtonTopLayoutConstraint.constant = 240
            self.welcomeToThrottleYConstraint.constant = 10
        }
        
        if (auth.isUserLoggedIn() && hasAtLeastOneAccountAdded()) {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            self.refreshDataWithCompletion({
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let hasAtLeastOneAccount = hasAtLeastOneAccountAdded()
        self.updateNavigationBar(hasAtLeastOneAccount)
        self.dashboardContentContainer.hidden = !hasAtLeastOneAccount
        
        if (hasAtLeastOneAccount) {
            if self.refreshControl == nil {
                self.refreshControl = UIRefreshControl()
                self.refreshControl!.addTarget(self, action: #selector(WelcomeViewController.refreshData), forControlEvents: .ValueChanged)
                self.scrollView.addSubview(refreshControl!)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if (!alreadyLayedOutSubviews) {
            alreadyLayedOutSubviews = true
            self.updateCards()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.updateCardTotals()
        
        if (!hasAtLeastOneAccountAdded()) {
            NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.beginWelcomeButtonAnimation.rawValue, object: nil)
        }
        
        super.viewDidAppear(animated)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // get rid of the back button text, per mock ups
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    // MARK: - Button actions
    @IBAction func menuButtonTapped(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.presentSideBar.rawValue, object: nil)
    }
    
    @IBAction func tappedOnImprovePlanButton(sender: AnyObject) {
        self.performSegueWithIdentifier("segueToImprovePlan", sender: nil)
    }
    
    // MARK: - Helpers
    func refreshData() {
        self.refreshDataWithCompletion(nil)
    }
    
    func refreshDataWithCompletion(completion: (() -> ())?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let refreshService = RefreshAllAccountDataService(auth: ConfigFactory.getAuth())
            refreshService.execute({ (result) in
                if (result.code == .Success) {
                    let saveDataService = SaveRefreshDataService()
                    saveDataService.saveRefreshResult(result)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.updateCardTotals()
                    })
                    
                    completion?()
                    self.refreshControl?.endRefreshing()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    return
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    if (result.code == .Unauthorized) {
                        NSNotificationCenter.defaultCenter().postNotificationName(NSNotificationName.userLoggedOut.rawValue, object: nil)
                    }
                    else {
                        let vc = AlertUtil.getSimpleAlert("API Error", message: "An unknown error has occurred. Please try again later or contact support.")
                        self.presentViewController(vc, animated: true, completion: nil)
                    }
                    
                    completion?()
                    self.refreshControl?.endRefreshing()
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                })
            })
        }
    }
    
    func retrieveAprForAccounts(result: RefreshAllAccountDataResult, completionBlock: () -> Void) {
        var numberOfRecordsProcessed = 0
        var totalRecords: [RefreshAllAccountDataResultItems] = []
        totalRecords.appendContentsOf(result.credits)
        totalRecords.appendContentsOf(result.loans)
        totalRecords.appendContentsOf(result.banks)
        
        totalRecords = totalRecords.filter() { (account: RefreshAllAccountDataResultItems) -> Bool in
            return !account.manualAccount
        }
        
        for item in totalRecords {
            let service = GetAccountDetailsService(auth: self.auth)
            
            service.execute(item.itemId, itemType: item.containerType!, completionBlock: { (interest) in
                item.interestRate = interest
                numberOfRecordsProcessed += 1
                
                if (numberOfRecordsProcessed == totalRecords.count) {
                    completionBlock()
                }
            })
        }
    }
    
    private func hasAtLeastOneAccountAdded() -> Bool {
        do {
            let realm = try Realm.getEncryptedInstance()
            return realm.objects(UserAccountEntity).count > 0
        } catch {
            CLSLogv("Realm Error: %@", getVaList(["\(error)"]))
            print("\(error)")
            // fatalError("Realm error")
        }
        
        return false
    }
    
    private func updateCards() {
        self.scrollView.setNeedsLayout()
        self.scrollView.layoutIfNeeded()
        
        self.sizeOfScrollView = self.scrollView.frame.size
        let heightOfView = self.sizeOfScrollView.height
        let yOffsetOfCards = sizeOfScrollView.height * 0.2
        var accumulatedYOffset: CGFloat = 0
        
        for (index, cardType) in self.cardTypes.enumerate() {
            let card = UINib(nibName: DashboardCard.NibName, bundle: nil).instantiateWithOwner(self, options: nil)[0] as! DashboardCard
            
            card.frame = CGRectMake(0, accumulatedYOffset, sizeOfScrollView.width, heightOfView)
            card.delegate = self
            card.updateWithCardType(cardType)
            card.index = addedCards.count
            
            self.addedCards.append(card)
            self.scrollView.addSubview(card)
            
            card.originalYOffset = accumulatedYOffset
            if (index == 0) {
                accumulatedYOffset += CGFloat(index) + sizeOfScrollView.height * 0.28
            } else {
                accumulatedYOffset += CGFloat(index) + sizeOfScrollView.height * 0.22
            }
            
        }
        
        self.scrollView.contentSize = CGSizeMake(sizeOfScrollView.width, yOffsetOfCards * CGFloat(self.cardTypes.count))
    }
    
    private func updateNavigationBar(hasAtLeastOneItem: Bool) {
        
        if (hasAtLeastOneItem) {
            self.title = "Dashboard"
            self.navigationItem.rightBarButtonItem = self.improvePlanButton
        } else {
            self.title = nil
            self.navigationItem.rightBarButtonItem = nil
        }
        
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        self.navigationController!.navigationBar.translucent = true
        
    }
    
    private func updateCardTotals() {
        let result = GetLoanAndCreditAccountsService().getAccounts()
        
        if (result.code == .Error) {
            let vc = AlertUtil.getSimpleAlert("Calculation Error", message: "Error calculating values")
            self.presentViewController(vc, animated: true, completion: nil)
            return
        }
        
        // HACK: There are many places where we don't actually update the monthly payment value to be at least the minimum.
        //   Make sure that it's at least the minimum here in order to prevent the app from breaking.
        if result.code == .Success && NSUserDefaults.getTotalMonthlyMinimumPayment() < result.totalMinimumPayments {
            print("HACK: Updating user monthly payment to minimum.")
            NSUserDefaults.setTotalMonthlyMinimumPayment(result.totalMinimumPayments)
        }
        
        var totalPrincipleBalance = 0
        var totalInterestOnPrincipleBalance = 0
        var totalPrinciplePlusInterestBalance = 0
        var totalMinimumPayments = 0
        
        for entity in result.accounts {
            totalPrincipleBalance += Int.convertToCents(entity.totalBalance)
            
            let interest = entity.APRPercentage
            let interestOnPrincipleBalance = Int.percentageOfMoneyToCents(Int.convertToCents(entity.totalBalance), percent: interest)
            
            totalInterestOnPrincipleBalance += interestOnPrincipleBalance
            totalPrinciplePlusInterestBalance += (Int.convertToCents(entity.totalBalance) + interestOnPrincipleBalance)
            
            totalMinimumPayments += Int.convertToCents(entity.minimumPayment)
        }
        
        let interestCard = self.addedCards[0]
        let principleBalanceCard = self.addedCards[1]
        let principlePlusInterest = self.addedCards[2]
        let totalMinPayments = self.addedCards[3]
        
        let calcResult = SnowballAvalancheCalculationService(logDetails: true).executeWithSnowballAlgorithm(NSUserDefaults.getCalculationAlgorithm(), withTotalMonthlyPayment: NSUserDefaults.getTotalMonthlyMinimumPayment())
        if calcResult.code == .Error {
            let vc = AlertUtil.getSimpleAlert("Calculation Error", message: calcResult.message!)
            // We need to use the rootViewController due to a UI bug where this view is not loaded onto the view hierarchy yet.
            self.view.window!.rootViewController?.presentViewController(vc, animated: true, completion: nil)
            return
        }
        
        interestCard.updateTotal(calcResult.interestPaid)
        
        principleBalanceCard.updateTotal(totalPrincipleBalance)
        principlePlusInterest.updateTotal(totalPrincipleBalance + calcResult.interestPaid)
        
        let userDefinedMinPayment = NSUserDefaults.getTotalMonthlyMinimumPayment()
        if (userDefinedMinPayment < totalMinimumPayments) {
            totalMinPayments.updateTotal(totalMinimumPayments)
        } else {
            totalMinPayments.updateTotal(userDefinedMinPayment)
        }
    }
}

//MARK: - DashboardCardProtocol
extension WelcomeViewController: DashboardCardProtocol {
    func tappedOnCard(card: DashboardCard) {
        let cardRowHeight = CGFloat(self.sizeOfScrollView.height)
        self.scrollView.clipsToBounds = false
        self.scrollView.bringSubviewToFront(card)
        
        card.titleLabel.alpha = 0
        card.totalAmountLabel.alpha = 0
        let cardHeightAndYOffset: CGFloat = 64
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            if (card.cardTapped) {
                card.frame = CGRectMake(0, -1 * cardHeightAndYOffset, self.sizeOfScrollView.width, self.sizeOfScrollView.height + cardHeightAndYOffset)
            } else {
                card.frame = CGRectMake(0, card.originalYOffset, self.sizeOfScrollView.width, cardRowHeight)
            }
            
            card.titleLabel.alpha = 1
            card.totalAmountLabel.alpha = 1
            
        }) { (complete) -> Void in
            if (complete) {
                if (!card.cardTapped) {
                    self.scrollView.clipsToBounds = true
                }
            }
        }
        
        var atLeastOneCardTapped = false
        for card in self.addedCards {
            if (card.cardTapped) {
                atLeastOneCardTapped = true
            }
        }
        
        if (atLeastOneCardTapped) {
            self.scrollView.scrollEnabled = false
        } else {
            self.scrollView.scrollEnabled = true
            for card in self.addedCards {
                self.scrollView.bringSubviewToFront(card)
            }
            
        }
    }
}
