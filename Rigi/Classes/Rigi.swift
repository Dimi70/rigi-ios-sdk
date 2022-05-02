//
//  Rigi.swift
//
//  Created by Dimitri van Oijen.
//
//  Version 1.0.0
//

import Foundation
import UIKit

public struct RigiSettings {

    public enum ClipBounds {
        case screen
        case upperViewController
    }

    public enum DivPosition {
        case topleft
        case center
    }

    // Show the scan button
    public var isButtonVisible = true

    // Add timestamps to the preview names
    public var addFileTimestamps = true

    // Enable auto scanning when new view controllers are detected in the view hierarchy
    public var enableAutoScanning = false
    public var autoScanInterval: Double = 1 // SHOULD BE GREATER THAN THE DELAY!!! TODO: Refactor
    public var autoScanCaptureDelay: Double = 0.7

    // This option will make sure only the upper view controller is scanned when multiple view controllers are stacked on the screen.
    // For example in MobilePark the onboarding flow will stack multiple view controllers.
    public var onlyScanUpperViewController = true

    // Temporarily clear textfields and textviews to snapshot hint texts
    public var autoClearTextFields = true

    // By default embedded/child view controllers will not handled as an 'upper' view controller (like popup windows)
    // Optionally you can register embedded/child view controllers here that should be handled as upper view controllers.
    // For example the menu view controller, that is an embedded child of map view controller, should be regarded as an upper view controller
    // and thus the capture should ignore all views 'behind' the menu view controller.
    public var additionalUpperViewControllers: [String] = ["SE_MenuViewController"]

    // What is the minimum part of the label that should visible in the screen?
    public var minimumOnscreenHorz = 0.8
    public var minimumOnscreenVert = 0.8

    // Clip the offscreen part of the label?
    public var clipOffscreen = true
    public var clipStyle: ClipBounds = .upperViewController

    // Select the entire button instead of the label inside a UIButton
    public var expandToButton = false

    // Add simulator border
    public var addDeviceBezels = true

    public var previewPosition: DivPosition = .center

    // Add borders around translatable texts
    public var addLabelBorders = true
    public var labelBorderColor = "#0a3679"

    // Include the Apple system font (San Francisco) for use in Windows
    public var includeAppleWebFonts = true

    public var includedAppleWebFonts = """
        /** Ultra Light */
        @font-face {
          font-family: "San Francisco";
          font-weight: 100;
          src: url("https://applesocial.s3.amazonaws.com/assets/styles/fonts/sanfrancisco/sanfranciscodisplay-ultralight-webfont.woff");
        }

        /** Thin */
        @font-face {
          font-family: "San Francisco";
          font-weight: 200;
          src: url("https://applesocial.s3.amazonaws.com/assets/styles/fonts/sanfrancisco/sanfranciscodisplay-thin-webfont.woff");
        }

        /** Regular */
        @font-face {
          font-family: "San Francisco";
          font-weight: 400;
          src: url("https://applesocial.s3.amazonaws.com/assets/styles/fonts/sanfrancisco/sanfranciscodisplay-regular-webfont.woff");
        }

        /** Medium */
        @font-face {
          font-family: "San Francisco";
          font-weight: 500;
          src: url("https://applesocial.s3.amazonaws.com/assets/styles/fonts/sanfrancisco/sanfranciscodisplay-medium-webfont.woff");
        }

        /** Semi Bold */
        @font-face {
          font-family: "San Francisco";
          font-weight: 600;
          src: url("https://applesocial.s3.amazonaws.com/assets/styles/fonts/sanfrancisco/sanfranciscodisplay-semibold-webfont.woff");
        }

        /** Bold */
        @font-face {
          font-family: "San Francisco";
          font-weight: 700;
          src: url("https://applesocial.s3.amazonaws.com/assets/styles/fonts/sanfrancisco/sanfranciscodisplay-bold-webfont.woff");
        }
    """

