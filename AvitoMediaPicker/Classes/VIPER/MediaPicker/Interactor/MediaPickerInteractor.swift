protocol MediaPickerInteractor: class {
    
    func addItems(_: [MediaPickerItem], completion: (canAddItems: Bool) -> ())
    func updateItem(_: MediaPickerItem, completion: () -> ())
    // `completion` вызывается с соседним item'ом — это item, который нужно выделить после того, как удалили `item`
    func removeItem(_: MediaPickerItem, completion: (adjacentItem: MediaPickerItem?, canAddItems: Bool) -> ())
    
    func items(completion: [MediaPickerItem] -> ())
    
    func indexOfItem(_: MediaPickerItem, completion: Int? -> ())
    
    func numberOfItemsAvailableForAdding(completion: Int? -> ())
    
    func observeDeviceOrientation(handler: (DeviceOrientation -> ())?)
    func observeLatestPhotoLibraryItem(handler: (ImageSource? -> ())?)
}