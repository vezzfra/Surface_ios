//
//  CheckDAEViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 27/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit
import FCAlertView
import RLBAlertsPickers

class CheckDAEViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var daeModelSelection: UISegmentedControl!
    @IBOutlet weak var infoView: UIView!
    
    var mainArray = [(String,String)]()
    var completed = [Int]()
    var htmlContent = ""
    var delegate = GestioneMezziViewController()
    
    private let daePhilips = [("FR2+ HeartStart pulito, privo di contaminazioni, nessun segno di danni",""), ("2 set di elettrodi adulti sigillati, integri e non scaduti",""), ("1 set di elettrodi pediatrici sigillati, integri e non scaduti",""), ("Forbici, rasoio, rotolo di garza",""), ("Presenza scheda dati nel suo alloggiamento",""), ("Presenza batteria nel suo alloggiamento",""), ("Lo schermo alterna la clessidra e il quadrato",""), ("Commenti, problemi, azioni correttive"," ")]
    private let daeLifePack = [("","")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.daeModelSelection.selectedSegmentIndex = 0
        self.mainArray = self.daePhilips
        
        for _ in self.mainArray {
            self.completed.append(0)
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    @IBAction func selectSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.mainArray = self.daePhilips
            self.tableView.reloadData()
        } else {
            self.mainArray = self.daeLifePack
            self.tableView.reloadData()
        }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendCheckDAE(_ sender: UIButton) {
        if !self.completed.contains(0) || (self.completed.indexes(of: 0).count == 1 && self.completed[2] == 0) {
            self.uploadCheck()
        } else {
            let alert = UIAlertController(title: "Attenzione", message: "La checklist non è stata completata interamente. Sei sicuro di volerla inviare così come è?", preferredStyle: .alert)
            let yes = UIAlertAction(title: "Sì", style: .default) { (action) in
                self.uploadCheck()
            }
            let no = UIAlertAction(title: "No", style: .cancel)
            alert.addAction(yes)
            alert.addAction(no)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func uploadCheck() {
        var newDaeHtml = ""
        if self.daeModelSelection.selectedSegmentIndex == 0 {
            //Philips
            newDaeHtml = "<table border=\"1\" style=\"width: 97.82399306945638%; border-collapse: collapse; height: 52px;\"><tbody><tr style=\"height: 18px;\"><td style=\"width: 90.34136743160107%; height: 18px;\">Dae rilevato a bordo</td><td style=\"width: 65.38807865874034%; text-align: right; height: 18px;\">Philips</td></tr><tr style=\"height: 18px;\"><td style=\"width: 90.34136743160107%; height: 18px;\">DAE pulito, privo di contaminazioni, nessun segno di danni</td><td style=\"width: 65.38807865874034%; text-align: right; height: 18px;\">#DAE_1#</td></tr></tbody></table><p><strong>Forniture disponibili:</strong></p><table border=\"1\" style=\"width: 97.82399306945638%; border-collapse: collapse; height: 52px;\"><tbody><tr style=\"height: 18px;\"><td style=\"width: 90.34136743160107%; height: 18px;\">2 set di elettrodi adulti sigillati, integri e non scaduti</td><td style=\"width: 65.38807865874034%; text-align: right; height: 18px;\">#DAE_2#</td></tr><tr style=\"height: 18px;\"><td style=\"width: 90.34136743160107%; height: 18px;\">1 set di elettrodi pediatrici sigillati, integri e non scaduti</td><td style=\"width: 65.38807865874034%; text-align: right; height: 18px;\">#DAE_3#</td></tr><tr style=\"height: 18px;\"><td style=\"width: 90.34136743160107%; height: 18px;\">Forbici, rasoio, rotolo di garza</td><td style=\"width: 65.38807865874034%; text-align: right; height: 18px;\">#DAE_4#</td></tr><tr style=\"height: 18px;\"><td style=\"width: 90.34136743160107%; height: 18px;\">Verificare la presenza della scheda dati nel suo alloggiamento</td><td style=\"width: 65.38807865874034%; text-align: right; height: 18px;\">#DAE_5#</td></tr><tr style=\"height: 18px;\"><td style=\"width: 90.34136743160107%; height: 18px;\">Verificare la presenza della batteria nel suo alloggiamento</td><td style=\"width: 65.38807865874034%; text-align: right; height: 18px;\">#DAE_6#</td></tr></tbody></table><p><strong>Indicatore di stato:</strong></p><table border=\"1\" style=\"width: 97.82399306945638%; border-collapse: collapse; height: 52px;\"><tbody><tr style=\"height: 18px;\"><td style=\"width: 90.34136743160107%; height: 18px;\">Alterna la visualizzazione della clessidra e del quadratino</td><td style=\"width: 65.38807865874034%; text-align: right; height: 18px;\">#DAE_7#</td></tr></tbody></table><p><strong>Note:</strong></p><p><em>#DAE_NOTE#</em></p>"
            
            newDaeHtml = newDaeHtml.replacingOccurrences(of: "#DAE_NOTE#", with: self.mainArray[7].1)
        } else {
            //Lifepack
        }
        
        var index = 1
        for num in self.completed {
            if num == 0 {
                newDaeHtml = newDaeHtml.replacingOccurrences(of: "#DAE_\(index)#", with: "NO")
            } else {
                newDaeHtml = newDaeHtml.replacingOccurrences(of: "#DAE_\(index)#", with: "OK")
            }
            index = index + 1
        }
        
        self.htmlContent = self.htmlContent.replacingOccurrences(of: "#DAE_LINES#", with: newDaeHtml)
        self.delegate.HTMLContent = self.htmlContent
        self.delegate.completedTask[8] = 1
        self.delegate.tableView.reloadData()
        print(self.htmlContent)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mainArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "daeCell", for: indexPath) as! DAETableViewCell
        
        cell.descriptionLabel.text = self.mainArray[indexPath.row].0
        
        if self.completed[indexPath.row] == 0 {
            cell.backView.backgroundColor = UIColor.clear
        } else {
            cell.backView.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 153/255, blue: 0/255, alpha: 1.0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.completed[indexPath.row] == 0 {
            if self.daeModelSelection.selectedSegmentIndex == 0 && indexPath.row == 7 {
                let alert = UIAlertController(style: .alert, title: "Note aggiuntive")
                let config: TextField.Config = { textField in
                    textField.becomeFirstResponder()
                    textField.textColor = .black
                    textField.textAlignment = .center
                    textField.placeholder = "Inserire eventuali note qui"
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
                        self.mainArray[indexPath.row].1 = textField.text!
                    }
                }
                alert.addOneTextField(configuration: config)
                alert.addAction(title: "Conferma", style: .cancel)
                self.show(alert, sender: nil)
            } // else, aggiungere controllo lifepack #1#
            self.completed[indexPath.row] = 1
            self.tableView.reloadData()
        } else {
            if self.daeModelSelection.selectedSegmentIndex == 0 && indexPath.row == 7 {
                let alert = UIAlertController(style: .alert, title: "Note aggiuntive e scadenza piastre")
                let config: TextField.Config = { textField in
                    textField.becomeFirstResponder()
                    textField.textColor = .black
                    textField.textAlignment = .center
                    textField.text = self.mainArray[indexPath.row].1
                    textField.placeholder = "Inserire le note qui"
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
                        self.mainArray[indexPath.row].1 = textField.text!
                    }
                }
                alert.addOneTextField(configuration: config)
                alert.addAction(title: "Conferma", style: .cancel)
                self.show(alert, sender: nil)
            } // else, aggiungere controllo lifepack #1#
            self.completed[indexPath.row] = 0
            self.tableView.reloadData()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