    public var includedFontStyles = """
        .system-font { font-family: -apple-system, San Francisco, BlinkMacSystemFont, sans-serif; }
        .ultralight { font-weight: 100; }
        .thin { font-weight: 200; }
        .light { font-weight: 300; }
        .regular { font-weight: 400; }
        .medium { font-weight: 500; }
        .semibold { font-weight: 600; }
        .bold { font-weight: 700; }
        .heavy { font-weight: 800; }
        .black { font-weight: 900; }
        .italic { font-style: italic; }
    """

    public var includedBodyStyles = """
        body {
            padding: 0;
            margin: 0;
            background-color: #ddd;
            font-family: "San Francisco";
            line-height: 125%;
        }
        .translatable {
            position: absolute;
            display: table;
        }
        .vertical-center {
            vertical-align: middle;
            display: table-cell;
        }
        .shadow {
            box-shadow: 0rem 0.4rem 0.6rem rgba(0, 0, 30, 0.5);
        }
        .center {
            margin: 0;
            position: absolute;
            top: 50%;
            left: 50%;
            -ms-transform: translate(-50%, -50%);
            transform: translate(-50%, -50%);
        }
        .top-left {
            position: absolute;
            top: 0;
            left: 0;
        }
    """

    public var fontStyleClasses: [String: String] = [
        ".SFUI-UltraLight": "system-font ultralight",
        ".SFUI-Thin": "system-font thin",
        ".SFUI-Light": "system-font light",
        ".SFUI-Regular": "system-font regular",
        ".SFUI-Medium": "system-font medium",
        ".SFUI-Semibold": "system-font semibold",
        ".SFUI-Bold": "system-font bold",
        ".SFUI-Heavy": "system-font heavy",
        ".SFUI-Black": "system-font black",

        ".SFUI-UltraLightItalic": "system-font ultralight italic",
        ".SFUI-ThinItalic": "system-font thin italic",
        ".SFUI-LightItalic": "system-font light italic",
        ".SFUI-RegularItalic": "system-font regular italic",
        ".SFUI-MediumItalic": "system-font medium italic",
        ".SFUI-SemiboldItalic": "system-font semibold italic",
        ".SFUI-BoldItalic": "system-font bold italic",
        ".SFUI-HeavyItalic": "system-font heavy italic",
        ".SFUI-BlackItalic": "system-font black italic"
    ]
}

public class Rigi {

    public static let shared = Rigi()
    private init() { }

    public var settings = RigiSettings()

    // MARK: - Private

    var rigiButton: FloatingButtonController?
    var bundleName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    var screenshotCount = 1

    // MARK: - Public

