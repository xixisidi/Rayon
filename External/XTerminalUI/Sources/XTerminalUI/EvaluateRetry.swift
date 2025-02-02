//
//  File.swift
//
//
//  Created by Lakr Aream on 2022/3/20.
//

import WebKit

extension WKWebView {
    func evaluateJavascriptWithRetry(javascript: String) {
        if Thread.isMainThread {
            #if DEBUG
                fatalError("this function is not designed to be used on main thread")
            #else
                DispatchQueue.global().async {
                    self.evaluateJavascriptWithRetry(javascript: javascript)
                }
            #endif
        } else {
            var success = false
            while !success {
                let sem = DispatchSemaphore(value: 0)
                DispatchQueue.main.async {
                    self.evaluateJavaScript(javascript) { _, error in
                        defer { sem.signal() }
                        if let error = error {
                            debugPrint(error.localizedDescription)
                        } else {
                            success = true
                        }
                    }
                }
                sem.wait()
                if success { return }
                usleep(1000)
            }
        }
    }
}
