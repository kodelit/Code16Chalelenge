//
//  ViewController.swift
//  Code16Chalelenge
//
//  Created by Grzegorz Maciak on 06/02/2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // We will use `viewDidAppear(_:)` method instead of `viewDidLoad()` because when view did appear its frame is set to the final size (view is added to the window, and layed out), in `viewDidLoad()` the frame has its value loaded from the storyboard/xib and is not set to the real device frame yet. Putting the code here will help us to avoid wrong frame calculations and strange layout look for example in the Xcode Preview of the view controller.
        
        // Kod został przeniesiony do metody `ładujWęża()` zdefiniowanej poniżej.
        // tutaj wywołujemy kod tej metody, jakby była ona zaimplementowana tutaj.
        // Dzielenie kodu na metody/funkcje pozwala podzielić go na logiczne podzadania oraz wywołać je (użyć) wielokrotnie.
        // Czy i czym się różni metoda od funkcji? Dowiedz się samodzielnie. To pierwsze zadanie dla Ciebie.
        //ładujWęża()

        //loadDemoCode(in: view)
        //loadDocumentedDemoCode(in: view)
    }

    /// Metoda, która ładuję kod gry.
    ///
    /// W swift można używać polskich znaków w nazwach, dopuszczalne są nawet emoji więc jeśli piszesz program dla zabawy możesz śmiało pisać wszystko po polsku
    /// Dobrym nawykiem jest jednak od poczatku przyswyczjać się do języka angielskiego. W warunkach zawodowych o ile z komentarzem po polsku można się czasem spotkać, to nazwy powinny być w języku angielskim inaczej jest obciach :)
    func ładujWęża() {
        // ładuj planszę
        loadTheBoard()
        // ładuj przyciski sterujące
        loadButtons()
        // uruchom grę, grę można tez uruchomić przyciskiem reset
        //start()
    }

    // MARK: - Generowanie planszy
    
    // Dla uproszczenia nazwijmy sobie komórką (ang. cell) każdą pojedyńczą część węża jak również obiekt pojawiający się na planszy, który ma być przez niego "zjedzony".
    // Komórki niech będą kwadratowe.
    // Komórki te ułożone obok siebie stworza siatkę, która będzie naszą planszą, po której będzie poruszał się wąż.
    
    // Bedziemy mieli dwa układy współrzędnych:
    // - pierwszy to układ współrzędnych widoku `view`, w którym będziemy układali kazdy element (komórki węża i losowa komórka na planszy do "zjedzenia")

    /// Punkt na siatce planszy.
    ///
    /// Posiada współrzędne rzeczywiste (w programowaniu nazywamy je zmiennoprzecinkowymi, ang. `floating point`, w skrócie `float`, w przypadku współrzędnych, rozmaru, ramki widoku mamy zawsze przedrostek `CG` czyli np. `CGPoint`, `CGRect`, `CGFloat`).
    typealias ViewPoint = CGPoint // CGPoint(x: CGFloat, y: CGFloat)

    // - drugi to układ współrzędnych na siatce planszy, po której będzie poruszał się wąż, jeden punkt na siatce to jedna komórka (1 element węża)
    /// Punkt na siatce planszy.
    ///
    /// Posiada współrzędne całkowite (w programowaniu nazywamy je z anglielskiego `Integer`, w skrócie `Int`).
    struct GridPoint {
        var column: Int = 0
        var row: Int = 0
    }
    
    // W aplikacjach iOS ekrany składają się z widoków, widok to element który ma określone położenie i wymiar, oraz może zawierać w sobie inne widoki. Widoki zagnieżdza sie po to, żeby łatwiej było okreslić ich położenie względem siebie, np. w naszym przypadku łatwiej nam będzie określić położenie węża w widoku planszy `boardView`, gdzie będą tylko elementy zwiazane z wężem, niż w widoku głównym `view` gdzie będą też przyciski, które musieli byśmy wziąć pod uwagę w obliczeniach, pamiętając że musi na nie być miejsce. Widoki mają dużo więcej innych funkcji i możliwości ale w tej chwili nie bedziemy się na nich skupiać.
    
    // Tak jak wspomnieliśmy głównym widokiem czyli, w którym umieścimy planszę (siatkę) po której będzie poruszał się wąż, oraz przyciski sterujące, będzie główny widok `view` kontrollera (czyli de fakto naszego ekranu)
    // Zdefiniujmy sobie dwie zmienne pomocnicze
    
    /// Szerokość widoku głównego
    var viewWidth: CGFloat { view.bounds.size.width }
    /// Wysokość widoku głównego
    var viewHeight: CGFloat { view.bounds.size.height }
    
    // Następnym krokiem będzie określenie siatki, po której bedzie poruszał się wąż i w ktorej będzie pojawiała się losowa kropka.
    // Jako punkt odniesienia przyjmijmy sobie, że chcemy uzyskać siatkę o szerokości 20 częściowego węża. To pozwoli określić nam wielkość takiej 1 komórki węża (zamienie będziemy nazywali ją kropką) w odniesieniu do szerokości ekranu, którym dysponujemy czyli `viewWidth`.

    /// Liczba kolumn.
    ///
    /// Określa jak długi wąż zmieści się w naszj siatce jeśli będzie leżał poziomo. Ta wartość pozwoli nam też określić jakiej wielkości powinna być jedna komórka siatki tak żeby zmieścić się w głównym widoku `view`
    let numberOfColumns: Int = 20
    
    /// Szerokość kolumny.
    ///
    /// Wartość przechowujemy w postaci liczby całkowitej `Int` (ang. Integer), ponieważ bedzie ona szerokością komórki naszej siatki.
    /// Dlatego, żeby móc łatwo określić, w której komórce lezy dany widok i uniknąć błedów zaokrąglenia wartości rzeczywistycz `float` (w naszym przypadku `CGFloat`) potrzebujemy wartości całkowitych.
    var columnWidth: Int { Int(viewWidth / CGFloat(numberOfColumns)) }
    
    // Chemy żeby wąż składał sie z kwadratow wiec wysokość wiersza powinna być taka sama jak szerokość kolumny
    
    /// Wysokość wiersza
    var rowHeight: Int { columnWidth }
    
    // Żeby obliczyć liczbę wierszy musimy wiedzieć jaką część ekranu chcemy przeznaczyć na planszę, następnie obliczymy ile wierszy zmieści się w tej przestrzeni.
    // Na iOS niektre urządzenia mają takzwany Notch czyli wcięcie u góry, a na dole jest pole do otwierania menagera aplikacji więc damy sobie u góry i u dołu pewien margines żeby uniknąć przypadku, że na np. iPhone 11 częsc ekranu będzie niewidoczna bądź niedostępna.
    /// Margines górny.
    let topMargin: CGFloat = 30
    /// Margines dolny
    let bottomMargin: CGFloat = 30
    
    // Poza marginesami na dole pod planszą potrzebujemy miejsca na przyciski do sterowania. Niech kazdy z nich ma wysokość 100 żeby było łatwo nimi sterować
    /// Wysokość przycisku sterowania
    let buttonHeight: CGFloat = 100

    // Dajmy guziomok sterującym takie samą wysokość, niech będą kwadratowe
    var buttonWidth: CGFloat { buttonHeight }
    
    // Teraz możemy określić jak bedziemy obliczali liczbę wierszy
    
    /// Liczba wierszy.
    ///
    /// Jest to obliczona ilość całkowitych wierszy mieszczących się w dostępnej na planszę przestrzeni ekranu
    var numberOfRows: Int {
        /// Maksymalna wysokość planszy po odjęciu marginesu górnego, wysokości przycisków i marginesu dolnego
        let maxBoardHeight = viewHeight - topMargin - buttonHeight - bottomMargin
        /// Ilość wierszy jest określona jako maksymalna wysokość podzielona przez określoną wcześniej wysokość wiersza
        let maxNumberOfRows = maxBoardHeight / CGFloat(rowHeight)
        // faktyczna liczba wierszy powinna być całkowita dlatego utniemy część ułamkową jeśli taka występuje pozostawiajac tylko wartość całkowitą
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

        // Ustaw pozycję x planszy tak żeby znajdowała się an środku ekranu, czyli na środku widoku głównego `view`

        /// Pozycja planszy na osi X
        let boardXPosition = (viewWidth - boardWidth)/2

        // Stwórzmy widok planszy

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
    func createCell(at point: ViewPoint = .zero) -> UIView {
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

        // stwórzmy przycisk do resetowania gry
        let button = UIButton(type: .system)
        let buttonPosition = ViewPoint(x: (viewWidth - buttonWidth)/2, // środek ekranu
                                       y: viewHeight - bottomMargin - buttonHeight)
        // ustawienie pozycji i wymiarów przycisku na ekranie
        button.frame = CGRect(origin: buttonPosition, size: buttonSize)

        // ustawienie ograzka/icony dla przycisku
        button.setImage(UIImage(systemName: "repeat"), for: .normal)

        // przypiszmy akcję do przycisku, ktora ma się wykonac w momencie jego tapnięcia czyli dotknięcie ekranu i podniesienie palca w obrębie przycisku
        button.addTarget(self, action: #selector(onResetButton), for: .touchUpInside)

        // dodanie przycisku do widoku głównego
        view.addSubview(button)

        // Odkomentuj aby zobrazować przycisk
        //button.layer.borderWidth = 1

        // przyciski nawigacyjne w lewo i prawo
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
            let buttonPosition = ViewPoint(x: buttonX, y: buttonY)
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
        // współrzędne całkowite czyli na naszej siatce (planszy)
        var gridPosition = GridPoint()
        repeat {
            // Wygeneruj losowe wartiści całkowite z przedziału od 0 do liczby wierszy pomniejszonej o 1
            gridPosition.column = Int.random(in: 0..<numberOfColumns)
            // można to też zapisać w ten sposób
            gridPosition.row = Int.random(in: 0...(numberOfRows-1))

            // następnie sprawdź czy wygenerowane wartości nie skazują na pole siatki które jest aktualnie zajęte, gdy (ang. `while`) tak jest powtórz (ang. `repeat`) proces, jeśli nie, przejdź dalej.
        } while !isGridPositionAvailable(gridPosition)

        let viewPosition = ViewPoint(x: CGFloat(gridPosition.column * columnWidth), y: CGFloat(gridPosition.row * rowHeight))
        let cell = createCell(at: viewPosition)
        return cell
    }

    /// Metoda sprawdzająca czy dana komórka (widok) znajduje się w danym punkcie na siatce.
    func isCell(_ cell: UIView, at position: GridPoint) -> Bool {
        /// Pozycja x comórki w widoku planszy. Rzutujemy ją na wartość całkowitą `Int` (ang. integer), żeby uniknąć błędów zaokrąglenia, tym bardziej, ze będziemy obliczali pozycję na siatce, która jest wartością całkowitą.
        let viewPosition: ViewPoint = cell.frame.origin
        var gridPosition = GridPoint()
        gridPosition.column = Int( viewPosition.x/CGFloat(columnWidth) )
        gridPosition.row = Int( viewPosition.y/CGFloat(rowHeight) )
        return position.column == gridPosition.column && position.row == gridPosition.row
    }

    /// Metoda sprawdzająca czy dany punkt na siatce jest wolny.
    func isGridPositionAvailable(_ position: GridPoint) -> Bool {
        // weź wszystkie komórki węża
        var allCels = snake
        // dodaj komórkę jedzenia sprawdzając czy istnieje. Komórka jedzenia (losowa komórka) może nie istnieć na początku póki jej nie ododamy.
        if let food = food {
            allCels.append(food)
        }

        // poszukaj pierwszej która
        let existingCell = allCels.first(where: { cell in
            self.isCell(cell, at: position)
        })
        return existingCell == nil
    }

    // MARK: - Uruchamianie gry (startowanie)

    weak var timer: Timer?

    // MARK: Zresetuj grę (przywróć wartości startowe)

    func reset() {
        // zatrzymaj poprzednią grę
        timer?.invalidate()

        currentDirection = .down
        // Ustawiamy zmianę kierunku na 0 czyli brak zmiany
        directionChange = .none
        // ustaw obecną pozycję na lewy górny róg siatki
        currentHeadPosition = GridPoint(column: 0, row: 0)

        // przywróc kolor tła pola
        boardView?.backgroundColor = .white

        // usuń poprzednie elementy gry (węża, losową kropkę, pogląd siatki jeśli był załadowany)
        boardView?.subviews.forEach { subview in
            subview.removeFromSuperview()
        }

        snake = []
    }
    
    func start() {
        reset()

        // Stwórzmy 3 początkowe komórki węża i wrzućmy je na pierwsze pole w siadce (lewy górny róg, punkt (0,0))
        for _ in 1...3 {
            // stwórzmy komórkę
            let cell = createCell(at: .zero)
            // dodamy ją do listy komórek węża
            snake.append(cell)
            // dodajmy ją do podwidoków planszy czyli umiesmy na planszy
            boardView?.addSubview(cell)
        }

        // Stwórzmy też komórkę w losowym pustym miejscu na planszy za pomoca metody którą przygotowaliśmy wcześniej, komórka ta bedzie nazywana "jedzeniem" (ang. `food`).
        let firstFood = generateRandomCell()
        // umieśćmy ją na planszy
        boardView?.addSubview(firstFood)
        // przypiszmy jej wartość do zmiennej lokalnej żeby móc się do niej odnieść później
        self.food = firstFood

        /// Odstęp w sekundach pomiędzy kolejnymi rucha zmieniał swoje położenie (gra zostanie ponownie odświeżona)
        let updateInterval: TimeInterval = 0.3
        timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(onMoveSnake(_:)), userInfo: nil, repeats: true)
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
        [.left: // gdy zmieniamy ruch w lewo
            [
                // gdy obecny kierunek ruchu jest w prawo, po zmianie wąż będzie poruszał się w górę ekranu
                .right: .up,
                // gdy obecny kierunek ruchu jest w górę, po zmianie wąż będzie poruszał się w lewą stronę ekranu, itd.
                .up: .left,
                .down: .right,
                .left: .down
            ],
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
        // Przypominam, że przesuwając węża prznosimy ostatni jego element na początek.

        // Bierzemy więc węża ale bez ostatniego elementu ogona, ponieważ bedzie on teraz stanowił głowę, jednak nie wiemy jeszcze gdzie i czy możemy tą głowę umieścić w nowym miejscu, co właśnie sprawdzimy. Głowa może zostać umieszczona tam gdzie dopiero co był koniec ogona.
        let snakeWithoutHead = snake.dropLast()

        // poszukaj pierwszej która
        let existingCell = snakeWithoutHead.first(where: { cell in
            self.isCell(cell, at: position)
        })
        return existingCell != nil
    }

    @objc func onMoveSnake(_ timer: Timer) {
        // wyznaczmy nowy kierunek poruszania się węża
        // jeśli zmiana kierunku `directionChange` posiada wartość inną niż `.none` (żadna) wówczas w mapie zmiany kierunku `directionChangeMap` dla wartości `directionChange` znajdziemy drugą mapę. Ta druga mapa pozwala nam określić jaki jest następny kerunek poruszania jeśli obecnie poruszamy się w kierunku `currentDirection`. Tą wartość przypusujemy do `currentDirection` bo będzie to nasz nowy kierunek.
        if let newDirection = directionChangeMap[directionChange]?[currentDirection] {
            currentDirection = newDirection

            // użyliśmy już informacji o zmianie kierunku do określenia nowego kierunku, więc przywracamy ją do wartości neutralnej
            directionChange = .none
        } else {
            // Jeśli natomiast zmiana kierunku nie nastąpiła (urzytkownik nie wcisnął żadnej strzałki) zmiana kierunku `directionChange` będzie wynosiła `.none` co oznacza brak zmiany a w słowniku `directionChangeMap` nie ma wartości dla klucza `.none`. Wobec tego nie będzie wartości `newDirection`, a `currentDirection` pozostanie bez zmian, wąż porusza się w tym samym kierunku co poprzednio.
            // Tu nie musimy robić nic.
        }

        // Teraz określmy w którym miejscu (w której komórce obok obecnej głowy) powinna znaleźć się głowa węża po wykonaniu przez niego ruchu
        if let move = directions[currentDirection] {
            // Ustaw nową pozycję głowy węża
            currentHeadPosition.column = currentHeadPosition.column + move.column;
            currentHeadPosition.row = currentHeadPosition.row + move.row;

            // sprawdzamy czy wąż nie wyszedł poza planszę
            if currentHeadPosition.column >= 0, currentHeadPosition.column < numberOfColumns,
               currentHeadPosition.row >= 0, currentHeadPosition.row < numberOfRows,
               // sprawdzamy czy wąż nie próbuje ugryźć sam siebie, czyli czy następne położenie głowy węża nie jest w miejscu gdzie znajduje sie już jakaś część węża
               !willSnakeBiteHimself(at: currentHeadPosition) {
                // wąż może iść dalej

                // bierzemy więc ostatni element węża i przenosimy go w nowe miejsce na głowę
                if let newHead = snake.popLast() {
                    // Teraz musimy wziąć pod uwagę, że jeśli wąż poruszy się do przodu, a na pozycji `currentGridPosition` znajduje się jedzenie (losowa komórka) wąż powinien ją zjeść. Zjadanie będzie polegalo na tym, że dodamy zjedoną komórkę na początek węża, jednak nie zmienimy jej pozycji na planszy. Dzięki temu komórka ta będzie w tym samy miejscu (przykryta przez ciało węża) do momentu gdy stanie się ona jego ostatnią częścią. Wtedy zostanie odslonięta na planszy, a w astępnym ruchu stanie się głową (zostanie przeniesiona na początek jako najdalsza część ogona)

                    // Teraz sprawdźmy czy przypadkiem jedzenie nie znajduje się w miejscu gdzie ma pojawić się głowa węża
                    if let food = food, isCell(food, at: currentHeadPosition) {
                        // jeśli tak, dodajemy komórkę jedzenia na początek węża, ale nie zmieniamy jej położenia na planszy, bedzie ona się przesówała pod wężem aż na jego koniec
                        snake.insert(food, at: 0)
                        // jako, że wąż zjadł obecne jedzenie nalezy wygenerować nowe, żeby wąż miał gdzie zmierzać
                        let newFood = generateRandomCell()
                        // następnie umieśćmy nową komórkę z jedzeniem na planszy
                        boardView?.addSubview(newFood)
                        // nie możemy zapomnieć to przypisania jej do zmiennej, bo będziemy jej potrzebować w następnym ruchu
                        self.food = newFood
                    }

                    // Określmy rzeczywiste położenie widoku głowy w widoku planszy
                    let headPosition = ViewPoint(x: currentHeadPosition.column * columnWidth, y: currentHeadPosition.row * rowHeight)
                    // przemieśćmy nową głowę węża w nowe położenie
                    newHead.frame.origin = headPosition
                    // umieśćmy głowę na poczatku węża
                    snake.insert(newHead, at: 0)
                } else {
                    // nie powinien wystąpić przypadek że wąż nie ma ogona bo już na poczatku gry ma on 3 komórki
                    fatalError("Snake has no tail, which mean that there is no snake at all. 😮")
                }
            } else {
                // wąż albo wyszedł za planszę, albo ugryzł sam siebie, kończymy grę poprzez zatrzymanie zegara
                timer.invalidate()
                // zmieniamy tło planszy na czarne w celu zasygnalizowania końca gry
                boardView?.backgroundColor = .black
            }
        }
    }
}

// !!!: Poniższy kod odpowiada tylko za podgląd dzialania kodu w czasie rzeczywistym dzięki automatycznemu podgladowi w Xcode.
// Metoda ta przy prostych aplikacjach jest wygodniejsza niż ciągle uruchamianie aplikacji na symulatorzę będź fizycznym urządzeniu w celu podejrzenia efektu pracy.

// MARK: - Xcode Preview
// Works from Xcode 11 and macOS 10.15
#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, tvOS 13.0, *)
struct ViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = ViewController

    func makeUIViewController(context: Context) -> ViewController {
        // let bundle = Bundle(for: StartViewController.self)
        // let storyboard = UIStoryboard(name: "Main", bundle: bundle)
        // return storyboard.instantiateViewController(identifier: "ViewController")
        return ViewController(nibName: nil, bundle: nil)
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

@available(iOS 13.0, tvOS 13.0, *)
struct UIKitViewControllerProvider: PreviewProvider {
    static var previews: ViewControllerRepresentable { ViewControllerRepresentable() }
}

#endif
