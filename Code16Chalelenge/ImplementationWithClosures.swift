//
//  ImplementationWithClosures.swift
//  Code16Chalelenge
//
//  Created by Grzegorz Maciak on 13/03/2021.
//

import UIKit

/// Funkcja uruchamiająca grę.
///
/// Kod w wersji:
/// - zaimplementowanej w jednej metodzie,
/// - bloki/closures zamiast funkcji
/// - bez dokumentacji
func loadDemoCode(in view: UIView) {
    /// Punkt na siatce planszy.
    typealias ViewPoint = CGPoint

    /// Punkt na siatce planszy.
    struct GridPoint {
        var column: Int = 0
        var row: Int = 0
    }

    /// Zmiana kierunku ruchu węża.
    enum DirectionChange {
        case left   // lewo
        case none   // bez zmian
        case right  // prawo
    }

    /// Kierunek ruchu węża.
    enum Direction: Int {
        case right, up, down, left
    }

    // MARK: - Generowanie planszy

    let viewWidth: CGFloat = view.bounds.size.width
    let viewHeight: CGFloat = view.bounds.size.height

    let numberOfColumns: Int = 20

    let columnWidth: Int = Int(viewWidth / CGFloat(numberOfColumns))
    let rowHeight: Int = columnWidth

    let topMargin: CGFloat = 30
    let bottomMargin: CGFloat = 30

    let buttonHeight: CGFloat = 100
    let buttonWidth: CGFloat = buttonHeight

    let numberOfRows: Int = {
        let maxBoardHeight = viewHeight - topMargin - buttonHeight - bottomMargin
        let maxNumberOfRows = maxBoardHeight / CGFloat(rowHeight)
        return Int(maxNumberOfRows)
    }()

    let boardWidth = CGFloat(columnWidth * numberOfColumns)
    let boardHeight = CGFloat(rowHeight * numberOfRows)
    let boardXPosition = (viewWidth - boardWidth)/2

    let boardView = UIView(frame: CGRect(x: boardXPosition, y: topMargin, width: boardWidth, height: boardHeight))
    boardView.layer.borderWidth = 1;
    view.addSubview(boardView)

    // MARK: - Tworzenie komórki siatki na planszy (Komórek węża i losowej komórki)

    /// Funkcja tworzaca nową komórkę siatki w podanym punkcie siatki badź w punkcie zerowym (piwerszye pole siatki w lewym gornym rogu).
    let createCellAt: (_ point: ViewPoint) -> UIView

    createCellAt = { point in
        let cell = UIView(frame: CGRect(origin: point, size: CGSize(width: columnWidth, height: rowHeight)))
        // Ustawiamy kolor tła komórki na zielony
        cell.backgroundColor = .green;
        // ustawiamy grubość ramki
        cell.layer.borderWidth = 1
        return cell
    }

    //var c = 0
    //var r = 0
    //for c in 0..<numberOfColumns {
    //    for r in 0..<numberOfRows {
    //        let cellPosition = ViewPoint(x: columnWidth * c, y: rowHeight * r)
    //        let cell = createCellAt(cellPosition)
    //        cell.backgroundColor = .lightGray
    //        boardView.addSubview(cell)
    //
    //        //let label = UILabel(frame: cell.bounds)
    //        //label.textAlignment = .center
    //        //label.text = "\(c)" // or "\(r)"
    //        //cell.addSubview(label)
    //    }
    //}

    /// Wszystkie komórki węża
    var snake: [UIView] = []

    /// Komórka, do której wąż musi dotrzeć i ją połknąć, by stać się większym.
    weak var food: UIView?

    /// Funkcja sprawdzająca czy dana komórka (widok) znajduje się na danej pozycji na siatce czy nie.
    let isCell: (_ cell: UIView, _ position: GridPoint) -> Bool = { cell, position in
        /// Pozycja x comórki w widoku planszy. Rzutujemy ją na wartość całkowitą `Int` (ang. integer), żeby uniknąć błędów zaokrąglenia, tym bardziej, ze będziemy obliczali pozycję na siatce, która jest wartością całkowitą.
        let viewPosition: ViewPoint = cell.frame.origin
        var gridPosition = GridPoint()
        gridPosition.column = Int( viewPosition.x/CGFloat(columnWidth) )
        gridPosition.row = Int( viewPosition.y/CGFloat(rowHeight) )
        return position.column == gridPosition.column && position.row == gridPosition.row
    }

    /// Funkcja sprawdzająca czy dany punkt na siatce jest wolny.
    let isGridPositionAvailable: (_ position: GridPoint) -> Bool = { position in
        var allCels = snake
        if let food = food {
            allCels.append(food)
        }

        let existingCell = allCels.first(where: { cell in
            isCell(cell, position)
        })
        return existingCell == nil
    }

    /// Funkcja generuje komórkę w losowym PUSTYM miejscu na planszy
    let generateRandomCell: () -> UIView = {
        var gridPosition = GridPoint()
        repeat {
            gridPosition.column = Int.random(in: 0..<numberOfColumns)
            gridPosition.row = Int.random(in: 0...(numberOfRows-1))
        } while !isGridPositionAvailable(gridPosition)

        let viewPosition = ViewPoint(x: CGFloat(gridPosition.column * columnWidth), y: CGFloat(gridPosition.row * rowHeight))
        let cell = createCellAt(viewPosition)
        return cell
    }

    // MARK: - Uruchamianie gry (startowanie)

    /// Mapa ruchu dla danego kierunku.
    ///
    /// Jest to słownik określający w jaki sposób powinno się zmieniać położenie głowy węża na siadce (o ile kolumn i wierszy) dla danego kierunku ruchu
    let directions: [Direction: GridPoint] = [.right:   GridPoint(column: 1, row: 0),
                                              .left:    GridPoint(column: -1, row: 0),
                                              .up:      GridPoint(column: 0, row: -1),
                                              .down:    GridPoint(column: 0, row: 1)]
    /// Mapa zmiany kierunku.
    ///
    /// Mapa zmiany kierunku jest typu Słownik (ang. `Dictionary`) czyli posiada klucz (ang. `key`) do którego jest (po dwukropku) przypisana wartość (ang. `value`). Znając klucz możemy odczytać wartosć. Nasza mapa zmiany kierunku posiada wartości dla zmiany w lewo `.left` i w prawo `.right`, ale nie dla `.none` bo to oznacza brak zmiany. Do każdej zmiany (klucza) przypisany jest kolejny słownik zawierający obecny kierunek `currentDirectory` jako klucz, a wartością jest kolejny kierunek, w którym powinien poruszać się wąż po zmianie kierunku.
    let directionChangeMap: [DirectionChange: [Direction: Direction]] =
        [
            .left: [.right: .up, .up: .left, .down: .right, .left: .down],
            .right: [.right: .down, .up: .right, .down: .left, .left: .up]
        ]

    /// Zmiana kierunku.
    ///
    /// Zmienna przechowująca wartość określającą zmianę kierunku podczas najbliższego odświerzenia gry.
    /// Jesli użytkownik przyciśnie jedną ze strzałek na ekranie zmienna ta zmieni wartość na `.left` (lewo) lub `.right` (prawo), a po kolejnym odświerzeniu ekranu gry zostanie przywrócona wartość `.none`
    var directionChange: DirectionChange = .none

    weak var timer: Timer?

    let start: () -> Void = { [weak boardView] in
        timer?.invalidate()
        snake = []
        boardView?.backgroundColor = .white
        boardView?.subviews.forEach { subview in
            subview.removeFromSuperview()
        }

        /// Obecny kierunek ruchu węża.
        var currentDirection: Direction = .down

        /// Położenie głowy weza na siatce. Pozycja startowa w lewym górnym rogu siatki.
        var currentHeadPosition = GridPoint(column: 0, row: 0)

        let willSnakeBiteHimselfAt: (_ position: GridPoint) -> Bool = { position in
            let snakeWithoutHead = snake.dropLast()
            let existingCell = snakeWithoutHead.first(where: { cell in
                isCell(cell, position)
            })
            return existingCell != nil
        }

        for _ in 1...3 {
            let cell = createCellAt(.zero)
            snake.append(cell)
            boardView?.addSubview(cell)
        }

        let firstFood = generateRandomCell()
        boardView?.addSubview(firstFood)
        food = firstFood

        /// Odstęp w sekundach pomiędzy kolejnymi rucha zmieniał swoje położenie (gra zostanie ponownie odświeżona)
        let updateInterval: TimeInterval = 0.3
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            if let newDirection = directionChangeMap[directionChange]?[currentDirection] {
                currentDirection = newDirection
                directionChange = .none
            }

            if let move = directions[currentDirection] {
                currentHeadPosition.column = currentHeadPosition.column + move.column;
                currentHeadPosition.row = currentHeadPosition.row + move.row;

                if currentHeadPosition.column >= 0, currentHeadPosition.column < numberOfColumns,
                   currentHeadPosition.row >= 0, currentHeadPosition.row < numberOfRows,
                   !willSnakeBiteHimselfAt(currentHeadPosition) {

                    if let newHead = snake.popLast() {
                        if let oldFood = food, isCell(oldFood, currentHeadPosition) {
                            snake.insert(oldFood, at: 0)
                            let newFood = generateRandomCell()
                            boardView?.addSubview(newFood)
                            food = newFood
                        }

                        let headPosition = ViewPoint(x: currentHeadPosition.column * columnWidth, y: currentHeadPosition.row * rowHeight)
                        newHead.frame.origin = headPosition
                        snake.insert(newHead, at: 0)
                    } else {
                        fatalError("Snake has no tail, which mean that there is no snake at all. 😮")
                    }
                } else {
                    timer.invalidate()
                    boardView?.backgroundColor = .black
                }
            }
        }
    }

    // MARK: - Dodawanie guzików sterowania

    /// Rozmiar przycisku sterującego
    let buttonSize = CGSize(width: buttonWidth, height: buttonHeight)
    /// Współrzędna y określająca na jakiej wysokości będą znajdowaly się przyciski sterujące
    let buttonY = viewHeight - bottomMargin - buttonHeight
    /// Odstęp od boku ekranu (lewego bądź prawego) w jakim powinien znaleźć się przycisk sterujący ze strzałką.
    let sideMargin: CGFloat = 20

    /// Akcja przypisana do przycisku reset
    let resetButtonAction = UIAction(handler: { _ in
        // rozpocznij grę od nowa
        start()
    })
    let button = UIButton(type: .system, primaryAction: resetButtonAction)
    let buttonPosition = ViewPoint(x: (viewWidth - buttonWidth)/2, // środek ekranu
                                   y: viewHeight - bottomMargin - buttonHeight)
    button.frame = CGRect(origin: buttonPosition, size: buttonSize)
    button.setImage(UIImage(systemName: "repeat"), for: .normal)
    view.addSubview(button)
    //button.layer.borderWidth = 1

    [DirectionChange.left, DirectionChange.right].forEach { (direction) in
        let buttonX: CGFloat

        /// Akcja przypisana do przycisku, zmieniająca kierunek ruchu
        let buttonAction = UIAction { _ in
            directionChange = direction
        }
        let button = UIButton(type: .system, primaryAction: buttonAction)

        if direction == .left {
            buttonX = sideMargin
            button.setImage(UIImage(systemName: "arrowshape.turn.up.left"), for: .normal)
        } else {
            buttonX = viewWidth - sideMargin - buttonWidth
            button.setImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
        }

        let buttonPosition = ViewPoint(x: buttonX, y: buttonY)
        button.frame = CGRect(origin: buttonPosition, size: buttonSize)
        view.addSubview(button)
        //button.layer.borderWidth = 1
    }
}
