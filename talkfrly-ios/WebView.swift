//
//  WebView.swift
//  talkfrly-ios
//
//  Created by Mike on 28/12/2025.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Environment(\.colorScheme) private var colorScheme

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        configuration.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator

        let initialTheme = themeString(for: colorScheme)
        contentController.addUserScript(
            WKUserScript(
                source: "window.appTheme = '\(initialTheme)';",
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            )
        )

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url == nil, let url = URL(string: "https://talkfrly.com") {
            webView.load(URLRequest(url: url))
        }

        let theme = themeString(for: colorScheme)
        context.coordinator.setTheme(theme, in: webView)
    }

    private func themeString(for scheme: ColorScheme) -> String {
        scheme == .dark ? "dark" : "light"
    }
}

final class Coordinator: NSObject, WKNavigationDelegate {
    private var isLoaded = false
    private var pendingTheme: String?

    func setTheme(_ theme: String, in webView: WKWebView) {
        if isLoaded {
            webView.evaluateJavaScript(themeScript(for: theme), completionHandler: nil)
        } else {
            pendingTheme = theme
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoaded = true
        if let theme = pendingTheme {
            webView.evaluateJavaScript(themeScript(for: theme), completionHandler: nil)
            pendingTheme = nil
        }
    }

    private func themeScript(for theme: String) -> String {
        """
        window.appTheme = '\(theme)';
        if (window.dispatchEvent) {
          window.dispatchEvent(new CustomEvent('appThemeChange', { detail: { theme: window.appTheme } }));
        }
        if (window.dispatcher && typeof window.dispatcher === 'function') {
          window.dispatcher('appThemeChange', { theme: window.appTheme });
        }
        """
    }
}
