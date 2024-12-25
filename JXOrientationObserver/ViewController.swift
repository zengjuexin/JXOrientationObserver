//
//  ViewController.swift
//  JXOrientationObserver
//
//  Created by zeng on 2024/12/24.
//

import UIKit

class ViewController: UIViewController {

    
    
    private lazy var orientationObserver: JXOrientationObserver = {
        let orientationObserver = JXOrientationObserver(viewController: fullScreenVC)
        orientationObserver.delegate = self
        return orientationObserver
    }()
    
    private lazy var fullScreenVC: JXFullScreenViewController = {
        let vc = JXFullScreenViewController()
        return vc
    }()
    

    private lazy var playerView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        
        playerView.frame = CGRect(x: 0, y: 200, width: self.view.frame.width, height: 300)
        view.addSubview(playerView)
        
        let button = UIButton(type: .custom)
        button.backgroundColor = .yellow
        button.frame = CGRect(x: 100, y: 600, width: 100, height: 100)
        button.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        view.addSubview(button)
        
        orientationObserver.addDeviceOrientationObserver()
        
        
        print(UIApplication.shared.windows)
        print(UIApplication.shared.connectedScenes)
    }

    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @objc private func handleButton() {
        orientationObserver.enterFullScreen(fullScreen: true, animated: true)
        
    }

}

extension ViewController: JXOrientationObserverDelegate {
    
    func jx_shouldRotate(orientation: UIInterfaceOrientation) -> Bool {
        return true
    }
    
    func jx_willRotate(orientation: UIInterfaceOrientation) {
        if orientation.isLandscape {
            let targetRect = playerView.convert(playerView.bounds, to: playerView.window)
            self.orientationObserver.targetRect = targetRect
            self.fullScreenVC.contentView.backgroundColor = .green
            
            
        }
        
    }
    
    func jx_didRotate(orientation: UIInterfaceOrientation) {
        if orientation.isPortrait {
            print("屏幕回正")
        }
        
        
    }
}
