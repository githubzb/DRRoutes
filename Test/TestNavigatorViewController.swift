//
//  TestNavigatorViewController.swift
//  Test
//
//  Created by dr.box on 2022/3/19.
//

import UIKit
import DrFlexLayout_swift
import DRRoutes

class TestNavigatorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.dr_flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem(UIButton(type: .custom)).size(CGSize(width: 120, height: 40)).define { flex in
                let btn = flex.view as! UIButton
                btn.layer.cornerRadius = 20
                btn.backgroundColor = .blue
                btn.setTitle("To User", for: .normal)
                btn.setTitleColor(.white, for: .normal)
                btn.addTarget(self, action: #selector(clickUserBtn), for: .touchUpInside)
            }
            
            flex.addItem(UIButton(type: .custom)).size(CGSize(width: 120, height: 40)).marginTop(10).define { flex in
                let btn = flex.view as! UIButton
                btn.layer.cornerRadius = 20
                btn.backgroundColor = .blue
                btn.setTitle("To Setting", for: .normal)
                btn.setTitleColor(.white, for: .normal)
                btn.addTarget(self, action: #selector(clickSettingBtn), for: .touchUpInside)
            }
            
            flex.addItem(UIButton(type: .custom)).size(CGSize(width: 120, height: 40)).marginTop(10).define { flex in
                let btn = flex.view as! UIButton
                btn.layer.cornerRadius = 20
                btn.backgroundColor = .blue
                btn.setTitle("关闭", for: .normal)
                btn.setTitleColor(.white, for: .normal)
                btn.addTarget(self, action: #selector(clickCloseBtn), for: .touchUpInside)
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.dr_flex.layout()
    }
    
    @objc func clickUserBtn() {
        DRNavigator.openPage(pager: Pagers.user(userId: "123"), in: self)
    }
    
    @objc func clickSettingBtn() {
        DRNavigator.openPage(pager: Pagers.setting, in: self)
    }
    
    @objc func clickCloseBtn() {
        DRNavigator.close(page: self)
    }

}
