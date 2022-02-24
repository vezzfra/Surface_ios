//
//  GestioneSquadreViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 15/12/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import SkyFloatingLabelTextField

class GestioneSquadreViewController: UIViewController {
    
    @IBOutlet weak var inServizioSwitch: UISwitch!
    @IBOutlet weak var firstMemberField: SkyFloatingLabelTextField!
    @IBOutlet weak var secondMemberField: SkyFloatingLabelTextField!
    @IBOutlet weak var thirdMemberField: SkyFloatingLabelTextField!

    var senderTag = 0
    var isOnService = false
    var fromServer = false
    var numberInTeam = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "isOnService") {
            self.isOnService = true
            self.inServizioSwitch.isOn = true
            
            if !self.fromServer {
                self.firstMemberField.text = (UserDefaults.standard.object(forKey: "firstMember") as! String)
                self.secondMemberField.text = (UserDefaults.standard.object(forKey: "secondMember") as! String)
                self.thirdMemberField.text = (UserDefaults.standard.object(forKey: "thirdMember") as! String)
            } else {
                var key = ""
                switch numberInTeam {
                case 1:
                    key = "second"
                case 2:
                    key = "third"
                case 3:
                    key = "fourth"
                default:
                    key = "second"
                }
                
                let query = PFQuery(className: "Squadre")
                query.whereKey(key, equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
                query.findObjectsInBackground { (objects, error) in
                    if error == nil {
                        if objects!.count > 0 {
                            self.firstMemberField.text = "N.D."
                            self.secondMemberField.text = "N.D."
                            self.thirdMemberField.text = "N.D."
                            
                            let alert = UIAlertController(title: "Attenzione", message: "Sei stato aggiunto in una squadra da \(objects![0]["first"] as! String). Non puoi vedere gli altri membri né modificarli, ma puoi eliminarti dall'equipaggio spegnengo l'interruttore: \"Sono in servizio\"", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Ok", style: .cancel)
                            alert.addAction(ok)
                            alert.show()
                        }
                    }
                }
            }
        } else {
            self.isOnService = false
            self.inServizioSwitch.isOn = false
            
            self.firstMemberField.text = ""
            self.secondMemberField.text = ""
            self.thirdMemberField.text = ""
        }
    }
    
    @IBAction func openSearchController(_ sender: UIButton) {
        self.senderTag = sender.tag
        if self.isOnService {
            self.performSegue(withIdentifier: "openSearch", sender: nil)
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeSwitch(_ sender: UISwitch) {
        if sender.isOn {
            self.isOnService = true
        } else {
            self.isOnService = false
            if self.fromServer {
                var key = ""
                switch numberInTeam {
                case 1:
                    key = "second"
                case 2:
                    key = "third"
                case 3:
                    key = "fourth"
                default:
                    key = "second"
                }
                
                let query = PFQuery(className: "Squadre")
                query.whereKey(key, equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
                query.findObjectsInBackground { (objects, error) in
                    if error == nil {
                        if objects!.count > 0 {
                            for obj in objects! {
                                obj[key] = ""
                                obj.saveInBackground()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func backAndSave(_ sender: UIButton) {
        if self.isOnService {
            if (self.firstMemberField.text?.isEmpty)! && (self.secondMemberField.text?.isEmpty)! && (self.thirdMemberField.text?.isEmpty)! {
                self.dismiss(animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(true, forKey: "isOnService")
                UserDefaults.standard.set(self.firstMemberField.text!, forKey: "firstMember")
                UserDefaults.standard.set(self.secondMemberField.text, forKey: "secondMember")
                UserDefaults.standard.set(self.thirdMemberField.text!, forKey: "thirdMember")
                UserDefaults.standard.set(Date(), forKey: "inServizioDate")
                UserDefaults.standard.synchronize()
                
                let squadra: PFObject = PFObject(className: "Squadre")
                squadra["first"] = UserDefaults.standard.object(forKey: "app_username") as! String
                squadra["second"] = self.firstMemberField.text!
                squadra["third"] = self.secondMemberField.text!
                squadra["fourth"] = self.thirdMemberField.text!
                squadra.saveInBackground { (success, error) in
                    if error == nil {
                        if success {
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: "Errore", message: "Impossibile caricare le squadre sul server al momento. Riprova più tardi.", preferredStyle: .alert)
                            let ok = UIAlertAction(title: "Ok", style: .cancel)
                            alert.addAction(ok)
                            alert.show()
                        }
                    } else {
                        let alert = UIAlertController(title: "Errore", message: "Impossibile caricare le squadre sul server al momento. Controlla la tua connessione internet e riprova.", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "Ok", style: .cancel)
                        alert.addAction(ok)
                        alert.show()
                    }
                }
            }
        } else {
            if !self.fromServer {
                let query = PFQuery(className: "Squadre")
                query.whereKey("first", equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
                query.limit = 10000
                query.findObjectsInBackground { (squadre, error) in
                    if error == nil {
                        if squadre!.count > 0 {
                            for squadra in squadre! {
                                squadra.deleteInBackground()
                            }
                            UserDefaults.standard.set(false, forKey: "isOnService")
                            UserDefaults.standard.removeObject(forKey: "firstMember")
                            UserDefaults.standard.removeObject(forKey: "secondMember")
                            UserDefaults.standard.removeObject(forKey: "thirdMember")
                            UserDefaults.standard.synchronize()
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            UserDefaults.standard.set(false, forKey: "isOnService")
                            UserDefaults.standard.removeObject(forKey: "firstMember")
                            UserDefaults.standard.removeObject(forKey: "secondMember")
                            UserDefaults.standard.removeObject(forKey: "thirdMember")
                            UserDefaults.standard.synchronize()
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func updateTextField(tag: Int, user: String) {
        switch tag {
        case 10:
            self.firstMemberField.text = user
        case 20:
            self.secondMemberField.text = user
        case 30:
            self.thirdMemberField.text = user
        default:
            print("default")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openSearch" {
            let dest = segue.destination as! SearchUsersViewController
            dest.tag = self.senderTag
            dest.delegate = self

            dest.firstMember = self.firstMemberField.text!
            dest.secondMember = self.secondMemberField.text!
            dest.thirdMember = self.thirdMemberField.text!
        }
    }
}