    public func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.settings.isButtonVisible {
                self.rigiButton = FloatingButtonController()
                self.rigiButton?.button.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
            }
        }
        if settings.enableAutoScanning {
            startAutoScanning()
        }
        print("Rigi Framework is loaded and started.")
    }

    @objc func handleTap() {

        rigiButton?.animateClick()

        let replaced = prepareTextFields()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.makeSnapshot()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.restoreTextFields(fields: replaced)
        }
    }

    // MARK: - Auto scanning

    var autoScanTimer: Timer?
    var autoScanViewController: UIViewController?

    func startAutoScanning() {
        autoScanTimer = Timer.scheduledTimer(timeInterval: settings.autoScanInterval, target: self, selector: #selector(self.autoScanCycle), userInfo: nil, repeats: true)
    }

    func stopAutoScanning() {
        autoScanTimer?.invalidate()
        autoScanTimer = nil
    }

    @objc func autoScanCycle() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + settings.autoScanCaptureDelay) {
            if self.shouldMakeSnapshot() {
                self.makeSnapshot()
            }
        }
    }

    func shouldMakeSnapshot() -> Bool {

        // TODO: This should be nicely integrated with the makeSnapshot() functionality

//        var upperViewController: UIViewController?
//        var upperViewControllerPassed = true
//
//        // Find upper view controller
//        if settings.onlyScanUpperViewController {
//
//            upperViewControllerPassed = false
//            appWindow?.traverseHierarchy { responder, level in
//                if let viewController = responder as? UIViewController {
//
//                    let viewControllerName = String(describing: type(of: viewController))
//
//                    // Embedded view controllers should not be the new upper view controller. Unless explicity registered as upper view controller..
//                    if !viewController.isEmbedded || settings.additionalUpperViewControllers.contains(viewControllerName) {
//                        upperViewController = viewController
//                    }
//                }
//            }
//        }
//
//        if upperViewController != nil && upperViewController != autoScanViewController {
//            autoScanViewController = upperViewController
//            return true
//        }
        return false
    }

    // MARK: - Internal snapshotter

    // Find the window that holds the app content. The FloatingButtonController will add a second window to the hierarchy that we do not want to scan.
    var appWindow: UIWindow? {

        // From iOS 13+ iPad apps can have multiple screens (scenes). For now we only can snapshot the first scene.
        if #available(iOS 13.0, *) {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let appWindow = windowScene.windows.first(where:{ !($0 is FloatingButtonWindow) }) else {
                return nil
            }
            return appWindow
        }
        guard
            let appWindow = UIApplication.shared.windows.first(where:{ !($0 is FloatingButtonWindow) }) else {
            return nil
        }
        return appWindow
    }

    typealias TextField = (id: String, field: UIView, text: String)

    func prepareTextFields() -> [TextField] {

        if !settings.autoClearTextFields {
            return []
        }
        var fields: [TextField] = []
        var id = 1

        appWindow?.traverseHierarchy { responder, level in
            if let field = responder as? UITextView {
                fields.append((String(id), field, field.text))
                field.accessibilityIdentifier = String(id)
                field.text = nil
                id += 1
            }
            if let field = responder as? UITextField, let text = field.text {
                fields.append((String(id), field, text))
                field.accessibilityIdentifier = String(id)
                field.text = nil
                id += 1
            }
        }
        return fields
    }

    func restoreTextFields(fields: [TextField]) {

        if !settings.autoClearTextFields {
            return
        }
        appWindow?.traverseHierarchy { responder, level in
            if let field = responder as? UITextView, let id = field.accessibilityIdentifier {
                if let restore = fields.first(where: { $0.id == id }) {
                    field.text = restore.text
                }
            }
            if let field = responder as? UITextField, let id = field.accessibilityIdentifier {
                if let restore = fields.first(where: { $0.id == id }) {
                    field.text = restore.text
                }
            }
        }
    }

    func makeSnapshot() {

        let screenshotTime = Date()

        var labels: [(label: UILabel, rect: CGRect, color: UIColor)] = []

        let window = appWindow
        var upperViewController: UIViewController?
        var upperViewControllerPassed = true

        // Find upper view controller
        if settings.onlyScanUpperViewController {

            upperViewControllerPassed = false
            window?.traverseHierarchy { responder, level in
                if let viewController = responder as? UIViewController {

                    let viewControllerName = String(describing: type(of: viewController))

                    // Embedded view controllers should not be the new upper view controller. Unless explicity registered as upper view controller.
                    if !viewController.isEmbedded || settings.additionalUpperViewControllers.contains(viewControllerName) {
                        upperViewController = viewController
                    }
                }
            }
        }

        // Grab labels
        window?.traverseHierarchy { responder, level in

            // Skip all views that are 'behind' the upper view controller
            if settings.onlyScanUpperViewController && !upperViewControllerPassed {
                if let viewController = responder as? UIViewController, viewController == upperViewController {
                    upperViewControllerPassed = true
                } else {
                    return
                }
            }

//            var fieldText: String
//            if let textField = responder as? UITextField,
//                let fieldText = textField.text {
//            }

            // Rigi Codering: \u206A\u206A\u206A [KEY] \u206A [TEXT] \u206A\u206A
            // Example:
            // \u206A\u206A\u206A\u200D\u200B\u200D\u200D\u200D\u200C\u200B\u200D\u200B\u200C\u200D\u200D\u200C\u200C\u200B\u200C\u200D\u200D\u200B\u200C\u200B\u200D\u200C\u200C\u200D\u200D\u200B\u200C\u200C\u200D\u200B\u200D\u200D\u200C\u200C\u200C\u200C\u200D\u200D\u200C\u206AWe have \u200B\u200B\u200B{0}\u200C\u200C\u200C apples.\u206A\u206A

            print(" - \(level): \(responder)")

            guard
                let label = responder as? UILabel,
                let text = label.text,
                let unicodes = text.applyingTransform(.toXMLHex, reverse: false), unicodes.starts(with: "&#x206A;&#x206A;")
                else { return }

            // For labels that are part of a button we use the button rect instead of the label rect
            let item = settings.expandToButton ? (label.superview as? UIButton ?? label) : label
            let location = item.superview!.convert(item.frame.origin, to: nil)

            var clippingBounds = UIScreen.main.bounds

            if settings.clipStyle == .upperViewController,
               let upperViewController = upperViewController,
               let clipTopLeft = upperViewController.view.superview?.convert(upperViewController.view.frame.origin, to: nil) {
                clippingBounds = CGRect(origin: clipTopLeft, size: upperViewController.view.bounds.size)
            }

            let itemRect = CGRect(origin: location, size: item.frame.size)
            let visibleRect = itemRect.intersection(clippingBounds)
            let visibleRatioHorz = visibleRect.width / itemRect.width
            let visibleRatioVert = visibleRect.height / itemRect.height

            let clippedRect = settings.clipOffscreen ? visibleRect : itemRect

            print("Found label: \"\(text)\" , location: \(location), size: \(item.frame.size), clip: \"\(clippingBounds)\" , visible = \(visibleRect), onscreen x = \(visibleRatioHorz), onscreen y = \(visibleRatioVert)")

            guard
                !clippedRect.origin.x.isInfinite,
                !clippedRect.origin.y.isInfinite,
                !clippedRect.width.isInfinite,
                !clippedRect.height.isInfinite,
                visibleRatioHorz > settings.minimumOnscreenHorz,
                visibleRatioVert > settings.minimumOnscreenVert
            else {
                print("SKIP label: \"\(text)\"")
                return
            }
            print("ADD label: \"\(text)\"")

            labels.append((label: label, rect: clippedRect, color: label.textColor))
        }

        // Hide the label text, then animate the text from red to the origial color
        DispatchQueue.main.async {

            labels.forEach { item in

                item.label.textColor = .clear

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {

                    UIView.transition(with: item.label, duration: 0.4, options: .transitionCrossDissolve, animations: {
                        item.label.textColor = .red
                    }, completion: { _ in

                        UIView.transition(with: item.label, duration: 0.4, options: .transitionCrossDissolve, animations: {
                            item.label.textColor = item.color
                        }, completion: nil)
                    })
                }
            }

            if let screenshotImage = self.getScreenshotImage(window: window) {

                if self.screenshotCount == 1 {
                    self.clearFolder()
                }

                let screenshotNumber = String(format: "%03d", self.screenshotCount)
                let screenshotName = self.settings.addFileTimestamps ? "\(Int(screenshotTime.timeIntervalSince1970))_screen_\(screenshotNumber)" : "rigi_screen_\(screenshotNumber)"

                self.saveScreenshot(screenshotName: screenshotName, image: screenshotImage)
                self.saveLabels(screenshotTime: screenshotTime, screenshotName: screenshotName, labels: labels, size: screenshotImage.size)

                self.screenshotCount += 1
            }
        }
    }

    func getScreenshotImage(window: UIWindow?) -> UIImage? {

        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: UIScreen.main.bounds.size)
            let image = renderer.image { ctx in
                window?.drawHierarchy(in: UIScreen.main.bounds, afterScreenUpdates: true)
            }
            return image
        }
        return nil
    }

    func clearFolder() {

        guard let fileDir = FileSystem.rigiDir else {return}

        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: fileDir)
            for filePath in filePaths {
                try FileManager.default.removeItem(atPath: fileDir + filePath)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }

    func saveScreenshot(screenshotName: String, image: UIImage) {

        guard var fileDir = FileSystem.rigiDir else {return}
        fileDir += "resources/img/"

        let filePath = fileDir + screenshotName + ".png"
        let fileURL = URL(fileURLWithPath: filePath)

        guard let data = image.jpegData(compressionQuality: 1) else { return }

        if !FileManager.default.fileExists(atPath: fileDir) {
              do {
                  try FileManager.default.createDirectory(atPath: fileDir, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    print("create error")
                  print(error.localizedDescription)
                  return
              }
         }

        // Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image \(fileURL.path)")
            } catch let removeError {
                print("couldn't remove file at path \(fileURL.path)", removeError)
            }
        }
        do {
            try data.write(to: fileURL)
            print("Saved image \(fileURL.path)")

        } catch let error {
            print("error saving file \(fileURL.path) with error", error)
        }
    }

    func saveLabels(screenshotTime: Date, screenshotName: String, labels: [(label: UILabel, rect: CGRect, color: UIColor)], size: CGSize) {

        guard let fileDir = FileSystem.rigiDir else {return}

        let filePath = fileDir + screenshotName + ".html"
        let fileURL = URL(fileURLWithPath: filePath)

        if !FileManager.default.fileExists(atPath: fileDir) {
              do {
                  try FileManager.default.createDirectory(atPath: fileDir, withIntermediateDirectories: true, attributes: nil)
              } catch let error {
                  print(error.localizedDescription)
                  return
              }
         }

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image \(fileURL.path)")
            } catch let removeError {
                print("couldn't remove file at path \(fileURL.path)", removeError)
            }
        }
        do {
            let html = makeHtml(screenshotTime: screenshotTime, screenshotName: screenshotName, labels: labels, size: size)
            try html.write(to: fileURL, atomically: false, encoding: .utf8)
            print("Saved html \(fileURL.path)")

        } catch let error {
            print("error saving file \(fileURL.path) with error", error)
        }
    }

    func makeHtml(screenshotTime: Date, screenshotName: String, labels: [(label: UILabel, rect: CGRect, color: UIColor)], size: CGSize) -> String {

        let notchWidth = 150
        let notchLeft = Int((Int(size.width) - notchWidth - 2*30) / 2)
        let bezel = settings.addDeviceBezels ? (UIDevice.hasTopNotch ? "border: 20px solid black; border-radius: 60px;" : "border: 20px solid black; border-width: 100px 20px; border-radius: 50px;") : ""
        let notch = settings.addDeviceBezels && UIDevice.hasTopNotch ? "<div style=\"border: 30px solid black; border-radius: 20px; position: absolute; width: 150px; height: 0px; top: -30px; left: \(notchLeft)px;\"></div>" : ""

        return """
        <!DOCTYPE html>
        <!-- BEGIN RIGI_RAW_HEADER {
            "texts":[\(labels.compactMap(makeText).joined(separator: ","))],
            "dependencies":["resources/img/\(screenshotName).png"],
            "dateCreated":"\(Int(screenshotTime.timeIntervalSince1970))",
            "signatureFormat":3,
            "guid":"\(UUID().uuidString)"
        } END RIGI_RAW_HEADER -->
        <html>
        <head>
          <title>RIGI Screenshot</title>
          <style>
            \(settings.includeAppleWebFonts ? settings.includedAppleWebFonts : "")
            \(settings.includedFontStyles)
            \(settings.includedBodyStyles)
          </style>
        </head>
        <meta charset="UTF-8">
        <body>
          <div class="\(settings.previewPosition) shadow" style="width: \(Int(size.width))px; height: \(Int(size.height))px; overflow: hidden; background: url(resources/img/\(screenshotName).png) no-repeat left top; background-size: \(Int(size.width))px; \(bezel)">
        \(labels.compactMap(makeDiv).joined(separator: "\n"))
        \(notch)
          </div>

        </body>
        </html>
        """
    }

    func makeText(label: UILabel, rect: CGRect, color: UIColor) -> String? {
        guard
            let key = label.text?.rigiKey
            else { return nil }

        return "\u{22}\u{206A}\u{206A}\u{206A}\(key)\u{206A}-\u{206A}\u{206A}\u{22}" // add quotes ("..")
    }

    func makeDiv(label: UILabel, rect: CGRect, color: UIColor) -> String? {
        guard
            var text = label.text
            else { return nil }

        text = text
            .replace(">", with: "&gt;")
            .replace("<", with: "&lt;")
            .replace("\r\n|\n\r|\r|\n", with: "<br>") // newline to <br>

        let textColor = toHex(color: color) ?? "#000000"
        //let backgroundColor = toHex(color: label.backgroundColor) ?? ""

        // Get the label alignment -or- center the label when expanded to button
        let isButtonLabel = label.superview is UIButton
        let alignments = [NSTextAlignment.center: "center", NSTextAlignment.left: "left", NSTextAlignment.right: "right", NSTextAlignment.justified: "justify", NSTextAlignment.natural: "left"]
        let alignment = (settings.expandToButton && isButtonLabel ? "center" : alignments[label.textAlignment]) ?? "left"

        let borderInset = settings.addLabelBorders ? 2 : 0

        var divStyle =
        "left: \(Int(rect.origin.x))px; " +
        "top: \(Int(rect.origin.y))px; " +
        "min-width: \(Int(rect.width) - borderInset)px; " +
        "min-height: \(Int(rect.height) - borderInset)px; " +
        "color: \(textColor); " +
        //(backgroundColor.isEmpty ? "" : "background-color: \(backgroundColor); ") +
        "font-size: \(Int(label.font.pointSize))px; " +
        "text-align: \(alignment); "

        if settings.addLabelBorders {
            divStyle += "border: 1px solid \(settings.labelBorderColor); "
        }

        var spanClass = "vertical-center"

        // Find included cross-browser font class -or- use the iOS font family (might not work in Windows)
        if let fontClass = settings.fontStyleClasses[label.font.fontName] {
            spanClass += " " + fontClass
        } else {
            divStyle += "font-family: '\(label.font.fontName)';"
        }

        let div = "<div class=\"translatable\" data-rg-resourceids=\"\" data-rg-signatures=\"\" style=\"\(divStyle)\"><span class=\"\(spanClass)\">\(text)</span></div>"
        return div
    }

