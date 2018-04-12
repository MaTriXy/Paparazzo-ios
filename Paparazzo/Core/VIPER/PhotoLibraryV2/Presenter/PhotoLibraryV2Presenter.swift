import Foundation

final class PhotoLibraryV2Presenter: PhotoLibraryV2Module {
    
    // MARK: - Dependencies
    
    private let interactor: PhotoLibraryV2Interactor
    private let router: PhotoLibraryV2Router
    private let overridenTheme: PaparazzoUITheme
    
    weak var view: PhotoLibraryV2ViewInput? {
        didSet {
            view?.onViewDidLoad = { [weak self] in
                self?.setUpView()
            }
        }
    }
    
    // MARK: - State
    var shouldScrollToTopOnFullReload = true
    
    // MARK: - Init
    
    init(
        interactor: PhotoLibraryV2Interactor,
        router: PhotoLibraryV2Router,
        overridenTheme: PaparazzoUITheme)
    {
        self.interactor = interactor
        self.router = router
        self.overridenTheme = overridenTheme
    }
    
    // MARK: - PhotoLibraryModule
    
    var onFinish: ((PhotoLibraryV2ModuleResult) -> ())?
    
    func dismissModule() {
        router.dismissCurrentModule()
    }
    
    func setContinueButtonTitle(_ title: String) {
        continueButtonTitle = title
        view?.setContinueButtonTitle(title)
    }
    
    // MARK: - Private
    private var continueButtonTitle: String?
    
