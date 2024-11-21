import Marshroute
import UIKit

protocol CameraV3MarshrouteAssembly: AnyObject {
    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        routerSeed: RouterSeed,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (CameraV3Module) -> (),
        cameraV3MeasureInitialization: (() -> ())?,
        cameraV3InitializationMeasurementStop: (() -> ())?,
        cameraV3DrawingMeasurement: (() -> ())?
    ) -> UIViewController
}

protocol CameraV3MarshrouteAssemblyFactory: AnyObject {
    func cameraV3Assembly() -> CameraV3MarshrouteAssembly
}

final class CameraV3MarshrouteAssemblyImpl:
    BasePaparazzoAssembly,
    CameraV3MarshrouteAssembly
{
    typealias AssemblyFactory = MediaPickerMarshrouteAssemblyFactory
    
    private let assemblyFactory: AssemblyFactory
    
    init(assemblyFactory: AssemblyFactory, theme: PaparazzoUITheme, serviceFactory: ServiceFactory) {
        self.assemblyFactory = assemblyFactory
        super.init(theme: theme, serviceFactory: serviceFactory)
    }

    func module(
        selectedImagesStorage: SelectedImageStorage,
        mediaPickerData: MediaPickerData,
        cameraService: CameraService,
        routerSeed: RouterSeed,
        isPresentingPhotosFromCameraFixEnabled: Bool,
        configure: (CameraV3Module) -> (),
        cameraV3MeasureInitialization: (() -> ())?,
        cameraV3InitializationMeasurementStop: (() -> ())?,
        cameraV3DrawingMeasurement: (() -> ())?
    ) -> UIViewController {
        measureScreenInitialization?()
        defer { initializationMeasurementStop?() }
        
        let interactor = CameraV3InteractorImpl(
            mediaPickerData: mediaPickerData,
            selectedImagesStorage: selectedImagesStorage,
            cameraService: cameraService
        )
        
        let router = CameraV3MarshrouteRouter(
            assemblyFactory: assemblyFactory,
            routerSeed: routerSeed
        )
        
        let viewController = CameraV3ViewController(
            deviceOrientationService: serviceFactory.deviceOrientationService()
        )
        
        let presenter = CameraV3Presenter(
            interactor: interactor,
            volumeService: serviceFactory.volumeService(),
            router: router,
            isPresentingPhotosFromCameraFixEnabled: isPresentingPhotosFromCameraFixEnabled,
            drawingMeasurement: drawingMeasurement
        )
        
        viewController.setTheme(theme)
        viewController.addDisposable(presenter)
        
        presenter.view = viewController
        
        configure(presenter)
        
        return viewController
    }
}
