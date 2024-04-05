import Foundation

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