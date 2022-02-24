//
//  NuovoTurnoViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 02/12/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD

class NuovoTurnoViewController: UIViewController {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var tipoField: UITextField!
    @IBOutlet weak var dataField: UITextField!
    @IBOutlet weak var oraInizioField: UITextField!
    @IBOutlet weak var oraFineField: UITextField!
    
    var dataDelTurno = Date()
    var oraInizioTurno = Date()
    var oraFineTurno = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func newTipo(_ sender: UIButton) {
        let alert = UIAlertController(title: "Tipologia servizio", message: nil, preferredStyle: .actionSheet)
        let contentArray: [String] = ["Convenzione", "Gettone", "Aggiuntiva", "Centralino", "Guardia Medica", "Formazione", "Altro"]
        let pickerViewValues: [[String]] = [contentArray]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.tipoField.text = contentArray[index.row]
        }
        
        let cancel = UIAlertAction(title: "Fatto", style: .cancel) { (action) in
            if self.tipoField.text == "Centralino" {
                self.icon.image = UIImage(named: "centralino.png")
            } else if self.tipoField.text == "Guardia Medica" {
                self.icon.image = UIImage(named: "gm.png")
            } else if self.tipoField.text == "Formazione" {
                self.icon.image = UIImage(named: "formazione.png")
            } else if self.tipoField.text == "Altro" {
                self.icon.image = UIImage(named: "wait.png")
            } else {
                self.icon.image = UIImage(named: "convenzione.png")
            }
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func newData(_ sender: UIButton) {
        let alert = UIAlertController(style: .actionSheet, title: "Seleziona data e ora")
        alert.addDatePicker(mode: .date, date: Date(), minimumDate: nil, maximumDate: nil) { date in
            
            let dFormatter1 = DateFormatter()
            dFormatter1.dateFormat = "dd/MM/yyyy"
            self.dataField.text = dFormatter1.string(from: date)
            self.dataDelTurno = date
        }
        alert.addAction(title: "Fatto", style: .cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func newOraInizio(_ sender: UIButton) {
        let alert = UIAlertController(style: .actionSheet, title: "Seleziona data e ora")
        alert.addDatePicker(mode: .time, date: Date(), minimumDate: nil, maximumDate: nil) { date in
            
            let dFormatter1 = DateFormatter()
            dFormatter1.dateFormat = "HH:mm"
            self.oraInizioField.text = dFormatter1.string(from: date)
            self.oraInizioTurno = date
        }
        alert.addAction(title: "Fatto", style: .cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func newOraFine(_ sender: UIButton) {
        let alert = UIAlertController(style: .actionSheet, title: "Seleziona data e ora")
        alert.addDatePicker(mode: .time, date: Date(), minimumDate: nil, maximumDate: nil) { date in
            
            let dFormatter1 = DateFormatter()
            dFormatter1.dateFormat = "HH:mm"
            self.oraFineField.text = dFormatter1.string(from: date)
            self.oraFineTurno = date
        }
        alert.addAction(title: "Fatto", style: .cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func uploadTurno(_ sender: UIButton) {
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Carico..."
        hud.show(in: self.view)
        
        let username = UserDefaults.standard.object(forKey: "app_username") as! String
        let nuovoTurno = PFObject(className: "turni")
        nuovoTurno["tipo"] = self.tipoField.text!
        nuovoTurno["data"] = self.dataDelTurno
        nuovoTurno["ora_inizio"] = self.oraInizioTurno
        nuovoTurno["ora_fine"] = self.oraFineTurno
        nuovoTurno["username"] = username
        
        nuovoTurno.saveInBackground { (success, error) in
            if success {
                hud.dismiss()
                self.dismiss(animated: true, completion: nil)
            } else {
                hud.dismiss()
                let alert = UIAlertController(title: "Errore", message: "Impossibile caricare il servizio sul server, riprova", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .cancel)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
