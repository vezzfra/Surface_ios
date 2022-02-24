//
//  GestioneTurniViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 02/12/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD

class GestioneTurniViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var icon404: UIImageView!
    
    var hud: JGProgressHUD = JGProgressHUD()
    var tipoTurni = [String]()
    var dataTurni = [Date]()
    var oraInizioTurni = [Date]()
    var oraFineTurni = [Date]()
    var turniPassati = [Bool]()
    let username = UserDefaults.standard.object(forKey: "app_username")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hud = JGProgressHUD(style: .dark)
        self.hud.textLabel.text = "Carico turni"
        self.hud.show(in: self.view)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.addSubview(self.refreshControl)
    
        self.loadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tipoTurni.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "turno_cell", for: indexPath) as! TurniTableViewCell
        
        cell.tipoLabel.text = self.tipoTurni[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dataTurno = dateFormatter.string(from: self.dataTurni[indexPath.row])
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "HH:mm"
        let ora_inizio = dateFormatter1.string(from: self.oraInizioTurni[indexPath.row])
        let ora_fine = dateFormatter1.string(from: self.oraFineTurni[indexPath.row])
        
        let oraTurno = "\(dataTurno) \(ora_inizio) - \(ora_fine)"
        cell.dataLabel.text = oraTurno
        
        switch self.tipoTurni[indexPath.row] {
        case "Convenzione":
            cell.icon.image = UIImage(named: "convenzione.png")
        case "Gettone":
            cell.icon.image = UIImage(named: "convenzione.png")
        case "Aggiuntiva":
            cell.icon.image = UIImage(named: "convenzione.png")
        case "Centralino":
            cell.icon.image = UIImage(named: "centralino.png")
        case "Formazione":
            cell.icon.image = UIImage(named: "formazione.png")
        case "Guardia Medica":
            cell.icon.image = UIImage(named: "gm.png")
        case "Altro":
            cell.icon.image = UIImage(named: "wait.png")
        default:
            print("default")
        }
        
        if self.turniPassati[indexPath.row] {
            cell.tickImage.image = UIImage(named: "tick.png")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func loadData() {
        
        self.tipoTurni.removeAll()
        self.dataTurni.removeAll()
        self.oraInizioTurni.removeAll()
        self.oraFineTurni.removeAll()
        self.turniPassati.removeAll()
        
        let q = PFQuery(className: "turni")
        q.whereKey("username", equalTo: self.username as! String)
        q.findObjectsInBackground { (turni, error) in
            if error == nil && (turni?.count)! > 0 {
                for turno in turni! {
                    self.tipoTurni.append(turno["tipo"] as! String)
                    self.dataTurni.append(turno["data"] as! Date)
                    self.oraInizioTurni.append(turno["ora_inizio"] as! Date)
                    self.oraFineTurni.append(turno["ora_fine"] as! Date)
                }
                self.hud.dismiss()
                self.icon404.isHidden = true
                self.tableView.reloadData()
                
                for data in self.dataTurni {
                    if data.timeIntervalSinceNow < 0 {
                        self.turniPassati.append(true)
                    } else {
                        self.turniPassati.append(false)
                    }
                }
                
            } else if error != nil {
                // Errore durante il download
                self.hud.dismiss()
                self.icon404.isHidden = false
                print("Errore: cannot parse element from class \"Servizi\"")
            } else {
                // Non ci sono turni sul server per l'username selezionato
                self.hud.dismiss()
                self.tableView.isHidden = true
                self.icon404.isHidden = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let alert = UIAlertController(title: "Attenzione!", message: "Vuoi davvero cancellare questo turno?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "No", style: .cancel)
            let yes = UIAlertAction(title: "Sì", style: .default) { (action) in
                let index = indexPath.row
                
                let hud = JGProgressHUD(style: .dark)
                hud.textLabel.text = "Elimino..."
                hud.show(in: self.view)
                
                let q = PFQuery(className: "turni")
                q.whereKey("username", equalTo: self.username as! String)
                q.whereKey("data", equalTo: self.dataTurni[index])
                q.whereKey("ora_inizio", equalTo: self.oraInizioTurni[index])
                q.whereKey("ora_fine", equalTo: self.oraFineTurni[index])
                q.whereKey("tipo", equalTo: self.tipoTurni[index])
                q.findObjectsInBackground(block: { (turni, error) in
                    if error == nil && (turni?.count)! > 0 {
                        for turno in turni! {
                            turno.deleteInBackground()
                        }
                        self.loadData()
                        hud.dismiss()
                    } else {
                        print("Error deleting shift")
                        hud.dismiss()
                    }
                })
            }
            alert.addAction(ok)
            alert.addAction(yes)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTurno(_ sender: UIButton) {
        self.performSegue(withIdentifier: "nuovo_turno", sender: nil)
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ViewController.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.loadData()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
}
