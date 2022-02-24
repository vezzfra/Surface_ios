//
//  InfoViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 12/11/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit
import Parse

class InfoViewController: UIViewController {
    
    @IBOutlet weak var cod_invio: UIView!
    @IBOutlet weak var cod_riscontro: UIView!
    @IBOutlet weak var cod_trasporto: UIView!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var oraLabel: UILabel!
    @IBOutlet weak var missionNumerLabel: UILabel!
    @IBOutlet weak var missionAddressLabel: UILabel!
    @IBOutlet weak var motivoImage: UIImageView!
    @IBOutlet weak var motivoLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var anagraficaLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var hospitalLabel: UILabel!
    @IBOutlet weak var missioneGestitaView: UIView!
    
    var code = ""
    var delegate = ViewController()
    var mode = "d"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.missioneGestitaView.isHidden = true
        
        let query = PFQuery(className: "Servizi")
        query.whereKey("codice", equalTo: self.code)
        query.whereKey("username", equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
        query.findObjectsInBackground { (servizi, error) in
            if error == nil && servizi!.count > 0 {
                for servizio in servizi! {
                    self.dataLabel.text = "\(String(describing: servizio["data"] as! String))"
                    self.oraLabel.text = "\(String(describing: servizio["ora"] as! String))"
                    self.motivoLabel.text = "Motivo: \(String(describing: servizio["tipologia"] as! String))"
                    self.noteLabel.text = "Note: \(String(describing: servizio["note"] as! String))"
                    
                    switch servizio["tipologia"] as! String {
                    case "Aggressione", "Evento Violento":
                        self.motivoImage.image = UIImage(named: "violento.png")
                    case "Caduta suolo", "Caduta":
                        self.motivoImage.image = UIImage(named: "caduta.png")
                    case "Soccorso persona":
                        self.motivoImage.image = UIImage(named: "soccorso_persona.png")
                    case "Altro - Non identifica", "Altro - Non classifica", "Altro":
                        self.motivoImage.image = UIImage(named: "non_identifica.png")
                    case "Inc stradale", "Inc in aria", "Inc ferrovia":
                        self.motivoImage.image = UIImage(named: "inc.png")
                    case "Inc in acqua":
                        self.motivoImage.image = UIImage(named: "acqua.png")
                    case "Inc in montagna":
                        self.motivoImage.image = UIImage(named: "montagna.png")
                    case "Inc speleologico":
                       self.motivoImage.image = UIImage(named: "grotta.png")
                    case "Inc infortunio", "Ferita":
                        self.motivoImage.image = UIImage(named: "infortunio.png")
                    case "Etilica", "Intossicazione":
                        self.motivoImage.image = UIImage(named: "intossicazione.png")
                    case "Animali":
                        self.motivoImage.image = UIImage(named: "animali.png")
                    case "Calamità naturali":
                       self.motivoImage.image = UIImage(named: "calamita.png")
                    case "Evento di massa", "Maxiemergenza", "Inc maggiore":
                       self.motivoImage.image = UIImage(named: "massa.png")
                    default:
                        self.motivoImage.image = UIImage(named: "medico.png")
                    }
                    
                    switch servizio["c_invio"] as! String {
                    case "Verde":
                        self.cod_invio.backgroundColor = UIColor.green
                    case "Giallo":
                        self.cod_invio.backgroundColor = UIColor.yellow
                    case "Rosso":
                        self.cod_invio.backgroundColor = UIColor.red
                    case "Bianco":
                        self.cod_invio.backgroundColor = UIColor.white
                    default:
                        print("Invio")
                    }
                    
                    if let riscontro = servizio["c_riscontro"] as? String {
                        switch riscontro {
                        case "Verde":
                            self.cod_riscontro.backgroundColor = UIColor.green
                        case "Giallo":
                            self.cod_riscontro.backgroundColor = UIColor.yellow
                        case "Rosso":
                            self.cod_riscontro.backgroundColor = UIColor.red
                        case "Non trasporta", "Vuoto", "Regolare - Non trasporta":
                            self.cod_riscontro.backgroundColor = UIColor.gray
                        default:
                            self.cod_riscontro.backgroundColor = UIColor.white
                        }
                    }
                    
                    switch servizio["c_trasporto"] as! String {
                    case "Verde":
                        self.cod_trasporto.backgroundColor = UIColor.green
                    case "Giallo":
                        self.cod_trasporto.backgroundColor = UIColor.yellow
                    case "Rosso":
                        self.cod_trasporto.backgroundColor = UIColor.red
                    default:
                        self.cod_trasporto.backgroundColor = UIColor.gray
                    }
                    
                    if let missionNumber = servizio["mission"] as? String {
                        self.missionNumerLabel.text = "Missione: \(missionNumber)"
                    } else {
                        self.missionNumerLabel.text = "Missione: N.D."
                    }
                    
                    if let missionAddress = servizio["indirizzo"] as? String {
                        self.missionAddressLabel.text = "Indirizzo: \(missionAddress)"
                    } else {
                        self.missionAddressLabel.text = "Indirizzo: N.D."
                    }
                    
                    if let hospital = servizio["hospital"] as? String {
                        self.hospitalLabel.text = "Ospedale: \(hospital)"
                    } else {
                        self.hospitalLabel.text = "Ospedale: N.D."
                    }
                    
                    if let gender = servizio["gender"] as? String {
                        self.genderLabel.text = "Sesso: \(gender)"
                    } else {
                        self.genderLabel.text = "Sesso: N.D."
                    }
                    
                    if let anagrafic = servizio["anagrafica"] as? String {
                        if anagrafic != "" {
                            self.anagraficaLabel.text = anagrafic
                        } else {
                            self.anagraficaLabel.text = "Anagrafica: N.D."
                        }
                    } else {
                        self.anagraficaLabel.text = "Anagrafica: N.D."
                    }
                    
                    if let detail = servizio["dettaglio_tipologia"] as? String {
                        self.detailLabel.text = "Dettaglio: \(detail)"
                    } else {
                        self.detailLabel.text = "Dettaglio: N.D."
                    }
                    
                    if let _ = servizio["gestito"] as? String {
                        if servizio["gestito"] as! String == "true" {
                            self.missioneGestitaView.isHidden = false
                        }
                    }
                }
            } else {
                print("Errore: impossibile trovare il servizio richiesto")
            }
        }

    }
}
