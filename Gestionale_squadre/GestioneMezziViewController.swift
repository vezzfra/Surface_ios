//
//  GestioneMezziViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 20/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit
import JGProgressHUD
import RLBAlertsPickers
import Parse
import SCLAlertView
import OneSignal

class GestioneMezziViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var nomeMezzo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var hud: JGProgressHUD = JGProgressHUD()
    var mezzoSelezionato = ""
    var elencoSezioni: [String] = ["Controlli generali", "Immobilizzazione e Trasporto", "Armadietti vano sanitario", "Set Vari", "Materiale Vario", "Ossigenoterapia", "Aspirazione", "Zaino", "Check DAE", "Materiale in sede", "Pulizia del Mezzo", "Materiale in Dotazione", "Controlli Vari", "Controlli Carrozzeria"]
    var HTMLContent = ""
    var completedTask = [Int]()
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in self.elencoSezioni {
            self.completedTask.append(0)
        }
        
        self.hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Attendere"
        
        self.nomeMezzo.text = self.mezzoSelezionato
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
        
        do {
            self.HTMLContent = try String(contentsOfFile: Bundle.main.path(forResource: "checklist", ofType: "html")!)
            self.HTMLContent = self.HTMLContent.replacingOccurrences(of: "#AMBULANZA#", with: self.mezzoSelezionato.suffix(3))
            
            let date = Date()
            let dateF = DateFormatter()
            dateF.dateFormat = "dd/MM/yyyy"
            let dateString = dateF.string(from: date)
            self.HTMLContent = self.HTMLContent.replacingOccurrences(of: "#DATA#", with: dateString)
            dateF.dateFormat = "HH:mm"
            let hourString = dateF.string(from: date)
            self.HTMLContent = self.HTMLContent.replacingOccurrences(of: "#ORA#", with: hourString)
        } catch {
            print("Error")
        }
    }
    
    @IBAction func goToHome(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.elencoSezioni.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "check_cell_1", for: indexPath) as! CheckListTableViewCell
        
        cell.label.text = self.elencoSezioni[indexPath.row]
        
        if indexPath.row >= 10 {
            cell.label.textColor = UIColor.black
        }
        
        if self.completedTask[indexPath.row] == 1 {
            cell.backView.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 153/255, blue: 0/255, alpha: 1.0)
        } else {
            cell.backView.backgroundColor = UIColor.clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.completedTask[indexPath.row] == 0 {
            if self.elencoSezioni[indexPath.row] != "Check DAE" {
                self.selectedIndex = indexPath.row
                self.performSegue(withIdentifier: "openSection", sender: nil)
            } else {
                //Apri check DAE
                self.performSegue(withIdentifier: "openDAE", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openSection" {
            let dest = segue.destination as! CheckListSectionViewController
            dest.sectionIndex = self.selectedIndex
            dest.htmlContent = self.HTMLContent
            dest.delegate = self
        } else if segue.identifier == "openDAE" {
            let dest = segue.destination as! CheckDAEViewController
            dest.htmlContent = self.HTMLContent
            dest.delegate = self
        }
    }
    
    @IBAction func uploadChecklist(_ sender: UIButton) {
        if !self.completedTask.contains(0) {
            self.HTMLContent = self.HTMLContent.replacingOccurrences(of: "#CAPO_EQ#", with: UserDefaults.standard.object(forKey: "app_username") as! String)
            self.HTMLContent = self.HTMLContent.replacingOccurrences(of: "#MAT1#", with: UserDefaults.standard.object(forKey: "app_matricola") as! String)
            let aut = self.selectAutista()
            if aut != ("","") {
                self.HTMLContent = self.HTMLContent.replacingOccurrences(of: "#AUTISTA#", with: aut.0)
                self.HTMLContent = self.HTMLContent.replacingOccurrences(of: "#MAT2#", with: aut.1)
                
                if UserDefaults.standard.object(forKey: "app_role") as! Int == 0 {
                    
                    // L'utente è un allievo, richiesta verifica della checklist
                    let appearance = SCLAlertView.SCLAppearance(
                        showCloseButton: false
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.addButton("Annulla") {
                        alertView.dismiss(animated: true, completion: nil)
                    }
                    alertView.addButton("Procedi") {
                        alertView.dismiss(animated: true, completion: nil)
                        let selectedMembro = self.selectMembroAnziano()
                        if selectedMembro != ("","") {
                            self.hud.textLabel.text = "Invio richiesta"
                            self.hud.show(in: self.view)
                            let obj = PFObject(className: "checklist")
                            obj["html_code"] = self.HTMLContent
                            obj["directed_to"] = selectedMembro.0
                            obj["mezzo"] = self.mezzoSelezionato
                            obj.saveInBackground(block: { (succ, error) in
                                if error == nil {
                                    // Invio notifica al membro selezionato
                                    
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
                                    }
                                    alertView.showError("Ops...", subTitle: "Si è verificato un errore inatteso. Si prega di riprovare.")
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
                            alertView.showError("Attenzione", subTitle: "Non è stato selezionato un membro valido. Riprova.")
                        }
                    }
                    alertView.showInfo("Attenzione", subTitle: "Essendo tu un allievo è richiesta la verifica della checklist che hai appena creato. Seleziona un membro dell'equipaggio che abbia quest'app installata per procedere con la verifica.")
                } else {
                //Creo file PDF
                /*let fmt = UIMarkupTextPrintFormatter(markupText: self.HTMLContent)
                let render = UIPrintPageRenderer()
                render.addPrintFormatter(fmt, startingAtPageAt: 0)
                
                let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
                render.setValue(page, forKey: "paperRect")
                render.setValue(page, forKey: "printableRect")
                
                let pdfData = NSMutableData()
                UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
                for i in 0..<render.numberOfPages {
                    UIGraphicsBeginPDFPage();
                    render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
                }
                UIGraphicsEndPDFContext();
                
                guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("output").appendingPathExtension("pdf")
                    else { fatalError("Destination URL Error") }
                pdfData.write(to: outputURL, atomically: true)
                
                //let dataString = try? Data(contentsOf: outputURL).base64EncodedString()
                //Invio checklist via email
                //let base64Data = pdfData.base64EncodedString()
                
                let date = Date()
                let dateF = DateFormatter()
                dateF.dateFormat = "dd/MM/yyyy"
                let dataO = dateF.string(from: date)
                dateF.dateFormat = "HH:mm"
                let hour = dateF.string(from: date)*/
                
                self.hud.textLabel.text = "Invio checklist"
                self.hud.show(in: self.view)
                
                let email = "vezzfra@gmail.com"
                
                var recipients = [Any]()
                recipients.append(["Email": email])
                
                let body: [String: Any] = [
                    "FromEmail": "noreply.missioni118@gmail.com",
                    "FromName": "Checklist mezzi",
                    "Subject": "Checklist del mezzo: \(self.mezzoSelezionato)",
                    "Text-part": "Alla cortese attenzione del centralinista.\nAllego checklist del mezzo \(self.mezzoSelezionato) appena terminata.\n\nGrazie\n\(UserDefaults.standard.object(forKey: "app_username") as! String)",
                    "Html-part": self.HTMLContent,
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
                        }
                        alertView.showError("Ops...", subTitle: "Si è verificato un errore inatteso. Si prega di riprovare.")
                    }
                })
                task.resume()
                }
            } else {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("Ok") {
                    alertView.dismiss(animated: true, completion: nil)
                }
                alertView.showError("Attenzione", subTitle: "Non è stato selezionato un autista valido. Riprova.")
            }
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("Ok") {
                alertView.dismiss(animated: true, completion: nil)
            }
            alertView.showWarning("Attenzione", subTitle: "É necessario completare tutta la checklist prima di inviarla.")
        }
    }
    
    func selectAutista() -> (String, String) {
        //Seleziona autista
        var autistiInViola = [String]()
        autistiInViola.append("")
        var matricoleAutisti = [String]()
        matricoleAutisti.append("")
        var autistaSelezionato = ""
        var matricolaSelezionata = ""
        
        self.hud.textLabel.text = "Contatto il server"
        self.hud.show(in: self.view)
        
        let query = PFQuery(className: "users")
        query.whereKey("role", equalTo: 3)
        query.findObjectsInBackground { (autisti, error) in
            if error == nil && autisti!.count > 0 {
                for autista in autisti! {
                    autistiInViola.append(autista["username"] as! String)
                    matricoleAutisti.append(autista["matricola"] as! String)
                }
                self.hud.dismiss()
                //Mostro la selezione dell'autista
                let alert = UIAlertController(title: "Seleziona il tuo autista", message: nil, preferredStyle: .actionSheet)
                let pickerViewValues: [[String]] = [autistiInViola]
                let pickerViewSelectedValue: PickerViewViewController
                    .Index = (column: 0, row: 0)
                
                alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
                    autistaSelezionato = autistiInViola[index.row]
                    matricolaSelezionata = matricoleAutisti[index.row]
                }
                let cancel = UIAlertAction(title: "Fatto", style: .cancel) { (action) in
                    return ("\(autistaSelezionato)","\(matricolaSelezionata)")
                }
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            } else {
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("Ok") {
                    alertView.dismiss(animated: true, completion: nil)
                }
                alertView.showError("Ops...", subTitle: "Si è verificato un errore inatteso. Si prega di riprovare.")
            }
        }
        return ("","")
    }
    
    func selectMembroAnziano() -> (String, String) {
        self.hud.textLabel.text = "Creo lista volontari"
        self.hud.show(in: self.view)
        var utenti = [String]()
        var done = false
        var utenteSelezionato = ""
        var selectedCode = ""
        
        let query = PFQuery(className: "users")
        query.whereKey("role", containedIn: [1, 2, 3])
        query.findObjectsInBackground { (objects, error) in
            if error == nil {
                for obj in objects! {
                    utenti.append(obj["username"] as! String)
                }
                self.hud.dismiss()
                //Mostro picker utenti
                let alert = UIAlertController(title: "Seleziona membro dell'equipaggio", message: nil, preferredStyle: .actionSheet)
                let pickerViewValues: [[String]] = [utenti]
                let pickerViewSelectedValue: PickerViewViewController
                    .Index = (column: 0, row: 0)
                
                alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
                    utenteSelezionato = utenti[index.row]
                }
                let cancel = UIAlertAction(title: "Fatto", style: .cancel) { (action) in
                    let q = PFQuery(className: "notificationCodes")
                    q.whereKey("username", equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
                    q.findObjectsInBackground(block: { (objects, error) in
                        if error == nil {
                            for obj in objects! {
                                selectedCode = obj["notification_code"] as! String
                                done = true
                            }
                        }
                    })
                }
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            } else {
                // Errore generico
                let appearance = SCLAlertView.SCLAppearance(
                    showCloseButton: false
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.addButton("Ok") {
                    alertView.dismiss(animated: true, completion: nil)
                }
                alertView.showError("Ops...", subTitle: "Si è verificato un errore inatteso. Si prega di riprovare.")
            }
        }
        if done {
            return (utenteSelezionato,selectedCode)
        }
        return ("","")
    }
}
