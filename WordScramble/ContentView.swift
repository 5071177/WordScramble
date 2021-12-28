//
//  ContentView.swift
//  WordScramble
//
//  Created by Yury Prokhorov on 26.12.2021.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var playerScore = 0
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                
                playerScore = 0
                usedWords = [String]()
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        fatalError("Could not loar start.txt from bundle.")
    }
    
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard answer.count > 0 else {return}
        
        guard isNotRoot(word: answer) else {
            wordError(title: "Word is the root word", message: "Did you want to trick me, you, bastard?")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original, asshole")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)', idiot!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, fckng genius!")
            return
        }
        
        guard isLong(word: answer) else {
            wordError(title: "Word is too short", message: "Could you stop beeing so short?")
            return
        }
        
        
        
        withAnimation{
        usedWords.insert(answer, at: 0)
        }
        newWord = ""
        playerScore += answer.count
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isLong (word: String) -> Bool {
        word.count >= 3
    }
    
    func isNotRoot (word: String) -> Bool {
        word != rootWord
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    var body: some View {
        
        
        
        NavigationView {
            
            
            List {
                
                Section {
                    Button ("Start new game", action: startGame)
                    Text ("Player score is \(playerScore)")
                }
                
                Section {
                    Text ("\(rootWord)")
                    TextField("Enter your word", text: $newWord).autocapitalization(.none)
                }
                Section {
                    ForEach(usedWords, id: \.self) {word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle("WordScramble")
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert (errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
