protocol NewCameraRouter: AnyObject {
    func focusOnCurrentModule()
    
    func showMediaPicker(
        isPresentingPhotosFromCameraFixEnabled: Bool,
        isPhotoFetchingByPageEnabled: Bool,
        data: MediaPickerData,
        overridenTheme: PaparazzoUITheme?,
        configure: (MediaPickerModule) -> ())
}
