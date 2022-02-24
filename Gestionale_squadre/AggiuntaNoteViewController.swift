//
//  AggiuntaNoteViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 24/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit

class AggiuntaNoteViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var aspetti: UITextView!
    @IBOutlet weak var confermaInserimento: UIButton!
    @IBOutlet weak var miglioramento: UIButton!
    @IBOutlet weak var positivi: UIButton!
    @IBOutlet weak var confermaParziale: UIButton!
    @IBOutlet weak var deleteNote: UIButton!
    
    var aspettiPositivi = ""
    var aspettiDaMigliorare = ""
    var stoInserendo = 0
    var delegate = NuovaSchedaSoccorritoreViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.aspetti.delegate = self
        if self.aspettiPositivi != "" {
            self.positivi.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 153/255, blue: 0/255, alpha: 1.0)
        }
        if self.aspettiDaMigliorare != "" {
            self.miglioramento.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 153/255, blue: 0/255, alpha: 1.0)
        }
        
        self.deleteNote.isHidden = true
        self.aspetti.isHidden = true
        self.confermaParziale.isHidden = true
        self.aspetti.layer.cornerRadius = 5
        self.aspetti.layer.masksToBounds = true
    }
    
    @IBAction func addAspettiPositivi(_ sender: UIButton) {
        if self.aspettiPositivi == "" {
            self.aspetti.text = ""
            self.deleteNote.isHidden = false
            self.miglioramento.isHidden = true
            self.positivi.isHidden = true
            self.confermaInserimento.isHidden = true
            self.aspetti.isHidden = false
            self.confermaParziale.isHidden = false
            self.stoInserendo = 1
        } else {
            self.aspetti.text = self.aspettiPositivi
            self.miglioramento.isHidden = true
            self.deleteNote.isHidden = false
            self.positivi.isHidden = true
            self.confermaInserimento.isHidden = true
            self.aspetti.isHidden = false
            self.confermaParziale.isHidden = false
            self.stoInserendo = 1
        }
    }
    
    @IBAction func addAspettiDaMigliorare(_ sender: UIButton) {
        if self.aspettiDaMigliorare == "" {
            self.aspetti.text = ""
            self.miglioramento.isHidden = true
            self.deleteNote.isHidden = false
            self.positivi.isHidden = true
            self.confermaInserimento.isHidden = true
            self.aspetti.isHidden = false
            self.confermaParziale.isHidden = false
            self.stoInserendo = 2
        } else {
            self.aspetti.text = self.aspettiDaMigliorare
            self.miglioramento.isHidden = true
            self.positivi.isHidden = true
            self.deleteNote.isHidden = false
            self.confermaInserimento.isHidden = true
            self.aspetti.isHidden = false
            self.confermaParziale.isHidden = false
            self.stoInserendo = 2
        }
    }
    
    @IBAction func inserisciNota(_ sender: UIButton) {
        if self.stoInserendo == 1 {
            if self.aspetti.text != "" {
                self.aspettiPositivi = self.aspetti.text
               
                self.miglioramento.isHidden = false
                self.positivi.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 153/255, blue: 0/255, alpha: 1.0)
                self.positivi.isHidden = false
                self.confermaInserimento.isHidden = false
                self.deleteNote.isHidden = true
                self.aspetti.isHidden = true
                self.confermaParziale.isHidden = true
                self.stoInserendo = 0
            } else {
                let alert = UIAlertController(title: "Nessun testo inserito", message: nil, preferredStyle: .alert)
                let no = UIAlertAction(title: "Ok", style: .cancel)
                alert.addAction(no)
                self.show(alert, sender: nil)
            }
        } else if self.stoInserendo == 2 {
            if self.aspetti.text != "" {
                self.aspettiDaMigliorare = self.aspetti.text
                
                self.miglioramento.isHidden = false
                self.miglioramento.backgroundColor = UIColor.init(displayP3Red: 0/255, green: 153/255, blue: 0/255, alpha: 1.0)
                self.positivi.isHidden = false
                self.confermaInserimento.isHidden = false
                self.aspetti.isHidden = true
                self.deleteNote.isHidden = true
                self.confermaParziale.isHidden = true
                self.stoInserendo = 0
            } else {
                let alert = UIAlertController(title: "Nessun testo inserito", message: nil, preferredStyle: .alert)
                let no = UIAlertAction(title: "Ok", style: .cancel)
                alert.addAction(no)
                self.show(alert, sender: nil)
            }
        }
    }
    
    @IBAction func eliminaNota(_ sender: UIButton) {
        if self.aspetti.text == "" {
            self.miglioramento.isHidden = false
            self.deleteNote.isHidden = true
            self.positivi.isHidden = false
            self.confermaInserimento.isHidden = false
            self.aspetti.isHidden = true
            self.confermaParziale.isHidden = true
            self.stoInserendo = 0
        } else {
            if self.aspetti.text != self.aspettiDaMigliorare || self.aspetti.text != self.aspettiPositivi {
                let alert = UIAlertController(title: "Vuoi davvero annullare le modifiche apportate?", message: nil, preferredStyle: .alert)
                let yes = UIAlertAction(title: "Sì", style: .default) { (action) in
                    self.miglioramento.isHidden = false
                    self.deleteNote.isHidden = true
                    self.positivi.isHidden = false
                    self.confermaInserimento.isHidden = false
                    self.aspetti.isHidden = true
                    self.confermaParziale.isHidden = true
                    self.stoInserendo = 0
                }
                let no = UIAlertAction(title: "No", style: .cancel)
                alert.addAction(yes)
                alert.addAction(no)
                self.show(alert, sender: nil)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Sei sicuro?", message: "Le note che hai inserito non verranno salvate.", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Sì", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        let no = UIAlertAction(title: "No", style: .cancel)
        alert.addAction(yes)
        alert.addAction(no)
        self.show(alert, sender: nil)
    }
    
    @IBAction func confermaNote(_ sender: UIButton) {
        if self.aspettiPositivi != "" && self.aspettiDaMigliorare != "" {
            self.delegate.noteAspettiPositivi = self.aspettiPositivi
            self.delegate.noteAspettiMigliorabili = self.aspettiDaMigliorare
            self.delegate.noteInserite = true
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Note mancanti", message: "Tutte le note sono obbligatorie per completare la scheda", preferredStyle: .alert)
            let no = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(no)
            self.show(alert, sender: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.aspetti.resignFirstResponder()
        super.touchesBegan(touches, with: event)
    }
}

