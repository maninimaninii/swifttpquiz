import Foundation


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
    print("2. Ajouter une question\n")
    print("Votre choix: ", terminator: "")

    var choice = -1
    while choice == -1 {
        guard let choiceInput = readLine(), let chosenChoice = Int(choiceInput), chosenChoice == 1 || chosenChoice == 2 else {
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
