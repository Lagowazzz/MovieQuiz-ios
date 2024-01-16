import UIKit
final class AlertPresenter {
    
    func presentAlert(on viewController: UIViewController, with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.resultMessage,
            preferredStyle: .alert
        )
        alert.setValue("Alert", forKey: "accessibilityIdentifier")
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        alert.addAction(action)
        alert.setValue("Alert", forKey: "accessibilityIdentifier")
        viewController.present(alert, animated: true, completion: nil)
    }
}
