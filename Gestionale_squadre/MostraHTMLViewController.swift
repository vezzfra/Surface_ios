//
//  MostraHTMLViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 01/03/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD
import RLBAlertsPickers

class MostraHTMLViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var formatoreLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var titleInfoLabel: UILabel!
    
    var selectedScheda = 0
    var selectedMode = 0
    var codiciInvio = [String]()
    var codiciTrasporto = [String]()
    var noteMissioni = [String]()
    var notePositivi = ""
    var noteMigliorabili = ""
    
    var hud: JGProgressHUD = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.titleInfoLabel.text = "Scheda n: \(self.selectedScheda)"
        
        var classname = ""
        switch self.selectedMode {
        case 1:
            classname = "schedeAllievo"
        case 2:
            classname = "schedeCS"
        default:
            classname = ""
        }
        
        self.hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Carico scheda..."
        self.hud.show(in: self.view)
        
        let query = PFQuery(className: classname)
        query.whereKey("allievo", equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
        query.whereKey("numero_scheda", equalTo: self.selectedScheda)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                for obj in objects! {
                    self.codiciInvio = obj["codici_invio"] as! [String]
                    self.codiciTrasporto = obj["codici_trasporto"] as! [String]
                    self.noteMissioni = obj["note_missioni"] as! [String]
                    self.notePositivi = obj["aspetti_positivi"] as! String
                    self.noteMigliorabili = obj["aspetti_migliorabili"] as! String
                    self.formatoreLabel.text = "Valutato da: \(obj["formatore"] as! String)"
                    self.dataLabel.text = "Data: \(obj["data"] as! String)"
                }
                self.tableView.reloadData()
                self.hud.dismiss()
            } else {
                self.hud.dismiss()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.codiciInvio.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! ServizioCSTableViewCell
        
        cell.codiceInvioLabel.text = "Invio: \(self.codiciInvio[indexPath.row])"
        cell.codiceTrasportoLabel.text = "Trasporto: \(self.codiciTrasporto[indexPath.row])"
        cell.noteLabel.text = "Note: \(self.noteMissioni[indexPath.row])"
        
        return cell
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showNoteAggiuntive(_ sender: UIButton) {
        if sender.backgroundImage(for: .normal) == UIImage(named: "thumb.png") {
            let alert = UIAlertController(title: "Aspetti positivi", message: nil, preferredStyle: .actionSheet)
            if self.notePositivi != "" {
                alert.addTextViewer(text: TextViewerViewController.Kind.text(self.notePositivi))
            } else {
                alert.addTextViewer(text: TextViewerViewController.Kind.text("Non sono state aggiunte queste note nella scheda. Chiedi di più a chi ti ha valutato."))
            }
            alert.addAction(title: "Chiudi", style: .cancel)
            self.show(alert, sender: nil)
        } else {
            let alert = UIAlertController(title: "Aspetti migliorabili", message: nil, preferredStyle: .actionSheet)
            if self.noteMigliorabili != "" {
                alert.addTextViewer(text: TextViewerViewController.Kind.text(self.noteMigliorabili))
            } else {
                alert.addTextViewer(text: TextViewerViewController.Kind.text("Non sono state aggiunte queste note nella scheda. Chiedi di più a chi ti ha valutato."))
            }
            alert.addAction(title: "Chiudi", style: .cancel)
            self.show(alert, sender: nil)
        }
    }
}
