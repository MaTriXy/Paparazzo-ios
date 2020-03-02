import UIKit

final class ExampleView: UIView {
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    private let mediaPickerButton = UIButton()
    private let maskCropperButton = UIButton()
    private let photoLibraryButton = UIButton()
    private let photoLibraryV2Button = UIButton()
    private let photoLibraryV2NewFlowButton = UIButton()
    private let scannerButton = UIButton()
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        
        mediaPickerButton.setTitle("Show Media Picker", for: .normal)
        mediaPickerButton.addTarget(
            self,
            action: #selector(onShowMediaPickerButtonTap(_:)),
            for: .touchUpInside
        )
        
        maskCropperButton.setTitle("Show Mask Cropper", for: .normal)
        maskCropperButton.addTarget(
            self,
            action: #selector(onMaskCropperButtonTap(_:)),
            for: .touchUpInside
        )
        
        photoLibraryButton.setTitle("Show Photo Library", for: .normal)
        photoLibraryButton.addTarget(
            self,
            action: #selector(onShowPhotoLibraryButtonTap(_:)),
            for: .touchUpInside
        )
        
        photoLibraryV2Button.setTitle("Show Photo Library V2", for: .normal)
        photoLibraryV2Button.addTarget(
            self,
            action: #selector(onShowPhotoLibraryV2ButtonTap(_:)),
            for: .touchUpInside
        )
        
        photoLibraryV2NewFlowButton.setTitle("Show Photo Library V2 New Flow", for: .normal)
        photoLibraryV2NewFlowButton.addTarget(
            self,
            action: #selector(onShowPhotoLibraryV2NewFlowButtonTap(_:)),
            for: .touchUpInside
        )
        
        scannerButton.setTitle("Show Scanner", for: .normal)
        scannerButton.addTarget(
            self,
            action: #selector(onShowScannerButtonTap(_:)),
            for: .touchUpInside
        )
        
        stackView.addArrangedSubview(mediaPickerButton)
        stackView.addArrangedSubview(maskCropperButton)
        stackView.addArrangedSubview(photoLibraryButton)
        stackView.addArrangedSubview(photoLibraryV2Button)
        stackView.addArrangedSubview(photoLibraryV2NewFlowButton)
        stackView.addArrangedSubview(scannerButton)
        
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ExampleView
    
    func setMediaPickerButtonTitle(_ title: String) {
        mediaPickerButton.setTitle(title, for: .normal)
    }
    
    func setMaskCropperButtonTitle(_ title: String) {
        maskCropperButton.setTitle(title, for: .normal)
    }
    
    func setPhotoLibraryButtonTitle(_ title: String) {
        photoLibraryButton.setTitle(title, for: .normal)
    }
    
    func setPhotoLibraryV2ButtonTitle(_ title: String) {
        photoLibraryV2Button.setTitle(title, for: .normal)
    }
    
    func setScannerButtonTitle(_ title: String) {
        scannerButton.setTitle(title, for: .normal)
    }
    
    var onShowMediaPickerButtonTap: (() -> ())?
    var onShowMaskCropperButtonTap: (() -> ())?
    var onShowPhotoLibraryButtonTap: (() -> ())?
    var onShowPhotoLibraryV2ButtonTap: (() -> ())?
    var onShowPhotoLibraryV2NewFlowButtonTap: (() -> ())?
    var onShowScannerButtonTap: (() -> ())?
    
    // MARK: - Private
    
    @objc private func onShowMediaPickerButtonTap(_: UIButton) {
        onShowMediaPickerButtonTap?()
    }
    
    @objc private func onMaskCropperButtonTap(_: UIButton) {
        onShowMaskCropperButtonTap?()
    }
    
    @objc private func onShowPhotoLibraryButtonTap(_: UIButton) {
        onShowPhotoLibraryButtonTap?()
    }
    
    @objc private func onShowPhotoLibraryV2ButtonTap(_: UIButton) {
        onShowPhotoLibraryV2ButtonTap?()
    }
    
    @objc private func onShowPhotoLibraryV2NewFlowButtonTap(_: UIButton) {
        onShowPhotoLibraryV2NewFlowButtonTap?()
    }
    
    @objc private func onShowScannerButtonTap(_: UIButton) {
        onShowScannerButtonTap?()
    }
}
