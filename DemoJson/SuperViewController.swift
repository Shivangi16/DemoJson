//
//  SuperViewController.swift
//  SALocation
//
//  Created by ShivangiBhatt on 25/04/17.
//  Copyright © 2017 mac-0001. All rights reserved.
//

import UIKit

enum userType: Int {
    case iSelf = 99
    case friend = 1
    case pending = 9
    case unknown = 0
    case blocked = 8
    case blockedby = 88
    case declineReq = 10
}

class SuperViewController: UIViewController
{
    var apiReq: URLSessionTask?
    var superTable: UITableView?
    var queue: OperationQueue?
    
    var dragging: Bool = false
    var pullToRefresh: Bool = false
    var shouldUpdate: Bool = false
    var isUpdating: Bool = false
    
    // pull to resfresh
    var arryData = [Any]()
    var APIOffset: Int = 0
    var offset: Float = 0.0
    var lastScrollOffset: CGFloat = 0.0
    
    var spinner:UIActivityIndicatorView?
    var updateLabel: UILabel?
    var lastUpdateLabel: UILabel?
    var updateImageView: UIImageView?
    var updateImageViewPng: UIImageView?
    var refreshControl: UIRefreshControl!

    var iObjectDic : [String:AnyObject]?
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent =  (self.view.tag == 101)
        //        self.navigationController?.navigationBar.backgroundColor = CAppGreenColor
        self.navigationController?.navigationBar.barTintColor =  UIColor.black //UIColor(red: 0, green: 55.0, blue: 160.0, alpha: 1.0);
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, 0), for: .default)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Back")
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Back")
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.isNavigationBarHidden =   (self.view.tag == 100)
        
        //        self.edgesForExtendedLayout = []
        self.edgesForExtendedLayout = UIRectEdge.top
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false

//        UIApplication.shared.statusBarStyle = .lightContent
//        self.automaticallyAdjustsScrollViewInsets = false
//        // Do any additional setup after loading the view.
//
//            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//            navigationController?.navigationBar.shadowImage = UIImage()
//            self.navigationController?.navigationBar.isTranslucent = false //(self.view.tag == 101)
//            self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0, green: 55.0, blue: 160.0, alpha: 1.0)
//            self.navigationController?.navigationBar.barTintColor =  UIColor(red: 0, green: 55.0, blue: 160.0, alpha: 1.0);
//
//            self.navigationController?.navigationBar.tintColor = UIColor.white;
//            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
//
//            self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
//            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, 0), for: .default)
//            self.navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Back")
//            self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Back")
//            self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false
//            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//            self.navigationController?.isNavigationBarHidden =  false // (self.view.tag == 100)

            

    }
    
    
    func setPullToRefresh()
    {
        /*
         refreshControl = UIRefreshControl()
         refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
         refreshControl.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
         superTable?.addSubview(refreshControl) // not required when using UITableViewController
         */
        
        if pullToRefresh {
            initializePullToRefresh()
        }
        superTable?.backgroundColor = UIColor.clear
    }

    func initializePullToRefresh()
    {
        updateLabel = UILabel(frame: CGRect(x: 0, y: -40, width: 320, height: 20))
        updateLabel?.textAlignment = .center
        updateLabel?.text = "Pull down to refresh..."
        updateLabel?.textColor = UIColor.gray
        updateLabel?.backgroundColor = UIColor.clear
        
        lastUpdateLabel = UILabel(frame: CGRect(x: 0, y: -20, width: 320, height: 20))
        lastUpdateLabel?.textAlignment = .center
        lastUpdateLabel?.textColor = UIColor.white
        lastUpdateLabel?.backgroundColor = UIColor.red
        lastUpdateLabel?.font = UIFont(name: "Helvetica", size: 10)
        
        updateImageView?.isHidden = true
        updateImageView?.isHidden = false
        shouldUpdate = false
        isUpdating = false
        
    }
    func cancelCurrentRequest(currentReq : URLSessionTask?)
    {
        if let currentReq = currentReq
        {
            if currentReq.state == URLSessionTask.State.running
            {
                currentReq.cancel()
            }
        }
    }
    func refresh(sender:AnyObject) {
        // Code to refresh table view
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    //MARK: Scroll View Delegate
    @objc func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        dragging = false
        
        if shouldUpdate {
            queue = OperationQueue()
            
            let blockOperation = BlockOperation {
                self.updateMethod()
            }
            
            queue?.addOperation(blockOperation)
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            superTable?.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
            UIView.commitAnimations()
        }
        
        if targetContentOffset.pointee.y >= scrollView.contentSize.height - 240 - scrollView.frame.size.height && targetContentOffset.pointee.y < scrollView.contentOffset.y {
            loadMoreData()
        }
        

    }

