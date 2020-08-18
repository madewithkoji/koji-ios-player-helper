import UIKit
import WebKit

public protocol KojiPlayerViewDelegate: AnyObject {
  func playerViewDidLoad(_ playerView: KojiPlayerView)
  func playerViewShouldPresentRemixView(_ playerView: KojiPlayerView, remixView: KojiRemixView)
}

open class KojiPlayerView: UIView {
  private var post: String?
  var webView: WKWebView?

  weak open var delegate: KojiPlayerViewDelegate?

  public override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = .black

    // Configure a script handler for callbacks
    let contentController = WKUserContentController()
    contentController.add(self, name: "callback")

    // Build the webview
    let configuration = WKWebViewConfiguration()
    configuration.allowsInlineMediaPlayback = true
    configuration.mediaPlaybackRequiresUserAction = false
    configuration.userContentController = contentController

    self.webView = WKWebView(frame: self.bounds, configuration: configuration)
    self.webView!.allowsBackForwardNavigationGestures = false
    self.webView!.scrollView.isScrollEnabled = false
    self.webView!.frame = self.bounds
    self.webView!.configuration.userContentController = contentController
    self.webView!.navigationDelegate = self
    self.addSubview(self.webView!)

    // Build the HTML to render in the webview
    guard let path = Bundle.frameworkBundle()?.path(forResource: "KojiPlayerView-iframe", ofType: "html") else {
      print("Error getting path to html file")
      return
    }

    guard let template = try? String(contentsOfFile: path) else {
      return
    }

    self.webView!.loadHTMLString(template, baseURL: URL(string: "about:blank"))
  }

  public func load(post: String) {
    self.post = post
    self.webView?.evaluateJavaScript("window.onLoad('\(post)');", completionHandler: nil)
  }

  public func play() {
    self.webView?.evaluateJavaScript("window.onPlay();", completionHandler: nil)
  }

  public func pause() {
    self.webView?.evaluateJavaScript("window.onPause();", completionHandler: nil)
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    self.webView?.frame = self.bounds
  }

  public required init?(coder: NSCoder) {
    fatalError()
  }
}

extension KojiPlayerView: WKScriptMessageHandler, WKNavigationDelegate {
  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    guard let response = message.body as? String else {
      return
    }
    let messageParts = response.components(separatedBy: ":")

    if (messageParts[0] == "loaded") {
      self.delegate?.playerViewDidLoad(self)
    }

    if (messageParts[0] == "create-remix" && messageParts.count == 2) {
      let remixView = KojiRemixView(id: messageParts[1])
      self.delegate?.playerViewShouldPresentRemixView(self, remixView: remixView)
    }
  }

  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    guard let post = self.post else {
      return
    }
    self.webView?.evaluateJavaScript("window.onLoad('\(post)');", completionHandler: nil)
  }
}

extension Bundle {
  class func frameworkBundle() -> Bundle? {
    guard let mainBundlePath = Bundle(for: KojiPlayerView.self).resourcePath else {
      return nil
    }
    let frameworkBundlePath = mainBundlePath.appending("/KojiPlayerHelper.bundle")
    return Bundle(path: frameworkBundlePath)
  }
}
