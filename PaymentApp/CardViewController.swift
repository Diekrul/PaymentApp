//
//  CardViewController.swift
//  PaymentApp
//
//  Created by Diego Jaume on 08-09-18.
//  Copyright © 2018 Diego Jaume. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON

class CardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectedPaymentMethodLabel: UILabel!
    @IBOutlet weak var selectedAmountLabel: UILabel!
    
    var arrayOfimages: [UIImage] = []
    var selectedAmount: String!
    var paymentId: String!
    var paymentMethodSelected: JSON = []
    var arrayOfIdNameThumb: [JSON] = []
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        selectedPaymentMethodLabel.text = paymentMethodSelected["name"].stringValue
        selectedAmountLabel.text = selectedAmount
        self.getCardIssuers()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "bankCell", for: indexPath)
        cell.textLabel?.text = arrayOfIdNameThumb[indexPath.row]["name"].stringValue
        if (indexPath.row < arrayOfimages.count){
            cell.imageView?.image = arrayOfimages[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "fromBankToInstallments", sender: arrayOfIdNameThumb[indexPath.row])

//        let selectedPayment: String! = arrayOfIdNameThumb[indexPath.row]["id"].stringValue
//        self.performSegue(withIdentifier: "fromPaymentToCard", sender: selectedPayment)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            if indexPath == lastVisibleIndexPath {
                stopLoading()
            }
        }
    }
    
    func alert(){
        let alert = UIAlertController(title: "Error", message: "Error en la sincronización", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: {});
            self.navigationController?.popViewController(animated: true);
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getCardIssuers(){
        startLoading()
        var payment_method_id = paymentMethodSelected["id"].stringValue
        let myParameters: Parameters = ["public_key": "444a9ef5-8a6b-429f-abdf-587639155d88", "payment_method_id":payment_method_id]
        print(myParameters)
        let urlString: String! = "https://api.mercadopago.com/v1/payment_methods/card_issuers"
        Alamofire.request(urlString, method: .get, parameters: myParameters).responseJSON { response in
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    print("200")
                    if let result = response.result.value {
                        let json = JSON(result)
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
                    self.alert()
                }
            }else{
                self.alert()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromBankToInstallments" {
            let installmentsViewController = segue.destination as! InstallmentsViewController
            installmentsViewController.selectedPaymentMethod = paymentMethodSelected
            installmentsViewController.selectedAmuont = selectedAmount
            installmentsViewController.selectedBank = sender as! JSON
        }
    }
}
