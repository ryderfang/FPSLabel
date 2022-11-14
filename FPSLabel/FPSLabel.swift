//
//  FPSLabel.swift
//  Demo
//
//  Created by ryfang on 2022/11/14.
//

import UIKit

public final class DisplayLinkTarget: NSObject {
    private let f: () -> Void

    public init(_ f: @escaping () -> Void) {
        self.f = f
    }

    @objc public func event() {
        self.f()
    }
}

@objcMembers
public class FPSLabel: UILabel {
    private enum Const {
        static let hPadding: CGFloat = 20.0
        static let topPadding: CGFloat = 88.0
        static let bottomPadding: CGFloat = 78.0
    }

    private lazy var mainFont: UIFont = {
        return Self.fontWithSize(14.0)
    }()

    private lazy var subFont: UIFont = {
        return Self.fontWithSize(4.0)
    }()

    private var displayLink: CADisplayLink?
    private var count: Int = 0
    private var lastTime: Double = 0

    public static let shared = FPSLabel(frame: CGRect(x: Const.hPadding, y: Const.topPadding, width: 0, height: 0))

    // MARK: public
    public static func install(on window: UIWindow?) {
        guard let window = window else { return }
#if DEBUG
        uninstall()
        window.makeKeyAndVisible()
        window.addSubview(shared)
#endif
    }

    public static func uninstall() {
        if shared.superview != nil {
            shared.removeFromSuperview()
        }
    }

    override init(frame: CGRect) {
        var frame = frame
        if frame.size == .zero {
            frame.size = CGSize(width: 60, height: 20)
        }
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        displayLink?.invalidate()
    }

    // MARK: private
    private func commonInit() {
        self.layer.cornerRadius = 5
        self.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
        self.clipsToBounds = true
        self.textAlignment = .center
        self.isUserInteractionEnabled = true
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.7)

        displayLink = CADisplayLink(target: DisplayLinkTarget({ [weak self] in
            self?.tick()
        }), selector: #selector(DisplayLinkTarget.event))
        if #available(iOS 15.0, *) {
            displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 120)
        }
        displayLink?.add(to: .main, forMode: .common)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(didDrag(_:)))
        addGestureRecognizer(pan)
    }

    private func tick() {
        guard let displayLink = displayLink else { return }
        if lastTime == 0 {
            lastTime = displayLink.timestamp
            return
        }

        count += 1
        let diff = displayLink.timestamp - lastTime
        if diff < 1 {
            return
        }
        lastTime = displayLink.timestamp
        let fps = Double(count) / diff
        count = 0

        let progress = fps / 60.0
        let color = UIColor(hue: 0.27 * (progress - 0.2), saturation: 1, brightness: 0.9, alpha: 1)
        let displayText = String(format: "%d FPS", Int(fps.rounded()))
        let attrText = NSMutableAttributedString(string: displayText)
        attrText.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: displayText.count - 3))
        attrText.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: displayText.count - 3, length: 3))
        attrText.addAttribute(.font, value: mainFont, range: NSRange(location: 0, length: displayText.count))
        attrText.addAttribute(.font, value: subFont, range: NSRange(location: displayText.count - 4, length: 1))
        
        self.attributedText = attrText
    }

    @objc private func didDrag(_ panGesture: UIPanGestureRecognizer) {
        let touchPoint = panGesture.translation(in: self)
        self.transform = CGAffineTransformTranslate(self.transform, touchPoint.x, touchPoint.y)
        // reset
        panGesture.setTranslation(.zero, in: self)
        if panGesture.state == .ended {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                let screenWidth = UIScreen.main.bounds.size.width
                let screenHeight = UIScreen.main.bounds.size.height
                var frame = self.frame
                frame.origin.x = frame.origin.x - screenWidth / 2 > 0 ? (screenWidth - frame.size.width - Const.hPadding) : Const.hPadding
                frame.origin.y = min(max(frame.origin.y, Const.topPadding), screenHeight - Const.bottomPadding)
                self.frame = frame
            }
        }
    }

    private static func fontWithSize(_ size: CGFloat) -> UIFont {
        if let fontMenlo = UIFont(name: "Menlo", size: size) {
            return fontMenlo
        }
        if let fontCourier = UIFont(name: "Courier", size: size) {
            return fontCourier
        }
        return UIFont.systemFont(ofSize: size)
    }
}
