//
//  RigiExtensions.swift
//  Rigi
//
//  Created by Dimitri van Oijen on 02/05/2022.
//

import Foundation

// MARK: - Window Traverse Hierarchy

// https://medium.com/flawless-app-stories/exploring-view-hierarchy-332ea63262e9

extension UIWindow {

    /// Traverse the window's view hierarchy in the same way as the Debug View Hierarchy tool in Xcode.
    ///
    /// `traverseHierarchy` uses Depth First Search (DFS) to traverse the view hierarchy starting in the window. This way the method can traverse all sub-hierarchies in a correct order.
    ///
    /// - parameters:
    ///     - visitor: The closure executed for every view object in the hierarchy
    ///     - responder: The view object, `UIView`, `UIViewController`, or `UIWindow` instance.
    ///     - level: The depth level in the view hierarchy.
    func traverseHierarchy(_ visitor: (_ responder: UIResponder, _ level: Int) -> Void) {
        /// Stack used to accumulate objects to visit.
        var stack: [(responder: UIResponder, level: Int)] = [(responder: self, level: 0)]

        while !stack.isEmpty {
            let current = stack.removeLast()

            // Push objects to visit on the stack depending on the current object's type.
            switch current.responder {
                case let view as UIView:
                    // For `UIView` object push subviews on the stack following next rules:
                    //      - Exclude hidden subviews;
                    //      - If the subview is the root view in the view controller - take the view controller instead.
                    stack.append(contentsOf: view.subviews.reversed().compactMap {
                        $0.isHidden ? nil : (responder: $0.next as? UIViewController ?? $0, level: current.level + 1)
                    })

                case let viewController as UIViewController:
                    // For `UIViewController` object push it's view. Here the view is guaranteed to be loaded and in the window.
                    stack.append((responder: viewController.view, level: current.level + 1))

                default:
                    break
            }

            // Visit the current object
            visitor(current.responder, current.level)
        }
    }
}

// MARK: - Rigi codes

extension String {

    var rigiKey: String? {

        // Will extract the [KEY] from string, matching:
        // \u206A\u206A\u206A [KEY] \u206A [TEXT] \u206A\u206A

        let pattern = "\u{206A}\u{206A}\u{206A}([^\u{206A}]+)\u{206A}"
        if let range = self.range(of: pattern, options: .regularExpression) {
            return String(self[range])
        }
        return nil

        //if let regex = try? NSRegularExpression(pattern: "\u{206A}\u{206A}\u{206A}([^\u{206A}]+)\u{206A}.*", options: []) {
        //    let test = text
        //        .replacingGroups(matching: regex, with: "\u{206A}\u{206A}\u{206A}$1\u{206A}-\u{206A}\u{206A}")
        //        .applyingTransform(.toXMLHex, reverse: false)
        //    print("*** \(text) = \(test)")
        //}
   }
}

// MARK: - Class extensions

extension UIDevice {
    static var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
}

extension UIView{
    func rotate(duration: CFTimeInterval) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
}

extension UIViewController {
    var isEmbedded: Bool {
        if let parentVC = self.parent {
            if parentVC is UINavigationController || parentVC is UITabBarController || parentVC is UISplitViewController {
              return false
           } else {
              return true
           }
        }
        return false
    }
}

extension UIView {
    var isVisible: Bool {
        guard isHidden == false,
            alpha > 0,
            bounds != .zero,
            let window = window, // In a window's view hierarchy
            window.isKeyWindow, // Does not consider cases covered by another transparent window
            window.hitTest(convert(center, to: nil), with: nil) != self
            else { return false }

        // Checck subviews
        let invisibleSubviews: Bool = {
            for subview in subviews {
                if subview.isVisible {
                    return false
                }
            }
            return true // Including no subviews
        }()

        // No subview and no color, its not visible
        if invisibleSubviews {
            if (backgroundColor == nil || backgroundColor == .clear)
                && (layer.backgroundColor == nil || layer.backgroundColor?.alpha == 0){
                return false
            }
        }

        // What about special CALayer cases?
        return true // maybe, not 100% sure XD
    }
}

