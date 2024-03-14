import Foundation

struct Quiz {  //structure de jeu
    var questions: [Question] //questions
    var lives: Int  //nombre de vies du joueur (décidées par la difficulté choisies)

    init(questions: [Question], lives: Int) { //constructeur
        self.questions = questions
        self.lives = lives
    }

    mutating func start() {  //fonction du jeu

        var remainingQuestions = questions
        var score = 0

        while !remainingQuestions.isEmpty && lives > 0 {
            let currentQuestion = remainingQuestions.removeFirst()
            print(currentQuestion.question)
            print("Options:")
            for (index, option) in currentQuestion.options.enumerated() {
                print("\(index + 1). \(option)")
            }

            print("Faites votre choix (1-\(currentQuestion.options.count)):")
            if let userInput = readLine(), let userChoice = Int(userInput), userChoice > 0, userChoice <= currentQuestion.options.count {
                let userAnswerIndex = userChoice - 1
                if userAnswerIndex == currentQuestion.answerIndex {
                    print("Correct!\n")
                    score += 1
                } else {
                    print("Faux!\n")
                    lives -= 1
                }
            } else {
                print("Veuillez entrer une valeur entre 1 et \(currentQuestion.options.count).\n")
            }
        }

        if lives == 0 {
            print("Vous n'avez plus de vie, le jeu est fini.༼☯﹏☯༽")
        } else {
            print("FELICITATIONS !! Vous avez réussi à terminer le quizz !!!. ⊂◉‿◉つ")
        }
    }
}