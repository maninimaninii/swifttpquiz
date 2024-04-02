import Foundation


struct Joueur: Codable {
    let nom: String
    var score: Int
    var difficulty: Int
}

// Fonction pour afficher le tableau des scores concernant la difficulté choisie par le joueur
func leaderboard(joueur: Joueur) {
    do {
        // Charger les données de scores depuis le fichier
        let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("scores.json")
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let allPlayers = try decoder.decode([Joueur].self, from: data)

        // Filtrer les joueurs ayant la même difficulté que le joueur actuel
        let filteredPlayers = allPlayers.filter { $0.difficulty == joueur.difficulty }

        // Trier les joueurs par score décroissant
        let sortedPlayers = filteredPlayers.sorted(by: { $0.score > $1.score })

        // Afficher le classement
        print("Classement des joueurs (Difficulté \(joueur.difficulty)):\n")
        for (index, player) in sortedPlayers.enumerated() {
            print("\(index + 1). \(player.nom) - Score: \(player.score)")
        }
    } catch {
        print("Erreur lors de la lecture du fichier de scores: \(error.localizedDescription)")
    }
}

// Fonction pour sauvegarder les scores des joueurs
func saveScores(joueur: Joueur) {
    let fileManager = FileManager.default
    let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let fileURL = currentDirectory.appendingPathComponent("scores.json")

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




