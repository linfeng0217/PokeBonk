import SwiftUI
import WebKit

/// PokéBonk 网页游戏地址
private let gameURL = URL(string: "https://pokebonk.com/")!

/// 全屏 WKWebView 容器：针对 WebGL 游戏调优
struct WebGameView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GameWebViewController {
        GameWebViewController()
    }

    func updateUIViewController(_ uiViewController: GameWebViewController, context: Context) {}
}

final class GameWebViewController: UIViewController {

    private var webView: WKWebView!
    private var retryHost: UIHostingController<RetryView>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let config = WKWebViewConfiguration()
        // 游戏可能有音效/视频，允许内联播放且不强制用户先点一下
        config.allowsInlineMediaPlayback = true
        config.mediaPlaybackRequiresUserAction = false
        config.mediaTypesRequiringUserActionForPlayback = []
        // 网页内 JS 弹窗 / window.open 直接接管
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self

        // —— 游戏化封装：禁用一切干扰手势 ——
        let scroll = webView.scrollView
        scroll.bounces = false
        scroll.bouncesZoom = false
        scroll.isScrollEnabled = false           // 游戏自绘画面，不允许页面滚动
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = 1
        scroll.contentInsetAdjustmentBehavior = .never

        webView.isOpaque = true
        webView.backgroundColor = .black
        scroll.backgroundColor = .black

        view.addSubview(webView)

        // 失败重试遮罩
        retryHost = UIHostingController(rootView: RetryView(onRetry: { [weak self] in
            self?.retryHost.view.isHidden = true
            self?.webView.load(URLRequest(url: gameURL))
        }))
        addChild(retryHost)
        retryHost.view.frame = view.bounds
        retryHost.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        retryHost.view.backgroundColor = .black
        retryHost.view.isHidden = true
        view.addSubview(retryHost.view)
        retryHost.didMove(toParent: self)

        webView.load(URLRequest(url: gameURL))
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .allButUpsideDown
    }

    override var prefersStatusBarHidden: Bool { true }

    fileprivate func showRetry() {
        retryHost.view.isHidden = false
    }
}

extension GameWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showRetry()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // 用户取消（NSURLErrorCancelled = -999）不算失败
        let err = error as NSError
        if err.code != NSURLErrorCancelled { showRetry() }
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 preferences: WKWebpagePreferences,
                 decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel, preferences)
            return
        }
        // 只放行 http/https；tel/mail 等协议一律拦截（游戏不需要）
        if ["http", "https"].contains(url.scheme?.lowercased()) {
            decisionHandler(.allow, preferences)
        } else {
            decisionHandler(.cancel, preferences)
        }
    }
}

extension GameWebViewController: WKUIDelegate {

    // target="_blank" / window.open：在当前 WebView 里打开，不跳 Safari
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}

/// 加载失败时的重试界面
struct RetryView: View {
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("无法连接 PokéBonk")
                .font(.title2).bold()
                .foregroundColor(.white)
            Text("请检查 iPhone 是否已联网，然后点重试。")
                .foregroundColor(.secondary)
            Button(action: onRetry) {
                Text("重试").padding(.horizontal, 24).padding(.vertical, 10)
                    .background(Color.blue).foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
