//
//  Rigi.swift
//
//  Created by Dimitri van Oijen.
//

import Foundation
import UIKit

public class Rigi {

    public static let shared = Rigi()
    private init() { }

    public var settings = RigiSettings()

    // MARK: - Private

    var bundleName = Bundle.main.infoDictionary!["CFBundleName"] as! String

    var rigiButton: RigiButton?
    var screenshotCount = 1

    // MARK: - Public

    public func start() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.settings.isButtonVisible {
                self.rigiButton = RigiButton()
                self.rigiButton?.button.addTarget(self, action: #selector(self.handleTap), for: .touchUpInside)
            }
        }
        if settings.enableAutoScanning {
            startAutoScanning()
        }
        RigiLogger.log(.verbose, "Rigi Framework is loaded and started.")
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

    // Find the window that holds the app content. The RigiButton will add a second window to the hierarchy that we do not want to scan.
    var appWindow: UIWindow? {

        // From iOS 13+ iPad apps can have multiple screens (scenes). For now we only can snapshot the first scene.
        if #available(iOS 13.0, *) {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let appWindow = windowScene.windows.first(where:{ !($0 is RigiButtonWindow) }) else {
                return nil
            }
            return appWindow
        }
        guard
            let appWindow = UIApplication.shared.windows.first(where:{ !($0 is RigiButtonWindow) }) else {
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

            RigiLogger.log(.debug, " - \(level): \(responder)")

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

            RigiLogger.log(.debug, "Found label: \"\(text)\" , location: \(location), size: \(item.frame.size), clip: \"\(clippingBounds)\" , visible = \(visibleRect), onscreen x = \(visibleRatioHorz), onscreen y = \(visibleRatioVert)")

            guard
                !clippedRect.origin.x.isInfinite,
                !clippedRect.origin.y.isInfinite,
                !clippedRect.width.isInfinite,
                !clippedRect.height.isInfinite,
                visibleRatioHorz > settings.minimumOnscreenHorz,
                visibleRatioVert > settings.minimumOnscreenVert
            else {
                RigiLogger.log(.debug, "SKIP label: \"\(text)\"")
                return
            }
            RigiLogger.log(.debug, "ADD label: \"\(text)\"")

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

        guard let fileDir = RigiFileSystem.rigiDir else {return}

        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: fileDir)
            for filePath in filePaths {
                try FileManager.default.removeItem(atPath: fileDir + filePath)
            }
        } catch {
            RigiLogger.log(.error, "Could not clear temp folder", error)
        }
    }

    func saveScreenshot(screenshotName: String, image: UIImage) {

        guard var fileDir = RigiFileSystem.rigiDir else {return}
        fileDir += "resources/img/"

        let filePath = fileDir + screenshotName + ".png"
        let fileURL = URL(fileURLWithPath: filePath)

        guard let data = image.jpegData(compressionQuality: 1) else { return }

        if !FileManager.default.fileExists(atPath: fileDir) {
              do {
                  try FileManager.default.createDirectory(atPath: fileDir, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    RigiLogger.log(.error, "Create error", error)
                  RigiLogger.log(.verbose, error.localizedDescription)
                  return
              }
         }

        // Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                RigiLogger.log(.debug, "Removed old image \(fileURL.path)")
            } catch let removeError {
                RigiLogger.log(.error, "Couldn't remove file at path \(fileURL.path)", removeError)
            }
        }
        do {
            try data.write(to: fileURL)
            RigiLogger.log(.debug, "Saved image \(fileURL.path)")

        } catch let error {
            RigiLogger.log(.error, "Error saving file \(fileURL.path) with error", error)
        }
    }

    func saveLabels(screenshotTime: Date, screenshotName: String, labels: [(label: UILabel, rect: CGRect, color: UIColor)], size: CGSize) {

        guard let fileDir = RigiFileSystem.rigiDir else {return}

        let filePath = fileDir + screenshotName + ".html"
        let fileURL = URL(fileURLWithPath: filePath)

        if !FileManager.default.fileExists(atPath: fileDir) {
              do {
                  try FileManager.default.createDirectory(atPath: fileDir, withIntermediateDirectories: true, attributes: nil)
              } catch let error {
                  RigiLogger.log(.verbose, error.localizedDescription)
                  return
              }
         }

        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                RigiLogger.log(.debug, "Removed old image \(fileURL.path)")
            } catch let removeError {
                RigiLogger.log(.error, "Couldn't remove file at path \(fileURL.path)", removeError)
            }
        }
        do {
            let html = makeHtml(screenshotTime: screenshotTime, screenshotName: screenshotName, labels: labels, size: size)
            try html.write(to: fileURL, atomically: false, encoding: .utf8)
            RigiLogger.log(.verbose, "Saved html \(fileURL.path)")

        } catch let error {
            RigiLogger.log(.error, "Error saving file \(fileURL.path) with error", error)
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

