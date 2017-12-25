//
//  SearchViewController.swift
//  
//
//  Created by ShivangiBhatt on 24/12/17.
//

import UIKit

class SearchViewController: SuperViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet var tblSearch: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    var arrSearchProducts = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblSearch.register(UINib(nibName: "ProductDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductDetailsTableViewCell")
        
        tblSearch.estimatedRowHeight = 126.0
        self.tblSearch.rowHeight = UITableViewAutomaticDimension;

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
    
    
    //MARK: - Tableview datasource and delegate
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearchProducts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier:"ProductDetailsTableViewCell", for: indexPath) as! ProductDetailsTableViewCell
        
        let objProduct = arrSearchProducts[indexPath.row] as? TblProducts

        var strTitle = ""
        var strValue = ""
        if objProduct?.view_count != nil
        {
            strTitle = "No. of views"
            strValue = objProduct?.view_count ?? ""
        }
        else if objProduct?.order_count != nil
        {
            strTitle = "No. of order"
            strValue = objProduct?.order_count ?? ""

        }
        else if objProduct?.share_count != nil
        {
            strTitle = "No. of share"
            strValue = objProduct?.share_count ?? ""

        }

        cell.lblProduct.text = objProduct?.name
        cell.lblBrand.text = objProduct?.brand
        cell.lblTax.text = "\(objProduct?.taxName ?? ""): \(objProduct?.taxValue ?? "")"
        cell.lblCount.text = "\(strTitle) = \(strValue)"
        cell.accessoryType = .none
        
        if (objProduct?.varients?.count ?? 0) > 0
        {
            cell.accessoryType = .disclosureIndicator
        }

        return cell
    }

    //MARK: Search Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print("Search string = \(searchText)")
        self.searchForProduct(strSeach: searchText)
        self.tblSearch.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       // getProductDetails()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func searchForProduct(strSeach:String)
    {
        let fetchRequest = TblProducts.fetch(predicate: NSPredicate(format: "name contains[cd] %@ OR brand contains[cd] %@", strSeach, strSeach), orderBy: nil, ascending: true)
        arrSearchProducts = fetchRequest as? [Any] ?? []
        self.tblSearch.reloadData()
    }


}
