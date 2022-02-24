//
//  DisambuguazioneViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 20/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit
import JGProgressHUD
import Parse
import SCLAlertView
import OneSignal

class DisambuguazioneViewController: UIViewController {
    @IBOutlet weak var mezziView: UIView!
    @IBOutlet weak var volontariView: UIView!
    @IBOutlet weak var missioniButton: UIButton!
    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var viola28: UIButton!
    @IBOutlet weak var viola29: UIButton!
    @IBOutlet weak var viola30: UIButton!
    @IBOutlet weak var mySchede: UIButton!
    @IBOutlet weak var newSchedaAllievo: UIButton!
    @IBOutlet weak var newSchedaCS: UIButton!
    @IBOutlet weak var newSchedaAutista: UIButton!
 
    var username = ""
    var mezzo = ""
    var code = ""
    var checkMezzo = ""
    var hud: JGProgressHUD = JGProgressHUD()
    var addSchedeIsEnabled = false
    var addAutistaIsEnabled = false
    var comingFrom = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.viola28.alpha = 0.0
        self.viola29.alpha = 0.0
        self.viola30.alpha = 0.0
        self.mySchede.alpha = 0.0
        self.newSchedaAllievo.alpha = 0.0
        self.newSchedaCS.alpha = 0.0
        self.newSchedaAutista.alpha = 0.0
        
        if self.username == "" {
            self.username = UserDefaults.standard.object(forKey: "app_username") as! String
        }
        
        if self.username != "vezzoli.francesco" {
            self.missioniButton.isHidden = true
        }
        
        self.hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Contatto il server"
        self.hud.show(in: self.view)
        
        PFUser.logOutInBackground()
        PFUser.logInWithUsername(inBackground: "admin", password: "CroceViola4me") { (user, error) in
            if error == nil {
                let acl = PFACL()
                acl.hasPublicReadAccess = true
                acl.hasPublicWriteAccess = true
                PFACL.setDefault(acl, withAccessForCurrentUser: true)
            }
        }
        
        if UserDefaults.standard.object(forKey: "app_role") as! Int >= 1 {
            let q = PFQuery(className: "users")
            q.whereKey("username", equalTo: self.username)
            q.findObjectsInBackground { (objects, error) in
                if error == nil {
                    self.hud.textLabel.text = "Aggiorno stato"
                    for obj in objects! {
                        UserDefaults.standard.set(obj["role"] as! Int, forKey: "app_role")
                    }
                    self.update()
                } else {
                    self.hud.dismiss()
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.showError("Ops...", subTitle: "Impossibile comunicare con il server. Verifica che la connessione ad internet sia attiva, chiudi l'app e riprova.")
                }
            }
        } else {
            let q = PFQuery(className: "users")
            q.whereKey("username", equalTo: self.username)
            q.findObjectsInBackground { (objects, error) in
                if error == nil {
                    for obj in objects! {
                        UserDefaults.standard.set(obj["role"] as! Int, forKey: "app_role")
                    }
                    self.hud.dismiss()
                } else {
                    self.hud.dismiss()
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.showError("Ops...", subTitle: "Impossibile comunicare con il server. Verifica che la connessione ad internet sia attiva, chiudi l'app e riprova.")
                }
            }
        }
        self.nomeLabel.text = self.username
        
