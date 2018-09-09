//
//  PaymentMethodViewController.swift
//  PaymentApp
//
//  Created by Diego Jaume on 05-09-18.
//  Copyright © 2018 Diego Jaume. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON


class PaymentMethodViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedAmout: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var arrayOfimages: [UIImage] = []
    var amount: String!
    var arrayOfIdNameThumb: [JSON] = []
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedAmout.text = amount
        tableView.dataSource = self
        tableView.delegate = self
        self.getPaymentMethods()
    }
    
    func startLoading(){
        activityIndicator.center = self.view.center;
        activityIndicator.hidesWhenStopped = true;
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray;
        activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        view.addSubview(activityIndicator);
        activityIndicator.startAnimating();
        UIApplication.shared.beginIgnoringInteractionEvents();
    }
    
    func stopLoading(){
        activityIndicator.stopAnimating();
        UIApplication.shared.endIgnoringInteractionEvents();
    }
    
    func loadData(){
        arrayOfimages.removeAll()
        for item in arrayOfIdNameThumb {
            var thumbnail = item["thumbnail"].stringValue
            let url = URL(string: thumbnail)
            do{
                let data = try Data(contentsOf: url!)
                let image = UIImage(data: data)
                arrayOfimages.append(image!)
            }catch{
                print("error al cargar la fotografía")
            }
        }
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfIdNameThumb.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transportCell", for: indexPath)
        cell.textLabel?.text = arrayOfIdNameThumb[indexPath.row]["name"].stringValue
        cell.imageView?.image = arrayOfimages[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPayment: JSON = arrayOfIdNameThumb[indexPath.row]
        self.performSegue(withIdentifier: "fromPaymentToCard", sender: selectedPayment)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                stopLoading()
            }
        }
    }
    
    func getPaymentMethods(){
        startLoading()
        let myParameters: Parameters = ["public_key": "444a9ef5-8a6b-429f-abdf-587639155d88"]
        let urlString: String! = "https://api.mercadopago.com/v1/payment_methods"
        Alamofire.request(urlString, method: .get, parameters: myParameters).responseJSON { response in
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    print("200")
                    if let result = response.result.value {
                        let json = JSON(result)
//                        print(json)
                        self.arrayOfIdNameThumb.removeAll()
                        for jsonObject in json.arrayValue {
                            let id = jsonObject["id"].stringValue
                            let name = jsonObject["name"].stringValue
                            let thumbnail = jsonObject["thumbnail"].stringValue
                            let data = JSON(["id":id,"name":name,"thumbnail":thumbnail])
                            self.arrayOfIdNameThumb.append(data)
                        }
                        self.loadData()
                    }
                default:
                    SVProgressHUD.showError(withStatus: "Error \(status)")
                }
            }else{
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "Verifique su conexión e intentelo nuevamente")
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromPaymentToCard" {
            let cardViewController = segue.destination as! CardViewController
            cardViewController.paymentMethodSelected = sender as! JSON
            cardViewController.selectedAmount = self.amount as! String
        }
    }
    
}
