//
//  RigiSettings.swift
//  Rigi
//
//  Created by Dimitri van Oijen on 02/05/2022.
//

import Foundation

public struct RigiSettings {

    public enum ClipBounds {
        case screen
        case upperViewController
    }

    public enum DivPosition {
        case topleft
        case center
    }

    // Enable (debug) logging
    public var loggingEnabled = true

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
