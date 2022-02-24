//
//  ManageAccountViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 02/03/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD
import SCLAlertView
import RLBAlertsPickers

class ManageAccountViewController: UIViewController {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var ruoloLabel: UILabel!
    @IBOutlet weak var titleInfoLabel: UILabel!
    @IBOutlet weak var turnoLabel: UILabel!
    
    var hud: JGProgressHUD = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var ruoli = ["Allievo", "Soccorritore", "Capo equipaggio", "Autista"]

        self.titleInfoLabel.text = (UserDefaults.standard.object(forKey: "app_username") as! String)
        
        self.hud = JGProgressHUD(style: .dark)
        self.hud.textLabel.text = "Aggiorno"
        self.hud.show(in: self.view)
        
        let query = PFQuery(className: "users")
        query.whereKey("username", equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
        query.findObjectsInBackground { (objects, error) in
            if error == nil && objects!.count == 1 {
                for obj in objects! {
                    self.ruoloLabel.text = "Ruolo: \(ruoli[obj["role"] as! Int])"
                    self.turnoLabel.text =  "Turno: \(obj["turno"] as! String)"
                    if (obj["gender"] as! String == "M") {
                        print("male")
                        self.profilePicture.image = UIImage(named: "man.jpg")
                    } else {
                        self.profilePicture.image = UIImage(named: "woman.jpg")
                    }
                }
                self.hud.dismiss()
            } else {
                self.hud.dismiss()
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("Ok") {
                    alertView.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                alertView.showError("Errore", subTitle: "Si è verificato un errore inatteso, si prega di riprovare.")
            }
        }
    }
    
    @IBAction func backHome(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendFeedback(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToFAQ", sender: nil)
    }
    
    @IBAction func changePassword(_ sender: UIButton) {
        
        var vecchiaPWD = ""
        var nuovaPWD = ""
        var confermaPWD = ""
        
        let alert = UIAlertController(style: .alert, title: "Vecchia password")
        let config: TextField.Config = { textField in
            textField.becomeFirstResponder()
            textField.textColor = .black
            textField.textAlignment = .center
            textField.isSecureTextEntry = true
            textField.placeholder = "Vecchia password"
            textField.leftViewPadding = 12
            textField.borderWidth = 1
            textField.cornerRadius = 8
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.isSecureTextEntry = true
            textField.returnKeyType = .done
            textField.action { textField in
                vecchiaPWD = textField.text!
            }
        }
        alert.addOneTextField(configuration: config)
        alert.addAction(title: "Avanti", style: .cancel) { (action) in
            if vecchiaPWD == (UserDefaults.standard.object(forKey: "app_password") as! String) {
                let alert1 = UIAlertController(style: .alert, title: "Nuova password")
                
                let configOne: TextField.Config = { textField in
                    textField.leftViewPadding = 16
                    textField.leftTextPadding = 12
                    textField.becomeFirstResponder()
                    textField.backgroundColor = nil
                    textField.textColor = .black
                    textField.isSecureTextEntry = true
                    textField.placeholder = "Nuova password"
                    textField.clearButtonMode = .whileEditing
                    textField.keyboardAppearance = .default
                    textField.keyboardType = .default
                    textField.returnKeyType = .done
                    textField.action { textField in
                        nuovaPWD = textField.text!
                    }
                }
                
                let configTwo: TextField.Config = { textField in
                    textField.textColor = .black
                    textField.placeholder = "Conferma nuova password"
                    textField.leftViewPadding = 16
                    textField.leftTextPadding = 12
                    textField.borderWidth = 1
                    textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
                    textField.backgroundColor = nil
                    textField.clearsOnBeginEditing = true
                    textField.keyboardAppearance = .default
                    textField.keyboardType = .default
                    textField.isSecureTextEntry = true
                    textField.returnKeyType = .done
                    textField.action { textField in
                        confermaPWD = textField.text!
                    }
                }
                
                // vInset - is top and bottom margin of two textFields
                alert1.addTwoTextFields(vInset: 12, textFieldOne: configOne, textFieldTwo: configTwo)
                alert1.addAction(title: "Salva", style: .cancel) { (action) in
                    if nuovaPWD == confermaPWD {
                        
                        self.hud.textLabel.text = "Salvo nuova password"
                        self.hud.show(in: self.view)
                        
                        let query = PFQuery(className: "users")
                        query.whereKey("username", equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
                        query.findObjectsInBackground(block: { (objects, error) in
                            if error == nil {
                                for obj in objects! {
                                    obj["password"] = nuovaPWD
                                    obj.saveInBackground(block: { (succ, error) in
                                        if error == nil && succ {
                                            UserDefaults.standard.set(nuovaPWD, forKey: "app_password")
                                            UserDefaults.standard.synchronize()
                                            
                                            let appearance = SCLAlertView.SCLAppearance(
                                                showCloseButton: false
                                            )
                                            let alertView = SCLAlertView(appearance: appearance)
                                            alertView.addButton("Ok") {
                                                alertView.dismiss(animated: true, completion: nil)
                                            }
                                            alertView.showSuccess("Fatto!", subTitle: "La password è stata modificata con successo.")
                                        } else {
                                            self.hud.dismiss()
                                            let appearance = SCLAlertView.SCLAppearance(
                                                showCloseButton: false
                                            )
                                            let alertView = SCLAlertView(appearance: appearance)
                                            alertView.addButton("Ok") {
                                                alertView.dismiss(animated: true, completion: nil)
                                            }
                                            alertView.showError("Errore", subTitle: "Si è verificato un errore inatteso, si prega di riprovare.")
                                        }
                                    })
                                }
                            } else {
                                self.hud.dismiss()
                                let appearance = SCLAlertView.SCLAppearance(
                                    showCloseButton: false
                                )
                                let alertView = SCLAlertView(appearance: appearance)
                                alertView.addButton("Ok") {
                                    alertView.dismiss(animated: true, completion: nil)
                                }
                                alertView.showError("Errore", subTitle: "Si è verificato un errore inatteso, si prega di riprovare.")
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
                        alertView.showError("Errore", subTitle: "Le password non corrispondono.")
                    }
                }
                self.show(alert1, sender: nil)
            } else {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("Ok") {
                    alertView.dismiss(animated: true, completion: nil)
                }
                alertView.showError("Errore", subTitle: "La password inserita non è corretta. Riprova.")
            }
        }
        self.show(alert, sender: nil)
    }
}
