import UIKit

final class AlertPresenter {
    
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
        if let alertView = alert.view {
            alertView.accessibilityIdentifier = "Alert"
        }
        viewController.present(alert, animated: true, completion: nil)
    }
}
