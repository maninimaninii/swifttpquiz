import Foundation


struct Question: Codable {

    // structure qui representera le type de donnée des questions chargées
    let question: String  //énoncé
    let options: [String]  // réponses potentielles 
    let answerIndex: Int   //index réponse
    let difficulty : Int //difficulté
}



struct Quiz {
    let questions: [Question]
    var lives: Int //nombre de vies
    var timeLimit: TimeInterval //limite de temps

   mutating func start() {
    print("Début du quiz!")
    
    for question in questions {
        print("\nQuestion: \(question.question)")
        print("Options:")
        for (index, option) in question.options.enumerated() {
            print("\(index + 1). \(option)")
        }
        
        // si le joueur prend le mode difficile, il aura une durée de réponse limitée
        let timeToAnswer = question.difficulty == 3 ? timeLimit : .infinity
        
        // enregistrer le début du délai de réponse
        let startTime = Date()
        
        // attendre la réponse du joueur
        if(question.difficulty == 3){
        print("Vous avez \(Int(timeToAnswer)) secondes pour répondre.")}
        print("Votre réponse: ")
        
        var validAnswer = false // Variable pour vérifier la validité de la réponse
        var chosenIndex: Int? // Variable pour stocker la réponse choisie
        
        // Boucle jusqu'à ce qu'une réponse valide soit entrée
        while !validAnswer {
            if let answer = readLine(), let playerChoice = Int(answer) {
                if playerChoice >= 1 && playerChoice <= question.options.count {
                    chosenIndex = playerChoice - 1
                    validAnswer = true // La réponse est valide
                } else {
                    print("Réponse invalide. Veuillez entrer un nombre entre 1 et \(question.options.count).")
                }
            } else {
                print("Réponse invalide. Veuillez entrer un nombre entre 1 et \(question.options.count).")
            }
        }
        
        // Vérifier le temps écoulé
        let elapsedTime = Date().timeIntervalSince(startTime)
        if elapsedTime > timeToAnswer {
            print("Temps écoulé! La question est considérée fausse.")
            lives -= 1
            if lives == 0 {
                print("Vous avez perdu!.")
                return
            }
        } else {
            // Vérifier la réponse du joueur
            if let playerChoice = chosenIndex {
                if playerChoice == question.answerIndex {
                    print("Bonne réponse!")
                } else {
                    print("Mauvaise réponse!")
                    lives -= 1 // Enlever une vie
                    if lives == 0 {
                        print("Vous avez perdu.")
                        return
                    }
                }
            }
        }
    }
    
    print("Félicitations! Vous avez répondu à toutes les questions avec succès..")
}


}

func loadQuestions(difficulty: Int) -> [Question]? {
    // Vous devez définir ici vos questions en fonction de la difficulté.
    // Voici juste un exemple de questions pour tester le code.

    let questions: [Question]

    switch difficulty {
    case 1:
        questions = [
            Question(question: "Quelle est la capitale de la France ?", options: ["Paris", "Londres", "Berlin"], answerIndex: 0, difficulty: 1),
            Question(question: "Combien de jours y a-t-il dans une année bissextile ?", options: ["365", "366", "364"], answerIndex: 1, difficulty: 1),
            Question(question: "Qui a peint la Joconde ?", options: ["Vincent van Gogh", "Pablo Picasso", "Leonardo da Vinci"], answerIndex: 2, difficulty: 1)
        ]
    case 2:
        questions = [
            Question(question: "Quel est le plus grand océan du monde ?", options: ["Océan Atlantique", "Océan Arctique", "Océan Pacifique"], answerIndex: 2, difficulty: 2),
            Question(question: "Quel est le symbole chimique de l'or ?", options: ["Au", "Ag", "Fe"], answerIndex: 0, difficulty: 2),
            Question(question: "Quel est le plus grand désert chaud du monde ?", options: ["Sahara", "Antarctique", "Gobi"], answerIndex: 0, difficulty: 2)
        ]
    case 3:
        questions = [
            Question(question: "Quelle est la vitesse de la lumière en mètres par seconde (approximativement) ?", options: ["299 792 458", "100 000 000", "500 000 000"], answerIndex: 0, difficulty: 3),
            Question(question: "Qui a écrit 'Guerre et Paix' ?", options: ["Fiodor Dostoïevski", "Léon Tolstoï", "Victor Hugo"], answerIndex: 1, difficulty: 3),
            Question(question: "Quel est le composant principal de l'air ?", options: ["Azote", "Oxygène", "Dioxyde de carbone"], answerIndex: 1, difficulty: 3)
        ]
    default:
        return nil
    }

    return questions
}




func main() {
 var continuerJeu = true

    while continuerJeu{
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
    


    // Charger les questions
    guard let questions = loadQuestions(difficulty: difficulty) else {
        print("Impossible de charger les questions.")
        return
    }

    // si difficile durée limitée à 8 secondes
    let timeLimit: TimeInterval = (difficulty == 3) ? 8.0 : .infinity

    var quiz: Quiz
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

 
    quiz.start() 
    print("Voulez-vous lancer une nouvelle partie ? (oui/non)")
        let choix = readLine()?.lowercased()
        if choix == "non" {
            continuerJeu = false
        }
}

print("Merci d'avoir joué au Quiz !")


}

main()
