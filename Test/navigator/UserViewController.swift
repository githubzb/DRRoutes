//
//  UserViewController.swift
//  Test
//
//  Created by dr.box on 2022/3/19.
//

import UIKit
import DrFlexLayout_swift
import DRRoutes

class UserViewController: UIViewController {
    
    let userId: String
    
    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        view.dr_flex.justifyContent(.center).alignItems(.center).define { flex in
            flex.addItem().width(50%).paddingVertical(20).justifyContent(.center).alignItems(.center).define { flex in
                flex.addItem(UILabel()).define { flex in
                    let lb = flex.view as! UILabel
                    lb.text = "User: \(userId)"
                    lb.textColor = .orange
                    lb.font = .systemFont(ofSize: 20, weight: .bold)
                }
            }
            flex.addItem(UIButton(type: .custom)).size(CGSize(width: 120, height: 40)).marginTop(20).define { flex in
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
    
    @objc func clickCloseBtn() {
        DRNavigator.close(page: self)
    }

}
