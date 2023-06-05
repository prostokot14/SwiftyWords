//
//  ViewController.swift
//  Project8
//
//  Created by Антон Кашников on 04.06.2023.
//

import UIKit

final class ViewController: UIViewController {
    private var cluesLabel: UILabel!
    private var answersLabel: UILabel!
    private var currentAnswerLabel: UITextField!
    private var scoreLabel: UILabel!
    private var letterButtons = [UIButton]()
    private var activatedButtons = [UIButton]()
    private var solutions = [String]()
    private var score = 0
    private var level = 1

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)

        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24)
        cluesLabel.text = "CLUES"
        cluesLabel.numberOfLines = 0
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(cluesLabel)

        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.text = "ANSWERS"
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .right
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabel)

        currentAnswerLabel = UITextField()
        currentAnswerLabel.translatesAutoresizingMaskIntoConstraints = false
        currentAnswerLabel.placeholder = "Tap letters to guess"
        currentAnswerLabel.textAlignment = .center
        currentAnswerLabel.font = UIFont.systemFont(ofSize: 44)
        currentAnswerLabel.isUserInteractionEnabled = false
        view.addSubview(currentAnswerLabel)

        let submitButton = UIButton(type: .system)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("SUBMIT", for: .normal)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        view.addSubview(submitButton)

        let clearButton = UIButton(type: .system)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.setTitle("CLEAR", for: .normal)
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        view.addSubview(clearButton)

        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)

        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            currentAnswerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswerLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentAnswerLabel.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            submitButton.topAnchor.constraint(equalTo: currentAnswerLabel.bottomAnchor),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            clearButton.topAnchor.constraint(equalTo: submitButton.topAnchor),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clearButton.heightAnchor.constraint(equalToConstant: 44),
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])

        let letterButtonWidth = 150
        let letterButtonHeight = 80

        for row in 0..<4 {
            for column in 0..<5 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle("WWW", for: .normal)
                letterButton.frame = CGRect(x: column * letterButtonWidth, y: row * letterButtonHeight, width: letterButtonWidth, height: letterButtonHeight)
                letterButton.addTarget(self, action: #selector(letterButtonTapped), for: .touchUpInside)
                buttonsView.addSubview(letterButton)

                letterButtons.append(letterButton)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadLevel()
    }

    private func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()

        if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt"), let levelContents = try? String(contentsOf: levelFileURL) {
            var lines = levelContents.components(separatedBy: .newlines)
            lines.shuffle()

            for (index, line) in lines.enumerated() {
                let parts = line.components(separatedBy: ": ")
                let answer = parts[0]
                let clue = parts[1]

                clueString += "\(index + 1). \(clue)\n"

                let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                solutionString += "\(solutionWord.count) letters\n"
                solutions.append(solutionWord)

                letterBits += answer.components(separatedBy: "|")
            }
        }

        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)

        letterBits.shuffle()

        if letterBits.count == letterButtons.count {
            for i in 0..<letterButtons.count {
                letterButtons[i].setTitle(letterBits[i], for: .normal)
            }
        }
    }

    private func levelUp(alertAction: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)
        loadLevel()

        for activatedButton in activatedButtons {
            activatedButton.isHidden = false
        }
    }

    @objc private func submitButtonTapped(_ sender: UIButton) {
        guard let currentAnswerText = currentAnswerLabel.text else {
            return
        }

        if let solutionPosition = solutions.firstIndex(of: currentAnswerText) {
            activatedButtons.removeAll()

            var splitAnswers = answersLabel.text?.components(separatedBy: .newlines)
            splitAnswers?[solutionPosition] = currentAnswerText
            answersLabel.text = splitAnswers?.joined(separator: "\n")

            currentAnswerLabel.text = ""
            score += 1

            if score % 7 == 0 {
                let alertController = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                present(alertController, animated: true)
            }
        }
    }

    @objc private func clearButtonTapped(_ sender: UIButton) {
        currentAnswerLabel.text = ""

        for activatedButton in activatedButtons {
            activatedButton.isHidden = false
        }

        activatedButtons.removeAll()
    }

    @objc private func letterButtonTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else {
            return
        }

        currentAnswerLabel.text = currentAnswerLabel.text?.appending(buttonTitle)
        activatedButtons.append(sender)
        sender.isHidden = true
    }
}
