import Foundation

struct Quiz {
    let questions: [Question]
    var lives: Int //nombre de vies
    var timeLimit: TimeInterval //limite de temps

    mutating func start(joueur: inout Joueur) {
        print("Début du quiz!")
        
        for question in questions {
            print("\nQuestion: \(question.question)")
            print("Options:")
            for (index, option) in question.options.enumerated() {
                print("\(index + 1). \(option)")
            }
            
            // si le joueur prends le mode difficile, il aura une durée de reponse limitée
            let timeToAnswer = question.difficulty == 3 ? timeLimit : .infinity
            
            // attendre la réponse du joueur
            print("Vous avez \(Int(timeToAnswer)) secondes pour répondre.")
            print("Votre réponse: ")
            let answer = readLine()
            
            // vérifier la réponse du joueur
            if let playerAnswer = answer, let playerChoice = Int(playerAnswer) {
                if playerChoice - 1 == question.answerIndex {
                    print("Bonne réponse!")
                    joueur.score += question.difficulty // ajouter la difficulté de la question en points au score 
                } else {
                    print("Mauvaise réponse!")
                    lives -= 1 //on enleve une vie
                    if lives == 0 {
                        print("Vous avez perdu! Votre score final est \(joueur.score).")
                        return
                    }
                }
            } else {
                print("Temps écoulé! La question est considérée fausse.")
                lives -= 1
                if lives == 0 {
                    print("Vous avez perdu! Votre score final est \(joueur.score).")
                    return
                }
            }
        }
        
        print("Félicitations! Vous avez répondu à toutes les questions avec succès. Votre score final est \(joueur.score).")
    }
}