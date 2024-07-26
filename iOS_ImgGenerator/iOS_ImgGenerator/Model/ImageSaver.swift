import UIKit
import Combine
import Photos

class ImageSaver: NSObject, ObservableObject {
    private var isPermissionDenied = false

    @Published var isSaved: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    func writeToPhotoAlbum(image: UIImage) {
        checkPhotoPermission { [weak self] isDenied in
            DispatchQueue.main.async {
                if isDenied {
                    self?.isPermissionDenied = true
                    self?.alertMessage = "Please allow permissions in settings"
                    self?.showAlert = true
                } else {
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.saveCompleted), nil)
                }
            }
        }
    }

    @objc 
    func saveCompleted(image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async { [self] in
            if let error = error {
                NSLog("Failed to save image. Error = \(error.localizedDescription)")
                if isPermissionDenied {
                    alertMessage = "Failed to save photo"
                    showAlert = true
                }
            } else {
                isSaved = true
            }
        }
    }

    private func checkPhotoPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            completion(false)
        case .denied, .restricted:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                completion(newStatus == .denied)
            }
        @unknown default:
            completion(true)
        }
    }
}
