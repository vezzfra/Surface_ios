//
//  CheckListSectionViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 27/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit
import RLBAlertsPickers

class CheckListSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var titleSectionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var dictionaryPresidi = [(String,String)]()
    var completedPoint = [Int]()
    var sectionIndex = 0
    var delegate = GestioneMezziViewController()
    var htmlContent = ""
    var firstNumber = 0
    var backFromImages = false
    
    //Creo checkList
    private let controlloGenerale = [("Illuminazione",""), ("Riscaldamento",""), ("Areazione e ventilazione",""), ("Contenitore per rifiuti infetti rigido sigillabile","1"), ("Contenitore porta aghi rigido sigillabile","1"), ("Estintore da 3kg","1"), ("Disinfettante ambientale e presidi+stracci","")]
    private let immobilizzazione = [("Barella regolabile con cinghie","1"), ("Set collari cervicali (6 misure)","6"), ("KED (controllo cinghie, cuscino, 2 fascette)","1"), ("Barella a cucchiaio","1"), ("Cinghie per barella a cuchiaio","3"), ("Set steccobende rigide","1"), ("Set steccobende a depressione + pompa","1"), ("Materassino a depressione + pompa","1"), ("Tavola spinale con fissaggio fermacapo, fermacapo con fascette, ragno","1"), ("Tavola spinale pediatrica","1"), ("Telo porta feriti","1"), ("Sedia cardiopatica", "1")]
    private let armadietti = [("Disinfettante cutaneo","2"), ("Acqua ossigenata","2"), ("Soluzione fisiologica","5"), ("Ghiaccio sintetico (buste)","6"), ("Ghiaccio spray","2"), ("Teli medicazione sterili","3"), ("Garze sterili","10"), ("Garze non sterili (cubi)",""), ("Cerotti di varia misura (scatola)","1"), ("Telini termici (metalline)","3"), ("Rotoli di cerotto","3"), ("Bende di varia misura",""), ("Benda elastica di varia misura",""), ("Benda a rete tubolare (misure: 2-3-4-6)","4"), ("Guanti sterili monouso (misure: 6 - 7 - 7.5 - 8 - 8.5)","5x4"), ("Guanti non sterili (scatole misura: S-M-L)","3"), ("Mascherine in carta monouso (almeno 5 pz)","1")]
    private let kit = [("Kit infettivi (sigillato)","1"), ("Kit parto (sigillato)","1"), ("Kit ustioni (sigillato)","1")]
    private let materiale = [("Cuscini e coperte","2+2"), ("Copri cuscino monouso","3"), ("Lenzuola monouso","10"), ("Traverse salvaletto","4"), ("Lenzuola sterili","3"), ("Supporto portaflebo","2"), ("Pappagallo o 2 monouso","1o2"), ("Padella","1"), ("Forbice di Robin","1"), ("Caschi protettivi","3"), ("Sacchi di plastica per rifiuti non infetti","5")]
    private let ossigenoterapia = [("Bombole O2 portatili da 2L (almeno 2 a 100 atm)","3"), ("Sacca bombola con maschera adulti, pediatrica e occhialini","1"), ("Maschere adulti con reservoir","5"), ("Maschere pediatriche con reservoir","5"), ("Occhialini","3"), ("Bombole O2 fisse da 7L (almeno 1 a 150 atm)","2")]
    private let aspirazione = [("Aspiratore portatile (carico e funzionante)","1"), ("Sondini per aspiratore (3 per colore): nero, bianco, verde, arancio, giallo e rosso","18"), ("Sacchetti monouso aspiratore","3")]
    private let zaino = [("Saturimetro (controllare funzionamento)","1"), ("Sonda pediatrica per saturimetro riutilizzabile","1"), ("Sfigmomanometro e fonendoscopio adulti","1+1"), ("Sfigmomanometro e fonendoscopio pediatrico","1+1"), ("Pallone AMBU adulti con reservoir","1"), ("Maschere adulti x pallone AMBU (3 misure)","3"), ("Cannule adulti (3 rosse, 3 arancio, 3 gialle, 3 verdi)","12"), ("Pallone AMBU pediatrico/neonatale con reservoir","1"), ("Maschere pediatriche x pallone AMBU (3 misure)","3"), ("Cannule pediatriche (3 bianche, 3 rosa, 3 blu)","9"), ("Teli di medicazione sterili","3"), ("Garze sterili (pacchetti)","10"), ("Garze non sterili (cubi)",""), ("Cerotti di varia misura (scatola)","1"), ("Telini termici (metalline)","2"), ("Rotoli di cerotto","2"), ("Bende di varia misura",""), ("Benda elastica di varia misura",""), ("Rete tubolare elastica (testa - arto)","2x1"), ("Guanti sterili monouso (misure: 6.0 - 7.0 - 7.5 - 8.0 - 8.5)","5x1"), ("Forbici curve a punta smusse","1"), ("Pocket mask","1"), ("Apribocca","1"), ("Laccio emostatico venoso + laccio arterioso","2+1"), ("Acqua ossigenata + disinfettante cutaneo","1+1"), ("Soluzione fisiologica","2"), ("Ghiaccio sintetico (buste)","2"), ("Lenzuola monouso","2"), ("Forbici bottonute (taglia abito)","1"), ("Mascherine in carta monouso","4"), ("Mascherine faccia paraschizzi","3")]
    private let materialeInSede = [("Bollettario (con almeno 10 bolle libere)","1"), ("Telefono di servizio e radio portatili","1+2"), ("ECG", "1"), ("DAE","1"), ("Blocco relazione di soccorso MSB con almeno 15 schede)","1")]
    private let pulizia = [("Lavaggio esterno del mezzo",""), ("Pulizia parabrezza e cruscotto",""), ("Pulizia del vano guida",""), ("Pulizia del vano sanitario","")]
    private let materialeInDotaz = [("Estintore 3kg","1"), ("Lampada portatile","1"), ("Kit scasso + 2 torce antivento e fiammiferi + 2 fumogeni",""), ("Paia di guanti da lavoro","2"), ("Stradario \"Ortelio\"","1"), ("Stradario \"Di Lauro\"","1"), ("Carta e penna","")]
    private let controlli = [("Carburante",""), ("Luci anteriori e posteriori",""), ("Frecce (anteriori e posteriori)",""), ("Stop",""), ("Apparato radio Croce Viola",""), ("Sistema radio evoluto 118 Milano","")]
    private let carrozzeria = [("Nessun danno",""), ("Sì, segnare la posizione sulla figura",""), ("Note","")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch sectionIndex {
        case 0:
            self.titleSectionLabel.text = "Controlli generali"
            self.dictionaryPresidi = self.controlloGenerale
            self.firstNumber = 1
        case 1:
            self.titleSectionLabel.text = "Immobilizzazione e Trasporto"
            self.dictionaryPresidi = self.immobilizzazione
            self.firstNumber = 8
        case 2:
            self.titleSectionLabel.text = "Armadietti"
            self.dictionaryPresidi = self.armadietti
            self.firstNumber = 20
        case 3:
            self.titleSectionLabel.text = "Set vari"
            self.dictionaryPresidi = self.kit
            self.firstNumber = 36
        case 4:
            self.titleSectionLabel.text = "Materiale vario"
            self.dictionaryPresidi = self.materiale
            self.firstNumber = 39
        case 5:
            self.titleSectionLabel.text = "Ossigenoterapia"
            self.dictionaryPresidi = self.ossigenoterapia
            self.firstNumber = 50
        case 6:
            self.titleSectionLabel.text = "Aspirazione"
            self.dictionaryPresidi = self.aspirazione
            self.firstNumber = 56
        case 7:
            self.titleSectionLabel.text = "Zaino"
            self.dictionaryPresidi = self.zaino
            self.firstNumber = 59
        case 9:
            self.titleSectionLabel.text = "Materiale in sede"
            self.dictionaryPresidi = self.materialeInSede
            self.firstNumber = 90
        case 10:
            self.titleSectionLabel.text = "Pulizia del mezzo"
            self.dictionaryPresidi = self.pulizia
            self.firstNumber = 95
        case 11:
            self.titleSectionLabel.text = "Materiale in dotazione"
            self.dictionaryPresidi = self.materialeInDotaz
             self.firstNumber = 99
        case 12:
            self.titleSectionLabel.text = "Controlli vari"
            self.dictionaryPresidi = self.controlli
            self.firstNumber = 106
        case 13:
            self.titleSectionLabel.text = "Carrozzeria"
            self.dictionaryPresidi = self.carrozzeria
            self.firstNumber = 115
        default:
            self.titleSectionLabel.text = "Check-list mezzo"
        }
        
        for (_,_) in self.dictionaryPresidi {
            self.completedPoint.append(0)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dictionaryPresidi.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell", for: indexPath) as! CheckSectionTableViewCell
        
        cell.descriptionLabel.text = self.dictionaryPresidi[indexPath.row].0
        cell.numberLabel.text = self.dictionaryPresidi[indexPath.row].1
        
        if self.completedPoint[indexPath.row] == 0 {
            cell.backView.backgroundColor = UIColor.clear
        } else {
            cell.backView.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 153/255, blue: 0/255, alpha: 1.0)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if self.backFromImages == false {
            if self.dictionaryPresidi[indexPath.row].1 == "" {
                if self.completedPoint[indexPath.row] == 0 {
                    self.completedPoint[indexPath.row] = 1
                    self.tableView.reloadData()
                } else {
                    self.completedPoint[indexPath.row] = 0
                    self.tableView.reloadData()
                }
            } else {
                let alert = UIAlertController(style: .alert, title: self.dictionaryPresidi[indexPath.row].0)
                let config: TextField.Config = { textField in
                    textField.becomeFirstResponder()
                    textField.textColor = .black
                    textField.textAlignment = .center
                    textField.text = self.dictionaryPresidi[indexPath.row].1
                    textField.placeholder = "Valore reale sul mezzo"
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
                        self.dictionaryPresidi[indexPath.row].1 = textField.text!
                    }
                }
                alert.addOneTextField(configuration: config)
                alert.addAction(title: "Conferma", style: .cancel) { (action) in
                    self.completedPoint[indexPath.row] = 1
                    self.tableView.reloadData()
                }
                self.show(alert, sender: nil)
            }
            if self.dictionaryPresidi[indexPath.row].0 == "Sì, segnare la posizione sulla figura" {
                self.performSegue(withIdentifier: "completeCarrozzeria", sender: nil)
            } else if self.dictionaryPresidi[indexPath.row].0 == "Carburante" {
                let alert = UIAlertController(style: .actionSheet, title: "Carburante", message: "Seleziona la quantità di carburante rilevata.")
                alert.addAction(UIAlertAction(title: "Pieno", style: .default, handler: { (action) in
                    self.dictionaryPresidi[indexPath.row].1 = "Pieno"
                    self.completedPoint[indexPath.row] = 1
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "3/4", style: .default, handler: { (action) in
                    self.dictionaryPresidi[indexPath.row].1 = "3/4"
                    self.completedPoint[indexPath.row] = 1
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "1/2", style: .default, handler: { (action) in
                    self.dictionaryPresidi[indexPath.row].1 = "1/2"
                    self.completedPoint[indexPath.row] = 1
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "1/4", style: .default, handler: { (action) in
                    self.dictionaryPresidi[indexPath.row].1 = "1/4"
                    self.completedPoint[indexPath.row] = 1
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Riserva", style: .default, handler: { (action) in
                    self.dictionaryPresidi[indexPath.row].1 = "Riserva"
                    self.completedPoint[indexPath.row] = 1
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Annulla", style: .cancel))
                self.show(alert, sender: nil)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func completeSection(_ sender: UIButton) {
        var count = 0
        for _ in self.completedPoint {
            if self.completedPoint[count] == 1 {
                count = count + 1
            }
        }
        
        if count == self.dictionaryPresidi.count || (self.sectionIndex == 13 && count >= 1) {
            self.createHTML()
        } else {
            if self.titleSectionLabel.text == "Carrozzeria" {
                self.createHTML()
            } else {
                let alert = UIAlertController(title: "Attenzione", message: "É necessario completare tutta la checklist. Se qualcosa non fosse presente modificarne la quantità a 0.", preferredStyle: .alert)
                let no = UIAlertAction(title: "Ok", style: .cancel)
                alert.addAction(no)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func createHTML() {
        
        var startingFrom = self.firstNumber
        for (_,numero) in self.dictionaryPresidi {
            if numero == "" {
                if self.sectionIndex == 13 && self.completedPoint[0] == 0 {
                    self.htmlContent = self.htmlContent.replacingOccurrences(of: "#N\(startingFrom)#", with: "")
                } else if self.sectionIndex == 13 && self.completedPoint[1] == 0 {
                    self.htmlContent = self.htmlContent.replacingOccurrences(of: "#N\(startingFrom)#", with: "")
                } else {
                    self.htmlContent = self.htmlContent.replacingOccurrences(of: "#N\(startingFrom)#", with: "OK")
                }
            } else {
                self.htmlContent = self.htmlContent.replacingOccurrences(of: "#N\(startingFrom)#", with: numero)
            }
            startingFrom = startingFrom + 1
        }
        
        if self.sectionIndex == 13 {
            self.htmlContent = self.htmlContent.replacingOccurrences(of: "#NOTE#", with: self.dictionaryPresidi[2].1)
        }
        
        print(self.htmlContent)
        //Salvo e chiudo la finestra
        delegate.completedTask[self.sectionIndex] = 1
        delegate.HTMLContent = self.htmlContent
        delegate.tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "completeCarrozzeria" {
            let dest = segue.destination as! ControlloCarrozzeriaViewController
            dest.delegate = self
            dest.htmlContent = self.htmlContent
        }
    }
}
