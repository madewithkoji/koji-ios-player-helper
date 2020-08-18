import UIKit
import WebKit

public protocol KojiRemixViewDelegate: AnyObject {
  func remixViewDidClose(_ remixView: KojiRemixView)
  func remixViewDidCreate(_ remixView: KojiRemixView, urlString: String)
}

open class KojiRemixView: UIView {
  var webView: WKWebView?
  weak open var delegate: KojiRemixViewDelegate?

  private var _id: String?
  public var id: String? {
    get {
      return self._id
    }
  }

  init(id: String) {
    super.init(frame: .zero)

    self.backgroundColor = .red

    self._id = id
    self.load(id: id)
  }

  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func load(id: String) {
    self.webView?.removeFromSuperview()

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
    self.webView!.backgroundColor = .black
    self.addSubview(self.webView!)

    // Build the HTML to render in the webview
    guard let path = Bundle.frameworkBundle()?.path(forResource: "KojiRemixView-iframe", ofType: "html") else {
      return
    }

    guard let template = try? String(contentsOfFile: path) else {
      return
    }

    let formattedTemplate = String(format: template, id)
    self.webView!.loadHTMLString(formattedTemplate, baseURL: URL(string: "about:blank"))
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    self.webView?.frame = self.bounds
  }
}

extension KojiRemixView: WKScriptMessageHandler {
  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    guard let response = message.body as? String else {
      return
    }
    let messageParts = response.split(separator: ":")

    if (messageParts[0] == "dismiss") {
      self.delegate?.remixViewDidClose(self)
    }
    if (messageParts[0] == "post-created" && messageParts.count == 2) {
      self.delegate?.remixViewDidCreate(self, urlString: "https://withkoji.com\(messageParts[1])")
    }
  }
}
