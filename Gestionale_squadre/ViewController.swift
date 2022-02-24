//
//  ViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 11/11/2018.
//  Copyright © 2018 Ro.v.er. All rights reserved.
//

import UIKit
import Parse
import JGProgressHUD
import MapKit
import Whisper
import CoreLocation
import SwiftForms

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var selectionSegment: UISegmentedControl!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var listOrder: UIButton!
    @IBOutlet weak var typeFilterButton: UIButton!
    @IBOutlet weak var dataFilterButton: UIButton!
    @IBOutlet weak var codeFilterButton: UIButton!
    @IBOutlet weak var teamButton: UIButton!
    
    var username = ""
    var selected_code = ""
    var mode = "missioni"
    var list_mode = "d"
    var codice_servizio = [String]()
    var servizi = [String]()
    var codice_invio = [String]()
    var codice_trasporto = [String]()
    var dataMissione = [String]()
    var oraMissione = [String]()
    var codice_servizioFiltered = [String]()
    var serviziFiltered = [String]()
    var codice_invioFiltered = [String]()
    var codice_trasportoFiltered = [String]()
    var pendingMissions = [String]()
    var indirizzi = [String]()
    var latitudeArray = [Double]()
    var longitudeArray = [Double]()
    var tipiMissioni = NSMutableArray()
    var numeri = [Int]()
    var hud: JGProgressHUD = JGProgressHUD()
    var isFiltering = false
    
    var filterDate = ""
    var filterType = ""
    var filterCode = ""
    var currentMission = ""
    var mapError = false
    var memberInTeam = 0
    var fromServer = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        self.tableView.addSubview(self.refreshControl)
        self.selectionSegment.selectedSegmentIndex = 0
        self.teamButton.imageView?.contentMode = .scaleAspectFit
        
        self.username = (UserDefaults.standard.object(forKey: "app_username") as! String)
        
        self.hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Carico missioni"
        
        self.filterButton.setImage(UIImage(named: "filter_off.png"), for: .normal)
        self.listOrder.setImage(UIImage(named: "descending.png"), for: .normal)
        self.loadData(mode: self.list_mode)
        
        if UserDefaults.standard.bool(forKey: "isOnService") {
            let data = UserDefaults.standard.object(forKey: "inServizioDate") as! Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let giorno = dateFormatter.string(from: data)
            dateFormatter.dateFormat = "HH:mm"
            let ora = dateFormatter.string(from: data)
            
            if (data.timeIntervalSinceNow < -18000) {
                let alert = UIAlertController(title: "Attenzione!", message: "Sei ancora in servizio con la stessa squadra dal \(giorno) alle \(ora)?", preferredStyle: .alert)
                let si = UIAlertAction(title: "Sì", style: .cancel)
                let no =  UIAlertAction(title: "No", style: .default) { (action) in
                    UserDefaults.standard.set(false, forKey: "isOnService")
                    UserDefaults.standard.synchronize()
                }
                alert.addAction(si)
                alert.addAction(no)
                alert.show()
            }
        } else {
            let query = PFQuery(className: "Squadre")
            query.whereKey("second", equalTo: self.username)
            query.findObjectsInBackground { (objects, error) in
                if error == nil {
                    if objects!.count > 0 {
                        self.memberInTeam = 1
                        self.fromServer = true
                        UserDefaults.standard.set(true, forKey: "isOnService")
                    } else {
                        let query1 = PFQuery(className: "Squadre")
                        query1.whereKey("third", equalTo: self.username)
                        query1.findObjectsInBackground { (objects, error) in
                            if error == nil {
                                if objects!.count > 0 {
                                    self.memberInTeam = 2
                                    self.fromServer = true
                                    UserDefaults.standard.set(true, forKey: "isOnService")
                                } else {
                                    let query2 = PFQuery(className: "Squadre")
                                    query2.whereKey("fourth", equalTo: self.username)
                                    query2.findObjectsInBackground { (objects, error) in
                                        if error == nil {
                                            if objects!.count > 0 {
                                                self.memberInTeam = 3
                                                self.fromServer = true
                                                UserDefaults.standard.set(true, forKey: "isOnService")
                                            }
            }}}}}}}} /* end_of_query */
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.mode == "missioni" {
            if !isFiltering {
                self.totalLabel.text = "Totale missioni: \(self.servizi.count)"
                return self.servizi.count
            } else {
                self.totalLabel.text = "Totale filtrate: \(self.serviziFiltered.count)"
                return self.serviziFiltered.count
            }
        } else {
            self.totalLabel.text = "Totale missioni: \(self.servizi.count)"
            return self.tipiMissioni.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.mode == "missioni" {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cella_servizio", for: indexPath) as! ServiceTableViewCell
        
            if !isFiltering {
                cell.tipologia.text = self.servizi[indexPath.row]
                
                switch self.servizi[indexPath.row] {
                case "Aggressione", "Evento Violento":
                    cell.iconImage.image = UIImage(named: "violento.png")
                case "Caduta suolo", "Caduta":
                    cell.iconImage.image = UIImage(named: "caduta.png")
                case "Soccorso persona":
                    cell.iconImage.image = UIImage(named: "soccorso_persona.png")
                case "Altro - Non identifica", "Altro - Non classifica", "Altro":
                    cell.iconImage.image = UIImage(named: "non_identifica.png")
                case "Inc stradale":
                    cell.iconImage.image = UIImage(named: "inc.png")
                case "Inc in acqua":
                    cell.iconImage.image = UIImage(named: "acqua.png")
                case "Inc in montagna":
                    cell.iconImage.image = UIImage(named: "montagna.png")
                case "Inc speleologico":
                    cell.iconImage.image = UIImage(named: "grotta.png")
                case "Inc infortunio", "Ferita":
                    cell.iconImage.image = UIImage(named: "infortunio.png")
                case "Etilica", "Intossicazione":
                    cell.iconImage.image = UIImage(named: "intossicazione.png")
                case "Animali":
                    cell.iconImage.image = UIImage(named: "animali.png")
                case "Calamità naturali":
                    cell.iconImage.image = UIImage(named: "calamita.png")
                case "Evento di massa", "Maxiemergenza", "Inc maggiore":
                    cell.iconImage.image = UIImage(named: "massa.png")
                default:
                    cell.iconImage.image = UIImage(named: "medico.png")
                }
                
                switch self.codice_invio[indexPath.row] {
                case "Verde":
                    cell.cod_invio.backgroundColor = UIColor(red: 40/155, green: 137/155, blue: 38/155, alpha: 1.0)
                case "Giallo":
                    cell.cod_invio.backgroundColor = UIColor.yellow
                case "Rosso":
                    cell.cod_invio.backgroundColor = UIColor(red: 158/155, green: 14/155, blue: 21/155, alpha: 1.0)
                case "Bianco":
                    cell.cod_invio.backgroundColor = UIColor.white
                default:
                    print("Invio")
                }
                
                switch self.codice_trasporto[indexPath.row] {
                case "Verde":
                    cell.cod_trasporto.backgroundColor = UIColor(red: 40/155, green: 137/155, blue: 38/155, alpha: 1.0)
                case "Giallo":
                    cell.cod_trasporto.backgroundColor = UIColor.yellow
                case "Rosso":
                    cell.cod_trasporto.backgroundColor = UIColor(red: 158/155, green: 14/155, blue: 21/155, alpha: 1.0)
                default:
                    cell.cod_trasporto.backgroundColor = UIColor.lightGray
                }
                
                if self.pendingMissions.contains(self.codice_servizio[indexPath.row]) {
                    cell.iconImage.image = UIImage(named: "alert_pending.png")
                }
            } else {
                cell.tipologia.text = self.serviziFiltered[indexPath.row]
                
                switch self.serviziFiltered[indexPath.row] {
                case "Aggressione", "Evento Violento":
                    cell.iconImage.image = UIImage(named: "violento.png")
                case "Caduta suolo", "Caduta":
                    cell.iconImage.image = UIImage(named: "caduta.png")
                case "Soccorso persona":
                    cell.iconImage.image = UIImage(named: "soccorso_persona.png")
                case "Altro - Non identifica", "Altro - Non classifica", "Altro":
                    cell.iconImage.image = UIImage(named: "non_identifica.png")
                case "Inc stradale", "Inc in aria", "Inc ferrovia":
                    cell.iconImage.image = UIImage(named: "inc.png")
                case "Inc in acqua":
                    cell.iconImage.image = UIImage(named: "acqua.png")
                case "Inc in montagna":
                    cell.iconImage.image = UIImage(named: "montagna.png")
                case "Inc speleologico":
                    cell.iconImage.image = UIImage(named: "grotta.png")
                case "Inc infortunio", "Ferita":
                    cell.iconImage.image = UIImage(named: "infortunio.png")
                case "Etilica", "Intossicazione":
                    cell.iconImage.image = UIImage(named: "intossicazione.png")
                case "Animali":
                    cell.iconImage.image = UIImage(named: "animali.png")
                case "Calamità naturali":
                    cell.iconImage.image = UIImage(named: "calamita.png")
                case "Evento di massa", "Maxiemergenza", "Inc maggiore":
                    cell.iconImage.image = UIImage(named: "massa.png")
                default:
                    cell.iconImage.image = UIImage(named: "medico.png")
                }
                
                switch self.codice_invioFiltered[indexPath.row] {
                case "Verde":
                    cell.cod_invio.backgroundColor = UIColor(red: 40/155, green: 137/155, blue: 38/155, alpha: 1.0)
                case "Giallo":
                    cell.cod_invio.backgroundColor = UIColor.yellow
                case "Rosso":
                    cell.cod_invio.backgroundColor = UIColor(red: 158/155, green: 14/155, blue: 21/155, alpha: 1.0)
                case "Bianco":
                    cell.cod_invio.backgroundColor = UIColor.white
                default:
                    print("Invio")
                }
                
                switch self.codice_trasportoFiltered[indexPath.row] {
                case "Verde":
                    cell.cod_trasporto.backgroundColor = UIColor(red: 40/155, green: 137/155, blue: 38/155, alpha: 1.0)
                case "Giallo":
                    cell.cod_trasporto.backgroundColor = UIColor.yellow
                case "Rosso":
                    cell.cod_trasporto.backgroundColor = UIColor(red: 158/155, green: 14/155, blue: 21/155, alpha: 1.0)
                default:
                    cell.cod_trasporto.backgroundColor = UIColor.lightGray
                }
                
                if self.pendingMissions.contains(self.codice_servizio[indexPath.row]) {
                    cell.iconImage.image = UIImage(named: "alert_pending.png")
                }
            }
        return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cella_statistica", for: indexPath) as! StatisticaTableViewCell
            
            cell.tipoServizio.text = (self.tipiMissioni[indexPath.row] as! String)
            cell.numeroServizi.text = String(describing: self.numeri[indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.mode == "missioni" {
            if !isFiltering {
                self.selected_code = self.codice_servizio[indexPath.row]
            } else {
                self.selected_code = self.codice_servizioFiltered[indexPath.row]
            }
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.performSegue(withIdentifier: "goToInfo", sender: nil)
        }
    }
    
    @IBAction func addNewTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "newServizio", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToInfo" {
            let dest = segue.destination as! InfoViewController
            dest.code = self.selected_code
            dest.delegate = self
            dest.mode = self.list_mode
        } else if segue.identifier == "newServizio" {
            let dest = segue.destination as! FormViewController as! NuovoServizioViewController
            dest.delegate = self
            dest.fromServer = self.fromServer
        } else if segue.identifier == "logout" {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(ViewController.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.loadData(mode: self.list_mode)
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    func loadData(mode: String) {
        
        self.isFiltering = false
        self.codice_servizio.removeAll()
        self.codice_invio.removeAll()
        self.codice_trasporto.removeAll()
        self.servizi.removeAll()
        self.tipiMissioni.removeAllObjects()
        self.dataMissione.removeAll()
        self.codice_invioFiltered.removeAll()
        self.codice_servizioFiltered.removeAll()
        self.codice_trasportoFiltered.removeAll()
        self.oraMissione.removeAll()
        self.serviziFiltered.removeAll()
        self.indirizzi.removeAll()
        self.numeri.removeAll()
        self.latitudeArray.removeAll()
        self.longitudeArray.removeAll()
        self.pendingMissions.removeAll()
        self.hud.show(in: self.view)
        
        let query = PFQuery(className: "Servizi")
        query.whereKey("username", equalTo: self.username)
        if mode == "d" {
            query.order(byDescending: "_created_at")
        } else {
            query.order(byAscending: "_created_at")
        }
        query.limit = 10000
        query.findObjectsInBackground { (objects, error) in
            if error == nil && objects!.count > 0 {
                for servizio in objects! {
                    self.codice_servizio.append(servizio["codice"] as! String)
                    self.servizi.append(servizio["tipologia"] as! String)
                    self.codice_invio.append(servizio["c_invio"] as! String)
                    self.codice_trasporto.append(servizio["c_trasporto"] as! String)
                    self.dataMissione.append(servizio["data"] as! String)
                    self.indirizzi.append(servizio["indirizzo"] as! String)
                    self.oraMissione.append(servizio["ora"] as! String)
                    self.latitudeArray.append(servizio["latitude"] as! Double)
                    self.longitudeArray.append(servizio["longitude"] as! Double)
                    
                    if (servizio["stato"] as! String) == "pending" {
                        self.pendingMissions.append(servizio["codice"] as! String)
                    }
                    
                    if self.tipiMissioni.contains(servizio["tipologia"] as! String) {
                        let index = self.tipiMissioni.index(of: servizio["tipologia"] as! String)
                        self.numeri[index] = self.numeri[index] + 1
                    } else {
                        self.tipiMissioni.add(servizio["tipologia"] as! String)
                        self.numeri.append(1)
                    }
                }
                self.orderStatArray()
                self.hud.dismiss()
                self.tableView.isHidden = false
                self.tableView.reloadData()
            } else {
                // Errore generico
                self.tableView.isHidden = true
                print("Errore: cannot parse element from class \"Servizi\"")
            }
        }
    }
    
    @IBAction func changeSelection(_ sender: UISegmentedControl) {
        if self.selectionSegment.selectedSegmentIndex == 1 {
            self.mode = "statistiche"
            self.listOrder.isEnabled = false
            self.isFiltering = false
            self.tableView.allowsSelection = false
            self.tableView.reloadData()
        } else if self.selectionSegment.selectedSegmentIndex == 0 {
            self.mode = "missioni"
            self.listOrder.isEnabled = true
            self.tableView.allowsSelection = true
            self.tableView.reloadData()
        }
    }
    
    func orderStatArray() {
        if (numeri.count > 1) {
            for _ in 0...numeri.count {
                for j in 0...(numeri.count - 2) {
                    if numeri[j] < numeri[j + 1] {
                        self.numeri.swapAt(j, j + 1)
                        swap(&self.tipiMissioni[j], &self.tipiMissioni[j + 1])
                    }
                }
            }
        }
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        self.typeFilterButton.isEnabled = true
        self.dataFilterButton.isEnabled = true
        self.codeFilterButton.isEnabled = true
        self.listOrder.isEnabled = true
        self.typeFilterButton.backgroundColor = UIColor.white
        self.codeFilterButton.backgroundColor = UIColor.white
        self.dataFilterButton.backgroundColor = UIColor.white
        self.isFiltering = false
        self.filterButton.setImage(UIImage(named: "filter_off.png"), for: .normal)
        self.tableView.reloadData()
    }
    
    @IBAction func filterForData(_ sender: UIButton) {
        if self.mode == "missioni" {
            let alert = UIAlertController(style: .actionSheet, title: "Seleziona data e ora")
            alert.addDatePicker(mode: .date, date: Date(), minimumDate: nil, maximumDate: Date()) { date in
                
                let dFormatter = DateFormatter()
                dFormatter.dateFormat = "dd/MM/yyyy"
                self.filterDate = dFormatter.string(from: date)
            }
            alert.addAction(UIAlertAction(title: "Fatto", style: .cancel, handler: { (action) in
                self.codice_invioFiltered.removeAll()
                self.codice_servizioFiltered.removeAll()
                self.codice_trasportoFiltered.removeAll()
                self.serviziFiltered.removeAll()
                
                for i in 0...(self.servizi.count - 1) {
                    if self.dataMissione[i] == self.filterDate {
                        self.serviziFiltered.append(self.servizi[i])
                        self.codice_invioFiltered.append(self.codice_invio[i])
                        self.codice_trasportoFiltered.append(self.codice_trasporto[i])
                        self.codice_servizioFiltered.append(self.codice_servizio[i])
                    }
                }
                
                if self.serviziFiltered.count > 0 {
                    self.listOrder.isEnabled = false
                    self.isFiltering = true
                    self.filterButton.setImage(UIImage(named: "filter_on.png"), for: .normal)
                    self.dataFilterButton.isEnabled = true
                    self.dataFilterButton.backgroundColor = UIColor.lightGray
                    self.typeFilterButton.isEnabled = false
                    self.codeFilterButton.isEnabled = false
                    self.tableView.reloadData()
                } else {
                    let alert = UIAlertController(title: "Ops...", message: "Nessuna missione trovata per la data selezionata. Prova con un altro giorno.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Attenzione", message: "Impossibile filtrare i risultati mentre si è nella modalita: Statistiche", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func filterForCode(_ sender: UIButton) {
        if self.mode == "missioni" {
            let alert = UIAlertController(title: "Codice colore", message: nil, preferredStyle: .actionSheet)
            let contentArray: [String] = ["", "Verde", "Giallo", "Rosso", "Bianco", "Non trasporta", "Regolare - Non trasporta", "Interrotta da C.O.", "Interrotta - Incidente", "Vuoto"]
            let pickerViewValues: [[String]] = [contentArray]
            let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: 0)
            
            alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
                self.filterCode = contentArray[index.row]
            }
            let cancel = UIAlertAction(title: "Fatto", style: .cancel) { (action) in
                self.codice_invioFiltered.removeAll()
                self.codice_servizioFiltered.removeAll()
                self.codice_trasportoFiltered.removeAll()
                self.serviziFiltered.removeAll()
                
                for i in 0...(self.servizi.count - 1) {
                    if self.codice_trasporto[i] == self.filterCode {
                        self.serviziFiltered.append(self.servizi[i])
                        self.codice_invioFiltered.append(self.codice_invio[i])
                        self.codice_trasportoFiltered.append(self.codice_trasporto[i])
                        self.codice_servizioFiltered.append(self.codice_servizio[i])
                    }
                }
                
                if self.serviziFiltered.count > 0 {
                    self.listOrder.isEnabled = false
                    self.isFiltering = true
                    self.filterButton.setImage(UIImage(named: "filter_on.png"), for: .normal)
                    self.codeFilterButton.isEnabled = true
                    self.codeFilterButton.backgroundColor = UIColor.lightGray
                    self.dataFilterButton.isEnabled = false
                    self.typeFilterButton.isEnabled = false
                    self.tableView.reloadData()
                } else {
                    let alert = UIAlertController(title: "Ops...", message: "Nessuna missione trovata per il codice selezionato", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Attenzione", message: "Impossibile filtrare i risultati mentre si è nella modalita: Statistiche", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func filterForType(_ sender: UIButton) {

        if self.mode == "missioni" {
            let alert = UIAlertController(title: "Tipologia servizio", message: nil, preferredStyle: .actionSheet)
            
            let contentArray: [String] = ["", "Aggressione", "Altro - Non classifica", "Altro - Non identifica", "Animali", "Caduta", "Calamità naturali", "Cardiocircolatoria", "Digerente", "Evento di massa", "Evento Violento", "Ferita", "Gravidanza parto", "Inc in acqua", "Inc infortunio", "Inc in montagna", "Inc speleologico", "Inc stradale", "Intossicazione", "Maxiemergenza", "Neurologica", "Orecchio naso gola", "Osteo-muscolare", "Psichiatrica", "Respiratoria", "Soccorso persona", "Uro-Genitale", "Altro"]
            let pickerViewValues: [[String]] = [contentArray]
            let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, row: 0)
            
            alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { vc, picker, index, values in
                self.filterType = contentArray[index.row]
            }
            
            let cancel = UIAlertAction(title: "Fatto", style: .cancel) { (action) in
                self.codice_invioFiltered.removeAll()
                self.codice_servizioFiltered.removeAll()
                self.codice_trasportoFiltered.removeAll()
                self.serviziFiltered.removeAll()
                
                for i in 0...(self.servizi.count - 1) {
                    if self.servizi[i] == self.filterType {
                        self.serviziFiltered.append(self.servizi[i])
                        self.codice_invioFiltered.append(self.codice_invio[i])
                        self.codice_trasportoFiltered.append(self.codice_trasporto[i])
                        self.codice_servizioFiltered.append(self.codice_servizio[i])
                    }
                }
                
                if self.serviziFiltered.count > 0 {
                    self.listOrder.isEnabled = false
                    self.isFiltering = true
                    self.filterButton.setImage(UIImage(named: "filter_on.png"), for: .normal)
                    self.typeFilterButton.isEnabled = true
                    self.typeFilterButton.backgroundColor = UIColor.lightGray
                    self.dataFilterButton.isEnabled = false
                    self.codeFilterButton.isEnabled = false
                    self.tableView.reloadData()
                } else {
                    let alert = UIAlertController(title: "Ops...", message: "Nessuna missione trovata per il tipo selezionata", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .cancel)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Attenzione", message: "Impossibile filtrare i risultati mentre si è nella modalita: Statistiche", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func listOrderTapped(_ sender: UIButton) {
        if self.list_mode == "d" {
            self.list_mode = "a"
            sender.setImage(UIImage(named: "ascending.png"), for: .normal)
            self.loadData(mode: self.list_mode)
        } else {
            self.list_mode = "d"
            sender.setImage(UIImage(named: "descending.png"), for: .normal)
            self.loadData(mode: self.list_mode)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            let alert = UIAlertController(title: "Attenzione!", message: "Vuoi davvero eliminare definitivamente questa missione?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "No", style: .cancel)
            let yes = UIAlertAction(title: "Sì", style: .default) { (action) in
                
                let hud = JGProgressHUD(style: .dark)
                hud.textLabel.text = "Elimino..."
                hud.show(in: self.view)
            
                
                let q = PFQuery(className: "Servizi")
                q.whereKey("username", equalTo: self.username)
                q.whereKey("codice", equalTo: self.codice_servizio[indexPath.row])
                q.findObjectsInBackground(block: { (missioni, error) in
                    if error == nil && (missioni?.count)! > 0 {
                        for obj in missioni! {
                            obj.deleteInBackground()
                        }
                        
                        let index = self.tipiMissioni.index(of: self.servizi[indexPath.row])
                        if (self.numeri[index] > 1) {
                            self.numeri[index] = self.numeri[index] - 1
                        } else {
                            self.numeri.remove(at: index)
                            self.tipiMissioni.removeObject(at: index)
                        }
                        self.servizi.remove(at: indexPath.row)
                        self.codice_servizio.remove(at: indexPath.row)
                        self.codice_trasporto.remove(at: indexPath.row)
                        self.codice_invio.remove(at: indexPath.row)
                        self.dataMissione.remove(at: indexPath.row)
                        self.oraMissione.remove(at: indexPath.row)
                        self.indirizzi.remove(at: indexPath.row)
                        self.latitudeArray.remove(at: indexPath.row)
                        self.longitudeArray.remove(at: indexPath.row)
                        self.tableView.reloadData()
                        hud.dismiss()
                    } else {
                        hud.dismiss()
                        let alert = UIAlertController(title: "Errore", message: "Impossibile eliminare la missione al momento. Riprova più tardi", preferredStyle: .alert)
                        let ok = UIAlertAction(title: "OK", style: .cancel)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
            alert.addAction(ok)
            alert.addAction(yes)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backHome(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
