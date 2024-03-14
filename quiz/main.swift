import Foundation

func main() {
    print("Bienvenue dans le Quiz!")

    // demander au joueur de choisir une difficulté
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
    guard let questions = loadQuestions() else {
        print("Impossible de charger les questions.")
        return
    }

    // Créer une instance de Quiz avec le nombre de vies correspondant à la difficulté choisie
    let quiz: Quiz
    switch difficulty {
    case 1:
        quiz = Quiz(questions: questions, lives: 5)
    case 2:
        quiz = Quiz(questions: questions, lives: 3)
    case 3:
        quiz = Quiz(questions: questions, lives: 1)
    default:
        fatalError("Difficulté invalide.")
    }

    // Démarrer le quiz
    quiz.start()
}

// Appeler la fonction principale
main()

func loadQuestions() -> [Question]? {//fonction de récuperation des quest depuis le json  
    guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else { 
        print("Fichier introuvable.")
        return nil
    }
    
    do {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let questions = try decoder.decode([Question].self, from: data)
        return questions
    } catch {
        print("Failed to load questions from questions.json: \(error.localizedDescription)")
        return nil
    }
}
