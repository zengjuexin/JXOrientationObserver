//
//  JXOrientationObserver.swift
//  JXOrientationObserver
//
//  Created by zeng on 2024/12/24.
//

import UIKit

@objc protocol JXOrientationObserverDelegate: NSObjectProtocol {
    ///即将旋转
    @objc optional func jx_shouldRotate(orientation: UIInterfaceOrientation) -> Bool
    ///将要旋转，这里处理赋值的业务逻辑
    @objc optional func jx_willRotate(orientation: UIInterfaceOrientation)
    ///旋转完成
    @objc optional func jx_didRotate(orientation: UIInterfaceOrientation)
    
}

class JXOrientationObserver: NSObject {
    
    weak var delegate: JXOrientationObserverDelegate?
    
//    /**
//     播放器容器  用于动画
//     */
//    weak var containerView: UIView?
    
    var targetRect: CGRect = .zero
    
    /**
     是否允许旋转
     */
    var allowOrientationRotation: Bool = true
    
    private(set) var activeDeviceObserver: Bool = false
    
    ///当前屏幕方向
    private(set) var currentOrientation: UIInterfaceOrientation = .portrait
    
    private var isFullScreen: Bool = false {
        didSet {
            self.window.rootViewController?.setNeedsStatusBarAppearanceUpdate()
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    private var previousKeyWindow: UIWindow?
    
    private lazy var window: JXFullScreenWindow = {
        let window = JXFullScreenWindow()
        return window
    }()
    
    init(viewController: JXFullScreenViewController) {
        super.init()
        viewController.delegate = self
        viewController.orientationObserver = self
        window.rootViewController = viewController
    }
    
    func addDeviceOrientationObserver() {
        self.activeDeviceObserver = true
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func removeDeviceOrientationObserver() {
        self.activeDeviceObserver = false
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc private func handleDeviceOrientationChange() {
        if !self.allowOrientationRotation { return }
        if !UIDevice.current.orientation.isValidInterfaceOrientation { return }
        
        guard let orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue) else { return }
        
        if let isRotate = self.delegate?.jx_shouldRotate?(orientation: orientation), !isRotate { return }
        
        if orientation == self.currentOrientation { return }
        if orientation == .portraitUpsideDown { return }
        
        
        
        
        rotate(to: orientation, animated: true)
        
    }
    
    private func rotate(to orientation: UIInterfaceOrientation, animated: Bool) {
        window.windowScene = UIWindow.getKeyWindow()?.windowScene
        self.currentOrientation = orientation
        
        
        self.delegate?.jx_willRotate?(orientation: orientation)
        
        if orientation.isLandscape {
            
            if !self.isFullScreen {
                self.isFullScreen = true
                
                
                if #available(iOS 16, *) {
                    self.window.isHidden = false
                }
            }
            
            getAppDelegate()?.allowOrentitaionRotation = true
            
            
        } else {
            self.isFullScreen = false
        }
        fullScreenViewController?.orientation = orientation
        interfaceOrientation(viewController: fullScreenViewController, orientation: orientation)
        
    }
    
    func enterFullScreen(fullScreen: Bool, animated: Bool = true) {
        var orientation = UIInterfaceOrientation.unknown
        orientation = fullScreen ? .landscapeRight : .portrait
        rotate(to: orientation, animated: animated)
    }
}



//MARK: --------------   JXFullScreenViewControllerDelegate  --------------
extension JXOrientationObserver: JXFullScreenViewControllerDelegate {
    func jx_shouldAutorotate() -> Bool {

//        if self.forceRotaion {
//            _rotationToLandscapeOrientation(orientation: self.currentOrientation)
//            return true
//        }
        
//        if !self.activeDeviceObserver {
//            return false
//        }
        
        _rotationToLandscapeOrientation(orientation: self.currentOrientation)
        return true
    }
    
    func jx_willRotateToOrientation(orientation: UIInterfaceOrientation) {
        self.isFullScreen = orientation.isLandscape
        getAppDelegate()?.allowOrentitaionRotation = self.isFullScreen
    }
    
    func jx_didRotateFromOrientation(orientation: UIInterfaceOrientation) {
        if !self.isFullScreen {
            self._rotationToPortraitOrientation(orientation: .portrait)
        }
        self.delegate?.jx_didRotate?(orientation: orientation)
    }
    
    func jx_targetRect() -> CGRect {
        return targetRect
    }
}

//MARK: --------------   private  --------------
extension JXOrientationObserver {
    private var fullScreenViewController: JXFullScreenViewController? {
        return self.window.rootViewController as? JXFullScreenViewController
    }
    
    private func getAppDelegate() -> AppDelegate? {
        return UIApplication.shared.delegate as? AppDelegate
    }
    
    private func _isSupportedPortrait() -> Bool {
        return true
    }
    
    private func _rotationToLandscapeOrientation(orientation: UIInterfaceOrientation) {
        if orientation.isLandscape {
            let keyWindow = UIWindow.getKeyWindow()
            if keyWindow != self.window && self.previousKeyWindow != keyWindow {
                self.previousKeyWindow = keyWindow
            }
            
            if !self.window.isKeyWindow {
                window.isHidden = false
                window.makeKeyAndVisible()
            }
        }
    }
    
    private func _rotationToPortraitOrientation(orientation: UIInterfaceOrientation) {
        if orientation == .portrait && !self.window.isHidden {
            self.performSelector(onMainThread: #selector(_makeKeyAndVisible), with: nil, waitUntilDone: false, modes: [RunLoop.Mode.default.rawValue])
        }
    }
     
    @objc private func _makeKeyAndVisible() {
        let previousKeyWindow = self.previousKeyWindow ?? UIApplication.shared.windows.first
        previousKeyWindow?.makeKeyAndVisible()
        self.previousKeyWindow = nil
        self.window.isHidden = true
    }
    
    
    /**
     设置横竖屏
     */
    private func interfaceOrientation(viewController: UIViewController?, orientation: UIInterfaceOrientation) {
        if #available(iOS 16, *) {
            viewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            
            var orientationMask = UIInterfaceOrientationMask.all
            switch orientation {
            case .landscapeLeft:
                orientationMask = .landscapeLeft
                
            case .landscapeRight:
                orientationMask = .landscapeRight
                
            case .portraitUpsideDown:
                orientationMask = .portraitUpsideDown
                
            case .portrait:
                orientationMask = .portrait
                
            
            default:
                break
            }
            print("屏幕方向改变\(orientationMask.rawValue)")
            
            let preferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientationMask)

            scene.requestGeometryUpdate(preferences) { error in
                print(error)
            }
        } else {

            UIDevice.current.setValue(NSNumber(value: UIInterfaceOrientation.unknown.rawValue), forKey: "orientation")
            
            let num = NSNumber(value: orientation.rawValue)
            UIDevice.current.setValue(num, forKey: "orientation")
            
        }
        
        
        
    }
}
