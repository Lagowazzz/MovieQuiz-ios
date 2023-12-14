import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter = AlertPresenter()
    
    private var statisticService: StatisticServiceImplementation = StatisticServiceImplementation()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        guard let question = question else {
            
            return
            
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            
        }
        
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        
        answerGived(answer: false)
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        
        answerGived(answer: true)
        
    }
    
    private func setButtonsStatus(isEnabled: Bool) {
        
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
        
    }
    
    private func answerGived(answer: Bool) {
        
        guard let currentQuestion = currentQuestion else {
            
            return
            
        }
        
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
        
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let image = UIImage(named: model.image) ?? UIImage()
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questionsAmount)"
        return QuizStepViewModel(image: image, question: question, questionNumber: questionNumber)
        
    }
    
    private func show(quiz step: QuizStepViewModel) {
        
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.image = step.image
        
    }
    
    private func resetImageBorder() {
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        
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
    
    private func resetGame() {
        
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
        
    }
    
    private func showNextQuestionOrResults() {
        
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let resultText = "Ваш результат: \(correctAnswers)/10"
            let totalGamesText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let bestGameText: String
            if statisticService.bestGame.correct > 0 {
                let formattedDate = dateTimeDefaultFormatter.string(from: statisticService.bestGame.date)
                bestGameText = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(formattedDate))"
            } else {
                bestGameText = "Рекорд: Еще нет данных"
            }
            let averageAccuracyText = String(format: "Средняя точность: %.2f%%", statisticService.totalAccuracy * 100)
            
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
            
            setButtonsStatus(isEnabled: true)
            statisticService.gamesCount += 1
            
        } else {
            
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            setButtonsStatus(isEnabled: true)
            
        }
        
    }
    
}
