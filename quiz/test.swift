import Foundation


struct Question: Codable {
  var question: String  // énoncé
  var options: [String]  // réponses potentielles
  var answerIndex: Int   // index réponse
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




struct Joueur: Codable {
    let nom: String
    var score: Int
    var difficulty: Int
}

// Fonction pour afficher le tableau des scores concernant la difficulté choisie par le joueur
func leaderboard(joueur: Joueur) {
    do {
        // Charger les données de scores depuis le fichier
        let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("scores.json")
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let allPlayers = try decoder.decode([Joueur].self, from: data)

        // Filtrer les joueurs ayant la même difficulté que le joueur actuel
        let filteredPlayers = allPlayers.filter { $0.difficulty == joueur.difficulty }

        // Trier les joueurs par score décroissant
        let sortedPlayers = filteredPlayers.sorted(by: { $0.score > $1.score })

        // Afficher le classement
        print("Classement des joueurs (Difficulté \(joueur.difficulty)):\n")
        for (index, player) in sortedPlayers.enumerated() {
            print("\(index + 1). \(player.nom) - Score: \(player.score)")
        }
    } catch {
        print("Erreur lors de la lecture du fichier de scores: \(error.localizedDescription)")
    }
}

// Fonction pour sauvegarder les scores des joueurs
func saveScores(joueur: Joueur) {
    let fileManager = FileManager.default
    let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileURL = currentDirectory.appendingPathComponent("scores.json")

    var players: [Joueur] = []

    // Vérifier si le fichier existe
    if fileManager.fileExists(atPath: fileURL.path) {
        // Charger les joueurs depuis le fichier
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            players = try decoder.decode([Joueur].self, from: data)
        } catch {
            print("Erreur lors du chargement des scores: \(error.localizedDescription)")
        }
    }

    // Vérifier si le joueur existe déjà avec le même niveau de difficulté
    if let existingPlayerIndex = players.firstIndex(where: { $0.nom == joueur.nom && $0.difficulty == joueur.difficulty }) {
        // Mettre à jour le score du joueur existant
        players[existingPlayerIndex].score = joueur.score
    } else {
        // Ajouter un nouvel enregistrement pour ce joueur et ce niveau de difficulté
        players.append(joueur)
    }

    // Enregistrer les joueurs mis à jour dans le fichier
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(players)
        try data.write(to: fileURL)
        print("Scores sauvegardés avec succès.")
    } catch {
        print("Erreur lors de la sauvegarde des scores: \(error.localizedDescription)")
    }
}






struct Quiz {
    let questions: [Question]
    var lives: Int //nombre de vies
    var timeLimit: TimeInterval //limite de temps

  mutating func start(joueur: inout Joueur) {
      print("Début du quiz!")

      var remainingQuestions = questions.shuffled() // mélanger les questions

      for question in remainingQuestions {
          print("\nQuestion: \(question.question)")
          print("Options:")
          for (index, option) in question.options.enumerated() {
              print("\(index + 1). \(option)")
          }
          print("\n")

          let timeToAnswer = question.difficulty == 3 ? timeLimit : .infinity
          let startTime = Date()

          if question.difficulty == 3 {
              print("Vous avez \(Int(timeToAnswer)) secondes pour répondre.")
          }
          print("Votre réponse: ")

          var validAnswer = false // variable pour vérifier la validité de la réponse
          var chosenIndex: Int? // variable pour stocker la réponse choisie

          while !validAnswer {
              if let answer = readLine(), let playerChoice = Int(answer) {
                  if playerChoice >= 1 && playerChoice <= question.options.count {
                      chosenIndex = playerChoice - 1
                      validAnswer = true // la réponse est valide
                  } else {
                      print("Réponse invalide. Veuillez entrer un nombre entre 1 et \(question.options.count).")
                  }
              } else {
                  print("Réponse invalide. Veuillez entrer un nombre entre 1 et \(question.options.count).")
              }
          }

          let elapsedTime = Date().timeIntervalSince(startTime)

          if elapsedTime > timeToAnswer {
              print("Temps écoulé! La question est considérée fausse.")
              lives -= 1
              if lives == 0 {
                  print("Vous avez perdu!.")
                  return
              }
          } else {
              if let chosenIndex = chosenIndex {
                  let playerChoice = chosenIndex
                  if playerChoice == question.answerIndex {
                      joueur.score += question.difficulty // ajouter la difficulté de la question en points au score
                      print("\(question.quote)\n\nVotre score est actuellement de : \(joueur.score)\n\n") // affichage du score du joueur
                  } else {
                      print("Mauvaise réponse!\n")
                      lives -= 1 // on enleve une vie
                      if lives == 0 {
                          print("Vous avez perdu! Votre score final est \(joueur.score).\n")
                          return
                      }
                  }
              }
          }

          remainingQuestions.removeFirst() // retirer la question posée de la liste des questions restantes
      }

      print("Félicitations! Vous avez répondu à toutes les questions avec succès. Votre score final est \(joueur.score).")
  }

}

