//
//  NuovaSchedaSoccorritoreViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 23/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Parse
import JGProgressHUD
import SCLAlertView
import OneSignal

class NuovaSchedaSoccorritoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var dataField: SkyFloatingLabelTextField!
    @IBOutlet weak var formatoreField: SkyFloatingLabelTextField!
    @IBOutlet weak var allievoField: SkyFloatingLabelTextField!
    @IBOutlet weak var note: UITextView!
    @IBOutlet weak var cancelNewMission: UIButton!
    @IBOutlet weak var addNewMission: UIButton!
    @IBOutlet weak var titleLabelScreen: UILabel!
    @IBOutlet weak var numeroSchedaLabel: UILabel!
    @IBOutlet weak var missioniTableView: UITableView!
    
    var selectedDate = ""
    var numeroScheda = 0
    var hud: JGProgressHUD = JGProgressHUD()
    var selectedRole = 0
    var utentiDaMostrare = [String]()
    var selectedAllievo = ""
    var codiciInvio = [String]()
    var codiciTrasporto = [String]()
    var noteMissioni = [String]()
    var noteAspettiPositivi = ""
    var noteAspettiMigliorabili = ""
    var noteInserite = false
    var newInvio = ""
    var newTrasporto = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.missioniTableView.delegate = self
        self.missioniTableView.dataSource = self
        
        self.note.isHidden = true
        self.cancelNewMission.isHidden = true
        self.addNewMission.isHidden = true
        self.note.layer.cornerRadius = 5
        self.note.layer.masksToBounds = true
        
        self.formatoreField.text = (UserDefaults.standard.object(forKey: "app_username") as! String)
        self.hud = JGProgressHUD(style: .dark)
        self.hud.textLabel.text = "Creo lista allievi"
        self.hud.show(in: self.view)
        
        switch self.selectedRole {
        case 0:
            self.titleLabelScreen.text = "Nuova scheda allievo"
        case 1:
            self.titleLabelScreen.text = "Nuova scheda CS"
        default:
            self.titleLabelScreen.text = "Nuova scheda"
        }
        
        self.utentiDaMostrare.append("")
        let query = PFQuery(className: "users")
        query.whereKey("role", equalTo: self.selectedRole)
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                self.utentiDaMostrare.removeAll()
                if objects!.count > 0 {
                    for obj in objects! {
                        self.utentiDaMostrare.append(obj["username"] as! String)
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
            self.hud.textLabel.text = "Conto il numero di schede"
            self.hud.show(in: self.view)
            var query: PFQuery = PFQuery()
            if self.selectedRole == 0 {
                query = PFQuery(className: "schedeAllievo")
            } else {
                query = PFQuery(className: "schedeCS")
            }
            query.whereKey("allievo", equalTo: self.selectedAllievo)
            query.findObjectsInBackground(block: { (schede, error) in
                if error == nil && schede!.count > 0 {
                    self.numeroSchedaLabel.text = "Numero scheda: \(schede!.count + 1)"
                    self.numeroScheda = schede!.count + 1
                } else {
                    self.numeroSchedaLabel.text = "Numero scheda: 1"
                    self.numeroScheda = 1
                }
                self.hud.dismiss()
            })
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.noteMissioni.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellaServizioCs", for: indexPath) as! ServizioCSTableViewCell
        
        cell.codiceInvioLabel.text = "Invio: \(self.codiciInvio[indexPath.row])"
        cell.codiceTrasportoLabel.text = "Trasporto: \(self.codiciTrasporto[indexPath.row])"
        cell.noteLabel.text = "Note: \(self.noteMissioni[indexPath.row])"
        
        return cell
    }
    
    @IBAction func addNewMission(_ sender: UIButton) {
        let alert = UIAlertController(title: "Codice Invio", message: nil, preferredStyle: .actionSheet)
        let red = UIAlertAction(title: "Rosso", style: .default) { (action) in
            self.selectTrasporto(invio: "Rosso")
        }
        let yellow = UIAlertAction(title: "Giallo", style: .default) { (action) in
            self.selectTrasporto(invio: "Giallo")
        }
        let green = UIAlertAction(title: "Verde", style: .default) { (action) in
            self.selectTrasporto(invio: "Verde")
        }
        let cancel = UIAlertAction(title: "Annulla", style: .cancel)
        alert.addAction(red)
        alert.addAction(yellow)
        alert.addAction(green)
        alert.addAction(cancel)
        self.show(alert, sender: nil)
    }
    
    @IBAction func addNotes(_ sender: UIButton) {
        self.performSegue(withIdentifier: "addNotes", sender: nil)
    }
    
    @IBAction func sendScheda(_ sender: UIButton) {
        let alert = UIAlertController(title: "Sei sicuro?", message: "Inviando questa scheda non sarai più in grado di modificarla.", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Sì", style: .default) { (action) in
            
            self.createPDF()
        }
        let no = UIAlertAction(title: "No", style: .cancel)
        alert.addAction(yes)
        alert.addAction(no)
        self.show(alert, sender: nil)
    }
    
    func selectTrasporto(invio: String) {
        let alert = UIAlertController(title: "Codice Trasporto", message: nil, preferredStyle: .actionSheet)
        let red = UIAlertAction(title: "Rosso", style: .default) { (action) in
            self.addNoteOfMission(invio: invio, trasporto: "Rosso")
        }
        let yellow = UIAlertAction(title: "Giallo", style: .default) { (action) in
            self.addNoteOfMission(invio: invio, trasporto: "Giallo")
        }
        let green = UIAlertAction(title: "Verde", style: .default) { (action) in
            self.addNoteOfMission(invio: invio, trasporto: "Verde")
        }
        let not = UIAlertAction(title: "Non trasporta", style: .default) { (action) in
            self.addNoteOfMission(invio: invio, trasporto: "Non trasporta")
        }
        let interr = UIAlertAction(title: "Interrotta", style: .default) { (action) in
            self.addNoteOfMission(invio: invio, trasporto: "Interrotta")
        }
        let vuoto = UIAlertAction(title: "Vuoto", style: .default) { (action) in
            self.addNoteOfMission(invio: invio, trasporto: "Vuoto")
        }
        let cancel = UIAlertAction(title: "Annulla", style: .cancel)
        alert.addAction(red)
        alert.addAction(yellow)
        alert.addAction(green)
        alert.addAction(not)
        alert.addAction(interr)
        alert.addAction(vuoto)
        alert.addAction(cancel)
        self.show(alert, sender: nil)
    }
    
    func addNoteOfMission(invio: String, trasporto: String) {
        self.note.isHidden = false
        self.note.text = ""
        self.cancelNewMission.isHidden = false
        self.addNewMission.isHidden = false
        self.missioniTableView.isHidden = true
        self.newInvio = invio
        self.newTrasporto = trasporto
    }
    
    @IBAction func cancelNote(_ sender: UIButton) {
        self.note.isHidden = true
        self.cancelNewMission.isHidden = true
        self.addNewMission.isHidden = true
        self.missioniTableView.isHidden = false
        self.newInvio = ""
        self.newTrasporto = ""
        self.note.resignFirstResponder()
    }
    
    @IBAction func addNote(_ sender: UIButton) {
        self.codiciInvio.append(self.newInvio)
        self.codiciTrasporto.append(self.newTrasporto)
        self.noteMissioni.append(self.note.text!)
        self.missioniTableView.reloadData()
        
        self.newInvio = ""
        self.newTrasporto = ""
        self.note.isHidden = true
        self.cancelNewMission.isHidden = true
        self.addNewMission.isHidden = true
        self.missioniTableView.isHidden = false
        self.note.resignFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addNotes" {
            let dest = segue.destination as! AggiuntaNoteViewController
            dest.delegate = self
            dest.aspettiPositivi = self.noteAspettiPositivi
            dest.aspettiDaMigliorare = self.noteAspettiMigliorabili
        }
    }
    
    func createPDF() {
        self.hud.textLabel.text = "Invio scheda"
        self.hud.show(in: self.view)
        var tipoScheda = ""
        do {
            var htmlContent = try String(contentsOfFile: Bundle.main.path(forResource: "scheda", ofType: "html")!)
            
            if self.selectedRole == 0 {
                htmlContent = htmlContent.replacingOccurrences(of: "#TIPO_SCHEDA#", with: "Allievo")
                tipoScheda = "Allievo"
            } else {
                htmlContent = htmlContent.replacingOccurrences(of: "#TIPO_SCHEDA#", with: "capo equipaggio")
                tipoScheda = "Capo equipaggio"
            }
            htmlContent = htmlContent.replacingOccurrences(of: "#NUMERO_SCHEDA#", with: String(describing: self.numeroScheda))
            htmlContent = htmlContent.replacingOccurrences(of: "#USERNAME#", with: self.selectedAllievo)
            htmlContent = htmlContent.replacingOccurrences(of: "#DATA#", with: self.selectedDate)
            htmlContent = htmlContent.replacingOccurrences(of: "#FORMATORE#", with: UserDefaults.standard.object(forKey: "app_username") as! String)
            htmlContent = htmlContent.replacingOccurrences(of: "#NOTE_POSITIVE#", with: self.noteAspettiPositivi)
            htmlContent = htmlContent.replacingOccurrences(of: "#NOTE_MIGLIORAMENTO#", with: self.noteAspettiMigliorabili)
            
            var stringaTabella = ""
            var i = 0
            for _ in self.codiciInvio {
                
                stringaTabella = stringaTabella + "<br><table border=\"1\" style=\"width: 97.82399306945638%; border-collapse: collapse; height: 52px;\"><tbody><tr style=\"height: 18px;\"><td style=\"width: 90.34136743160107%; height: 18px; text-align: center;\">Codice Invio: \(self.codiciInvio[i]) &nbsp; &nbsp; &nbsp; Codice Trasporto: \(self.codiciTrasporto[i])</td></tr><tr style=\"height: 18px;\"><td style=\"width: 90.34136743160107%; height: 18px; text-align: center;\">\(self.noteMissioni[i])</td></tr></tbody></table>"
                
                i = i + 1
            }
            
            htmlContent = htmlContent.replacingOccurrences(of: "#TABLE#", with: stringaTabella)
            
            if self.selectedRole == 0 {
                let obj = PFObject(className: "schedeAllievo")
                obj["htmlContent"] = htmlContent
                obj["formatore"] = UserDefaults.standard.object(forKey: "app_username") as! String
                obj["allievo"] = self.selectedAllievo
                obj["numero_scheda"] = self.numeroScheda
                obj.saveInBackground { (success, error) in
                    if error == nil {
                        if success {
                            let q = PFQuery(className: "notificationCodes")
                            q.whereKey("username", equalTo: self.selectedAllievo)
                            q.findObjectsInBackground(block: { (objects, error) in
                                if error == nil {
                                    for obj in objects! {
                                        OneSignal.postNotification(["contents:": ["en": "\(UserDefaults.standard.object(forKey: "app_username") as! String) ha inserito una nuova scheda di valutazione per te."], "include_player_ids": ["\(obj["notification_code"] as! String)"]])
                                    }
                                    self.hud.dismiss()
                                    self.dismiss(animated: true, completion: nil)
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
                                    alertView.showWarning("Attenzione", subTitle: "La scheda è stata caricata con successo, purtroppo non è stato possibile avvertire il destinatario tramite una notifica per un errore inatteso.")
                                }
                            })
                        } else {
                            self.hud.dismiss()
                            let appearance = SCLAlertView.SCLAppearance(
                                showCloseButton: false
                            )
                            let alertView = SCLAlertView(appearance: appearance)
                            alertView.addButton("Ok") {
                                alertView.dismiss(animated: true, completion: nil)
                            }
                            alertView.showError("Ops..", subTitle: "C'è stato un errore, riprova.")
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
                        alertView.showError("Ops..", subTitle: "C'è stato un errore, riprova.")
                    }
                }
            } else {
                let obj = PFObject(className: "schedeCS")
                obj["data"] = self.selectedDate
                obj["formatore"] = UserDefaults.standard.object(forKey: "app_username") as! String
                obj["allievo"] = self.selectedAllievo
                obj["numero_scheda"] = self.numeroScheda
                obj["codici_invio"] = self.codiciInvio
                obj["codici_trasporto"] = self.codiciTrasporto
                obj["note_missioni"] = self.noteMissioni
                obj["aspetti_positivi"] = self.noteAspettiPositivi
                obj["aspetti_migliorabili"] = self.noteAspettiMigliorabili
                
                obj.saveInBackground { (success, error) in
                    if error == nil {
                        if success {
                            let email = "vezzfra@gmail.com"
                            
                            var recipients = [Any]()
                            recipients.append(["Email": email])
                            
                            let body: [String: Any] = [
                                "FromEmail": "noreply.missioni118@gmail.com",
                                "FromName": "Formazione Croce Viola",
                                "Subject": "Nuova scheda valutativa \(tipoScheda): \(self.selectedAllievo)",
                                "Text-part": "",
                                "Html-part": "\(htmlContent)",
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
                                    let q = PFQuery(className: "notificationCodes")
                                    q.whereKey("username", equalTo: self.selectedAllievo)
                                    q.findObjectsInBackground(block: { (objects, error) in
                                        if error == nil {
                                            for obj in objects! {
                                                OneSignal.postNotification(["contents:": ["en": "\(UserDefaults.standard.object(forKey: "app_username") as! String) ha inserito una nuova scheda di valutazione per te."], "include_player_ids": ["\(obj["notification_code"] as! String)"]])
                                            }
                                            self.hud.dismiss()
                                            self.dismiss(animated: true, completion: nil)
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
                                            alertView.showWarning("Attenzione", subTitle: "La scheda è stata caricata con successo, purtroppo non è stato possibile avvertire il destinatario tramite una notifica per un errore inatteso.")
                                        }
                                    })
                                } else {
                                    self.hud.dismiss()
                                    let appearance = SCLAlertView.SCLAppearance(
                                        showCloseButton: false
                                    )
                                    let alertView = SCLAlertView(appearance: appearance)
                                    alertView.addButton("Ok") {
                                        alertView.dismiss(animated: true, completion: nil)
                                    }
                                    alertView.showError("Ops..", subTitle: "Si è verificato un errore durante l'invio della scheda, riprovare.")
                                }
                            })
                            task.resume()
                            
                            //self.dismiss(animated: true, completion: nil)
                        } else {
                            self.hud.dismiss()
                            let appearance = SCLAlertView.SCLAppearance(
                                showCloseButton: false
                            )
                            let alertView = SCLAlertView(appearance: appearance)
                            alertView.addButton("Ok") {
                                alertView.dismiss(animated: true, completion: nil)
                            }
                            alertView.showError("Ops..", subTitle: "C'è stato un errore, riprova.")
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
                        alertView.showError("Ops..", subTitle: "C'è stato un errore, riprova.")
                    }
                }
            }
        } catch {
            print("Unable to open and use HTML template files.")
        }
    }
}
