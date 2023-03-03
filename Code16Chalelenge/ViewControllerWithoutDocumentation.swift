//
//  ViewControllerWithoutDocumentation.swift
//  Code16Chalelenge
//
//  Created by Grzegorz Maciak on 14/03/2021.
//

import UIKit

class ViewControllerWithoutDocumentation: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // We will use `viewDidAppear(_:)` method instead of `viewDidLoad()` because when view did appear its frame is set to the final size (view is added to the window, and layed out), in `viewDidLoad()` the frame has its value loaded from the storyboard/xib and is not set to the real device frame yet. Putting the code here will help us to avoid wrong frame calculations and strange layout look for example in the Xcode Preview of the view controller.

        ładujWęża()
    }

    /// Metoda, która ładuję kod gry.
    ///
    /// W swift można używać polskich znaków w nazwach, dopuszczalne są nawet emoji więc jeśli piszesz program dla zabawy możesz śmiało pisać wszystko po polsku
    /// Dobrym nawykiem jest jednak od poczatku przyswyczjać się do języka angielskiego. W warunkach zawodowych o ile z komentarzem po polsku można się czasem spotkać, to nazwy powinny być w języku angielskim inaczej jest obciach :)
    func ładujWęża() {
        loadTheBoard()
        loadButtons()
        //start()
    }

    // MARK: - Generowanie planszy

    /// Punkt na siatce planszy.
    ///
    /// Posiada współrzędne całkowite (w programowaniu nazywamy je z anglielskiego `Integer`, w skrócie `Int`).
    struct GridPoint {
        var column: Int = 0
        var row: Int = 0
    }

    /// Szerokość widoku głównego
    var viewWidth: CGFloat { view.bounds.size.width }
    /// Wysokość widoku głównego
    var viewHeight: CGFloat { view.bounds.size.height }

    /// Liczba kolumn.
    ///
    /// Określa jak długi wąż zmieści się w naszj siatce jeśli będzie leżał poziomo. Ta wartość pozwoli nam też określić jakiej wielkości powinna być jedna komórka siatki tak żeby zmieścić się w głównym widoku `view`
    let numberOfColumns: Int = 20

    /// Szerokość kolumny.
    ///
    /// Wartość przechowujemy w postaci liczby całkowitej `Int` (ang. Integer), ponieważ bedzie ona szerokością komórki naszej siatki.
    /// Dlatego, żeby móc łatwo określić, w której komórce lezy dany widok i uniknąć błedów zaokrąglenia wartości rzeczywistycz `float` (w naszym przypadku `CGFloat`) potrzebujemy wartości całkowitych.
    var columnWidth: Int { Int(viewWidth / CGFloat(numberOfColumns)) }

    /// Wysokość wiersza
    var rowHeight: Int { columnWidth }
    /// Margines górny.
    let topMargin: CGFloat = 30
    /// Margines dolny
    let bottomMargin: CGFloat = 30

    /// Wysokość przycisku sterowania
    let buttonHeight: CGFloat = 100
    var buttonWidth: CGFloat { buttonHeight }

    /// Liczba wierszy.
    ///
    /// Jest to obliczona ilość całkowitych wierszy mieszczących się w dostępnej na planszę przestrzeni ekranu
    var numberOfRows: Int {
        /// Maksymalna wysokość planszy po odjęciu marginesu górnego, wysokości przycisków i marginesu dolnego
        let maxBoardHeight = viewHeight - topMargin - buttonHeight - bottomMargin
        /// Ilość wierszy jest określona jako maksymalna wysokość podzielona przez określoną wcześniej wysokość wiersza
        let maxNumberOfRows = maxBoardHeight / CGFloat(rowHeight)
        return Int(maxNumberOfRows)
    }

    /// Zmienna przechowująca słabą (ang. `weak`) referencję na widok planszy (siatki).
    ///
    /// Referencja widoku najczęściej jest słaba gdyż jego istnienie jest zależne od tego czy jest dodany do innego widoku, czyli czy jest dodany do hierarchi widoków. Jeśli zostanie z niej usunięty, nie ma sensu trzymać go w pamięci, w takiej sytuacji słaba referencja zostanie ustawiona na wartość zerową `nil` i nie bedzie więcej wskazywała na ten widok. Żeby jednak referencja mogła być słaba i ustawiona na wartość `nil` musi być opcjonalna, co jest oznaczone przez znak `?`. **Twoim zadaniem jest dowiedzieć się dlaczego tak jest**.
    weak var boardView: UIView?

    /// Metoda ładująca/tworząca widok planszy/siatki, po której będzie poruszał się wąż
    func loadTheBoard() {
        /// Szerokość planszy.
        let boardWidth = CGFloat(columnWidth * numberOfColumns)
        /// Wysokość planszy.
        let boardHeight = CGFloat(rowHeight * numberOfRows)

        /// Pozycja planszy na osi X
        let boardXPosition = (viewWidth - boardWidth)/2

        /// Widok planszy po ktorej porusza sie wąż
        let boardView = UIView(frame: CGRect(x: boardXPosition, y: topMargin, width: boardWidth, height: boardHeight))
        boardView.layer.borderWidth = 1;
        view.addSubview(boardView)
        self.boardView = boardView

        // Odkomentuj aby zobrazować siatkę
        //var c = 0
        //var r = 0
        //for c in 0..<numberOfColumns {
        //    for r in 0..<numberOfRows {
        //        let cellPosition = ViewPoint(x: columnWidth * c, y: rowHeight * r)
        //        let cell = createCell(at: cellPosition)
        //        cell.backgroundColor = .lightGray
        //        boardView.addSubview(cell)
        //
        //        //let label = UILabel(frame: cell.bounds)
        //        //label.textAlignment = .center
        //        //label.text = "\(c)"
        //        //cell.addSubview(label)
        //    }
        //}
    }

    /// Metoda tworzaca nową komórkę siatki w podanym punkcie siatki badź w punkcie zerowym (piwerszye pole siatki w lewym gornym rogu)..
    ///
    /// - parameter point: Punkt w którym powinna się pojawić kropka, określony jako współrzędne w granicach widoku. Można pominąć parametr `point` co spowoduje utworzenie kropki  punkcie (0,0) (lewy górny róg widoku)
    func createCell(at point: CGPoint = .zero) -> UIView {
        let cell = UIView(frame: CGRect(origin: point, size: CGSize(width: columnWidth, height: rowHeight)))
        // Ustawiamy kolor tła komórki na zielony
        cell.backgroundColor = .green;
        // ustawiamy grubość ramki
        cell.layer.borderWidth = 1
        return cell
    }

    // MARK: - Dodawanie guzików sterowania

    func loadButtons() {
        /// Rozmiar przycisku sterującego
        let buttonSize = CGSize(width: buttonWidth, height: buttonHeight)
        /// Współrzędna y określająca na jakiej wysokości będą znajdowaly się przyciski sterujące
        let buttonY = viewHeight - bottomMargin - buttonHeight
        /// Odstęp od boku ekranu (lewego bądź prawego) w jakim powinien znaleźć się przycisk sterujący ze strzałką.
        let sideMargin: CGFloat = 20

        let button = UIButton(type: .system)
        let buttonPosition = CGPoint(x: (viewWidth - buttonWidth)/2, // środek ekranu
                                       y: viewHeight - bottomMargin - buttonHeight)
        button.frame = CGRect(origin: buttonPosition, size: buttonSize)
        button.setImage(UIImage(systemName: "repeat"), for: .normal)
        button.addTarget(self, action: #selector(onResetButton), for: .touchUpInside)
        view.addSubview(button)

        // Odkomentuj aby zobrazować przycisk
        //button.layer.borderWidth = 1

        [DirectionChange.left, DirectionChange.right].forEach { (direction) in
            let button = UIButton(type: .system)
            let buttonX: CGFloat

            if direction == .left {
                buttonX = sideMargin
                button.setImage(UIImage(systemName: "arrowshape.turn.up.left"), for: .normal)
                button.addTarget(self, action: #selector(onLeftButton), for: .touchUpInside)
            } else {
                buttonX = viewWidth - sideMargin - buttonWidth
                button.setImage(UIImage(systemName: "arrowshape.turn.up.right"), for: .normal)
                button.addTarget(self, action: #selector(onRightButton), for: .touchUpInside)
            }
            let buttonPosition = CGPoint(x: buttonX, y: buttonY)
            button.frame = CGRect(origin: buttonPosition, size: buttonSize)
            view.addSubview(button)

            // Odkomentuj aby zobrazować przycisk
            //button.layer.borderWidth = 1
        }
    }

    @objc func onResetButton() {
        start()
    }

    @objc func onLeftButton() {
        directionChange = .left
    }

    @objc func onRightButton() {
        directionChange = .right
    }

    // MARK: - Elementy węża

    /// Wszystkie komórki węża
    var snake: [UIView] = []

    /// Komórka, do której wąż musi dotrzeć i ją połknąć, by stać się większym.
    weak var food: UIView?

    /// Generuje komórkę w losowym PUSTYM miejscu na planszy
    func generateRandomCell() -> UIView {
        var gridPosition = GridPoint()
        repeat {
            gridPosition.column = Int.random(in: 0..<numberOfColumns)
            // można to też zapisać w ten sposób
            gridPosition.row = Int.random(in: 0...(numberOfRows-1))
        } while !isGridPositionAvailable(gridPosition)

        let viewPosition = CGPoint(x: CGFloat(gridPosition.column * columnWidth), y: CGFloat(gridPosition.row * rowHeight))
        let cell = createCell(at: viewPosition)
        return cell
    }

    /// Metoda sprawdzająca czy dana komórka (widok) znajduje się w danym punkcie na siatce.
    func isCell(_ cell: UIView, at position: GridPoint) -> Bool {
        /// Pozycja x comórki w widoku planszy. Rzutujemy ją na wartość całkowitą `Int` (ang. integer), żeby uniknąć błędów zaokrąglenia, tym bardziej, ze będziemy obliczali pozycję na siatce, która jest wartością całkowitą.
        let viewPosition: CGPoint = cell.frame.origin
        var gridPosition = GridPoint()
        gridPosition.column = Int( viewPosition.x/CGFloat(columnWidth) )
        gridPosition.row = Int( viewPosition.y/CGFloat(rowHeight) )
        return position.column == gridPosition.column && position.row == gridPosition.row
    }

    /// Metoda sprawdzająca czy dany punkt na siatce jest wolny.
    func isGridPositionAvailable(_ position: GridPoint) -> Bool {
        var allCels = snake
        if let food = food {
            allCels.append(food)
        }

        let existingCell = allCels.first(where: { cell in
            self.isCell(cell, at: position)
        })
        return existingCell == nil
    }

    // MARK: - Uruchamianie gry (startowanie)

    weak var timer: Timer?

    func start() {
        reset()
        for _ in 1...3 {
            let cell = createCell(at: .zero)
            snake.append(cell)
            boardView?.addSubview(cell)
        }

        let firstFood = generateRandomCell()
        boardView?.addSubview(firstFood)
        self.food = firstFood

        /// Odstęp w sekundach pomiędzy kolejnymi rucha zmieniał swoje położenie (gra zostanie ponownie odświeżona)
        let updateInterval: TimeInterval = 0.3
        timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(onMoveSnake(_:)), userInfo: nil, repeats: true)
    }

    // MARK: Zresetuj grę (przywróć wartości startowe)

    func reset() {
        timer?.invalidate()
        currentDirection = .down
        directionChange = .none
        currentHeadPosition = GridPoint(column: 0, row: 0)
        boardView?.backgroundColor = .white
        boardView?.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        snake = []
    }

    // MARK: - Przebieg gry (odświeżanie)

    enum DirectionChange: Int {
        case left = -1  // lewo
        case none       // bez zmian
        case right      // prawo
    }

    enum Direction: Int {
        case right, up, down, left
    }

    /// Mapa ruchu dla danego kierunku.
    ///
    /// Jest to słownik określający w jaki sposób powinno się zmieniać położenie głowy węża na siadce (o ile kolumn i wierszy) dla danego kierunku ruchu
    let directions: [Direction: GridPoint] = [.right:   GridPoint(column: 1, row: 0), // w prawo, wąż przeskakuje na siatce planszy o 1 kolumnę w prawo przy każdym odświerzeniu
                                              .left:    GridPoint(column: -1, row: 0),// w lewo, wąż przeskakuje na siatce planszy o 1 kolumnę w lewo przy każdym odświerzeniu
                                              .up:      GridPoint(column: 0, row: -1),// w górę, wąż przeskakuje na siatce planszy o 1 wiersz w górę przy każdym odświerzeniu
                                              .down:    GridPoint(column: 0, row: 1)] // w dół, wąż przeskakuje na siatce planszy o 1 wiersz w dół przy każdym odświerzeniu
    /// Mapa zmiany kierunku.
    ///
    /// Mapa zmiany kierunku jest typu Słownik (ang. `Dictionary`) czyli posiada klucz (ang. `key`) do którego jest (po dwukropku) przypisana wartość (ang. `value`). Znając klucz możemy odczytać wartosć. Nasza mapa zmiany kierunku posiada wartości dla zmiany w lewo `.left` i w prawo `.right`, ale nie dla `.none` bo to oznacza brak zmiany. Do każdej zmiany (klucza) przypisany jest kolejny słownik zawierający obecny kierunek `currentDirectory` jako klucz, a wartością jest kolejny kierunek, w którym powinien poruszać się wąż po zmianie kierunku.
    let directionChangeMap: [DirectionChange: [Direction: Direction]] =
        [.left: [.right: .up,
                 .up: .left,
                 .down: .right,
                 .left: .down],
         .right: [.right: .down,
                  .up: .right,
                  .down: .left,
                  .left: .up]]

    /// Zmiana kierunku.
    ///
    /// Zmienna określająca zmianę kierunku. Jesli użytkownik przyciśnie jedną ze strzałek na ekranie zmienna ta zmieni wartość na `.left` (lewo) lub `.right` (prawo), a po kolejnym odświerzeniu ekranu gry zostanie przywrócona wartość `.none`
    var directionChange: DirectionChange = .none

    /// Obecny kierunek ruchu węża.
    var currentDirection = Direction.down

    /// Położenie głowy weza na siatce.
    var currentHeadPosition = GridPoint(column: 0, row: 0)

    func willSnakeBiteHimself(at position: GridPoint) -> Bool {
        let snakeWithoutHead = snake.dropLast()
        let existingCell = snakeWithoutHead.first(where: { cell in
            self.isCell(cell, at: position)
        })
        return existingCell != nil
    }

    @objc func onMoveSnake(_ timer: Timer) {
        if let newDirection = directionChangeMap[directionChange]?[currentDirection] {
            currentDirection = newDirection
            directionChange = .none
        }

        if let move = directions[currentDirection] {
            currentHeadPosition.column = currentHeadPosition.column + move.column;
            currentHeadPosition.row = currentHeadPosition.row + move.row;

            if currentHeadPosition.column >= 0, currentHeadPosition.column < numberOfColumns,
               currentHeadPosition.row >= 0, currentHeadPosition.row < numberOfRows,
               !willSnakeBiteHimself(at: currentHeadPosition) {

                if let newHead = snake.popLast() {
                    if let food = food, isCell(food, at: currentHeadPosition) {
                        snake.insert(food, at: 0)
                        let newFood = generateRandomCell()
                        boardView?.addSubview(newFood)
                        self.food = newFood
                    }

                    let headPosition = CGPoint(x: currentHeadPosition.column * columnWidth, y: currentHeadPosition.row * rowHeight)
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
