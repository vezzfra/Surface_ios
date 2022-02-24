//
//  LeMieSchedeViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 28/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD

class LeMieSchedeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectType: UISegmentedControl!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var hud: JGProgressHUD = JGProgressHUD()
    var schede: [String] = [String]()
    var schedeAutista = [(String, String, Int, String, String, String, String)]()
    var selectedCode = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if let user = UserDefaults.standard.object(forKey: "app_role") as? Int {
            if user == 0 {
                self.hud = JGProgressHUD(style: .dark)
                hud.textLabel.text = "Carico schede"
                self.selectType.selectedSegmentIndex = 0
                self.getAllievo()
            } else if user == 1 {
                self.hud = JGProgressHUD(style: .dark)
                hud.textLabel.text = "Carico schede"
                self.selectType.selectedSegmentIndex = 1
                self.getCS()
            } else if user > 1 {
                self.hud = JGProgressHUD(style: .dark)
                hud.textLabel.text = "Carico schede"
                self.selectType.selectedSegmentIndex = 2
                self.getAutista()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectType.selectedSegmentIndex == 0 || self.selectType.selectedSegmentIndex == 1 {
            return self.schede.count
        } else {
            return self.schedeAutista.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.selectType.selectedSegmentIndex == 0 || self.selectType.selectedSegmentIndex == 1 {
            return 80
        } else {
            return 150
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.selectType.selectedSegmentIndex == 0 || self.selectType.selectedSegmentIndex == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "allievoCsCell", for: indexPath) as! MieSchedeTableViewCell
            
            cell.descriptionLabel.text = "Scheda n: #\(self.schede[indexPath.row])"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "autistaCell", for: indexPath) as! SchedeAutistaTableViewCell
            
            cell.numeroScheda.text = "Scheda n: #\(String(describing: self.schedeAutista[indexPath.row].2))"
            cell.dataScheda.text = "Data: \(self.schedeAutista[indexPath.row].0)"
            cell.kmPercorsi.text = "Km: \(self.schedeAutista[indexPath.row].1)"
            cell.percorso.text = "Percorso: \(self.schedeAutista[indexPath.row].3)"
            cell.note.text = "Note: \(self.schedeAutista[indexPath.row].5)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectType.selectedSegmentIndex == 0 || self.selectType.selectedSegmentIndex == 1 {
            //Mostra html
            self.selectedCode = Int(self.schede[indexPath.row])!
            self.performSegue(withIdentifier: "showHTML", sender: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getAllievo() {
        self.schede.removeAll()
        self.hud.show(in: self.view)
        let query = PFQuery(className: "schedeAllievo")
        query.whereKey("allievo", equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
        query.findObjectsInBackground { (objects, error) in
            if error == nil && objects!.count > 0 {
                self.tableView.isHidden = false
                for obj in objects! {
                    self.schede.append(String(describing: obj["numero_scheda"] as! Int))
                }
                self.tableView.reloadData()
                self.hud.dismiss()
            } else {
                self.tableView.isHidden = true
                self.errorLabel.text = "Nessuna scheda trovata a tuo nome per: Allievo"
                self.hud.dismiss()
            }
        }
    }
    
    func getCS() {
        self.schede.removeAll()
        self.hud.show(in: self.view)
        let query1 = PFQuery(className: "schedeCS")
        query1.whereKey("allievo", equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
        query1.findObjectsInBackground { (objects, error) in
            if error == nil && objects!.count > 0 {
                self.tableView.isHidden = false
                for obj in objects! {
                    self.schede.append(String(describing: obj["numero_scheda"] as! Int))
                }
                self.tableView.reloadData()
                self.hud.dismiss()
            } else {
                self.tableView.isHidden = true
                self.errorLabel.text = "Nessuna scheda trovata a tuo nome per: Capo Equipaggio"
                self.hud.dismiss()
            }
        }
    }
    
    func getAutista() {
        self.schede.removeAll()
        self.schedeAutista.removeAll()
        self.hud.show(in: self.view)
        let query = PFQuery(className: "schedeAutista")
        query.whereKey("allievo", equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
        query.findObjectsInBackground { (objects, error) in
            if error == nil && objects!.count > 0 {
                self.tableView.isHidden = false
                for obj in objects! {
                    self.schedeAutista.append((obj["data"] as! String, obj["km"] as! String, obj["numeroGuida"] as! Int, obj["percorso"] as! String, obj["mezzo"] as! String, obj["note"] as! String, obj["formatore"] as! String))
                }
                self.tableView.reloadData()
                self.hud.dismiss()
            } else {
                self.tableView.isHidden = true
                self.errorLabel.text = "Nessuna scheda trovata a tuo nome per: Autista"
                self.hud.dismiss()
            }
        }
    }
    
    @IBAction func changeType(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.getAllievo()
        } else if sender.selectedSegmentIndex == 1 {
            self.getCS()
        } else {
            self.getAutista()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHTML" {
            let dest = segue.destination as! MostraHTMLViewController
            dest.selectedScheda = self.selectedCode
            if self.selectType.selectedSegmentIndex == 0 {
                dest.selectedMode = 1
            } else if self.selectType.selectedSegmentIndex == 1 {
                dest.selectedMode = 2
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