func modifyQuestions() { //editeur de questions
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
    print("3. Modifier une question")
    print("Votre choix: ", terminator: "")

    var choice = -1
    while choice == -1 {
        guard let choiceInput = readLine(), let chosenChoice = Int(choiceInput), chosenChoice == 1 || chosenChoice == 2 || chosenChoice == 3 else {
            print("Choix invalide. Veuillez entrer 1,2ou 3.\n")
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
        let filteredQuestions = loadedQuestions.filter { $0.difficulty == difficulty } //on recupere les questions du niveau choisi
        for (index, question) in filteredQuestions.enumerated() {
            print("\(index + 1). \(question.question)")
        }

        var deleteIndex = -1
        while deleteIndex == -1 { //choix de la question
            print("Entrez le numéro de la question que vous souhaitez supprimer : ", terminator: "")
            guard let deleteIndexInput = readLine(), let chosenIndex = Int(deleteIndexInput), chosenIndex >= 1 && chosenIndex <= filteredQuestions.count else {
                print("Numéro de question invalide. Veuillez entrer un numéro valide.")
                continue
            }
            deleteIndex = chosenIndex
        }

        let deletedQuestion = filteredQuestions[deleteIndex - 1]
        print("Question supprimée: \(deletedQuestion.question)")

        loadedQuestions.removeAll { $0.question == deletedQuestion.question } //suppression de la liste

        do { //on sauvegarde dans le json
            try saveQuestions(questions: loadedQuestions)
            print("Question supprimée avec succès.  \n\n")
        } catch {
            print("Erreur lors de la sauvegarde des questions: \(error.localizedDescription)")
        }



      

    case 2:
        print("Ajout d'une nouvelle question:")
        print("Entrez l'énoncé de la question: ", terminator: "") //on commence par ajouter l'énoncer
        guard let newQuestion = readLine(), !newQuestion.isEmpty else {
            print("Énoncé de la question invalide.")
            return
        }

        var responses = [String]() //ensuite les options de réponse
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

        var answerIndex = -1  //enfin l'index de réponse correcte puis la quote
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

        let newQuestionObject = Question(question: newQuestion, options: responses, answerIndex: answerIndex - 1, difficulty: difficulty, quote: quote) //creation de l'objet qui sera ajouté
        loadedQuestions.append(newQuestionObject)

        do {
            try saveQuestions(questions: loadedQuestions) //on sauvegarde dans le json
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
          case 1:  //on remplace l'anoncé de la question
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

        do { //à la fin on sauvegarde dans le json peu importe la modif
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



func saveQuestions(questions: [Question]) throws { //question pour sauvegarder dans le json
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(questions)
    let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let saveURL = currentDirectoryURL.appendingPathComponent("questions.json")
    try data.write(to: saveURL)
}





func main() {
    var continuerJeu = true



    while continuerJeu {
        print("\n Menu Principal: \n")
        print("1. Démarrer le jeu")
        print("2. Éditeur de banque de questions")
        print("3. Quitter \n")
        print("Votre choix: ", terminator: "")

        guard let choice = readLine(), let menuChoice = Int(choice) else {
            print("Choix invalide.")
            continue
        }

        switch menuChoice {
        case 1:
            guard let questions = loadQuestions() else {
                print("Impossible de charger les questions.")
                return
            }
            // démarrer le jeu
            print("Bienvenue dans le Quiz!\n")

            // demander le nom du joueur
            print("Entrez votre nom: ")
            guard let playerName = readLine(), !playerName.isEmpty else {
                print("Nom invalide.")
                return
            }

            // demander au joueur de choisir une difficulté
            var difficulty: Int = 0
            while difficulty < 1 || difficulty > 3 {
                print("\nChoisissez votre difficulté (1: Facile, 2: Moyen, 3: Difficile): ")
                if let input = readLine(), let chosenDifficulty = Int(input) {
                    difficulty = chosenDifficulty
                } else {
                    print("Entrée invalide. Veuillez entrer un nombre entre 1 et 3.")
                }
            }

            // créer une instance de Joueur avec le nom saisi
            var joueur = Joueur(nom: playerName, score: 0, difficulty: difficulty)

            // si difficile durée limitée à 8 secondes
            let timeLimit: TimeInterval = (difficulty == 3) ? 8.0 : .infinity

            var quiz: Quiz
            switch difficulty {
            case 1:
                quiz = Quiz(questions: filterQuestionsClosed(difficulty : difficulty, questions : questions), lives: 6, timeLimit: timeLimit)
            case 2:
                quiz = Quiz(questions: filterQuestionsClosed(difficulty : difficulty, questions : questions), lives: 4, timeLimit: timeLimit)
            case 3:
                quiz = Quiz(questions: filterQuestionsClosed(difficulty : difficulty, questions : questions), lives: 2, timeLimit: timeLimit)
            default:
                fatalError("Difficulté invalide.")
            }

            // démarrer le quiz
            quiz.start(joueur: &joueur) // passage du par reference pour pouvoir modifier le score
            saveScores(joueur: joueur)
            leaderboard(joueur: joueur)

        case 2:
        //lancer l'editeur de banque de questions
            modifyQuestions()


        case 3:
            // quitter l'application
            continuerJeu = false
            print("Merci d'avoir joué au Quiz !")

        default:
            print("Choix invalide.")
        }
    }
}

// appeler la fonction principale
main()




