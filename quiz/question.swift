import Foundation

struct Question: Codable {
  let question: String  // énoncé
  let options: [String]  // réponses potentielles
  let answerIndex: Int   // index réponse
  let difficulty: Int    // difficulté
  let quote: String      // phrase en cas de réussite

  private enum CodingKeys: String, CodingKey {
      case question, options, answerIndex, difficulty, quote
  }
}

// Function to load JSON data from the questions.json file
func loadQuestions() -> [Question]? {
  if let jsonData = loadJsonData(fileName: "questions.json") {
      do {
          let decoder = JSONDecoder()
          let questions = try decoder.decode([Question].self, from: jsonData)
          return questions
      } catch {
          print("Error decoding JSON: \(error)")
          return nil
      }
  } else {
      return nil
  }
}

// Function to load JSON data from a file
func loadJsonData(fileName: String) -> Data? {
  let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
  let jsonFileURL = currentDirectoryURL.appendingPathComponent(fileName)
  do {
      let jsonData = try Data(contentsOf: jsonFileURL)
      return jsonData
  } catch {
      print("Error loading JSON file: \(error)")
      return nil
  }
}
