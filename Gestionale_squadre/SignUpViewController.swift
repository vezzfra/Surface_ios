//
//  SignUpViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 15/11/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import SkyFloatingLabelTextField

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmPasswordField: SkyFloatingLabelTextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        self.confirmPasswordField.delegate = self
        self.emailTextField.delegate = self
        
        self.usernameField.textAlignment = .center
        self.passwordField.textAlignment = .center
        self.confirmPasswordField.textAlignment = .center
        self.emailTextField.textAlignment = .center
        
        self.signUpButton.layer.cornerRadius = 10
        self.signUpButton.layer.masksToBounds = true
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        if self.usernameField.text != "" && self.passwordField.text != "" && (self.passwordField.text == self.confirmPasswordField.text) && self.emailTextField.text != "" && (self.emailTextField.text?.contains("@"))! {
            
            let q = PFQuery(className: "users")
            q.whereKey("username", equalTo: self.usernameField.text!)
            q.findObjectsInBackground { (objects, error) in
                if error == nil && objects!.count == 0 {
                    let obj = PFObject(className: "users")
                    obj["username"] = self.usernameField.text!
                    obj["password"] = self.passwordField.text!
                    obj["email"] = self.emailTextField.text!
                    obj.saveInBackground { (success, error) in
                        if error == nil && success {
                            let alert = UIAlertController(title: "Fatto!", message: "Il tuo account è stato creato.", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                                self.dismiss(animated: true, completion: nil)
                            })
                            alert.addAction(ok)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "Errore", message: "L'username inserito esiste già. Provane un altro.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            
            let alert = UIAlertController(title: "Errore", message: "Ricontrolla i dati inseriti e riprova. Tutti i campi sono obbligatori", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
