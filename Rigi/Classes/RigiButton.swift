//
//  RigiButton.swift
//  Rigi
//
//  Created by Dimitri van Oijen on 02/05/2022.
//

import Foundation

// MARK: - Floating Button Window

class RigiButton: UIViewController {
    private(set) var button: UIButton!
    private(set) var active: UIImageView!

    private let window = RigiButtonWindow()

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
        window.isHidden = false
        window.rootViewController = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }

    @objc func keyboardDidShow(note: NSNotification) {
        window.windowLevel = UIWindow.Level(rawValue: 0)
        window.windowLevel = UIWindow.Level(rawValue: CGFloat.greatestFiniteMagnitude)
    }

    override func loadView() {
        let screen  = UIScreen.main.bounds
        let size = screen.width / 7

        // Note:
        // When using the default "s.resource_bundles" in the "Rigi.podspec" the assets where not added to
        // the correct target (see the assets file target membership in the file inspector panel).
        // Maybe we should match the naming of the Bundle(for:) and the "resource_bundles" naming in
        // the podspec somehow. Using "s.resource" instead seems to work ok however. So lets do it that way.


        let iconNormal = UIImage(named: "rigi-icon-blue", in: Bundle(for: Rigi.self), compatibleWith: nil)
        let iconActive = UIImage(named: "rigi-icon-red", in: Bundle(for: Rigi.self), compatibleWith: nil)

//        let iconNormal = UIImage(named: "rigi-icon-blue", in: Bundle(identifier: "Rigi"), compatibleWith: nil)
//        let iconActive = UIImage(named: "rigi-icon-red", in: Bundle(identifier: "Rigi"), compatibleWith: nil)


        let view = UIView()

        button = UIButton(frame: CGRect(x: 0, y: 0, width: size, height: size))
        button.setImage(iconNormal, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize.zero

        view.addSubview(button)

        active = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        active.image = iconActive
        active.alpha = 0

        button.addSubview(active)

        button.rotate(duration: 60)

        self.view = view
        window.button = button

        let panner = UIPanGestureRecognizer(target: self, action: #selector(panDidFire))
        button.addGestureRecognizer(panner)
    }

    @objc func panDidFire(panner: UIPanGestureRecognizer) {
        let offset = panner.translation(in: view)
        panner.setTranslation(CGPoint.zero, in: view)
        var center = button.center
        center.x += offset.x
        center.y += offset.y
        button.center = center

        if panner.state == .ended || panner.state == .cancelled {
            UIView.animate(withDuration: 0.3) {
                self.snapButtonToSocket()
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        snapButtonToSocket()
    }

    var sockets: [CGPoint] {
        let buttonSize = button.bounds.size

        let rect = view.bounds.inset(by: view.safeAreaInsetsCompat).insetBy(dx: 14 + buttonSize.width / 2, dy: 14 + buttonSize.height / 2)
        let sockets: [CGPoint] = [
            CGPoint(x: rect.minX, y: rect.minY),
            CGPoint(x: rect.minX, y: rect.maxY),
            CGPoint(x: rect.maxX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.maxY),
            CGPoint(x: rect.midX, y: rect.midY)
        ]
        return sockets
    }

    private func snapButtonToSocket() {
        var bestSocket = CGPoint.zero
        var distanceToBestSocket = CGFloat.infinity
        let center = button.center
        for socket in sockets {
            let distance = hypot(center.x - socket.x, center.y - socket.y)
            if distance < distanceToBestSocket {
                distanceToBestSocket = distance
                bestSocket = socket
            }
        }
        button.center = bestSocket
    }

    public func animateClick() {

        self.active.alpha = 1
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.active.alpha = 0
//        }, completion: { _ in
//            UIView.animate(withDuration: 0.2, animations: {
//                self.active.alpha = 0
//            })
        })
    }
}

// https://stackoverflow.com/questions/34777558/in-ios-how-do-i-create-a-button-that-is-always-on-top-of-all-other-view-control/34883581

class RigiButtonWindow: UIWindow {

    var button: UIButton?
    var controller: RigiButton?

    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let button = button else { return false }
        let buttonPoint = convert(point, to: button)
        return button.point(inside: buttonPoint, with: event)
    }
}

