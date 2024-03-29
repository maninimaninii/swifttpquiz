import Foundation


func saveScores(joueur: Joueur) {
    let fileManager = FileManager.default
    let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentDirectory.appendingPathComponent("scores.json")
    
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





func modifyQuestions() {  //fonction qui permet de modifier la banque de questions
    print("Éditeur de banque de questions:")
    print("Quel niveau de difficulté souhaitez-vous modifier ? (1: Facile, 2: Moyen, 3: Difficile): ", terminator: "")

    while difficulty == nil { // l'utilisateur choisit une difficulté concernée car beaucoup de questions
        guard let difficultyInput = readLine(), let chosenDifficulty = Int(difficultyInput), chosenDifficulty >= 1 && chosenDifficulty <= 3 else {
            print("Niveau de difficulté invalide. Veuillez entrer un nombre entre 1 et 3.")
            continue
        }
        difficulty = chosenDifficulty
    }

    print("Que souhaitez-vous faire ?")
    print("1. Supprimer une question")
    print("2. Ajouter une question")
    print("Votre choix: ", terminator: "")

     while choice == nil {
        guard let choiceInput = readLine(), let chosenChoice = Int(choiceInput), chosenChoice == 1 || chosenChoice == 2 else {
            print("Choix invalide. Veuillez entrer 1 ou 2.")
            continue
        }
        choice = chosenChoice
    }

    var questions = loadQuestions()
    guard var loadedQuestions = questions else {
        print("Impossible de charger les questions.")
        return
    }

    switch choice {
    case 1:
        print("Voici les questions actuelles pour le niveau de difficulté \(difficulty):")
        let filteredQuestions = filterQuestionsClosed(difficulty: difficulty, questions: loadedQuestions)
        for (index, question) in filteredQuestions.enumerated() {  //on affiche toutes les questions concernées avec un index
            print("\(index + 1). \(question.question)")
        }

        pwhile deleteIndex == nil {
        print("Entrez le numéro de la question que vous souhaitez supprimer : ", terminator: "")  //l'utilisateur choisit l'index de la question
        guard let deleteIndexInput = readLine(), let chosenIndex = Int(deleteIndexInput), chosenIndex >= 1 && chosenIndex <= filteredQuestions.count else {
        print("Numéro de question invalide. Veuillez entrer un numéro valide.")
        continue }
            deleteIndex = chosenIndex
        }   

        let deletedQuestion = filteredQuestions[deleteIndex - 1]
        print("Question supprimée: \(deletedQuestion.question)")

        // supprimer la question de la liste chargée
        loadedQuestions.removeAll { $0.question == deletedQuestion.question } 

        // mettre à jour le fichier JSON après suppression de la question
        do {
            try saveQuestions(questions: loadedQuestions)
            print("Question supprimée avec succès.")
        } catch {
            print("Erreur lors de la sauvegarde des questions: \(error.localizedDescription)")
        }



    case 2:
        // Ajouter une question
        print("Ajout d'une nouvelle question:")
        print("Entrez l'énoncé de la question: ", terminator: "")
        guard let newQuestion = readLine(), !newQuestion.isEmpty else {
            print("Énoncé de la question invalide.")
            return
        }

        var reponses = [String]()
        for i in 1...4 {
            var response: String?
            while response == nil {
                print("Entrez la réponse \(i): ", terminator: "")
                response = readLine()
                if response == nil || response!.isEmpty {
                    print("Réponse invalide. Veuillez entrer une réponse valide.")
                }
            }
            reponses.append(response!)
        }

        var answerIndex: Int?
        while answerIndex == nil {
            print("Entrez l'index de la réponse correcte (1-4): ", terminator: "")
            guard let answerIndexInput = readLine(), let index = Int(answerIndexInput), index >= 1 && index <= 4 else {
                print("Index de réponse invalide. Veuillez entrer un index valide.")
                continue
            }
            answerIndex = index
        }

        var quote: Int?
        while quote == nil {
            print("Entrez la quote de la question (1-10): ", terminator: "")
            guard let quoteInput = readLine(), let q = Int(quoteInput), q >= 1 && q <= 10 else {
                print("Quote de la question invalide. Veuillez entrer une quote valide.")
                continue
            }
            quote = q
        }

        //création de la nouvelle question et ajout dans la liste 
        let newQuestionObject = Question(question: newQuestion, options: reponses, answerIndex: answerIndex - 1, difficulty: difficulty)
        loadedQuestions.append(newQuestionObject)

        // Mettre à jour le fichier JSON après ajout de la question
        do {
            try saveQuestions(questions: loadedQuestions)
            print("Question ajoutée avec succès.")
        } catch {
            print("Erreur lors de la sauvegarde des questions: \(error.localizedDescription)")
        }

    default:
        print("Choix invalide.")
    }
}






func loadQuestions() -> [Question]? {//fonction de récuperation des quest depuis le json  
    guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else { 
        print("Fichier introuvable.")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let allQuestions = try decoder.decode([Question].self, from: data)
        
       return allQuestions
    } catch {
        print("Failed to load questions from questions.json: \(error.localizedDescription)")
        return nil
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


func leaderboard(joueur: Joueur) { //fonction qui permet d'afficher le tableau des scores concernant la difficulté choisie par le joueur
    do {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("scores.json")
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        var allPlayers = try decoder.decode([Joueur].self, from: data)
        
        // filtrer les joueurs ayant la même difficulté que le joueur actuel
        let filteredPlayers = allPlayers.filter { $0.difficulty == joueur.difficulty }
        
        // Trier les joueurs par score décroissant
        let sortedPlayers = filteredPlayers.sorted(by: { $0.score > $1.score })
        
        // Afficher le classement
        print("Classement des joueurs (Difficulté \(joueur.difficulty)):")
        for (index, player) in sortedPlayers.enumerated() {
            print("\(index + 1). \(player.nom) - Score: \(player.score)")
        }
    } catch {
        print("Erreur lors de la lecture du fichier de scores: \(error.localizedDescription)")
    }
}