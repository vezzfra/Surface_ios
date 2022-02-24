//
//  FAQViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 02/03/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {
    @IBOutlet weak var mainView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let items = [FAQItem(question: "A cosa serve quest'app?", answer: "Questa applicazione è stata sviluppata in collaborazione con la Croce Viola Milano per digitalizzare i processi di creazione delle checklist dei mezzi associativi e delle schede di valutazione dei volontari. Il tutto per facilitare il processo e renderlo più fruibile a tutti tramite il proprio smartphone."), FAQItem(question: "Non hai trovato quello che cercavi?", answer: "Non preoccuparti, per qualsiasi assistenza aggiuntiva invia un'email a email@croceviola.org e ti risponderemo non appena sarà possibile.")]
        let faqView = FAQView(frame: CGRect(x: 0, y: 0, width: self.mainView.frame.width, height: self.mainView.frame.height), title: "", items: items)
        self.view.backgroundColor = faqView.backgroundColor
        faqView.dataDetectorTypes = [.link]
        self.mainView.backgroundColor = faqView.backgroundColor
        self.mainView.addSubview(faqView)*/
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
