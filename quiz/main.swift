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


func leaderboard(joueur: Joueur) {
    do {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("scores.json")
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        var allPlayers = try decoder.decode([Joueur].self, from: data)
        
        // Filtrer les joueurs ayant la même difficulté que le joueur actuel
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






func main() {
    var continuerJeu = true

    guard let questions = loadQuestions() else {
                print("Impossible de charger les questions.")
                return
            }

    while continuerJeu {
        print("Menu Principal:")
        print("1. Démarrer le jeu")
        print("2. Éditeur de banque de questions")
        print("3. Quitter")
        print("Votre choix: ", terminator: "")

        guard let choice = readLine(), let menuChoice = Int(choice) else {
            print("Choix invalide.")
            continue
        }

        switch menuChoice {
        case 1:
            // Démarrer le jeu
            print("Bienvenue dans le Quiz!")
            
            // Demander le nom du joueur
            print("Entrez votre nom: ")
            guard let playerName = readLine(), !playerName.isEmpty else {
                print("Nom invalide.")
                return
            }
            
            // Demander au joueur de choisir une difficulté
            var difficulty: Int = 0
            while difficulty < 1 || difficulty > 3 {
                print("Choisissez votre difficulté (1: Facile, 2: Moyen, 3: Difficile): ")
                if let input = readLine(), let chosenDifficulty = Int(input) {
                    difficulty = chosenDifficulty
                } else {
                    print("Entrée invalide. Veuillez entrer un nombre entre 1 et 3.")
                }
            }
            
            // Créer une instance de Joueur avec le nom saisi
            var joueur = Joueur(nom: playerName, score: 0, difficulty: difficulty)
            
            // si difficile durée limitée à 8 secondes
            let timeLimit: TimeInterval = (difficulty == 3) ? 8.0 : .infinity
            
            var quiz: Quiz
            switch difficulty {
            case 1:
                quiz = Quiz(questions: filterQuestions(difficulty : difficulty, questions : questions), lives: 6, timeLimit: timeLimit)
            case 2:
                quiz = Quiz(questions: filterQuestions(difficulty : difficulty, questions : questions), lives: 4, timeLimit: timeLimit)
            case 3:
                quiz = Quiz(questions: filterQuestions(difficulty : difficulty, questions : questions), lives: 2, timeLimit: timeLimit)
            default:
                fatalError("Difficulté invalide.")
            }
            
            // Démarrer le quiz
            quiz.start(joueur: &joueur) // Passage du par reference pour pouvoir modifier le score
            saveScores(joueur: joueur)
            leaderboard(joueur: joueur)
            
        case 2:
            // editeur questions
            print("Bienvenue dans l'éditeur de la banque de questions.")
            
            
        case 3:
            // quitter l'application
            continuerJeu = false
            print("Merci d'avoir joué au Quiz !")
            
        default:
            print("Choix invalide.")
        }
    }
}

// Appeler la fonction principale
main()


