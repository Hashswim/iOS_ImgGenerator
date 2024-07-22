
import SwiftUI

struct MainContainerView: View {
    @StateObject var imageGenerator = ImageGenerator()
    @State var selection = 0

    var body: some View {
        VStack {
            HStack {
                Text("Image Generator")
                    .font(.title)
                    .foregroundStyle(Color.white)
                Spacer()
            }.padding(.horizontal)

            Picker(selection: $selection, label: Text("test")) {
                Text("Text to Image").tag(0)
                Text("Image to Image").tag(1)
            }
            .pickerStyle(.segmented)
            .background(MySpecialColors.guideTextGray)
            .clipShape(RoundedRectangle(cornerRadius: 8.0))
            .padding(.horizontal)

            TabView(selection: $selection) {
                TextToImageView()
                    .tag(0)
                ImageToImageView()
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .environmentObject(imageGenerator)
//            .animation(.easeIn, value: selection)
        }
        .background(MySpecialColors.backgroundIndigo)
    }
}

struct MainContainerView_PreView: PreviewProvider {
    static var previews: some View {
        MainContainerView()
            .environmentObject(ImageGenerator())
    }
}
