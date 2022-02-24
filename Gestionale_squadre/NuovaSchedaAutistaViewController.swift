//
//  NuovaSchedaAutistaViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 01/03/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import SkyFloatingLabelTextField
import JGProgressHUD
import RLBAlertsPickers

class NuovaSchedaAutistaViewController: UIViewController {
    @IBOutlet weak var dataField: SkyFloatingLabelTextField!
    @IBOutlet weak var formatoreField: SkyFloatingLabelTextField!
    @IBOutlet weak var allievoField: SkyFloatingLabelTextField!
    @IBOutlet weak var mezzoField: SkyFloatingLabelTextField!
    @IBOutlet weak var kmField: SkyFloatingLabelTextField!
    @IBOutlet weak var percorsoField: SkyFloatingLabelTextField!
    @IBOutlet weak var noteField: SkyFloatingLabelTextField!
    
    var km = ""
    var note = ""
    var percorso = ""
    var mezzo = ""
    var numero_guida = 0
    var selectedDate = ""
    var selectedAllievo = ""
    var utentiDaMostrare = [String]()
    var picker = ["","VIO_MI_028", "VIO_MI_029", "VIO_MI_030"]
    
    var hud: JGProgressHUD = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.utentiDaMostrare.append(" ")
        self.formatoreField.text = (UserDefaults.standard.object(forKey: "app_username") as! String)
        
        self.hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Caricamento..."
        self.hud.show(in: self.view)
        
