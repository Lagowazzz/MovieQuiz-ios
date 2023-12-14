import UIKit

class AlertPresenter {
    
    func presentAlert(on viewController: UIViewController, with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.resultMessage,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
            
        }
        
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
        
    }
    
}
