//
//  ViewController.swift
//  AffirmSDKDemo-Swift
//
//  Created by Jackie Qi on 6/13/17.
//  Copyright © 2017 Affirm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet var label: UILabel!
  @IBOutlet var textField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    label.numberOfLines = 0
    
    let toolBar = UIToolbar()
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: textField, action: #selector(resignFirstResponder))
    toolBar.items = [flexibleItem, doneItem]
    
    toolBar.sizeToFit()
    textField.inputAccessoryView = toolBar
    updateLabel()
  }

  func showAlert(message: String) {
    let alert = UIAlertController(title: "Affirm Checkout", message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
  }

  // MARK: IBAction Methods
  @IBAction func startCheckout(_ sender: UIButton) {
    let configuration = AffirmConfiguration(affirmDomain: "sandbox.affirm.com", publicAPIKey: "Y8CQXFF044903JC0")
    
    var stringToCheckout = ""
    if let string = textField.text {
      stringToCheckout = string
    }
    let price = NSDecimalNumber(string: stringToCheckout)
    
    let item = AffirmItem(name: "Affirm Test Item", sku: "test_item", unitPrice: price, quantity: 1,
                          url: URL(string: "http://sandbox.affirm.com/item")!,
                          imageURL: URL(string: "http://sandbox.affirm.com/image.png")!)
    
    let address = AffirmAddress(line1: "325 Pacific Ave.", line2: "", city: "San Francisco",
                                state: "CA", zipCode: "94111", countryCode: "USA")
    
    let contact = AffirmContact(name: "Test Tester", address: address)
    
    let checkout = AffirmCheckout(items: [item], shipping: contact, taxAmount: .zero,
                                  shippingAmount: .zero)
    
    // Initialize the view controller, which creates the checkout on Affirm and starts the user checkout flow.
    let vc = AffirmCheckoutViewController.checkoutController(with: self,
                                                             configuration: configuration,
                                                             checkout: checkout)
    present(vc, animated: true, completion: nil)
  }

  @IBAction func presentSiteModal(_ sender: UIButton) {
    let configuration = AffirmConfiguration(affirmDomain: "cdn1-sandbox.affirm.com", publicAPIKey: "Y8CQXFF044903JC0")
    let vc = AffirmSiteModalViewController.siteModalController(withModalId: "5LNMQ33SEUYHLNUC",
                                                      configuration: configuration)
    present(vc, animated: true, completion: nil)
  }
  
  @IBAction func presentProductModal(_ sender: UIButton) {
    let configuration = AffirmConfiguration(affirmDomain: "cdn1-sandbox.affirm.com", publicAPIKey: "Y8CQXFF044903JC0")
    
    let price = NSDecimalNumber(string: textField.text)
    let vc = AffirmProductModalViewController.productModalController(withModalId: "0Q97G0Z4Y4TLGHGB",
                                                            amount: price,
                                                            configuration: configuration)
    present(vc, animated: true, completion: nil)
  }
  
  // MARK: Private Methods
  fileprivate func updateLabel() {
    let configuration = AffirmConfiguration(affirmDomain: "cdn1-sandbox.affirm.com", publicAPIKey: "Y8CQXFF044903JC0")
    
    let price = NSDecimalNumber(string: textField.text)
    AffirmAsLowAs.write(to: label, amount: price, promoId: "SFCRL4VYS0C78607", affirmType: .logo, affirmColor: .black, configuration: configuration) { [weak self] (error, success) in
      if error != nil {
        let message = self?.parseError(error: error)
        print(message ?? "Error out")
      }
    }
  }
  
  @discardableResult
  fileprivate func parseError(error: Error, prefixMessage: String? = nil) -> String {
    var message = ""
    if let error = error as? NSError, let prefixMessage = prefixMessage {
      message = String(format: "%@ %@", prefixMessage, error.userInfo)
    }
    else {
      message = error.localizedDescription
    }
    
    return message
  }
}

extension ViewController: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    updateLabel()
  }
}

extension ViewController: AffirmCheckoutDelegate {
  func checkoutComplete(withToken checkoutToken: String) {
    // The user has completed the checkout and created a checkout token.
    // This token should be forwarded to your server, which should then authorize it with Affirm and create a charge.
    // For more information about the server integration, see https://docs.affirm.com/v2/api/charges
    dismiss(animated: true, completion: nil)
    showAlert(message: "Checkout completed.")
  }
  
  func checkoutCancelled() {
    // The user has cancelled the checkout.
    dismiss(animated: true, completion: nil)
    showAlert(message: "Checkout Cancelled.")
  }

  func checkoutCreationFailedWithError(_ error: Error) {
    // Checkout creation has failed for some reason.
    dismiss(animated: true, completion: nil)
    
    let message = parseError(error: error, prefixMessage: "There was an error creating the checkout:")

    showAlert(message: message)
  }
}
