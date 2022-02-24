//
//  LoadingViewController.swift
//  Gestionale_squadre
//
//  Created by Francesco Vezzoli on 25/09/2019.
//  Copyright © 2019 Ro.v.er. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController, CAAnimationDelegate {

    weak var shapeLayer: CAShapeLayer?
    weak var shapeLayer1: CAShapeLayer?
    @IBOutlet weak var logo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shapeLayer?.removeFromSuperlayer()
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: -1, y: self.view.frame.maxY / 2))
        path.addLine(to: CGPoint(x: 15, y: (self.view.frame.maxY / 2) - 100))
        path.addLine(to: CGPoint(x: 30, y: (self.view.frame.maxY / 2) + 30))
        path.addLine(to: CGPoint(x: 40, y: self.view.frame.maxY / 2))
        path.addLine(to: CGPoint(x: 60, y: self.view.frame.maxY / 2))
        path.addQuadCurve(to: CGPoint(x: 90, y: self.view.frame.maxY / 2), controlPoint: CGPoint(x: 75, y: (self.view.frame.maxY / 2) - 30))
        path.addLine(to: CGPoint(x: 110, y: self.view.frame.maxY / 2))
        path.addQuadCurve(to: CGPoint(x: 130, y: self.view.frame.maxY / 2), controlPoint: CGPoint(x: 120, y: (self.view.frame.maxY / 2) - 10))
        path.addLine(to: CGPoint(x: 140, y: self.view.frame.maxY / 2))
        path.addQuadCurve(to: CGPoint(x: 145, y: (self.view.frame.maxY / 2) + 5), controlPoint: CGPoint(x: 143, y: self.view.frame.maxY / 2))
        path.addLine(to: CGPoint(x: 160, y: (self.view.frame.maxY / 2) - 105))
        path.addLine(to: CGPoint(x: 175, y: (self.view.frame.maxY / 2) + 30))
        path.addLine(to: CGPoint(x: 185, y: self.view.frame.maxY / 2))
        path.addLine(to: CGPoint(x: 205, y: self.view.frame.maxY / 2))
        path.addQuadCurve(to: CGPoint(x: 235, y: self.view.frame.maxY / 2), controlPoint: CGPoint(x: 220, y: (self.view.frame.maxY / 2) - 30))
        path.addLine(to: CGPoint(x: 255, y: self.view.frame.maxY / 2))
        path.addQuadCurve(to: CGPoint(x: 275, y: self.view.frame.maxY / 2), controlPoint: CGPoint(x: 265, y: (self.view.frame.maxY / 2) - 10))
        path.addLine(to: CGPoint(x: 285, y: self.view.frame.maxY / 2))
        path.addQuadCurve(to: CGPoint(x: 290, y: (self.view.frame.maxY / 2) + 5), controlPoint: CGPoint(x: 288, y: self.view.frame.maxY / 2))
        path.addLine(to: CGPoint(x: 310, y: (self.view.frame.maxY / 2) - 105))
        path.addLine(to: CGPoint(x: 325, y: (self.view.frame.maxY / 2) + 30))
        path.addLine(to: CGPoint(x: 335, y: self.view.frame.maxY / 2))
        path.addLine(to: CGPoint(x: 355, y: self.view.frame.maxY / 2))
        path.addQuadCurve(to: CGPoint(x: 385, y: self.view.frame.maxY / 2), controlPoint: CGPoint(x: 370, y: (self.view.frame.maxY / 2) - 30))
        path.addLine(to: CGPoint(x: 405, y: self.view.frame.maxY / 2))
        path.addQuadCurve(to: CGPoint(x: 425, y: self.view.frame.maxY / 2), controlPoint: CGPoint(x: 415, y: (self.view.frame.maxY / 2) - 10))
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1).cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.path = path.cgPath
        
        view.layer.addSublayer(shapeLayer)
        
        let endAnimation = CABasicAnimation(keyPath: "strokeStart")
        endAnimation.fromValue = 0
        endAnimation.toValue = 1
        
        let startAnimation = CABasicAnimation(keyPath: "strokeEnd")
        startAnimation.fromValue = 0
        startAnimation.toValue = 2
        
        let animation = CAAnimationGroup()
        animation.animations = [startAnimation, endAnimation]
        animation.duration = 2
        animation.repeatDuration = 3
        animation.isRemovedOnCompletion = true
        animation.delegate = self
        shapeLayer.add(animation, forKey: "MyAnimation")
        
        self.shapeLayer = shapeLayer
        self.shapeLayer?.zPosition = 0
        self.view.bringSubviewToFront(self.logo)
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.performSegue(withIdentifier: "goToLogin", sender: nil)
    }
}
