//
//  ViewController.swift
//  testAuthDigest
//
//  Created by tomohiro obara on 2018/10/11.
//  Copyright © 2018年 tomohiro obara. All rights reserved.
//  https://hirooka.pro/?p=3223
//  を参考に

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var mimeType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        webView.isHidden = true
    }


    @IBAction func onAccess(_ sender: Any) {
        _ = self.connect(url_str: "https://127.0.0.1/digest/")
    }
}

extension ViewController : URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print(#file, #function, #line, separator:":")
        
        // レスポンスBody
        if data.isEmpty {
            print(#file, #function, #line, "responce body is empty.", separator:":")
            return
        }
        print("length: ", data.count)
        
//        DispatchQueue.main.async {
//            self.webView.load(data, mimeType: self.mimeType, characterEncodingName: "utf8", baseURL: nil)
//        }
        guard let str = String(bytes: data, encoding: .utf8) else {
            print("utf8 conversion error.")
            return
        }
        print("body: ")
        print(str)
        
        DispatchQueue.main.async {
            self.webView.loadHTMLString(str, baseURL: nil)
        }
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        print(#file, #function, #line, separator:":")
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        print(#file, #function, #line, separator:":")
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print(#file, #function, #line, separator:":")
        
        guard let http_res = response as? HTTPURLResponse else {
            print(#line, "unknown response.", separator:":")
            print(response)
            completionHandler(.cancel)
            return
        }
        let statCode = http_res.statusCode
        print("status: ", statCode)
//        guard statCode == 200 else {
//            return
//        }
        if let mtype = http_res.mimeType {
            print("mime type: ",mtype)
        }
        self.mimeType = http_res.mimeType
        if let enc_name = http_res.textEncodingName {
            print("text encoding name: ",enc_name)
        }
        let all_headers = http_res.allHeaderFields
        for header in all_headers {
            print(header)
        }
        completionHandler(.allow)
        // 以下としなくても、.allowで十分
//        completionHandler(URLSession.ResponseDisposition.allow)
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        print(#file, #function, #line, separator:":")
        
        print("proposedResponse: ")
        print(proposedResponse)
        print("proposedResponse.storagePolicy: ", proposedResponse.storagePolicy.rawValue)
        completionHandler(proposedResponse)
    }
    
}

extension ViewController : URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(#file, #function, #line, separator:":")

        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.webView.isHidden = false
        }

        if let err = error {
            print("error happen", err.localizedDescription, separator:":")
        } else {
            print("success.")
        }
        
        session.invalidateAndCancel()
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        print(#file, #function, #line, separator:":")
        print("------------------")
        print("metrics: ", metrics)
        print("------------------")
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        print(#file, #function, #line, separator:":")
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        print(#file, #function, #line, separator:":")
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        print(#file, #function, #line, separator:":")
    }
    // ベーシック認証，ダイジェスト認証が掛かっている場合に呼ばれる
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(#file, #function, #line, separator:":")
        print("authentication method: ", challenge.protectionSpace.authenticationMethod)
        print("protection space , host: ", challenge.protectionSpace.host)
        let cnt = challenge.previousFailureCount
        print("previous failure count: ", cnt)
        guard cnt == 0 else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        let cred = URLCredential(user: "admin", password: "pass", persistence: .forSession)
        completionHandler(.useCredential, cred)
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        print(#file, #function, #line, separator:":")
    }
}

extension ViewController
{
    func connect(url_str: String) -> Bool {
    
        guard let url = URL(string: url_str) else {
            print("url_str is not valid.")
            return false
        }
        
        let task : URLSessionTask = {
            let conf = URLSessionConfiguration.default
            conf.waitsForConnectivity = true
            let ss = URLSession(configuration: conf, delegate: self, delegateQueue: nil)
            return ss.dataTask(with: url)
        }()
        task.resume()
        
//        let conf = URLSessionConfiguration.default
//        conf.waitsForConnectivity = true
//        let ss = URLSession(configuration: conf, delegate: self, delegateQueue: nil)
//        let task = ss.dataTask(with: url)
//        task.resume()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        return true
    }
}
