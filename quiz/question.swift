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

// fonction pour charger les questions
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

// fonction pour charger des données depuis un json
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


func modifyQuestions() {
    print("Éditeur de banque de questions:")
    print("Quel niveau de difficulté souhaitez-vous modifier ? (1: Facile, 2: Moyen, 3: Difficile): ", terminator: "")

    var difficulty = -1
    while difficulty == -1 {
        guard let difficultyInput = readLine(), let chosenDifficulty = Int(difficultyInput), chosenDifficulty >= 1 && chosenDifficulty <= 3 else {
            print("Niveau de difficulté invalide. Veuillez entrer un nombre entre 1 et 3.")
            continue
        }
        difficulty = chosenDifficulty
    }

    print("Que souhaitez-vous faire ?\n")
    print("1. Supprimer une question")
    print("2. Ajouter une question")
  print("3. Modifier une question\n")
    print("Votre choix: ", terminator: "")

    var choice = -1
    while choice == -1 {
        guard let choiceInput = readLine(), let chosenChoice = Int(choiceInput), chosenChoice == 1 || chosenChoice == 2 || chosenChoice == 3 else {
            print("Choix invalide. Veuillez entrer 1 ou 2.")
            continue
        }
        choice = chosenChoice
    }

    guard var loadedQuestions = loadQuestions() else {
        print("Impossible de charger les questions.")
        return
    }

    switch choice {
    case 1:
        print("Voici les questions actuelles pour le niveau de difficulté \(difficulty):")
        let filteredQuestions = loadedQuestions.filter { $0.difficulty == difficulty }
        for (index, question) in filteredQuestions.enumerated() {
            print("\(index + 1). \(question.question)")
        }

        var deleteIndex = -1
        while deleteIndex == -1 {
            print("Entrez le numéro de la question que vous souhaitez supprimer : ", terminator: "")
            guard let deleteIndexInput = readLine(), let chosenIndex = Int(deleteIndexInput), chosenIndex >= 1 && chosenIndex <= filteredQuestions.count else {
                print("Numéro de question invalide. Veuillez entrer un numéro valide.")
                continue
            }
            deleteIndex = chosenIndex
        }

        let deletedQuestion = filteredQuestions[deleteIndex - 1]
        print("Question supprimée: \(deletedQuestion.question)")

        loadedQuestions.removeAll { $0.question == deletedQuestion.question }

        do {
            try saveQuestions(questions: loadedQuestions)
            print("Question supprimée avec succès.  \n\n")
        } catch {
            print("Erreur lors de la sauvegarde des questions: \(error.localizedDescription)")
        }



      

    case 2:
        print("Ajout d'une nouvelle question:")
        print("Entrez l'énoncé de la question: ", terminator: "")
        guard let newQuestion = readLine(), !newQuestion.isEmpty else {
            print("Énoncé de la question invalide.")
            return
        }

        var responses = [String]()
        for i in 1...4 {
            var response = ""
            while response.isEmpty {
                print("Entrez la réponse \(i): ", terminator: "")
                response = readLine() ?? ""
                if response.isEmpty {
                    print("Réponse invalide. Veuillez entrer une réponse valide.")
                }
            }
            responses.append(response)
        }

        var answerIndex = -1
        while answerIndex == -1 {
            print("Entrez l'index de la réponse correcte (1-4) : ", terminator: "")
            guard let answerIndexInput = readLine(), let index = Int(answerIndexInput), index >= 1 && index <= 4 else {
                print("Index de réponse invalide. Veuillez entrer un index valide.")
                continue
            }
            answerIndex = index
        }

        var quote = ""
        while quote.isEmpty {
            print("Entrez la quote de la question (1-10) : ", terminator: "")
            quote = readLine() ?? ""
            if quote.isEmpty {
                print("Quote de la question invalide. Veuillez entrer une quote valide.")
            }
        }

        let newQuestionObject = Question(question: newQuestion, options: responses, answerIndex: answerIndex - 1, difficulty: difficulty, quote: quote)
        loadedQuestions.append(newQuestionObject)

        do {
            try saveQuestions(questions: loadedQuestions)
            print("Question ajoutée avec succès.  \n\n")
        } catch {
            print("Erreur lors de la sauvegarde des questions: \(error.localizedDescription)")
        }



      
         case 3:
        print("Modification d'une question:\n")
        print("Voici les questions actuelles pour le niveau de difficulté \(difficulty):\n\n")
        let filteredQuestions = loadedQuestions.filter { $0.difficulty == difficulty }
        for (index, question) in filteredQuestions.enumerated() {
            print("\(index + 1). \(question.question)")
        }

        var modifyIndex = -1
        while modifyIndex == -1 {
            print("\nEntrez le numéro de la question que vous souhaitez modifier : ", terminator: "")
            guard let modifyIndexInput = readLine(), let chosenIndex = Int(modifyIndexInput), chosenIndex >= 1 && chosenIndex <= filteredQuestions.count else {
                print("Numéro de question invalide. Veuillez entrer un numéro valide.")
                continue
            }
            modifyIndex = chosenIndex
        }

        let selectedQuestion = filteredQuestions[modifyIndex - 1]

        print("\nQue souhaitez-vous modifier ?\n")
        print("1. Énoncé de la question")
        print("2. Réponses")
        print("Votre choix: ", terminator: "")

        var modificationChoice = -1
        while modificationChoice == -1 {
            guard let modificationChoiceInput = readLine(), let chosenModificationChoice = Int(modificationChoiceInput), chosenModificationChoice >= 1 && chosenModificationChoice <= 2 else {
                print("Choix invalide. Veuillez entrer 1, 2 ou 3.")
                continue
            }
            modificationChoice = chosenModificationChoice
        }

        switch modificationChoice {
          case 1:
              print("Ancien énoncé de la question: \(selectedQuestion.question)")
              print("Entrez le nouvel énoncé de la question: ", terminator: "")
              guard let newQuestion = readLine(), !newQuestion.isEmpty else {
                  print("Énoncé de la question invalide.")
                  return
              }
              loadedQuestions[loadedQuestions.firstIndex(where: { $0.question == selectedQuestion.question })!].question = newQuestion




          
          case 2:
          print("Anciennes réponses:")
          for (index, response) in selectedQuestion.options.enumerated() {
              print("\(index + 1). \(response)")
          }

          var newResponses = [String]()
          for i in 1...4 {
              var response = ""
              while response.isEmpty {
                  print("Entrez la nouvelle réponse \(i): ", terminator: "")
                  response = readLine() ?? ""
                  if response.isEmpty {
                      print("Réponse invalide. Veuillez entrer une réponse valide.")
                  }
              }
              newResponses.append(response)
          }

          var answerIndex = selectedQuestion.answerIndex + 1
          print("L'index de la réponse correcte est actuellement \(answerIndex). Souhaitez-vous le modifier ? (Oui/Non): ", terminator: "")
          guard let modifyAnswerIndex = readLine()?.lowercased(), modifyAnswerIndex == "oui" || modifyAnswerIndex == "non" else {
              print("Réponse invalide. Veuillez entrer Oui ou Non.")
              return
          }

          if modifyAnswerIndex == "oui" {
              var newIndex = -1
              while newIndex == -1 {
                  print("Entrez le nouvel index de la réponse correcte (1-4) : ", terminator: "")
                  guard let newIndexInput = readLine(), let index = Int(newIndexInput), index >= 1 && index <= 4 else {
                      print("Index de réponse invalide. Veuillez entrer un index valide.")
                      continue
                  }
                  newIndex = index
              }
              answerIndex = newIndex
          }

          loadedQuestions[loadedQuestions.firstIndex(where: { $0.question == selectedQuestion.question })!].options = newResponses
          loadedQuestions[loadedQuestions.firstIndex(where: { $0.question == selectedQuestion.question })!].answerIndex = answerIndex - 1



          
          


        default:
            print("Choix invalide.")
        }

        do {
            try saveQuestions(questions: loadedQuestions)
            print("Question modifiée avec succès.  \n\n")
        } catch {
            print("Erreur lors de la sauvegarde des questions: \(error.localizedDescription)")
        }
    default:
        print("Choix invalide.")
    }
}





//fonction pour filtrer les questions selon le niveau de difficulté
func filterQuestions(difficulty : Int, questions : [Question]) -> [Question]{
         // Filtrer les questions en fonction de la difficulté choisie
        let filteredQuestions = questions.filter { $0.difficulty <= difficulty }

        return filteredQuestions
}


//fonction pour filtrer les questions selon le niveau de difficulté mais radicale ( ex : niveau 3 que les questions de niveau 3 pas las anciens)
func filterQuestionsClosed(difficulty : Int, questions : [Question]) -> [Question]{
         // Filtrer les questions en fonction de la difficulté choisie
        let filteredQuestions = questions.filter { $0.difficulty == difficulty }

        return filteredQuestions
}



func saveQuestions(questions: [Question]) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(questions)
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let saveURL = currentDirectoryURL.appendingPathComponent("questions.json")
    try data.write(to: saveURL)
}