//
//  JXFullScreenWindow.swift
//  JXOrientationObserver
//
//  Created by zeng on 2024/12/24.
//

import UIKit

class JXFullScreenWindow: UIWindow {

    
    override var backgroundColor: UIColor? {
        set {
            
        }
        get {
            return nil
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.windowLevel = .normal
        
        if #available(iOS 13.0, *) {
            if self.windowScene == nil {
                self.windowScene = UIWindow.getKeyWindow()?.windowScene
            }
        }
        
        self.isHidden = true
    }
    
    @available(iOS 13.0, *)
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        self.windowLevel = .normal
        
        self.isHidden = true
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var bounds = CGRect.zero
        
        if !bounds.equalTo(self.bounds) {
            var superview: UIView = self
            if #available(iOS 13.0, *) {
                if let view = self.subviews.first {
                    superview = view
                }
            }

            UIView.performWithoutAnimation {
                for view in superview.subviews {
                    if view != self.rootViewController?.view && view.isMember(of: UIView.self) {
                        view.backgroundColor = .clear
                        for subview in view.subviews {
                            subview.backgroundColor = .clear
                        }
                    }
                }
            }
        }
        
        bounds = self.bounds
        self.rootViewController?.view.frame = bounds
//        self.rootViewController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}


extension UIWindow {
    
    static func getKeyWindow() -> UIWindow? {
        var window: UIWindow?
        if #available(iOS 13.0, *) {
            window = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        }
        if window == nil {
            window = UIApplication.shared.windows.first { $0.isKeyWindow }
        }
        if window == nil {
            window = UIApplication.shared.keyWindow
        }
        
        return window
    }
}