        let query = PFQuery(className: "users")
        query.whereKey("username", notEqualTo: UserDefaults.standard.object(forKey: "app_username") as! String)
        query.findObjectsInBackground { (utenti, error) in
            if error == nil {
                for utente in utenti! {
                    if utente["role"] as! Int >= 1 {
                        self.utentiDaMostrare.append(utente["username"] as! String)
                    }
                    self.hud.dismiss()
                }
            }
        }
    }
    
    @IBAction func selectDate(_ sender: UIButton) {
        let alert = UIAlertController(style: .actionSheet, title: "Seleziona la data della scheda")
        alert.addDatePicker(mode: .date, date: Date(), minimumDate: nil, maximumDate: Date()) { date in
            
            let dFormatter1 = DateFormatter()
            dFormatter1.dateFormat = "dd/MM/yyyy"
            self.selectedDate = dFormatter1.string(from: date)
        }
        alert.addAction(title: "Fatto", style: .cancel, handler: { (action) in
            self.dataField.text = self.selectedDate
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func selectAllievo(_ sender: UIButton) {
        let alert = UIAlertController(title: "Seleziona destinatario della scheda", message: nil, preferredStyle: .actionSheet)
        let pickerViewValues: [[String]] = [self.utentiDaMostrare]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.selectedAllievo = self.utentiDaMostrare[index.row]
        }
        let cancel = UIAlertAction(title: "Fatto", style: .cancel) { (action) in
            self.allievoField.text = self.selectedAllievo
            self.hud.show(in: self.view)
             let query = PFQuery(className: "schedeAutista")
             query.whereKey("allievo", equalTo: self.selectedAllievo)
             query.findObjectsInBackground(block: { (schede, error) in
             if error == nil {
                if (schede?.count)! > 0 {
                    self.numero_guida = schede![(schede?.count)! - 1]["numeroGuida"] as! Int + 1
                } else {
                    self.numero_guida = 1
                }
             }
             self.hud.dismiss()
             })
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addNewPercorso(_ sender: UIButton) {
        let alert = UIAlertController(style: .alert, title: "Percorso effettuato")
        let config: TextField.Config = { textField in
            textField.becomeFirstResponder()
            textField.textColor = .black
            textField.textAlignment = .center
            textField.placeholder = "Luogo partenza/Luogo arrivo"
            textField.leftViewPadding = 12
            textField.borderWidth = 1
            textField.cornerRadius = 8
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.keyboardAppearance = .default
            textField.keyboardType = .default
            textField.isSecureTextEntry = false
            textField.returnKeyType = .done
            textField.action { textField in
                self.percorso = textField.text!
            }
        }
        alert.addOneTextField(configuration: config)
        alert.addAction(title: "Conferma", style: .cancel) { (action) in
            self.percorsoField.text = self.percorso
        }
        self.show(alert, sender: nil)
    }
    
    @IBAction func addKm(_ sender: UIButton) {
        let alert = UIAlertController(style: .alert, title: "Km percorsi")
        let config: TextField.Config = { textField in
            textField.becomeFirstResponder()
            textField.textColor = .black
            textField.textAlignment = .center
            textField.placeholder = "Chilometri"
            textField.leftViewPadding = 12
            textField.borderWidth = 1
            textField.cornerRadius = 8
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.keyboardAppearance = .default
            textField.keyboardType = .numberPad
            textField.isSecureTextEntry = false
            textField.returnKeyType = .done
            textField.action { textField in
                self.km = textField.text!
            }
        }
        alert.addOneTextField(configuration: config)
        alert.addAction(title: "Conferma", style: .cancel) { (action) in
            self.kmField.text = self.km
        }
        self.show(alert, sender: nil)
    }
    
    @IBAction func addNote(_ sender: UIButton) {
        let alert = UIAlertController(style: .alert, title: "Note")
        let config: TextField.Config = { textField in
            textField.becomeFirstResponder()
            textField.textColor = .black
            textField.textAlignment = .center
            textField.placeholder = "Aggiungi eventuali note"
            textField.leftViewPadding = 12
            textField.borderWidth = 1
            textField.cornerRadius = 8
            textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
            textField.backgroundColor = nil
            textField.keyboardAppearance = .default
            textField.keyboardType = .numberPad
            textField.isSecureTextEntry = false
            textField.returnKeyType = .done
            textField.action { textField in
                self.note = textField.text!
            }
        }
        alert.addOneTextField(configuration: config)
        alert.addAction(title: "Aggiungi", style: .cancel) { (action) in
            self.noteField.text = self.note
        }
        self.show(alert, sender: nil)
    }
    
    @IBAction func selectMezzo(_ sender: UIButton) {
        let alert = UIAlertController(title: "Seleziona il mezzo utilizzato", message: nil, preferredStyle: .actionSheet)
        let pickerViewValues: [[String]] = [self.picker]
        let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: 0)
        
        alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
            self.mezzo = self.picker[index.row]
        }
        let cancel = UIAlertAction(title: "Fatto", style: .cancel) { (action) in
            self.mezzoField.text = self.mezzo
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backToSelection(_ sender: UIButton) {
        let alert = UIAlertController(title: "Vuoi davvero annullare la scheda attuale?", message: nil, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Sì", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        let no = UIAlertAction(title: "No", style: .cancel)
        alert.addAction(yes)
        alert.addAction(no)
        self.show(alert, sender: nil)
    }
    
    @IBAction func sendScheda(_ sender: UIButton) {
        if self.dataField.text != "" && self.selectedAllievo != "" && self.km != "" && self.percorso != "" && self.mezzo != "" {
            
            //Carico scheda sul server
            let obj = PFObject(className: "schedeAutista")
            obj["allievo"] = self.selectedAllievo
            obj["numeroGuida"] = self.numero_guida
            obj["percorso"] = self.percorso
            obj["km"] = self.km
            obj["mezzo"] = self.mezzo
            obj["data"] = self.selectedDate
            obj["formatore"] = UserDefaults.standard.object(forKey: "app_username") as! String
            obj["note"] = self.note
            obj.saveInBackground { (success, error) in
                if error == nil && success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Ops...", message: "C'è stato un errore con la tua richiesta. Si prega di riprovare.", preferredStyle: .alert)
                    let no = UIAlertAction(title: "Ok", style: .cancel)
                    alert.addAction(no)
                    self.show(alert, sender: nil)
                }
            }
        } else {
            let alert = UIAlertController(title: "Attenzione", message: "Tutti i campi a parte le note sono obbligatori", preferredStyle: .alert)
            let no = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(no)
            self.show(alert, sender: nil)
        }
    }
}