    private func setUpView() {
        
        view?.setContinueButtonTitle(continueButtonTitle ?? localized("Continue"))
        
        view?.setTitleVisible(false)
        
        view?.setPlaceholderState(.hidden)
        
        view?.setAccessDeniedTitle(localized("To pick photo from library"))
        view?.setAccessDeniedMessage(localized("Allow %@ to access your photo library", appName()))
        view?.setAccessDeniedButtonTitle(localized("Allow access to photo library"))
        
        view?.setProgressVisible(true)
        
        interactor.observeAuthorizationStatus { [weak self] accessGranted in
            self?.view?.setAccessDeniedViewVisible(!accessGranted)
            
            if !accessGranted {
                self?.view?.setProgressVisible(false)
            }
        }
        
        interactor.observeAlbums { [weak self] albums in
            guard let strongSelf = self else { return }
            
            // We're showing only non-empty albums
            let albums = albums.filter { $0.numberOfItems > 0 }
            
            self?.view?.setAlbums(albums.map(strongSelf.albumCellData))
            
            if let currentAlbum = strongSelf.interactor.currentAlbum, albums.contains(currentAlbum) {
                self?.adjustView(for: currentAlbum)  // title might have been changed
            } else if let album = albums.first {
                self?.selectAlbum(album)
            } else {
                self?.view?.setTitleVisible(false)
                self?.view?.setPlaceholderState(.visible(title: localized("No photos")))
                self?.view?.setProgressVisible(false)
            }
        }
        
        interactor.observeCurrentAlbumEvents { [weak self] event, selectionState in
            guard let strongSelf = self else { return }
            
            var needToShowPlaceholder: Bool
            
            switch event {
            case .fullReload(let items):
                needToShowPlaceholder = items.isEmpty
                self?.view?.setItems(
                    items.reversed().map(strongSelf.cellData),
                    scrollToTop: strongSelf.shouldScrollToTopOnFullReload,
                    completion: {
                        self?.shouldScrollToTopOnFullReload = false
                        self?.adjustViewForSelectionState(selectionState)
                        self?.view?.setProgressVisible(false)
                    }
                )
                
            case .incrementalChanges(let changes):
                needToShowPlaceholder = changes.itemsAfterChanges.isEmpty
                self?.view?.applyChanges(strongSelf.viewChanges(from: changes), completion: {
                    self?.adjustViewForSelectionState(selectionState)
                })
            }
            
            self?.view?.setPlaceholderState(
                needToShowPlaceholder ? .visible(title: localized("Album is empty")) : .hidden
            )
        }
        
        view?.onContinueButtonTap = { [weak self] in
            if let strongSelf = self {
                guard let strongSelf = self else { return }
                let selectedItems = strongSelf.interactor.selectedItems
                guard selectedItems.isEmpty == false else {
                    self?.onFinish?(.selectedItems([]))
                    return
                }
                
                let data = strongSelf.interactor.mediaPickerData.bySettingPhotoLibraryItems(
                    selectedItems
                )
                self?.router.showMediaPicker(
                    data: data,
                    overridenTheme: strongSelf.overridenTheme,
                    configure: { module in
                        weak var weakModule = module
                        module.onCancel = {
                            weakModule?.dismissModule()
                        }
                        
                        module.onFinish = { result in
                            weakModule?.dismissModule()
                            self?.onFinish?(.selectedItems(result))
                        }
                })
            }
        }
        
        view?.onCloseButtonTap = { [weak self] in
            self?.onFinish?(.cancelled)
        }
        
        view?.onAccessDeniedButtonTap = {
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        
        view?.onTitleTap = { [weak self] in
            self?.view?.toggleAlbumsList()
        }
        
        view?.onDimViewTap = { [weak self] in
            self?.view?.hideAlbumsList()
        }
        
        cameraViewData { [weak self] viewData in
            self?.view?.setCameraViewData(viewData)
        }
    }
    
    private func appName() -> String {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
    }
    
    private func adjustViewForSelectionState(_ state: PhotoLibraryItemSelectionState) {
        view?.setDimsUnselectedItems(!state.canSelectMoreItems)
        view?.setCanSelectMoreItems(state.canSelectMoreItems)
        
        switch state.preSelectionAction {
        case .none:
            break
        case .deselectAll:
            view?.deselectAllItems()
        }
    }
    
    private func albumCellData(for album: PhotoLibraryAlbum) -> PhotoLibraryAlbumCellData {
        return PhotoLibraryAlbumCellData(
            identifier: album.identifier,
            title: album.title ?? localized("Unnamed album"),
            coverImage: album.coverImage,
            onSelect: { [weak self] in
                self?.selectAlbum(album)
                self?.view?.hideAlbumsList()
            }
        )
    }
    
    private func selectAlbum(_ album: PhotoLibraryAlbum) {
        shouldScrollToTopOnFullReload = true
        interactor.setCurrentAlbum(album)
        adjustView(for: album)
    }
    
    private func adjustView(for album: PhotoLibraryAlbum) {
        view?.setTitle(album.title ?? localized("Unnamed album"))
        view?.setTitleVisible(true)
        view?.selectAlbum(withId: album.identifier)
    }
    
    private func cellData(_ item: PhotoLibraryItem) -> PhotoLibraryItemCellData {
        
        var cellData = PhotoLibraryItemCellData(image: item.image)

        cellData.selected = interactor.isSelected(item)
        
        cellData.onSelectionPrepare = { [weak self] in
            if let selectionState = self?.interactor.prepareSelection() {
                self?.adjustViewForSelectionState(selectionState)
            }
        }
        
        cellData.onSelect = { [weak self] in
            if let selectionState = self?.interactor.selectItem(item) {
                self?.adjustViewForSelectionState(selectionState)
            }
            
            self?.view?.setHeaderVisible(false)
        }
        
        cellData.onDeselect = { [weak self] in
            if let selectionState = self?.interactor.deselectItem(item) {
                self?.adjustViewForSelectionState(selectionState)
            }
            let hasNoItems = self?.interactor.selectedItems.isEmpty == true
            self?.view?.setHeaderVisible(hasNoItems)
        }
        
        return cellData
    }
    
    private func cameraViewData(completion: @escaping (_ viewData: PhotoLibraryCameraViewData?) -> ()) {
        interactor.getOutputParameters { parameters in
            let viewData = PhotoLibraryCameraViewData(
                parameters: parameters,
                onTap: { [weak self] in
                    guard let strongSelf = self else { return }
                    self?.router.showMediaPicker(
                        data: strongSelf.interactor.mediaPickerData.byDisablingLibrary(),
                        overridenTheme: strongSelf.overridenTheme,
                        configure: { module in
                            weak var weakModule = module
                            module.onCancel = {
                                weakModule?.dismissModule()
                            }
                            
                            module.onFinish = { result in
                                weakModule?.dismissModule()
                                self?.onFinish?(.selectedItems(result))
                            }
                    })
                }
            )
            
            completion(viewData)
        }
    }
    
    private func viewChanges(from changes: PhotoLibraryChanges) -> PhotoLibraryViewChanges {
        return PhotoLibraryViewChanges(
            removedIndexes: changes.removedIndexes,
            insertedItems: changes.insertedItems.map { (index: $0, cellData: cellData($1)) },
            updatedItems: changes.updatedItems.map { (index: $0, cellData: cellData($1)) },
            movedIndexes: changes.movedIndexes
        )
    }
}

extension MediaPickerData {
    func bySettingPhotoLibraryItems(_ items: [PhotoLibraryItem]) -> MediaPickerData {
        let mediaPickerItems = items.map {
            MediaPickerItem(
                image: $0.image,
                source: .photoLibrary
            )
        }
        return MediaPickerData(
            items: mediaPickerItems,
            autocorrectionFilters: autocorrectionFilters,
            selectedItem: mediaPickerItems.first ?? selectedItem,
            maxItemsCount: maxItemsCount,
            cropEnabled: cropEnabled,
            autocorrectEnabled: autocorrectEnabled,
            hapticFeedbackEnabled: hapticFeedbackEnabled,
            cropCanvasSize: cropCanvasSize,
            initialActiveCameraType: initialActiveCameraType,
            cameraEnabled: false,
            photoLibraryEnabled: false
        )
    }
    
    func byDisablingLibrary() -> MediaPickerData {
        return MediaPickerData(
            items: items,
            autocorrectionFilters: autocorrectionFilters,
            selectedItem: selectedItem,
            maxItemsCount: maxItemsCount,
            cropEnabled: cropEnabled,
            autocorrectEnabled: autocorrectEnabled,
            hapticFeedbackEnabled: hapticFeedbackEnabled,
            cropCanvasSize: cropCanvasSize,
            initialActiveCameraType: initialActiveCameraType,
            cameraEnabled: cameraEnabled,
            photoLibraryEnabled: false
        )
    }
}
