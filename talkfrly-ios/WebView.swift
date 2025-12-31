//
//  WebView.swift
//  talkfrly-ios
//
//  Created by Mike on 28/12/2025.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let url = URL(string: "https://talkfrly.com")
        
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
