import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
    private var currentQuestion: QuizQuestion?

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else { return }
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: error)
                }
                return
            }
            let randomRating = Float(Int.random(in: 0...9)) * 0.1 + 8.0
            let rating = Float(movie.rating) ?? 0
            let questionText: String
            let correctAnswer: Bool
            
            if Bool.random() {
                questionText = "Рейтинг этого фильма больше чем \(randomRating)?"
                correctAnswer = rating >= randomRating
            } else {
                questionText = "Рейтинг этого фильма меньше чем \(randomRating)?"
                correctAnswer = rating <= randomRating
            }
            
            let question = QuizQuestion(image: imageData, text: questionText, correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
