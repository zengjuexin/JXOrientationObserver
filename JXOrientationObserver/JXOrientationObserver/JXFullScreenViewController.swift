//
//  JXFullScreenViewController.swift
//  JXOrientationObserver
//
//  Created by zeng on 2024/12/24.
//

import UIKit

@objc protocol JXFullScreenViewControllerDelegate: NSObjectProtocol {
    @objc optional func jx_shouldAutorotate() -> Bool
    ///屏幕准备旋转
    @objc optional func jx_willRotateToOrientation(orientation :UIInterfaceOrientation)
    ///屏幕旋转完成
    @objc optional func jx_didRotateFromOrientation(orientation :UIInterfaceOrientation)
    @objc optional func jx_targetRect() -> CGRect
}

class JXFullScreenViewController: UIViewController {
    
    weak var delegate: JXFullScreenViewControllerDelegate?
    weak var orientationObserver: JXOrientationObserver?
    
    ///设置方向
    var orientation: UIInterfaceOrientation = .unknown
    
//    var rotatingCompleted: (() -> Void)?
    
    var rotating: Bool = false {
        didSet {
//            if !rotating {
//                self.rotatingCompleted?()
//            }
        }
    }
    
    private(set) lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        
        
        view.addSubview(contentView)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        exitFullScreen()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        self.rotating = true
        super.viewWillTransition(to: size, with: coordinator)
        
        self.delegate?.jx_willRotateToOrientation?(orientation: orientation)
        let isFullscreen = size.width > size.height
    
        let targetRect = self.delegate?.jx_targetRect?() ?? .zero
        self.contentView.frame = targetRect

        coordinator.animate { context in
            
            if isFullscreen {
                self.contentView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            } else {
                self.contentView.frame = targetRect
            }

        } completion: { context in
            
            if !isFullscreen {
                self.contentView.frame = targetRect
            }
            self.rotating = false
            self.delegate?.jx_didRotateFromOrientation?(orientation: self.orientation)
        }
    }
    
    override var shouldAutorotate: Bool {
        if let result = self.delegate?.jx_shouldAutorotate?() {
            return result
        } else {
            return false
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if orientation.isLandscape {
            return .landscape
        } else {
            return .portrait
        }
    }
    
    
    ///退出全屏
    func exitFullScreen() {
        self.orientationObserver?.enterFullScreen(fullScreen: false)
    }

}
