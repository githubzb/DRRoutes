//
//  ViewController.swift
//  Test
//
//  Created by dr.box on 2022/3/3.
//

import UIKit
import DRRoutes
import DrFlexLayout_swift

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.dr_flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(UIButton(type: .custom)).size(CGSize(width: 120, height: 40)).define { flex in
                let btn = flex.view as! UIButton
                btn.layer.cornerRadius = 20
                btn.backgroundColor = .blue
                btn.setTitle("Test Routes", for: .normal)
                btn.setTitleColor(.white, for: .normal)
                btn.addTarget(self, action: #selector(clickTestRoutesBtn), for: .touchUpInside)
            }
            flex.addItem(UIButton(type: .custom)).size(CGSize(width: 180, height: 40)).marginTop(10).define { flex in
                let btn = flex.view as! UIButton
                btn.layer.cornerRadius = 20
                btn.backgroundColor = .blue
                btn.setTitle("Test Navigator(1)", for: .normal)
                btn.setTitleColor(.white, for: .normal)
                btn.addTarget(self, action: #selector(clickTestNavigator1Btn), for: .touchUpInside)
            }
            
            flex.addItem(UIButton(type: .custom)).size(CGSize(width: 180, height: 40)).marginTop(10).define { flex in
                let btn = flex.view as! UIButton
                btn.layer.cornerRadius = 20
                btn.backgroundColor = .blue
                btn.setTitle("Test Navigator(2)", for: .normal)
                btn.setTitleColor(.white, for: .normal)
                btn.addTarget(self, action: #selector(clickTestNavigator2Btn), for: .touchUpInside)
            }
        }
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.dr_flex.layout()
    }
    
    
    @objc func clickTestRoutesBtn() {
        let vc = TestRoutesViewController()
        present(vc, animated: true, completion: nil)
    }
    
    @objc func clickTestNavigator1Btn() {
        let vc = TestNavigatorViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    @objc func clickTestNavigator2Btn() {
        let vc = TestNavigatorViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
}





