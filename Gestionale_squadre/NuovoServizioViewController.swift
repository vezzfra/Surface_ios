//
//  NuovoServizioViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 12/11/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD
import GooglePlaces
import SwiftForms

class NuovoServizioViewController: FormViewController {
    
    let username = UserDefaults.standard.object(forKey: "app_username") as! String
    var c_invio = ""
    var c_trasporto = ""
    var selectedType = ""
    var selectedHospital = ""
    var selectedDetail = ""
    var pzGender = ""
    var codes = [String]()
    var delegate = ViewController()
    var dateString_def = String()
    var hourString_def = String()
    var indirizzoScelto = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var codiceServizio = ""
    var fromServer = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let q = PFQuery(className: "Servizi")
        q.whereKey("username", equalTo: self.username)
        q.findObjectsInBackground { (servizi, errors) in
            if errors == nil && servizi!.count > 0 {
                for servizio in servizi! {
                    self.codes.append(servizio["codice"] as! String)
                }
            }
        }
        
        let form = FormDescriptor()
        form.title = "Nuova missione"
        
        let section1 = FormSectionDescriptor(headerTitle: "CODICI", footerTitle: nil)
        let sendCodeRow = FormRowDescriptor(tag: "send_code", type: .picker, title: "Codice d'invio")
        sendCodeRow.configuration.cell.showsInputToolbar = true
        sendCodeRow.configuration.selection.options = (["Bianco", "Verde", "Giallo", "Rosso"] as [String]) as [AnyObject]
        sendCodeRow.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? String else { return "" }
            self.c_invio = option
            return value as! String
        }
        section1.rows.append(sendCodeRow)
        
        let riscontroCodeRow = FormRowDescriptor(tag: "riscontro_code", type: .picker, title: "Primo riscontro")
        riscontroCodeRow.configuration.cell.showsInputToolbar = true
        riscontroCodeRow.configuration.selection.options = (["Verde", "Giallo", "Rosso", "Non trasporta", "Regolare - Non trasporta", "Vuoto", "N.D."] as [String]) as [AnyObject]
        riscontroCodeRow.configuration.selection.optionTitleClosure = { value in
            guard let _ = value as? String else { return "" }
            return value as! String
        }
        section1.rows.append(riscontroCodeRow)
        
        let transportCodeRow = FormRowDescriptor(tag: "transport_code", type: .picker, title: "Codice di trasporto")
        transportCodeRow.configuration.cell.showsInputToolbar = true
        transportCodeRow.configuration.selection.options = (["Verde", "Giallo", "Rosso", "Bianco", "Non trasporta", "Regolare - Non trasporta", "Interrotta da C.O.", "Interrotta da Richiedente", "Interrotta - Incidente", "Vuoto"] as [String]) as [AnyObject]
        transportCodeRow.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? String else { return "" }
            self.c_trasporto = option
            return value as! String
        }
        section1.rows.append(transportCodeRow)
        
        let section2 = FormSectionDescriptor(headerTitle: "Informazioni chiamata", footerTitle: nil)
        let missionNumberRow = FormRowDescriptor(tag: "mission_number", type: .text, title: "Missione")
        missionNumberRow.configuration.cell.showsInputToolbar = true
        missionNumberRow.value = "" as AnyObject
        section2.rows.append(missionNumberRow)
        
        let dateAndTimeRow = FormRowDescriptor(tag: "date_time", type: .dateAndTime, title: "Data e ora")
        dateAndTimeRow.configuration.cell.showsInputToolbar = true
        section2.rows.append(dateAndTimeRow)
        
        let missionAddressRow = FormRowDescriptor(tag: "mission_address", type: .text, title: "Indirizzo")
        missionAddressRow.configuration.cell.showsInputToolbar = true
        missionAddressRow.value = "" as AnyObject
        section2.rows.append(missionAddressRow)
        
        let callRow = FormRowDescriptor(tag: "motivo_chiamata", type: .picker, title: "Motivo della chiamata")
        callRow.configuration.cell.showsInputToolbar = true
        callRow.configuration.selection.options = (["", "Altro", "Animali", "Caduta", "Calamità naturali", "Evento di massa", "Evento Violento", "Inc in acqua", "Inc in aria", "Inc ferrovia", "Inc infortunio", "Inc in montagna", "Inc speleologico", "Inc stradale", "Intossicazione", "Medico Acuto", "Non Noto", "Prevenzione", "Soccorso Persona", "Trasferimento", "Trasporto", "Trauma Infortunio"] as [String]) as [AnyObject]
        callRow.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? String else { return "" }
            self.selectedType = option
            return value as! String
        }
        section2.rows.append(callRow)

        let detailRow = FormRowDescriptor(tag: "dettaglio_motivo", type: .picker, title: "Dettaglio motivo")
        detailRow.configuration.cell.showsInputToolbar = true
        detailRow.configuration.selection.options = (["", "Abitazione", "Accer. Consulenza", "Aeroporto", "Aggressione", "Alimentare", "Altro", "Altro Non classifica", "Altro Non identifica", "Altro Note", "Amputazione", "Annegamento",  "Arrotamento persona", "Arrotamento veicolo", "Ascensore", "Assideramento", "Assistenza a FF.O.", "Assistenza a VV.F.", "Assistenza a CNSAS", "Assist. a Prot. Civile", "Assistito Materno", "Ausilio", "Auto Auto", "Auto Moto", "Autovettura", "Caduta", "Caduta da Bici", "Caduta da Moto", "Calamità naturale", "Cardiocircolatoria", "Carenza posti letto", "Competenza", "Contro Ostacolo", "Crollo", "Cute Tessuto Connett.", "Da Cavallo", "Deragliamento", "Digerente", "Equipe Neonatale", "Equipe Trapianto", "Esondazione", "Esplosione", "Etilica", "Eventi di massa", "Farmaci", "Ferita", "Folgorato", "Frana", "Fuga di Gas", "Fuori Strada", "Gravidanza parto", "Impiccagione", "Inc. Nucleare", "Incastrato", "Incendio", "Incrodato", "Infettiva", "Investimento", "Investimento Ciclista", "Investimento Pedone", "Materiale Biologico", "Materiale Sanitario", "Metabolica", "Mezzo Pesante", "Modalità Non Nota", "Morso", "Moto Moto", "Neoplastica", "Neurologica", "Non Noto", "Nube Tossica", "Nubifragio", "Orecchio Naso Gola", "Organi", "Osteo Muscolare", "Panico/Schiacciamento", "Per Trapianto", "Piena", "Più di Due Veicoli", "Precipitato", "Psichiatrica", "Puntura", "Respiratoria", "Ribaltamento", "Ricevente Organo", "Rissa", "Scala", "Scarica Pietre", "Schiacciamento", "Scontro", "Scontro di Gioco", "Sfinito", "Sostanze Pericolose", "Sparatoria", "Sub", "Suolo", "Surf", "Tentato Suicidio", "Terremoto", "Trasporto", "Tromba d'Aria", "TSO - ASO", "Ultraleggero", "Uro-Genitale", "Ustione", "Valanga", "Veicolo Fermo", "Vela"] as [String]) as [AnyObject]
        detailRow.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? String else { return "" }
            self.selectedDetail = option
            return value as! String
        }
        section2.rows.append(detailRow)
        
        let hospitalRow = FormRowDescriptor(tag: "hospital", type: .picker, title: "Ospedale")
        hospitalRow.configuration.cell.showsInputToolbar = true
        hospitalRow.configuration.selection.options = (["-", "Melloni", "Istituto Clinico Città studi", "Mangiagalli", "Policlinico", "Fatebenefratelli", "Gaetano Pini", "Cardiologico Monzino", "IRCCS S.Raffaele", "S.Giuseppe", "Buzzi", "Niguarda", "CTO", "S.Ambrogio", "Auxologico San Luca", "Civile di Sesto", "Multimedica", "Galeazzi", "S.Paolo", "Policlinico San Donato", "Bassini", "S.Carlo Borromeo", "Uboldo Cernusco S.N.", "Sacco", "Humanitas", "S.Carlo Paderno Dugnano", "Policlinico Monza", "S.Gerardo Monza", "Altro ospedale"] as [String]) as [AnyObject]
        hospitalRow.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? String else { return "" }
            self.selectedHospital = option
            return value as! String
        }
        hospitalRow.value = "-" as AnyObject
        section2.rows.append(hospitalRow)
        
        let section4 = FormSectionDescriptor(headerTitle: "Informazioni paziente", footerTitle: nil)
        
        let anagraficaRow = FormRowDescriptor(tag: "pz_anagrafica", type: .text, title: "Anagrafica")
        anagraficaRow.configuration.cell.showsInputToolbar = true
        anagraficaRow.value = "" as AnyObject
        section4.rows.append(anagraficaRow)
        
        let genderSegment = FormRowDescriptor(tag: "pz_gender", type: .segmentedControl, title: "Sesso")
        genderSegment.configuration.selection.options = (["M", "F", "N.D."] as [String]) as [AnyObject]
        genderSegment.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? String else { return "" }
            self.pzGender = option
            return option
        }
        section4.rows.append(genderSegment)
        
        let section3 = FormSectionDescriptor(headerTitle: "Eventuali note", footerTitle: nil)
        let gestitaSegmentRow = FormRowDescriptor(tag: "missione_gestita", type: .segmentedControl, title: "C.E.")
        gestitaSegmentRow.configuration.selection.options = (["Sì", "No"] as [String]) as [AnyObject]
        gestitaSegmentRow.configuration.selection.optionTitleClosure = { value in
            guard let option = value as? String else { return "" }
            return option
        }
        section4.rows.append(gestitaSegmentRow)
        
        let notesRow = FormRowDescriptor(tag: "notes", type: .multilineText, title: "Note")
        notesRow.configuration.cell.showsInputToolbar = true
        notesRow.value = "" as AnyObject
        section3.rows.append(notesRow)
        
        let submitButton = FormRowDescriptor(tag: "submit", type: .button, title: "Procedi")
        submitButton.configuration.button.didSelectClosure = { _ in
            self.view.resignFirstResponder()
            self.sendServizio()
        }
        section3.rows.append(submitButton)
        
        form.sections = [section1, section2, section4, section3]
        self.form = form
    }
    
    var fourDigitNumber: String {
        var result = ""
        repeat {
            repeat {
                // Create a string with a random number 0...9999
                result = String(format:"%04d", arc4random_uniform(10000) )
            } while result.count < 4
        } while self.codes.contains(result)
        return result
    }
    
    func sendServizio() {
            let hud = JGProgressHUD(style: .dark)
            hud.textLabel.text = "Carico..."
            hud.show(in: self.view)
            
            let values = self.form.formValues()
            
            let dF = DateFormatter()
            dF.dateFormat = "dd/MM/yyyy"
            let date = dF.string(from: values["date_time"] as! Date)
            dF.dateFormat = "HH:mm"
            let hour = dF.string(from: values["date_time"] as! Date)
            
            let new = PFObject(className: "Servizi")
            new["mission"] = values["mission_number"] as! String
            new["indirizzo"] = values["mission_address"] as! String
            new["data"] = date
            new["ora"] = hour
            new["tipologia"] = values["motivo_chiamata"] as! String
            new["dettaglio_tipologia"] = values["dettaglio_motivo"] as! String
            new["gender"] = values["pz_gender"] as! String
            new["anagrafica"] = values["pz_anagrafica"]
            new["note"] = values["notes"] as! String
            new["gestito"] = values["missione_gestita"] as! String
            new["username"] = self.username
            new["c_invio"] = values["send_code"] as! String
            new["c_riscontro"] = values["riscontro_code"] as! String
            new["c_trasporto"] = values["transport_code"] as! String
            new["hospital"] = values["hospital"] as! String
            self.codiceServizio = self.fourDigitNumber
            new["stato"] = "approved"
            new["codice"] = self.codiceServizio
            new["latitude"] = self.latitude
            new["longitude"] = self.longitude
            
            new.saveInBackground { (success, error) in
                if error == nil && success {
                    hud.dismiss()
                    self.delegate.loadData(mode: self.delegate.list_mode)
                    
                    if UserDefaults.standard.bool(forKey: "isOnService") && !self.fromServer {
                        var squadra: [String] = [String]()
                        squadra.append(UserDefaults.standard.object(forKey: "firstMember") as! String)
                        squadra.append(UserDefaults.standard.object(forKey: "secondMember") as! String)
                        squadra.append(UserDefaults.standard.object(forKey: "thirdMember") as! String)
                        
                        for membro in squadra {
                            if membro != "" {
                                let values = self.form.formValues()
                                
                                let dF = DateFormatter()
                                dF.dateFormat = "dd/MM/aaaa"
                                let date = dF.string(from: values["date_time"] as! Date)
                                dF.dateFormat = "HH:mm"
                                let hour = dF.string(from: values["date_time"] as! Date)
                                
                                let new = PFObject(className: "Servizi")
                                new["mission"] = values["mission_number"]
                                new["indirizzo"] = values["mission_address"]
                                new["data"] = date
                                new["ora"] = hour
                                new["tipologia"] = values["motivo_chiamata"] as! String
                                new["dettaglio_tipologia"] = values["dettaglio_motivo"] as! String
                                new["note"] = values["notes"] as! String
                                new["username"] = self.username
                                new["c_invio"] = self.c_invio
                                new["c_riscontro"] = values["riscontro_code"] as! String
                                new["c_trasporto"] = self.c_trasporto
                                new["hospital"] = values["hospital"] as! String
                                self.codiceServizio = self.fourDigitNumber
                                new["stato"] = "approved"
                                new["codice"] = self.codiceServizio
                                new["latitude"] = self.latitude
                                new["longitude"] = self.longitude
                                new.saveInBackground()
                            }
                        }
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    hud.dismiss()
                    let alert = UIAlertController(title: "Errore", message: "Impossibile caricare il servizio sul server, riprova", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
    }
}
