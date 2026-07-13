// This file is part of Kpapp for iOS.

import Combine
import CoreData
import SwiftUI
import WebKit


struct WebView: UIViewControllerRepresentable {
    @ObservedObject var browser: BrowserViewModel

    func makeUIViewController(context: Context) -> WebViewController {
        WebViewController(webView: browser.webView)
    }

    func updateUIViewController(_ controller: WebViewController, context: Context) { }
}

final class WebViewController: UIViewController {
    private let webView: WKWebView
    private let pageZoomObserver: Defaults.Observation
    private var webViewURLObserver: NSKeyValueObservation?
    private var topSafeAreaConstraint: NSLayoutConstraint?
    private var layoutSubject = PassthroughSubject<Void, Never>()
    private var layoutCancellable: AnyCancellable?
    private var currentScrollViewOffset: CGFloat = 0.0
    private var compactViewNavigationController: UINavigationController?
    
    init(webView: WKWebView) {
        self.webView = webView
        pageZoomObserver = Defaults.observe(.webViewPageZoom) { change in
            webView.adjustTextSize(pageZoom: change.newValue)
        }
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        webView.alpha = 0

        /*
         HACK: Make sure the webview content does not jump after state restoration
         It appears the webview's state restoration does not properly take into account of the content inset.
         To mitigate, first pin the webview's top against safe area top anchor, after all viewDidLayoutSubviews calls,
         pin the webview's top against view's top anchor, so that content does not appears to move up.
         */
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: webView.leftAnchor),
            view.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            view.rightAnchor.constraint(equalTo: webView.rightAnchor)
        ])
        topSafeAreaConstraint = view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: webView.topAnchor)
        topSafeAreaConstraint?.isActive = true
        layoutCancellable = layoutSubject
            .debounce(for: .seconds(0.15), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let view = self?.view,
                      let webView = self?.webView,
                      view.subviews.contains(webView) else { return }
                webView.alpha = 1
                guard self?.topSafeAreaConstraint?.isActive == true else { return }
                self?.topSafeAreaConstraint?.isActive = false
                self?.view.topAnchor.constraint(equalTo: webView.topAnchor).isActive = true
            }
        if !Brand.disableImmersiveReading {
            configureImmersiveReading()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #unavailable(iOS 18.0) {
            webView.setValue(view.safeAreaInsets, forKey: "_obscuredInsets")
        }
        layoutSubject.send()
    }
}

// MARK: - UIScrollViewDelegate
extension WebViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        configureBars(on: scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentScrollViewOffset = scrollView.contentOffset.y
    }
    
    private func configureBars(on scrollView: UIScrollView) {
        guard let navigationController = compactViewNavigationController else {
            return
        }
        
        var isScrollingDown: Bool {
            scrollView.contentOffset.y > currentScrollViewOffset
        }
        
        if scrollView.isDragging {
            if isScrollingDown {
                hideBars(on: navigationController)
            } else {
                showBars(on: navigationController)
            }
        }
    }
    
    func hideBars(on navigationController: UINavigationController) {
        navigationController.setNavigationBarHidden(true, animated: true)
        navigationController.setToolbarHidden(true, animated: true)
    }
    
    func showBars(on navigationController: UINavigationController) {
        navigationController.setNavigationBarHidden(false, animated: true)
        if traitCollection.horizontalSizeClass == .compact {
            navigationController.setToolbarHidden(false, animated: true)
        }
    }
}

// MARK: - Screen orientation change

extension WebViewController {
    @objc func onOrientationChange() {
        guard let navigationController = compactViewNavigationController else {
            return
        }
        
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            showBars(on: navigationController)
        case .landscapeRight:
            showBars(on: navigationController)
        default:
            showBars(on: navigationController)
        }
    }
    
    private func configureImmersiveReading() {
        configureDeviceOrientationNotifications()
        configureNavigationController()

        func configureDeviceOrientationNotifications() {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.onOrientationChange),
                                                   name: UIDevice.orientationDidChangeNotification,
                                                   object: nil)
        }
        
        func configureNavigationController() {
            webView.scrollView.delegate = self
            if parent?.navigationController != nil {
                compactViewNavigationController = parent?.navigationController
            }
        }
    }
}

extension WKWebView {
    func adjustTextSize(pageZoom: Double? = nil) {
        let pageZoom = pageZoom ?? Defaults[.webViewPageZoom]
        let template = "document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='%.0f%%'"
        let javascript = String(format: template, pageZoom * 100)
        evaluateJavaScript(javascript, completionHandler: nil)
    }
}

final class WebViewConfiguration: WKWebViewConfiguration {
    override init() {
        super.init()
        setURLSchemeHandler(KpappURLSchemeHandler(), forURLScheme: KpappURLSchemeHandler.ZIMScheme)

        allowsInlineMediaPlayback = true
        mediaTypesRequiringUserActionForPlayback = []

        userContentController = {
            let controller = WKUserContentController()
            if let url = Bundle.main.url(forResource: "injection", withExtension: "js"),
               let javascript = try? String(contentsOf: url) {
                let script = WKUserScript(source: javascript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
                controller.addUserScript(script)
            }
            return controller
        }()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
