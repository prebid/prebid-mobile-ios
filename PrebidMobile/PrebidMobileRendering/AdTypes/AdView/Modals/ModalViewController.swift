//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import UIKit

@objc(PBMModalViewController)
@objcMembers
public class ModalViewController: UIViewController {

    // MARK: - Public Properties
    
    weak var modalViewControllerDelegate: ModalViewControllerDelegate?
    var modalState: ModalState?
    var contentView: UIView?
    var isRotationEnabled = true
    var modalManager: ModalManager?

    // MARK: - Private Properties

    var showCloseButtonBlock: VoidBlock?
    var startCloseDelay: Date?
    var preferAppStatusBarHidden = false
    let closeButtonDecorator = AdViewButtonDecorator()
    var interstitialLayout = InterstitialLayout.undefined

    // MARK: - Lifecycle
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        view.backgroundColor = .black
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        view.backgroundColor = .black
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCloseButton()
        setupContentView()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        preferAppStatusBarHidden = !UIApplication.shared.isStatusBarHidden
        
        setNeedsStatusBarAppearanceUpdate()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        preferAppStatusBarHidden = !prefersStatusBarHidden
        
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - Status Bar

    public override var prefersStatusBarHidden: Bool {
        preferAppStatusBarHidden
    }

    // MARK: - Orientation

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard !isRotationEnabled else {
            return .all
        }
        return interstitialLayout == .landscape ? .landscape : .portrait
    }

    public override var shouldAutorotate: Bool {
        isRotationEnabled
    }

    // MARK: - Internal Accessors

    var displayView: UIView? {
        modalState?.view
    }

    var displayProperties: InterstitialDisplayProperties? {
        modalState?.displayProperties
    }

    // MARK: - Public Methods

    func setupState(_ modalState: ModalState) {
        if let displayView = displayView,
           displayView.superview == contentView {
            displayView.removeFromSuperview()
        }

        if showCloseButtonBlock != nil {
            onCloseDelayInterrupted()
        }

        self.interstitialLayout = modalState.displayProperties?.interstitialLayout ?? .undefined
        self.modalState = modalState

        if self.interstitialLayout == .undefined {
            self.isRotationEnabled = modalState.isRotationEnabled
        } else {
            self.isRotationEnabled = modalState.displayProperties?.isRotationEnabled ?? false
        }

        configureSubView()
        configureCloseButton()
    }

    func closeButtonTapped() {
        modalViewControllerDelegate?.modalViewControllerCloseButtonTapped(self)
    }

    public func addFriendlyObstructions(toMeasurementSession session: PBMOpenMeasurementSession) {
        session.addFriendlyObstruction(view, purpose: .modalViewControllerView)
        session.addFriendlyObstruction(closeButtonDecorator.button, purpose: .modalViewControllerClose)
    }

    // MARK: - Subview Configuration

    private func setupContentView() {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        self.contentView = contentView
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // Adds the current view to the contentView if
    // - the current view is not nil,
    // - the contentView is not nil,
    // - the current isn't already added to the modal somewhere
    func configureSubView() {
        guard let displayView = displayView else {
            Log.error("Attempted to display a nil view")
            return
        }

        guard let contentView else {
            Log.error("ContentView not yet set up by InterfaceBuilder. Nothing to add content to")
            return
        }

        guard !displayView.isDescendant(of: view) else {
            Log.error("currentDisplayView is already a child of self.view")
            return
        }

        contentView.addSubview(displayView)
        configureDisplayView()
    }

    func configureDisplayView() {
        guard let props = displayProperties else {
            displayView?.PBMAddFillSuperviewConstraints()
            return
        }
        
        guard !props.contentFrame.isInfinite else {
            displayView?.PBMAddFillSuperviewConstraints()
            return
        }

        contentView?.backgroundColor = props.contentViewColor
        displayView?.backgroundColor = .clear
        displayView?.PBMAddConstraintsFromCGRect(props.contentFrame)
    }

    // MARK: - Close Button Handling

    private func setupCloseButton() {
        closeButtonDecorator.button.isHidden = true
    }

    private func configureCloseButton() {
        if let webView = modalState?.view as? WebView_Protocol {
            closeButtonDecorator.isMRAID = webView.isMRAID
        }

        if let videoConfig = modalState?.adConfiguration?.videoControlsConfig {
            closeButtonDecorator.buttonArea = videoConfig.closeButtonArea
            closeButtonDecorator.buttonPosition = videoConfig.closeButtonPosition
        }
        if let closeImage = displayProperties?.getCloseButtonImage() {
            closeButtonDecorator.setImage(closeImage)
        }
        
        if let displayView {
            closeButtonDecorator.addButton(to: view, displayView: displayView)
        }

        setupCloseButtonVisibility()

        closeButtonDecorator.buttonTouchUpInsideBlock = { [weak self] in
            self?.closeButtonTapped()
        }
    }

    private func setupCloseButtonVisibility() {
        // Set the close button view visibilty based on th view context (i.e. normal, clickthrough browser, rewarded video)
        closeButtonDecorator.bringButtonToFront()

        if modalState?.adConfiguration?.isRewarded == true {
            return // must stay hidden
        } else if let displayProperties, displayProperties.closeDelay > 0 {
            if displayProperties.closeDelayLeft <= 0 {
                return
            }

            closeButtonDecorator.button.isHidden = true
            setupCloseButtonDelay()
        } else {
            closeButtonDecorator.button.isHidden = false
        }
    }

    func creativeDisplayCompleted(_ creative: AbstractCreative) {
        guard modalState?.adConfiguration?.isRewarded == true else { return }

        let rewardedConfig = creative.creativeModel.adConfiguration?.rewardedConfig
        let ortbAction = rewardedConfig?.closeAction ?? ""
        let action = CloseActionManager.getAction(from: ortbAction)
        switch action {
        case .closeButton:
            closeButtonDecorator.button.isHidden = false
        case .autoClose:
            modalViewControllerDelegate?.modalViewControllerCloseButtonTapped(self)
        case .unknown:
            // By default SDK should show close button
            closeButtonDecorator.button.isHidden = false
            Log.warn("SDK met unknown close action.")
        }
    }

    func setupCloseButtonDelay() {
        showCloseButtonBlock = { [weak self] in
            guard let self = self else { return }
            self.closeButtonDecorator.button.isHidden = false
            self.onCloseDelayInterrupted()
        }

        let startDelay = Date()
        self.startCloseDelay = startDelay

        let closeDelayLeft = displayProperties?.closeDelayLeft ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + closeDelayLeft) { [weak self] in
            guard let self = self else { return }
            
            // The current block could be called twice: once for the initial timer and once for the restored one.
            // So need to check the creation timestamp of the current block before execution.
            if let showCloseButtonBlock, self.startCloseDelay == startDelay {
                showCloseButtonBlock()
            }
        }
    }

    func onCloseDelayInterrupted() {
        if let start = startCloseDelay {
            let displayTime = Date().timeIntervalSince(start)
            if displayTime > 0 {
                displayProperties?.closeDelayLeft -= displayTime
            }
        }

        startCloseDelay = nil
        showCloseButtonBlock = nil
    }
}
