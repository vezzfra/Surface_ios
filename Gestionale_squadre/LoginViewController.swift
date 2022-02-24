//
//  LoginViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 11/11/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import SkyFloatingLabelTextField
import JGProgressHUD
import OneSignal
import SCLAlertView

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var usernameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    
    var hud: JGProgressHUD = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.signUpButton.isHidden = true
        if let username = UserDefaults.standard.object(forKey: "app_username") as? String {
            self.usernameTextField.text = username
        } else {
            self.usernameTextField.textContentType = .username
        }
        if let password = UserDefaults.standard.object(forKey: "app_password") as? String {
            self.passwordTextField.text = password
        } else {
            self.passwordTextField.textContentType = .password
        }
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.usernameTextField.textAlignment = .center
        self.passwordTextField.textAlignment = .center
        
        self.signInButton.layer.cornerRadius = 10
        self.signInButton.layer.masksToBounds = true
        self.signUpButton.layer.cornerRadius = 10
        self.signUpButton.layer.masksToBounds = true
        
        self.hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Accedo"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginTapped(sender: UIButton) {
        if(self.usernameTextField.text != "" && self.passwordTextField.text != "") {
            
            self.hud.show(in: self.view)
            let q = PFQuery(className: "users")
            q.whereKey("username", equalTo: self.usernameTextField.text!)
            q.findObjectsInBackground { (objects, error) in
                if error == nil && (objects?.count)! > 0 {
                    for obj in objects! {
                        if obj["password"] as! String == self.passwordTextField.text! {
                            self.resignFirstResponder()
                            UserDefaults.standard.set(self.usernameTextField.text, forKey: "app_username")
                            UserDefaults.standard.set(self.passwordTextField.text, forKey: "app_password")
                            UserDefaults.standard.set(obj["role"] as! Int, forKey: "app_role")
                            UserDefaults.standard.set(obj["matricola"] as! String, forKey: "app_matricola")
                            self.hud.dismiss()
                            UserDefaults.standard.set(true, forKey: "logged")
                            
                            let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                            let userId = status.subscriptionStatus.userId
                            
                            let qu = PFQuery(className: "notificationCodes")
                            qu.whereKey("username", equalTo: self.usernameTextField.text!)
                            qu.findObjectsInBackground(block: { (objects, error) in
                                if error == nil && objects!.count > 0 {
                                    for obj in objects! {
                                        obj.deleteInBackground()
                                    }
                                    let object = PFObject(className: "notificationCodes")
                                    object["username"] = self.usernameTextField.text!
                                    object["notification_code"] = userId!
                                    object.saveInBackground(block: { (success, error) in
                                        if success {
                                            self.performSegue(withIdentifier: "login", sender: nil)
                                        }
                                    })
                                } else if objects!.count == 0 {
                                    let object = PFObject(className: "notificationCodes")
                                    object["username"] = self.usernameTextField.text!
                                    object["notification_code"] = userId!
                                    object.saveInBackground(block: { (success, error) in
                                        if success {
                                            self.performSegue(withIdentifier: "login", sender: nil)
                                        }
                                    })
                                }
                            })
                        } else {
                            let appearance = SCLAlertView.SCLAppearance(
                                showCloseButton: false
                            )
                            let alertView = SCLAlertView(appearance: appearance)
                            alertView.addButton("Ok") {
                                alertView.dismiss(animated: true, completion: nil)
                            }
                            alertView.showError("Errore", subTitle: "Username o password errati. Riprova")
                            self.usernameTextField.text = ""
                            self.passwordTextField.text = ""
                            self.hud.dismiss()
                            self.resignFirstResponder()
                        }
                    }
                } else {
                    self.usernameTextField.text = ""
                    self.passwordTextField.text = ""
                    self.hud.dismiss()
                    self.resignFirstResponder()
                    
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.addButton("Ok") {
                        alertView.dismiss(animated: true, completion: nil)
                    }
                    alertView.showError("Errore", subTitle: "Username o password errati. Riprova")
                }
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "signUp", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "login" {
            let dest = segue.destination as! DisambuguazioneViewController
            dest.username = self.usernameTextField.text!
        }
    }
    
    @IBAction func lostPasswordTapped(_ sender: UIButton) {
        
        if !(self.usernameTextField.text!.isEmpty) {
            
            let query = PFQuery(className: "users")
            query.whereKey("username", equalTo: self.usernameTextField.text!)
            query.limit = 10000
            query.findObjectsInBackground { (users, error) in
                if error == nil && users!.count > 0 {
                    for user in users! {
                        let password = user["password"] as! String
                        let email = user["email"] as! String
                        
                        var recipients = [Any]()
                        recipients.append(["Email": email])
                        
                        let body: [String: Any] = [
                            "FromEmail": "noreply.missioni118@gmail.com",
                            "FromName": "Missioni 118",
                            "Subject": "La password del tuo account",
                            "Text-part": "Come da tua richiesta ti abbiamo inviato la password per il tuo account con username: \(self.usernameTextField.text!). \n\nLa password è: \(password). \n\nSe vorrai potrai cambiarla all'interno dell'app dopo aver eseguito il login.",
                            "Recipients": recipients
                        ]
                        
                        let username_key =  "e7b7e9e69e309a866df37cb23324b9a0"
                        let password_key = "63726ad3ea14d52a33e30ad1c124a421"
                        let loginString = NSString(format: "%@:%@", username_key, password_key)
                        let loginData = loginString.data(using: String.Encoding.utf8.rawValue)!
                        let base64LoginString = loginData.base64EncodedString()

                        var request = URLRequest(url: URL(string: "https://api.mailjet.com/v3/send")!)
                        request.httpMethod = "POST"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.setValue("Basic <\(base64LoginString)>", forHTTPHeaderField: "Authorization")
                        
                        do {
                            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                        }
                        catch {
                            print("Error during JSON Serialization")
                            return
                        }
                        
                        let session = URLSession.shared
                        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                            
                            if error == nil {
                                let alert = UIAlertController(title: "Fatto!", message: "Ti abbiamo mandato un'email contenente la password da utilizzare per l'accesso. Controlla la tua casella di posta elettronica. Se non dovessi averla ricevuta controlla anche nella cartella SPAM.", preferredStyle: .alert)
                                let ok = UIAlertAction(title: "OK", style: .cancel)
                                alert.addAction(ok)
                                alert.show()
                            } else {
                                print("Error: " + error.debugDescription)
                            }
                        })
                        task.resume()
                    }
                }
            }
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("Ok") {
                alertView.dismiss(animated: true, completion: nil)
            }
            alertView.showWarning("Attenzione", subTitle: "Controlla di aver inserito il tuo username e riprova.")
        }
    }
}
