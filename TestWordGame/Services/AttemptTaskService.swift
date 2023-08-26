//
//  AttemptTaskService.swift
//  TestWordGame
//
//  Created by Nikita Timonin on 26.08.2023.
//

import Foundation
import ComposableArchitecture
import UniformTypeIdentifiers

private enum Constants {
    static let wordsFileName = "words"
    static let correctnessProbability = 0.25
}

struct AttemptTaskService {
    var fetch: () -> [AttemptTask]
}

extension AttemptTaskService: DependencyKey {
    static let liveValue = Self {
        guard let data = readLocalFile(name: Constants.wordsFileName, type: .json) else { return [] }
        do {
            let rawPairs = try parse(data: data)
            return prepareTasks(wordPairs: rawPairs)
        } catch {
            logError(error)
            return []
        }
        
        func readLocalFile(name: String, type: UTType) -> Data? {
            guard let bundlePath = Bundle.main.path(
                forResource: name,
                ofType: type.preferredFilenameExtension)
            else { return nil }
            
            do {
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8)
                return jsonData
            } catch {
                logError(error)
            }
            
            return nil
        }
        
        
        func parse(data: Data) throws -> [WordPair] {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let data = try decoder.decode([WordPair].self, from: data)
            return data
        }
        
        func prepareTasks(wordPairs: [WordPair]) -> [AttemptTask] {
            let rightAnswersCount = Int(Double(wordPairs.count) * Constants.correctnessProbability)
            
            var attempts = [AttemptTask]()
            
            for (index, value) in wordPairs.shuffled().enumerated() {
                if index < rightAnswersCount {
                    attempts.append(
                        AttemptTask(
                            source: value.textEng,
                            translation: value.textSpa,
                            isCorrect: true)
                    )
                } else {
                    let prevValue = wordPairs[index - 1]
                    attempts.append(
                        AttemptTask(
                            source: value.textEng,
                            translation: prevValue.textSpa,
                            isCorrect: false)
                    )
                }
            }
            
            return attempts.shuffled()
        }
    }
}

extension DependencyValues {
    var attemptTaskService: AttemptTaskService {
        get { self[AttemptTaskService.self] }
        set { self[AttemptTaskService.self] = newValue }
    }
}
