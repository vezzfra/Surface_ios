//
//  ShowCheckViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 03/03/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit
import WebKit
import Parse
import JGProgressHUD
import SCLAlertView

class ShowCheckViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!

    var htmlCode = ""
    var mezzo = ""
    var hud: JGProgressHUD = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hud = JGProgressHUD(style: .dark)
        self.webView.loadHTMLString(self.htmlCode, baseURL: nil)
    }
    
    @IBAction func approveChecklist(_ sender: UIButton) {
        self.hud.textLabel.text = "Invio checklist"
        self.hud.show(in: self.view)
        
        self.htmlCode = self.htmlCode.replacingOccurrences(of: "#INFO_ALLIEVO#", with: "Checklist approvata digitalmente da: \(UserDefaults.standard.object(forKey: "app_username") as! String)")
        
        let email = "vezzfra@gmail.com"
        var recipients = [Any]()
        recipients.append(["Email": email])
        
        let body: [String: Any] = [
            "FromEmail": "noreply.missioni118@gmail.com",
            "FromName": "Checklist mezzi",
            "Subject": "Checklist del mezzo: \(self.mezzo)",
            "Text-part": "",
            "Html-part": self.htmlCode,
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
                self.deleteCheck()
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
                alertView.showError("Ops...", subTitle: "Si è verificato un errore durante l'invio della checklist, riprovare.")
            }
        })
        task.resume()
    }
    
    @IBAction func deleteChecklist(_ sender: UIButton) {
        self.deleteCheck()
        //Avverto allievo del rigetto tramite notifica push
        self.dismiss(animated: true, completion: nil)
    }
    
    func deleteCheck() {
        self.hud.textLabel.text = "Attendere"
        let q = PFQuery(className: "checklist")
        q.whereKey("directed_to", equalTo: UserDefaults.standard.object(forKey: "app_username") as! String)
        q.findObjectsInBackground { (objects, error) in
            if error == nil {
                for obj in objects! {
                    obj.deleteInBackground()
                }
                self.hud.dismiss()
            }
        }
    }
}
