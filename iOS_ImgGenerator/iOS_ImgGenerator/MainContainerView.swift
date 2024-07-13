
import SwiftUI

struct MainContainerView: View {
    @StateObject var imageGenerator = ImageGenerator()
    @State var selection = 0

    var body: some View {
        VStack {
            Text("Image Generator")

            Picker(selection: $selection, label: Text("test")) {
                Text("Text to Image").tag(0)
                Text("Image to Image").tag(1)
            }
            .pickerStyle(.segmented)

            switch selection {
            case 0:
                TextToImageView(imageGenerator: imageGenerator)
            case 1:
                ImageToImageView(imageGenerator: imageGenerator)
            default:
                TextToImageView(imageGenerator: imageGenerator)
            }
        }.padding()
    }
}

struct MainContainerView_PreView: PreviewProvider {
    static var previews: some View {
        MainContainerView()
    }
}
