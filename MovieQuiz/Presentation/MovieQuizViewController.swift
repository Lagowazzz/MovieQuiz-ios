import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var noButton: UIButton!
    
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    private struct QuizQuestion {
        
        let image: String
        let text: String
        let correctAnswer: Bool
        
    }
    
    private var questions: [QuizQuestion] = [
        
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
        
    ]
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    private struct QuizStepViewModel {
        
        let image: UIImage
        let question: String
        let questionNumber: String
        
    }
    
    private struct QuizResultsViewModel {
        
        let title: String
        let text: String
        let buttonText: String
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let quizStepViewModel = convert(model:(questions[currentQuestionIndex]))
        show(quiz: quizStepViewModel)
        
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
        
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
        
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        
        let image = UIImage(named: model.image) ?? UIImage()
        let question = model.text
        let questionNumber = "\(currentQuestionIndex + 1)/\(questions.count)"
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
        
        if currentQuestionIndex == questions.count - 1 {
            
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
            setButtonsStatus(isEnabled: true)
            
        } else {
            
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            setButtonsStatus(isEnabled: true)
            show(quiz: viewModel)
            
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
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
            
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