extension UIView {
    var safeAreaInsetsCompat: UIEdgeInsets {
        if #available(iOS 11, *) {
            return safeAreaInsets
        }
        return UIEdgeInsets()
    }
}

extension UIView {

    var id: String? {
        get {
            return self.accessibilityIdentifier
        }
        set {
            self.accessibilityIdentifier = newValue
        }
    }

    func view(withId id: String) -> UIView? {
        if self.id == id {
            return self
        }
        for view in self.subviews {
            if let view = view.view(withId: id) {
                return view
            }
        }
        return nil
    }
}

extension String {
    func replace(_ pattern: String, with: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let result = regex.stringByReplacingMatches(in: self, options: .withTransparentBounds, range: NSMakeRange(0, self.count), withTemplate: with)
            return result
        } catch {
            return self
        }
    }
}

// "prefix12suffix fix1su".match("fix([0-9]+)su") -> [["fix12su", "12"], ["fix1su", "1"]]
extension String {
    func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0..<match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}

extension String {
    /// Finds matching groups and replace them with a template using an intuitive API.
    ///
    /// This example will go through an input string and replace all occurrences of "MyGreatBrand" with "**MyGreatBrand**".
    ///
    ///     let regex = try! NSRegularExpression(pattern: #"(MyGreatBrand)"#) // Matches all occurrences of MyGreatBrand
    ///     someMarkdownDocument.replaceGroups(matching: regex, with: #"**$1**"#) // Surround all matches with **, formatting as bold text in markdown.
    ///     print(someMarkdownDocument)
    ///
    /// - Parameters:
    ///   - regex: the regex used to match groups.
    ///   - template: the template used to replace the groups. Reference groups inside your template using dollar sign symbol followed by the group number, e.g. "$1", "$2", etc.
    public mutating func replaceGroups(matching regex: NSRegularExpression, with template: String, options: NSRegularExpression.MatchingOptions = []) {
        var replacingRanges: [(subrange: Range<String.Index>, replacement: String)] = []
        let matches = regex.matches(in: self, options: options, range: NSRange(location: 0, length: utf16.count))
        for match in matches {
            var replacement: String = template
            for rangeIndex in 1 ..< match.numberOfRanges {
                let group: String = (self as NSString).substring(with: match.range(at: rangeIndex))
                replacement = replacement.replacingOccurrences(of: "$\(rangeIndex)", with: group)
            }
            replacingRanges.append((subrange: Range(match.range(at: 0), in: self)!, replacement: replacement))
        }
        for (subrange, replacement) in replacingRanges.reversed() {
            self.replaceSubrange(subrange, with: replacement)
        }
    }

    /// Finds matching groups and replace them with a template using an intuitive API.
    ///
    /// This example will go through an input string and replace all occurrences of "MyGreatBrand" with "**MyGreatBrand**".
    ///
    ///     let regex = try! NSRegularExpression(pattern: #"(MyGreatBrand)"#) // Matches all occurrences of MyGreatBrand
    ///     let result = someMarkdownDocument.replacingGroups(matching: regex, with: #"**$1**"#) // Surround all matches with **, the bold text modifier syntax in markdown.
    ///     print(result)
    ///
    /// - Parameters:
    ///   - regex: the regex used to match groups.
    ///   - template: the template used to replace the groups. Reference groups inside your template using dollar sign symbol followed by the group number, e.g. "$1", "$2", etc.
    public func replacingGroups(matching regex: NSRegularExpression, with transformationString: String) -> String {
        var mutableSelf = self
        mutableSelf.replaceGroups(matching: regex, with: transformationString)
        return mutableSelf
    }
}

class BundleClass {
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
}
