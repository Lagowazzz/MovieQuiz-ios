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
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
    
    private func showNextQuestionOrResults() {
        
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
                    "Поздравляем, вы ответили на 10 из 10!" :
                    "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            setButtonsStatus(isEnabled: true)
            
        } else {
            
            currentQuestionIndex += 1
     questionFactory?.requestNextQuestion()
                setButtonsStatus(isEnabled: true)
      
     
            
        }
        
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            
            guard let self = self else {
                
                return
                
            }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
            
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
