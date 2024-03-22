import Foundation


func saveScores(joueur: Joueur) {
    let encoder = JSONEncoder()
    
    
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("scores.json")
    
    do {
        // verifier que le joueur n'existe pas deja 
        let data = try Data(contentsOf: fileURL)
        var joueurs = try JSONDecoder().decode([Joueur].self, from: data)
        
        // si oui modifier son score
        if let existingPlayerIndex = joueurs.firstIndex(where: { $0.nom == joueur.nom }) {
            joueurs[existingPlayerIndex].score = joueur.score
        } else {
            // sinon creation
            joueurs.append(joueur)
        }
        
        // sauvegarder
        let encodedData = try encoder.encode(joueurs)
        try encodedData.write(to: fileURL)
        
        print("Scores mis à jour avec succès.")
    } catch {
        print("Erreur lors de la mise à jour des scores: \(error.localizedDescription)")
    }
}


func loadQuestions(difficulty: Int) -> [Question]? {//fonction de récuperation des quest depuis le json  
    guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else { 
        print("Fichier introuvable.")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let allQuestions = try decoder.decode([Question].self, from: data)
        
        // Filtrer les questions en fonction de la difficulté choisie
        let filteredQuestions = allQuestions.filter { $0.difficulty <= difficulty }
        
        return filteredQuestions
    } catch {
        print("Failed to load questions from questions.json: \(error.localizedDescription)")
        return nil
    }
}

func main() {
    print("Bienvenue dans le Quiz!")
    
    // Demander le nom du joueur
    print("Entrez votre nom: ")
    guard let playerName = readLine(), !playerName.isEmpty else {
        print("Nom invalide.")
        return
    }

    // Créer une instance de Joueur avec le nom saisi
    var joueur = Joueur(nom: playerName, score: 0)

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

    // Charger les questions
    guard let questions = loadQuestions(difficulty: difficulty) else {
        print("Impossible de charger les questions.")
        return
    }

    // si difficile durée limitée à 8 secondes
    let timeLimit: TimeInterval = (difficulty == 3) ? 8.0 : .infinity

    let quiz: Quiz
    switch difficulty {
    case 1:
        quiz = Quiz(questions: questions, lives: 6, timeLimit: timeLimit)
    case 2:
        quiz = Quiz(questions: questions, lives: 4, timeLimit: timeLimit)
    case 3:
        quiz = Quiz(questions: questions, lives: 2, timeLimit: timeLimit)
    default:
        fatalError("Difficulté invalide.")
    }

    // Démarrer le quiz
    quiz.start(joueur: &joueur) // Passage du par reference pour pouvoir modifier le score
    saveScores(joueur : joueur)
}

// Appeler la fonction principale
main()


