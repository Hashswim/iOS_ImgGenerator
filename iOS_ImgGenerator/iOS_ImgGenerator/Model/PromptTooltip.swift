
import SwiftUI
import TipKit

enum PromptTooltip: Tip {
    case prompt(title: String, message: String)
    case negativePrompt(title: String, message: String)
    case strength(title: String, message: String)

    @Parameter static var show: Bool = false

    var title: Text {
        switch self {
        case .prompt(let title, _):
            Text(title)
        case .negativePrompt(let title, _):
            Text(title)
        case .strength(let title, _):
            Text(title)
        }
    }

    var message: Text? {
        switch self {
        case .prompt(_, let message):
            Text(message)
        case .negativePrompt(_, let message):
            Text(message)
        case .strength(_, let message):
            Text(message)
        }
    }

    var rules: [Rule] {
        [
            #Rule(Self.$show) {
                $0 == true
            }
        ]
    }
}
