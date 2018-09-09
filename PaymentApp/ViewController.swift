//
//  ViewController.swift
//  PaymentApp
//
//  Created by Diego Jaume on 05-09-18.
//  Copyright © 2018 Diego Jaume. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var amount: UITextField!
    var userAmount: String!
    var selectedAmount: String!
    var selectedPaymentMethod: String!
    var selectedBank: String!
    var selectedInstallment: String!
    var showAlert: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.amount.delegate = self
        self.amount.keyboardType = UIKeyboardType.numberPad
        self.navigationItem.setHidesBackButton(true, animated: false)
        if showAlert{
            alert()
        }
    }
    
    func alert(){
        let alert = UIAlertController(title: "Compras", message: "Los datos de la comprá son los siguientes\rMonto: \(String(selectedAmount))\rMetodo: \(String(selectedPaymentMethod))\rBanco: \(String(selectedBank))\rCuotas: \(String(selectedInstallment))", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: {});
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func errorAmountEmpty(){
        let alert = UIAlertController(title: "Monto", message: "Debe ingresar un monto", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: {});
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    
    @IBAction func toPaymentMethod(_ sender: UIButton) {
        self.userAmount = self.amount.text!
        if userAmount?.isEmpty ?? true {
            errorAmountEmpty()
        }else{
            self.performSegue(withIdentifier: "fromAmountToPaymentmethod", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromAmountToPaymentmethod" {
            let paymentMethodViewController = segue.destination as! PaymentMethodViewController
            paymentMethodViewController.amount = self.userAmount
        }
    }
    

}

