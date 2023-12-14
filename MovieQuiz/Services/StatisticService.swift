
import Foundation

protocol StatisticService {
    
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get set }
    func store(correct count: Int, total amount: Int)
    
}

struct GameRecord: Codable {
    
    let correct: Int
    let total: Int
    var date: Date
    
    func isBetterThan(_ another: GameRecord) -> Bool {
        
        correct > another.correct
        
    }
    
}

final class StatisticServiceImplementation: StatisticService {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        
        case correct, total, bestGame, gamesCount
        
    }
    
    func store(correct count: Int, total amount: Int) {
        
        let currentDate = Date()
        let newRecord = GameRecord(correct: count, total: amount, date: currentDate)
        
        if count > bestGame.correct {
            bestGame = newRecord
        } else if count == bestGame.correct {
            bestGame.date = currentDate
        }
        
        let formattedDate = dateTimeDefaultFormatter.string(from: currentDate)
        let totalCorrect = bestGame.correct + count
        let totalTotal = bestGame.total + amount
        totalAccuracy = totalTotal > 0 ? Double(totalCorrect) / Double(totalTotal) : 0.0
    }
    
    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
}
