struct Question: Codable {

    // structure qui representera le type de donnée des questions chargées
    let question: String  //énoncé
    let options: [String]  // réponses potentielles 
    let answerIndex: Int   //index réponse
}