//    @objc func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: CGPoint)
//    {
//        dragging = false
//
//        if shouldUpdate {
//            queue = OperationQueue()
//
//            let blockOperation = BlockOperation {
//                self.updateMethod()
//            }
//
//            queue?.addOperation(blockOperation)
//
//            UIView.beginAnimations(nil, context: nil)
//            UIView.setAnimationDuration(0.2)
//            superTable?.contentInset = UIEdgeInsetsMake(60, 0, 0, 0)
//            UIView.commitAnimations()
//        }
//
//        if targetContentOffset.y >= scrollView.contentSize.height - 240 - scrollView.frame.size.height && targetContentOffset.y < scrollView.contentOffset.y {
//            loadMoreData()
//        }
//
//
//    }
    
    @objc func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y > 0 {
            spinner?.isHidden = true
        }
        else {
            spinner?.isHidden = false
        }
        
        if scrollView.isDragging && scrollView.contentOffset.y >= scrollView.contentSize.height - 240 - scrollView.frame.size.height && lastScrollOffset < scrollView.contentOffset.y && !dragging {
            dragging = true
            loadMoreData()
        }
        
        lastScrollOffset = scrollView.contentOffset.y
        
        if  pullToRefresh {
            if (superTable != nil) {
                offset = Float(superTable!.contentOffset.y)
            }
            offset *= -1
            
            if offset > 0 && offset < 60 {
                if !isUpdating {
                    updateLabel?.text = "Pull to Reload"
                }
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationBeginsFromCurrentState(true)
                UIView.setAnimationDuration(0.2)
                updateImageViewPng?.transform = CGAffineTransform(rotationAngle: 0)
                UIView.commitAnimations()
                shouldUpdate = false
            }
            if offset >= 60 {
                if !isUpdating {
                    updateLabel?.text = "Release to Reload"
                }
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationBeginsFromCurrentState(true)
                UIView.setAnimationDuration(0.2)
                updateImageViewPng?.transform = CGAffineTransform(rotationAngle: 3.14159265)
                UIView.commitAnimations()
                shouldUpdate = true
                //                shouldPlaySound = true
            }
            if isUpdating {
                shouldUpdate = false
            }
            
            
        }
        
    }
    
    //MARK:
    func refreshData()
    {
        
    }
    
    func loadMoreData()
    {
        
    }
    
    
    func updateMethod() {
        
        refreshData()
        performSelector(onMainThread: #selector(self.startSpinner), with: nil, waitUntilDone: false)
    }
    
    func stopUpdating() {
        performSelector(onMainThread: #selector(self.stopSpinner) , with: nil, waitUntilDone: false)
        setUpdateDate()
    }
    
    @objc func startSpinner() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner?.color = UIColor.black //UIColor(red: 0, green: 55.0, blue: 160.0, alpha: 1.0)
        spinner?.frame = CGRect(x: (superTable?.frame.size.width)!/2.0 - 20.0, y: (superTable?.frame.origin.y)! + 15, width: 40, height: 40)
        updateImageView?.isHidden = true
        spinner?.startAnimating()
        updateLabel?.text = "Updating..."
        isUpdating = true
        self.view.addSubview(spinner!)
        
        updateImageViewPng?.isHidden = true;
        updateImageView?.isHidden = false;
        
    }
    
    @objc func stopSpinner() {
        spinner?.removeFromSuperview()
        updateImageView?.isHidden = false
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.2)
        superTable?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        UIView.commitAnimations()
        isUpdating = false
        updateImageViewPng?.isHidden = false;
        updateImageView?.isHidden = true;
        
    }
    
    func setUpdateDate() {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy HH:mm:ss"
        let now = Date()
        let dateString: String = dateFormat.string(from: now)
        let objectString: String = "\("Last updated on") \(dateString)"
        lastUpdateLabel?.text = objectString
        //    NSString *documentsFolderPath = [CCachesDirectory stringByAppendingPathComponent:fileStorageName];
        //    [objectString writeToFile:documentsFolderPath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
    }
    
    
    func validatePhone(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as NSString
            let length = decimalString.length
            let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne {
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3 {
                let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3 {
                let prefix = decimalString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            return false
        
    }


}
