import UIKit

protocol CameraV3Assembly: AnyObject {
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (CameraV3Module) -> (),
        cameraV3MeasureInitialization: (() -> ())?,
        cameraV3InitializationMeasurementStop: (() -> ())?,
        cameraV3drawingMeasurement: (() -> ())?
    ) -> UIViewController
}

protocol CameraV3AssemblyFactory: AnyObject {
    func cameraV3Assembly() -> CameraV3Assembly
}