        if UserDefaults.standard.object(forKey: "app_role") as! Int == 2 || UserDefaults.standard.object(forKey: "app_username") as! String == "vezzoli.francesco" {
            self.addSchedeIsEnabled = true
        }
        if UserDefaults.standard.object(forKey: "app_role") as! Int == 3 || UserDefaults.standard.object(forKey: "app_username") as! String == "vezzoli.francesco" {
            self.addSchedeIsEnabled = true
            self.addAutistaIsEnabled = true
        }
    }
    
    @IBAction func checkMissions(_ sender: UIButton) {
        self.performSegue(withIdentifier: "login_mission", sender: nil)
    }
    
    @IBAction func manageSquad(_ sender: UIButton) {
        
        for cons in self.volontariView.constraints {
            if cons.identifier == "volontariHeight" {
                if cons.constant == 420 {
                    // View allargata
                    UIView.animate(withDuration: 0.5) {
                        cons.constant = 185
                        for con in self.mezziView.constraints {
                            if con.identifier == "viewHeightConstraint" {
                                con.constant = 185
                            }
                        }
                        self.mySchede.alpha = 0.0
                        self.newSchedaAutista.alpha = 0.0
                        self.newSchedaCS.alpha = 0.0
                        self.newSchedaAllievo.alpha = 0.0
                        self.view.layoutIfNeeded()
                    }
                } else if cons.constant == 185 {
                    // View da allargare
                    UIView.animate(withDuration: 0.5) {
                        cons.constant = 420
                        for con in self.mezziView.constraints {
                            if con.identifier == "viewHeightConstraint" {
                                con.constant = 0
                            }
                        }
                        self.mySchede.alpha = 1.0
                        self.newSchedaAutista.alpha = 1.0
                        self.newSchedaCS.alpha = 1.0
                        self.newSchedaAllievo.alpha = 1.0
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    @IBAction func manageAmbulance(_ sender: UIButton) {
        
        for cons in self.mezziView.constraints {
            if cons.identifier == "viewHeightConstraint" {
                if cons.constant == 370 {
                    // View allargata
                    UIView.animate(withDuration: 0.5) {
                        cons.constant = 185
                        self.volontariView.alpha = 1.0
                        self.viola28.alpha = 0.0
                        self.viola29.alpha = 0.0
                        self.viola30.alpha = 0.0
                        self.view.layoutIfNeeded()
                    }
                } else if cons.constant == 185 {
                    // View da allargare
                    UIView.animate(withDuration: 0.5) {
                        cons.constant = 370
                        self.volontariView.alpha = 0.0
                        self.viola28.alpha = 1.0
                        self.viola29.alpha = 1.0
                        self.viola30.alpha = 1.0
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Attenzione", message: "Vuoi davvero eseguire il logout?", preferredStyle: .alert)
        let no = UIAlertAction(title: "No", style: .cancel)
        let ok = UIAlertAction(title: "Procedi", style: .default) { (action) in
            UserDefaults.standard.set(false, forKey: "logged")
            self.performSegue(withIdentifier: "logout", sender: nil)
        }
        alert.addAction(no)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func  manageAccount(_ sender: UIButton) {
        self.performSegue(withIdentifier: "manageAccount", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login_mission" {
            let dest = segue.destination as! ViewController
            dest.username = self.username
        } else if segue.identifier == "logout" {
            self.dismiss(animated: true, completion: nil)
        } else if segue.identifier == "goToMezzo" {
            let dest = segue.destination as! GestioneMezziViewController
            dest.mezzoSelezionato = self.mezzo
        } else if segue.identifier == "showCheck" {
            let dest = segue.destination as! ShowCheckViewController
            dest.htmlCode = self.code
            dest.mezzo = self.checkMezzo
        } else if segue.identifier == "createSchedaCS" {
            let dest = segue.destination as! NuovaSchedaSoccorritoreViewController
            dest.selectedRole = self.comingFrom
        }
    }
    
    func update() {
        self.hud.textLabel.text = "Controllo notifiche"
        let q = PFQuery(className: "checklist")
        q.whereKey("directed_to", equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
        q.findObjectsInBackground { (objects, error) in
            if error == nil {
                if objects!.count == 1 {
                    for object in objects! {
                        self.code = object["html_code"] as! String
                        self.checkMezzo = object["mezzo"] as! String
                    }
                    self.hud.dismiss()
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.addButton("Rifiuta") {
                        alertView.dismiss(animated: true, completion: nil)
                    }
                    alertView.addButton("Verifica") {
                        self.performSegue(withIdentifier: "showCheck", sender: nil)
                        alertView.dismiss(animated: true, completion: nil)
                    }
                    alertView.showWarning("Attenzione", subTitle: "Un allievo ha richiesto l'approvazione di una checklist indicandoti come membro dell'equipaggio.")
                } else {
                    self.hud.dismiss()
                }
            } else {
                self.hud.dismiss()
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.showError("Ops...", subTitle: "Impossibile comunicare con il server. Verifica che la connessione ad internet sia attiva, chiudi l'app e riprova.")
            }
        }
    }
    
    @IBAction func goToMezziManagement(_ sender: UIButton) {
        self.mezzo = (sender.titleLabel?.text!)!
        //Chiudi view mezzi
        for cons in self.mezziView.constraints {
            if cons.identifier == "viewHeightConstraint" {
                cons.constant = 185
                self.volontariView.alpha = 1.0
                self.viola28.alpha = 0.0
                self.viola29.alpha = 0.0
                self.viola30.alpha = 0.0
            }
        }
        // Segue alla pagina della checklist
        self.performSegue(withIdentifier: "goToMezzo", sender: nil)
    }
    
    @IBAction func addAllievo(_ sender: UIButton) {
        if self.addSchedeIsEnabled {
            self.comingFrom = 0
            for cons in self.volontariView.constraints {
                if cons.identifier == "volontariHeight" {
                    cons.constant = 185
                    for con in self.mezziView.constraints {
                        if con.identifier == "viewHeightConstraint" {
                            con.constant = 185
                        }
                    }
                    self.mySchede.alpha = 0.0
                    self.newSchedaAutista.alpha = 0.0
                    self.newSchedaCS.alpha = 0.0
                    self.newSchedaAllievo.alpha = 0.0
                }
            }
            self.performSegue(withIdentifier: "createSchedaCS", sender: nil)
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("Ok") {
                alertView.dismiss(animated: true, completion: nil)
            }
            alertView.showWarning("Ops...", subTitle: "Non sei autorizzato ad inserire schede")
        }
    }
    
    @IBAction func addCS(_ sender: UIButton) {
        if self.addSchedeIsEnabled {
            self.comingFrom = 1
            for cons in self.volontariView.constraints {
                if cons.identifier == "volontariHeight" {
                    cons.constant = 185
                    for con in self.mezziView.constraints {
                        if con.identifier == "viewHeightConstraint" {
                            con.constant = 185
                        }
                    }
                    self.mySchede.alpha = 0.0
                    self.newSchedaAutista.alpha = 0.0
                    self.newSchedaCS.alpha = 0.0
                    self.newSchedaAllievo.alpha = 0.0
                }
            }
            self.performSegue(withIdentifier: "createSchedaCS", sender: nil)
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("Ok") {
                alertView.dismiss(animated: true, completion: nil)
            }
            alertView.showWarning("Ops...", subTitle: "Non sei autorizzato ad inserire schede")
        }
    }
    
    @IBAction func addAutista(_ sender: UIButton) {
        if self.addAutistaIsEnabled {
            for cons in self.volontariView.constraints {
                if cons.identifier == "volontariHeight" {
                    cons.constant = 185
                    for con in self.mezziView.constraints {
                        if con.identifier == "viewHeightConstraint" {
                            con.constant = 185
                        }
                    }
                    self.mySchede.alpha = 0.0
                    self.newSchedaAutista.alpha = 0.0
                    self.newSchedaCS.alpha = 0.0
                    self.newSchedaAllievo.alpha = 0.0
                }
            }
            self.performSegue(withIdentifier: "newAutista", sender: nil)
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("Ok") {
                alertView.dismiss(animated: true, completion: nil)
            }
            alertView.showWarning("Ops...", subTitle: "Non sei autorizzato ad inserire schede per autisti")
        }
    }
    
    @IBAction func openSchede(_ sender: UIButton) {
        for cons in self.volontariView.constraints {
            if cons.identifier == "volontariHeight" {
                cons.constant = 185
                for con in self.mezziView.constraints {
                    if con.identifier == "viewHeightConstraint" {
                        con.constant = 185
                    }
                }
                self.mySchede.alpha = 0.0
                self.newSchedaAutista.alpha = 0.0
                self.newSchedaCS.alpha = 0.0
                self.newSchedaAllievo.alpha = 0.0
            }
        }
        self.performSegue(withIdentifier: "showMySchede", sender: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for cons in self.volontariView.constraints {
            if cons.constant == 420 {
                // View allargata
                UIView.animate(withDuration: 0.5) {
                    cons.constant = 185
                    for con in self.mezziView.constraints {
                        if con.identifier == "viewHeightConstraint" {
                            con.constant = 185
                        }
                    }
                    self.mySchede.alpha = 0.0
                    self.newSchedaAutista.alpha = 0.0
                    self.newSchedaCS.alpha = 0.0
                    self.newSchedaAllievo.alpha = 0.0
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        for cons in self.mezziView.constraints {
            if cons.constant == 370 {
                // View allargata
                UIView.animate(withDuration: 0.5) {
                    cons.constant = 185
                    self.volontariView.alpha = 1.0
                    self.viola28.alpha = 0.0
                    self.viola29.alpha = 0.0
                    self.viola30.alpha = 0.0
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        super.touchesBegan(touches, with: event)
    }
}
