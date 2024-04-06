import Foundation


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
            // Démarrer le jeu
            print("Bienvenue dans le Quiz!\n")
            
            // Demander le nom du joueur
            print("Entrez votre nom: ")
            guard let playerName = readLine(), !playerName.isEmpty else {
                print("Nom invalide.")
                return
            }
            
            // Demander au joueur de choisir une difficulté
            var difficulty: Int = 0
            while difficulty < 1 || difficulty > 3 {
                print("\nChoisissez votre difficulté (1: Facile, 2: Moyen, 3: Difficile): ")
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

// Appeler la fonction principale
main()

