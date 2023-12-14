import Foundation

struct AlertModel {
    
    let title: String
    let resultMessage: String
    let buttonText: String
    let completion: (() -> Void)?
    
}
