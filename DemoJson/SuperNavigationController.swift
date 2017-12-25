//
//  SuperNavigationController.swift
//  SALocation
//
//  Created by mac-00018 on 25/04/17.
//  Copyright © 2017 mac-0001. All rights reserved.
//

import UIKit

class SuperNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let insets : UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        let alignedImage = UIImage(named:"nav_back")?.withAlignmentRectInsets(insets)
        UINavigationBar.appearance().backIndicatorImage = alignedImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named:"nav_back")
        
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(0, 0), for: .default)
        
        UINavigationBar.appearance().tintColor = UIColor.white //ButtonColor.CBtnTitleColor
//        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white, NSFontAttributeName:CFontBebasBook(CFontSizeForButton)]
      
        self.navigationBar.isTranslucent = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
