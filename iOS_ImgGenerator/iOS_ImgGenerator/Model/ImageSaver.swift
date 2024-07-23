
import UIKit
import Combine

class ImageSaver: NSObject, ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    var isSaved : Bool = false {
        willSet {
            self.objectWillChange.send()
        }
    }

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        isSaved = true
    }
}
