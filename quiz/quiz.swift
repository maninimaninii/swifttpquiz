import Foundation

class Quiz {
    var questions: [Question]
    var lives: Int
    
    init(questions: [Question], lives: Int) {
        self.questions = questions
        self.lives = lives
    }
    
    func start(joueur: inout Joueur) {
        print("Début du quiz!")
        
        for question in questions {
            // Afficher la question
            print(question.question)
            for (index, option) in question.options.enumerated() {
                print("\(index + 1). \(option)")
            }
            
            // Demander la réponse du joueur
            print("Votre réponse (entrez le numéro correspondant): ")
            guard let input = readLine(), let choice = Int(input), choice > 0 && choice <= question.options.count else {
                print("Réponse invalide. Passons à la question suivante.")
                continue
            }
            
            // Vérifier la réponse
            let playerChoice = choice - 1 // Pour correspondre à l'index dans les options
            if playerChoice == question.answerIndex {
                print("Bonne réponse!")
                joueur.score += question.difficulty // Ajouter la difficulté de la question au score du joueur
            } else {
                print("Mauvaise réponse!")
                lives -= 1 // Enlever une vie au joueur pour une mauvaise réponse
                if lives <= 0 {
                    print("Vous avez perdu! Votre score final est \(joueur.score).")
                    return
                }
            }
        }
        
        print("Félicitations! Vous avez terminé le quiz avec un score de \(joueur.score).")
    }
}
