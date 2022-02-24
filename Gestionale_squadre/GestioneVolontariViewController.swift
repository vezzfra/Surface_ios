//
//  GestioneVolontariViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 20/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit

class GestioneVolontariViewController: UIViewController {
    
    var addSchedeIsEnabled = false
    var addAutistaIsEnabled = false
    
    var comingFrom = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "app_role") as! Int == 2 || UserDefaults.standard.object(forKey: "app_username") as! String == "vezzoli.francesco" {
            self.addSchedeIsEnabled = true
        }
        if UserDefaults.standard.object(forKey: "app_role") as! Int == 3 || UserDefaults.standard.object(forKey: "app_username") as! String == "vezzoli.francesco" {
            self.addSchedeIsEnabled = true
            self.addAutistaIsEnabled = true
        }
    }
    
    @IBAction func addAllievo(_ sender: UIButton) {
        if self.addSchedeIsEnabled {
            self.comingFrom = 0
            self.performSegue(withIdentifier: "createSchedaCS", sender: nil)
        } else {
            let alert = UIAlertController(title: "Ops...", message: "Non sei autorizzato ad inserire schede", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func addCS(_ sender: UIButton) {
        if self.addSchedeIsEnabled {
            self.comingFrom = 1
            self.performSegue(withIdentifier: "createSchedaCS", sender: nil)
        } else {
            let alert = UIAlertController(title: "Ops...", message: "Non sei autorizzato ad inserire schede", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func addAutista(_ sender: UIButton) {
        if self.addAutistaIsEnabled {
            self.performSegue(withIdentifier: "newAutista", sender: nil)
        } else {
            let alert = UIAlertController(title: "Ops...", message: "Non sei autorizzato ad inserire schede autista", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func openSchede(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showMySchede", sender: nil)
    }
    
    @IBAction func backHome(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createSchedaCS" {
            let dest = segue.destination as! NuovaSchedaSoccorritoreViewController
            dest.selectedRole = self.comingFrom
        }
    }
}
