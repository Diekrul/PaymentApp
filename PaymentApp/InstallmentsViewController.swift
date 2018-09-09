//
//  InstallmentsViewController.swift
//  PaymentApp
//
//  Created by Diego Jaume on 08-09-18.
//  Copyright © 2018 Diego Jaume. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON

class InstallmentsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var selectedPaymentMethodLabel: UILabel!
    @IBOutlet weak var selectedAmountLabel: UILabel!
    @IBOutlet weak var selectedBankLabel: UILabel!

    var selectedInstallment: String!
    var selectedPaymentMethod: JSON = []
    var selectedAmuont: String!
    var selectedBank: JSON = []
    var installments: [String] = []
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedPaymentMethodLabel.text = selectedPaymentMethod["name"].stringValue
        selectedAmountLabel.text = selectedAmuont
        selectedBankLabel.text = selectedBank["name"].stringValue
        getInstallments()
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
    }
    
    @IBAction func finish(_ sender: UIButton) {
        performSegue(withIdentifier: "fromInstallmentsToLogin", sender: nil)
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
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return installments.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return installments[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedInstallment = installments[row]
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
    
    func getInstallments(){
        startLoading()
        let payment_method_id = selectedPaymentMethod["id"].stringValue
        let amount = String(selectedAmuont)
        let issuer = selectedBank["id"].stringValue
        
        let myParameters: Parameters = ["public_key": "444a9ef5-8a6b-429f-abdf-587639155d88","amount":amount, "payment_method_id":payment_method_id, "issuer.id": issuer]
        print(myParameters)
        let urlString: String! = "https://api.mercadopago.com/v1/payment_methods/installments"
        Alamofire.request(urlString, method: .get, parameters: myParameters).responseJSON { response in
            if let status = response.response?.statusCode {
                switch(status){
                case 200:
                    print("200")
                    if let result = response.result.value {
                        let json = JSON(result)
                        self.installments.removeAll()
                        for jsonObject in json.arrayValue {
                            let payerCostJsonArray = jsonObject["payer_costs"].arrayValue
                            for payerCost in payerCostJsonArray {
                                let recommendedMessage = payerCost["recommended_message"].stringValue
                                self.installments.append(recommendedMessage)
                            }
                        }
                        self.pickerView.reloadAllComponents()
                        self.pickerView.selectRow(0, inComponent: 0, animated: false)
                        self.selectedInstallment = self.installments[0]
                        self.stopLoading()
                        
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
        if segue.identifier == "fromInstallmentsToLogin" {
            let mainViewController = segue.destination as! ViewController
            mainViewController.selectedBank = selectedBank["name"].stringValue
            mainViewController.selectedAmount = selectedAmuont
            mainViewController.selectedPaymentMethod = selectedPaymentMethod["name"].stringValue
            mainViewController.selectedInstallment = selectedInstallment
            mainViewController.showAlert = true
        }
    }
    
    

}
