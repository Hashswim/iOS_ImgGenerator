
import SwiftUI

struct PromptView: View {
    @Binding var parameter: ImageGenerator.GenerationParameter
    @State var hint: Bool = true

    var body: some View {
        VStack(spacing: 8) {
            HStack { Text("Prompt"); Spacer() }
            TextField("Prompt:", text: $parameter.prompt,prompt: Text("Enter what you want to draw").foregroundColor(.blue),  axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(1...30)

            HStack {
                Text("Negative Prompt")
                Spacer()
            }
            TextField("Prompt:", text: $parameter.negativePrompt, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...30)

            if parameter.mode == .imageToImage {
                HStack { 
                    Text("Strength: \(parameter.strength, specifier: "%.1f")"); Spacer() }
                Slider(
                    value: $parameter.strength,
                    in: 0.0...0.9,
                    step: 0.1
                )
            }
        }
        .padding()
    }
}

struct PromptView_Previews: PreviewProvider {
    @State static var param = ImageGenerator.GenerationParameter(mode: .imageToImage,
                                                          prompt: "a prompt",
                                                          negativePrompt: "a negative prompt",
                                                          guidanceScale: 0.5,
                                                          seed: 1_000,
                                                          stepCount: 20,
                                                          imageCount: 1,
                                                          disableSafety: false,
                                                          strength: 0.5)
    static var previews: some View {
        PromptView(parameter: $param)
    }
}
