//
//  ProductsViewController.swift
//  DemoJson
//
//  Created by Mac-00016 on 22/12/17.
//  Copyright © 2017 Mac-00016. All rights reserved.
//

import UIKit
let CMostSharedProducts = "Most ShaRed Products"
let CMostOrderedProduct = "Most OrdeRed Products"
let CMostViewedProducts = "Most Viewed Products"

let InitialLoad = "InitialLoad"
class ProductsViewController: SuperViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblProducts: UITableView!
    var arrProducts = [Any]()
    
    var strSearchString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Products"
        tblProducts.tableFooterView = UIView()

        self.superTable = self.tblProducts
        pullToRefresh = true

        if (UserDefaults.standard.value(forKey: InitialLoad) != nil)
        {
            self.getProductDetails()
        }
        else
        {
            self.getProductList()
        }
        let searchBtn = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(showSearchController))
        self.navigationItem.rightBarButtonItem = searchBtn
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func refreshData() {
        getProductList()
        
    }

    func getProductDetails()
    {
        let arrTitle = [CMostSharedProducts, CMostOrderedProduct, CMostViewedProducts]
        for i in 0..<arrTitle.count
        {
            let search = arrTitle[i] == CMostViewedProducts ? "view_count":(arrTitle[i] == CMostOrderedProduct ? "order_count" : "share_count")
            let arrData = (TblProducts.fetch(predicate: NSPredicate(format: "%K != nil", search), orderBy: search, ascending: false)) as? [Any] ?? []
            if arrData.count>0
            {
                let dictData = ["key": arrTitle[i], "value":arrData] as [String:AnyObject]
                arrProducts.append(dictData)
            }

        }
        tblProducts.register(UINib(nibName: "ProductDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailsTableViewCell")
        
        tblProducts.estimatedRowHeight = 126.0
        self.tblProducts.rowHeight = UITableViewAutomaticDimension;

        tblProducts.reloadData()
        print("\(arrProducts)")

    }
    
    @objc func showSearchController()
    {
        let vcSearch = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(vcSearch, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Tableview datasource and delegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let dictSection = arrProducts[section]  as? [String:AnyObject] else {
            return UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 0.0))
        }
        
        let vwHeader = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60))
        vwHeader.backgroundColor = UIColor(red: 232, green: 232, blue: 232, alpha: 1.0)
        let lblHeader = UILabel(frame: CGRect(x: 15, y: 0, width: self.view.frame.width-15.0, height: 60))
        lblHeader.text = (dictSection["key"] as? String)?.lowercased()
        vwHeader.addSubview(lblHeader)
        vwHeader.layer.borderColor = UIColor.lightGray.cgColor
        vwHeader.layer.borderWidth = 0.5
        vwHeader.layer.masksToBounds = true
        return vwHeader
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dictSection = arrProducts[section] as? [String:AnyObject]
        {
            if let arrValue = dictSection["value"] as? [Any]
            {
                return arrValue.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier:"ProductDetailsTableViewCell", for: indexPath) as! ProductDetailsTableViewCell

        if let dictSection = arrProducts[indexPath.section] as? [String:AnyObject]
        {
            if let arrValue = dictSection["value"] as? [Any]
            {
                let objProduct = arrValue[indexPath.row] as? TblProducts

                var strName = "", strTitle = ""
                if (dictSection["key"] as? String ?? "") == CMostViewedProducts
                {
                    strName = "\(objProduct?.view_count ?? "V")"
                    print("View Count = \(objProduct?.view_count)")
                    strTitle = "No. of views"
                }
                else if (dictSection["key"] as? String ?? "") == CMostOrderedProduct
                {
                    print("Order Count = \(objProduct?.order_count)")

                    strName = "\(objProduct?.order_count ?? "O")"
                    strTitle = "No. of order"
                }
                else
                {
                    print("Share Count = \(objProduct?.share_count)")

                    strName = "\(objProduct?.share_count ?? "S")"
                    strTitle = "No. of share"
                }
                
                cell.lblProduct.text = objProduct?.name
                cell.lblBrand.text = objProduct?.brand
                cell.lblTax.text = "\(objProduct?.taxName ?? ""): \(objProduct?.taxValue ?? "")"
                cell.lblCount.text = "\(strTitle) = \(strName)"
                
                cell.accessoryType = .none
                
                if (objProduct?.varients?.count ?? 0) > 0
                {
                    cell.accessoryType = .disclosureIndicator
                }

            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let dictSection = arrProducts[indexPath.section] as? [String:AnyObject]
        {
            if let arrValue = dictSection["value"] as? [Any]
            {
                let objProduct = arrValue[indexPath.row] as? TblProducts
                let vcVarient = VarientsViewController(nibName: "VarientsViewController", bundle: nil)
                vcVarient.arrVarients = objProduct?.varients?.allObjects ?? []
                self.navigationController?.pushViewController(vcVarient, animated: true)

            }
        }
        
        
//        }
        
    }



}

extension ProductsViewController
{
    func getProductList()
    {
        APIRequest.shared().wsGetCategoryList(successCallBack: { (response) in
            if let responseObject = response {
                
                if let categories = responseObject["categories"] as? [[String: AnyObject]]
                {
                    for i in 0..<categories.count
                    {
                        let dictAtIndex = categories[i]// as [String:AnyObject]
//                        let tblBrand = (TblBrand.findOrCreate(dictionary: ["id":"\(dictAtIndex["id"] ?? "" as AnyObject)"]) as? TblBrand)
//
//                        tblBrand?.name = dictAtIndex["name"] as? String ?? ""
                        let arrProductsInBrand = NSMutableOrderedSet()
                        
                        if let arrProducts = dictAtIndex["products"] as? [[String: AnyObject]]
                        {
                            for i in 0..<arrProducts.count
                            {
                                let dictProduct = arrProducts[i]// as [String:AnyObject]
                                let tblProdct = (TblProducts.findOrCreate(dictionary: ["id":"\(dictProduct["id"] ?? "" as AnyObject)"]) as? TblProducts)
                                tblProdct?.name = dictProduct["name"] as? String ?? ""
                                tblProdct?.brand = dictAtIndex["name"] as? String ?? ""
                                if let dictTax = dictProduct["tax"] as? [String: AnyObject]
                                {
                                    tblProdct?.taxName = dictTax["name"] as? String ?? ""
                                    tblProdct?.taxValue = "\(dictTax["value"]  ?? "" as AnyObject)"
                                }
                                let arrVarientsInProducts = NSMutableSet() //NSMutableOrderedSet()
                                if let arrVarient = dictProduct["variants"] as? [[String: AnyObject]]
                                {
                                    for j in 0..<arrVarient.count
                                    {
                                        let dictVarient = arrVarient[j]// as [String:AnyObject]
                                        let tblVarient = (TblVarients.findOrCreate(dictionary: ["id":"\(dictVarient["id"] ?? "" as AnyObject)"]) as? TblVarients)
                                        
                                        tblVarient?.color = dictVarient["color"] as? String ?? ""
                                        tblVarient?.size = "\(dictVarient["size"] ?? "" as AnyObject)"
                                        tblVarient?.price = "\(dictVarient["price"] ?? "" as AnyObject)"
                                        
                                        arrVarientsInProducts.add(tblVarient)
                                    }
                                    
                                }
                                
                                //Ranking
                                if let arrRankings = responseObject["rankings"] as? [[String: AnyObject]]
                                {
                                    for i in 0..<arrRankings.count
                                    {
                                        let dictRanking = arrRankings[i]
                                        let strRankingName = "\(dictRanking["ranking"] ?? "" as AnyObject)"
                                        
                                        if let arrProductsInRanking = dictRanking["products"] as? [Any]
                                        {
                                            for j in 0..<arrProductsInRanking.count
                                            {
                                                if let dictForRanking = arrProductsInRanking[j] as? [String:AnyObject]
                                                {
                                                    if tblProdct?.id == "\(dictForRanking["id"] ?? "" as AnyObject)"
                                                    {
                                                        if strRankingName == "Most Viewed Products"
                                                        {
                                                            tblProdct?.view_count = "\(dictForRanking["view_count"] ?? "" as AnyObject)"
                                                        }
                                                        else if  strRankingName == "Most OrdeRed Products"
                                                        {
                                                            tblProdct?.order_count = "\(dictForRanking["order_count"] ?? "" as AnyObject)"
                                                        }
                                                        else if strRankingName == "Most ShaRed Products"
                                                        {
                                                            tblProdct?.share_count = "\(dictForRanking["shares"] ?? "" as AnyObject)"
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                
                                tblProdct?.addToVarients(arrVarientsInProducts)
//                                arrProductsInBrand.add(tblProdct)
                            }
                        }
                        
                    }
                    
                }
                
                CoreData.sharedInstance.saveContext()
                
            }
            self.stopSpinner()
            UserDefaults.standard.set("isLoaded", forKey: InitialLoad)
            UserDefaults.standard.synchronize()
            self.getProductDetails()

        }) { (error) in
            print("Error \(error.description)")
        }
    }
}