//    func toHex(color: UIColor?) -> String? {
//        guard let color = color else { return nil }
//        var r: CGFloat = 0
//        var g: CGFloat = 0
//        var b: CGFloat = 0
//        var a: CGFloat = 0
//        color.getRed(&r, green: &g, blue: &b, alpha: &a)
//        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
//        return String(format: "#%06x", rgb)
//    }
    func toHex(color: UIColor?) -> String? {
        guard let color = color else { return nil }
        var r: CGFloat{ return CIColor(color: color).red }
        var g: CGFloat{ return CIColor(color: color).green }
        var b: CGFloat{ return CIColor(color: color).blue }
        var a: CGFloat{ return CIColor(color: color).alpha }
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }
}

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


// MARK: - Filesystem

class FileSystem {

    static var rigiDir: String? {
        guard let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            else { return nil }
        return dir + "/rigi/"
    }
}

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

// MARK: - Floating Button Window

// https://stackoverflow.com/questions/34777558/in-ios-how-do-i-create-a-button-that-is-always-on-top-of-all-other-view-control/34883581

private class FloatingButtonWindow: UIWindow {
    var button: UIButton?

    var floatingButtonController: FloatingButtonController?

    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let button = button else { return false }
        let buttonPoint = convert(point, to: button)
        return button.point(inside: buttonPoint, with: event)
    }
}

class BundleClass {
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
}

class FloatingButtonController: UIViewController {
    private(set) var button: UIButton!
    private(set) var active: UIImageView!

    private let window = FloatingButtonWindow()

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
