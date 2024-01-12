import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private weak var questionLabel: UILabel!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let presenter  = MovieQuizPresenter()
    
    private var correctAnswers = 0
    
    private var questionFactory: QuestionFactoryProtocol?

    private var alertPresenter = AlertPresenter()
    
    private var statisticService: StatisticService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(networkClient: NetworkClient()), delegate: self)
        statisticService = StatisticServiceImplementation()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        let model = AlertModel(title: "Ошибка",
                               resultMessage: "Ошибка загрузки данных((( \n Попробуйте еще раз!",
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            questionFactory?.loadData()
            self.questionFactory?.requestNextQuestion()
        }
        alertPresenter.presentAlert(on: self, with: model)
    }
    
    private func setButtonsStatus(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    
    
  func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        questionLabel.text = step.question
        imageView.image = step.image
    }
    
    private func resetImageBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
    }
    
    func showAnswerResult(isCorrect: Bool) {
        setButtonsStatus(isEnabled: false)
        if isCorrect == false {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        } else {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }
            setButtonsStatus(isEnabled: true)
            resetImageBorder()
            self.showNextQuestionOrResults()
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.startAnimating()
        questionFactory?.requestNextQuestion()
        activityIndicator.stopAnimating()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    private func resetGame() {
        presenter.resetQuestionIndex()
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            statisticService?.gamesCount += 1
            let resultText = "Ваш результат: \(correctAnswers)/10"
            let totalGamesText = "Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)"
            let bestGameText: String
            if statisticService?.bestGame.correct ?? 0 > 0 {
                let formattedDate = dateTimeDefaultFormatter.string(from: statisticService?.bestGame.date ?? Date())
                bestGameText = "Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(formattedDate))"
            } else {
                bestGameText = "Рекорд: Еще нет данных"
            }
            let averageAccuracyText = String(format: "Средняя точность: %.2f%%", (statisticService?.totalAccuracy ?? 0.0) * 100)
            let message = """
            \(resultText)
            \(totalGamesText)
            \(bestGameText)
            \(averageAccuracyText)
            """
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть ещё раз")
            alertPresenter.presentAlert(on: self, with: AlertModel(
                title: viewModel.title,
                resultMessage: viewModel.text,
                buttonText: viewModel.buttonText) { [weak self] in
                    self?.resetGame()
                })
        } else {
            activityIndicator.startAnimating()
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            activityIndicator.stopAnimating()
        }
    }
}
