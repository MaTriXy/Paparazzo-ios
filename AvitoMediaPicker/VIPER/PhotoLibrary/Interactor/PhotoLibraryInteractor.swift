import Foundation

protocol PhotoLibraryInteractor: class {
    
    func observeItems(handler: (items: [PhotoLibraryItem], selectionState: PhotoLibraryItemSelectionState) -> ())
    
    func selectItem(item: PhotoLibraryItem, completion: PhotoLibraryItemSelectionState -> ())
    func deselectItem(item: PhotoLibraryItem, completion: PhotoLibraryItemSelectionState -> ())
    func selectedItems(completion: (items: [PhotoLibraryItem], canSelectMoreItems: Bool) -> ())
}

public struct PhotoLibraryItem: Equatable {
    var identifier: String
    var image: LazyImage
    var selected: Bool
}

public func ==(item1: PhotoLibraryItem, item2: PhotoLibraryItem) -> Bool {
    return item1.identifier == item2.identifier
}

public struct PhotoLibraryItemSelectionState {
    var isAnyItemSelected: Bool
    var canSelectMoreItems: Bool
}