//
//  VarientsViewController.swift
//  DemoJson
//
//  Created by ShivangiBhatt on 25/12/17.
//  Copyright © 2017 Mac-00016. All rights reserved.
//

import UIKit

class VarientsViewController: SuperViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblVarients: UITableView!
    var arrVarients = [Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Varients"
        tblVarients.tableFooterView = UIView()

        // Do any additional setup after loading the view.
        tblVarients.register(UINib(nibName: "VarientsTableViewCell", bundle: nil), forCellReuseIdentifier: "VarientsTableViewCell")
        
//        tblVarients.estimatedRowHeight = 87.0
//        self.tblVarients.rowHeight = UITableViewAutomaticDimension;
//
        tblVarients.reloadData()

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
    //MARK: Tableview Delegate and Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrVarients.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 87.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"VarientsTableViewCell", for: indexPath) as! VarientsTableViewCell
        
        
        if let objVarient = arrVarients[indexPath.row] as? TblVarients
        {
            cell.lblColorName?.text = objVarient.color
            cell.lblSize.text = "\(objVarient.size ?? "")"
            cell.lblPrice.text = "\(objVarient.price ?? "")"
            
        }
        
        return cell
    }
    
    
    

}
