//
//  ControlloCarrozzeriaViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 28/02/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit
import SCLAlertView
import JGProgressHUD

class ControlloCarrozzeriaViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var latoPasseggero: UIImageView!
    @IBOutlet weak var latoGuida: UIImageView!
    @IBOutlet weak var anteriore: UIImageView!
    @IBOutlet weak var posteriore: UIImageView!
    @IBOutlet weak var undoButton: UIButton!
    
    var delegate = CheckListSectionViewController()
    var htmlContent = ""
    var addedViews: [UIView] = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: self.view)
            let availablePositions: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [(self.latoPasseggero.frame.minX, self.latoPasseggero.frame.maxX, self.latoPasseggero.frame.minY, self.latoPasseggero.frame.maxY), (self.latoGuida.frame.minX, self.latoGuida.frame.maxX, self.latoGuida.frame.minY, self.latoGuida.frame.maxY), (self.anteriore.frame.minX, self.anteriore.frame.maxX, self.anteriore.frame.minY, self.anteriore.frame.maxY), (self.posteriore.frame.minX, self.posteriore.frame.maxX, self.posteriore.frame.minY, self.posteriore.frame.maxY)]
            for (a,b,c,d) in availablePositions {
                if position.x > a && position.x < b {
                    if position.y > c && position.y < d {
                        let DynamicView = UIView(frame: CGRect(x: position.x, y: position.y, width: 20, height: 20))
                        DynamicView.backgroundColor = UIColor.red
                        DynamicView.layer.cornerRadius = 10
                        DynamicView.layer.masksToBounds = true
                        self.addedViews.append(DynamicView)
                        self.view.addSubview(DynamicView)
                        self.undoButton.isEnabled = true
                    }
                }
            }
        }
    }
    
    @IBAction func undo(_ sender: UIButton) {
        self.addedViews.last?.removeFromSuperview()
        self.addedViews.removeLast()
        if self.addedViews.count == 0 {
            self.undoButton.isEnabled = false
        }
    }
    
    @IBAction func completeCheckOfCarrozzeria(_ sender: UIButton) {
        let imagePasseggero: UIImage = self.latoPasseggero.takeScreenshot(frameView: self.latoPasseggero)
        let imageGuida: UIImage = self.latoGuida.takeScreenshot(frameView: self.latoGuida)
        let imageAnteriore: UIImage = self.anteriore.takeScreenshot(frameView: self.anteriore)
        let imagePosteriore: UIImage = self.posteriore.takeScreenshot(frameView: self.posteriore)
        
        let imagePasseggeroData = imagePasseggero.pngData()!
        let imageGuidaData = imageGuida.pngData()!
        let imageAnterioreData = imageAnteriore.pngData()!
        let imagePosterioreData = imagePosteriore.pngData()!
        
        let images: [Data] = [imagePasseggeroData, imageGuidaData, imageAnterioreData, imagePosterioreData]
        var i = 1
        for image in images {
            let image64Base = image.base64EncodedString(options: .lineLength64Characters)
            self.htmlContent = self.htmlContent.replacingOccurrences(of: "#IMAGE_\(i)#", with: image64Base)
            i = i + 1
        }
        
        self.delegate.htmlContent = self.htmlContent
        self.delegate.backFromImages = true
        self.delegate.tableView.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIView {
    
    func takeScreenshot(frameView: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}
