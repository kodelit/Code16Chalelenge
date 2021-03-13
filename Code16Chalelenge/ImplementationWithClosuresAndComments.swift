//
//  Source.swift
//  Code16Chalelenge
//
//  Created by Grzegorz Maciak on 06/03/2021.
//

import UIKit

/// Funkcja uruchamiająca grę.
///
/// Kod w wersji:
/// - zaimplementowanej w jednej metodzie,
/// - bloki/closures zamiast funkcji
/// - dokumentacja
func loadDocumentedDemoCode(in view: UIView) {
    // Dla uproszczenia nazwijmy sobie komórką (ang. cell) każdą pojedyńczą część węża jak również obiekt pojawiający się na planszy, który ma być przez niego "zjedzony".
    // Komórki niech będą kwadratowe.
    // Komórki te ułożone obok siebie stworza siatkę, która będzie naszą planszą, po której będzie poruszał się wąż.

    // Bedziemy mieli dwa układy współrzędnych:
    // - pierwszy to układ współrzędnych widoku `view`, w którym będziemy układali kazdy element (komórki węża i losowa komórka na planszy do "zjedzenia")

    // Dla czytelności nazwiemy sobie ten typ `ViewPoint` (punkt w widoku, we współrzędnych widoku), ktory będzie niczym innym jak domyślny iOS typ punktu czyli `CGPoint`:

    /// Punkt na siatce planszy.
    ///
    /// Posiada współrzędne rzeczywiste (w programowaniu nazywamy je zmiennoprzecinkowymi, ang. `floating point`, w skrócie `float`, w przypadku współrzędnych, rozmaru, ramki widoku mamy zawsze przedrostek `CG` czyli np. `CGPoint`, `CGRect`, `CGFloat`).
    typealias ViewPoint = CGPoint // CGPoint(x: CGFloat, y: CGFloat)

    // - drugi to układ współrzędnych na siatce planszy, po której będzie poruszał się wąż, jeden punkt na siatce to jedna komórka (1 element węża)

    // Dla czytelności nazwiemy sobie ten typ jako `GridPoint` (punkt na siadce, czyli numer kolumny i wiersza), ktory będzie niczym innym jak domyślny iOS typ punktu czyli `CGPoint`

    /// Punkt na siatce planszy.
    ///
    /// Posiada współrzędne całkowite (w programowaniu nazywamy je z anglielskiego `Integer`, w skrócie `Int`).
    struct GridPoint {
        var column: Int = 0
        var row: Int = 0
    }

    // Zdefiniujemy sobie też od razu dwa typy które pomogą nam określić kierunek i zmianę kierunku, w ktorym porusza sie wąż.

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

    // W aplikacjach iOS ekrany składają się z widoków, widok to element który ma określone położenie i wymiar, oraz może zawierać w sobie inne widoki. Widoki zagnieżdza sie po to, żeby łatwiej było okreslić ich położenie względem siebie, np. w naszym przypadku łatwiej nam będzie określić położenie węża w widoku planszy `boardView`, gdzie będą tylko elementy zwiazane z wężem, niż w widoku głównym `view` gdzie będą też przyciski, które musieli byśmy wziąć pod uwagę w obliczeniach, pamiętając że musi na nie być miejsce. Widoki mają dużo więcej innych funkcji i możliwości ale w tej chwili nie bedziemy się na nich skupiać.

    // Tak jak wspomnieliśmy głównym widokiem czyli, w którym umieścimy planszę (siatkę) po której będzie poruszał się wąż, oraz przyciski sterujące, będzie dostarczony jako parametr w naszej funkcji czyli widok `view`
    // Zdefiniujmy sobie dwie zmienne pomocnicze

    /// Szerokość widoku głównego
    let viewWidth: CGFloat = view.bounds.size.width
    /// Wysokość widoku głównego
    let viewHeight: CGFloat = view.bounds.size.height

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
    let columnWidth: Int = Int(viewWidth / CGFloat(numberOfColumns))

    // Chemy żeby wąż składał sie z kwadratow wiec wysokość wiersza powinna być taka sama jak szerokość kolumny

    /// Wysokość wiersza
    let rowHeight: Int = columnWidth

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
    let buttonWidth: CGFloat = buttonHeight

    // Teraz możemy określić jak bedziemy obliczali liczbę wierszy

    /// Liczba wierszy.
    ///
    /// Jest to obliczona ilość całkowitych wierszy mieszczących się w dostępnej na planszę przestrzeni ekranu
    let numberOfRows: Int = {
        /// Maksymalna wysokość planszy po odjęciu marginesu górnego, wysokości przycisków i marginesu dolnego
        let maxBoardHeight = viewHeight - topMargin - buttonHeight - bottomMargin
        /// Ilość wierszy jest określona jako maksymalna wysokość podzielona przez określoną wcześniej wysokość wiersza
        let maxNumberOfRows = maxBoardHeight / CGFloat(rowHeight)
        // faktyczna liczba wierszy powinna być całkowita dlatego utniemy część ułamkową jeśli taka występuje pozostawiajac tylko wartość całkowitą
        return Int(maxNumberOfRows)
    }()

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

    // MARK: - Tworzenie komórki siatki na planszy (Komórek węża i losowej komórki)

    // W następnej kolejności zaimplementujemy sobie anonimowa funkcję, która będzie tworzyła nam komórkę w danym punkcie.
    // W Swift taka funkcja nazywa się `Closur` (pl. `domkniecie` ale zasadniczo nie tłumaczy się tego), w Objective-C taka funkcja nazywała sie blokiem (bo jest to jakiś blok kodu) i ta nazwa jest też używana czasem w Swift pośród starszych programistów i też lepiej brzmi po polsku, w innych języach operuje się też nazwą `wyrażenie lambda`.
    // Tą anonimową funkcję przyiszemy sobie jednak to zmiennej co pozwoli nam użyć jej wielokrotnie, podobnie jak zwykłej funkcji.

    /// Funkcja tworzaca nową komórkę siatki w podanym punkcie siatki badź w punkcie zerowym (piwerszye pole siatki w lewym gornym rogu).
    ///
    /// - parameter point: Punkt w którym powinna się pojawić kropka, określony jako współrzędne w granicach widoku. Można pominąć parametr `point` co spowoduje utworzenie kropki  punkcie (0,0) (lewy górny róg widoku)
    let createCellAt: (_ point: ViewPoint) -> UIView

    // Powyżej mamy definicję takiej zmiennej przechowującej referencję do funkcji (a w zasadzie w Swift to będzie stała `let` a nie zmienna `var` ponieważ jej wartość przypisujemy tylko raz, a potem jej już nigdy nie zmieniamy).
    // Poniżej przypiszemy sobie do tej zmiennej wartość, która będzie naszą funkcją. Rozdzielimy to tylko raz, dla zobrazowania, kolejne tego typu zmienne/stałe będziemy już przypisywali w jednym wierszu.

    createCellAt = { point in
        let cell = UIView(frame: CGRect(origin: point, size: CGSize(width: columnWidth, height: rowHeight)))
        // Ustawiamy kolor tła komórki na zielony
        cell.backgroundColor = .green;
        // ustawiamy grubość ramki
        cell.layer.borderWidth = 1
        return cell
    }

    // Teraz gdy możemy sobie stworzyć i wyświetlić komórkę siatki możemy tez eksperymentalnie zobrazować sobie jak taka siatka wygladała by na ekranie gdybyśmy wypelnili ją całą komórkami

    // Odkomentuj kolejne wiersze aby zobrazować siatkę

    //var c = 0
    //var r = 0
    //for c in 0..<numberOfColumns {
    //    for r in 0..<numberOfRows {
    //        let cellPosition = ViewPoint(x: columnWidth * c, y: rowHeight * r)
    //        let cell = createCellAt(cellPosition)
    //        cell.backgroundColor = .lightGray
    //        boardView.addSubview(cell)
    //
    //        // Odkomentuj kolejne wiersze jeśli chcesz zobaczyć numery column (lub wierszy jeśli zmienisz text z "\(c)" na "\(r)"
    //
    //        //let label = UILabel(frame: cell.bounds)
    //        //label.textAlignment = .center
    //        //label.text = "\(c)" // or "\(r)"
    //        //cell.addSubview(label)
    //    }
    //}

    // Następnie zdefiniujemy kilka kolejnych stałych przechowywujących referencje do funkcji pomocniczych

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
        // zdefiniujemy sobie na poczatku pustą funkcję spawdzającą czy dana pozycja na siatce jest dostępna czyli nie jest zajmowana przez inną komórkę.
        //return false

        // Teraz gdy skończyliśmy już implementować funcję `generateRandomCell` możemy zaimplementować cialo funkcji sprawdzającej
        // Żeby sprawdzić czy pozycja na siatce jest dostępna musimy znać położenie komórek węża i jego jedzenia:

        // weź wszystkie komórki węża
        var allCels = snake
        // dodaj komórkę jedzenia sprawdzając czy istnieje. Komórka jedzenia (losowa komórka) może nie istnieć na początku póki jej nie ododamy.
        if let food = food {
            allCels.append(food)
        }

        // poszukaj pierwszej która
        let existingCell = allCels.first(where: { cell in
            isCell(cell, position)
        })
        return existingCell == nil
    }

    /// Funkcja generuje komórkę w losowym PUSTYM miejscu na planszy
    let generateRandomCell: () -> UIView = {
        // współrzędne całkowite czyli na naszej siatce (planszy)
        var gridPosition = GridPoint()
        repeat {
            // Wygeneruj losowe wartiści całkowite z przedziału od 0 do liczby wierszy pomniejszonej o 1
            gridPosition.column = Int.random(in: 0..<numberOfColumns)
            // można to też zapisać w ten sposób
            gridPosition.row = Int.random(in: 0...(numberOfRows-1))

            // następnie sprawdź czy wygenerowane wartości nie skazują na pole siatki które jest aktualnie zajęte, gdy (ang. `while`) tak jest powtórz (ang. `repeat`) proces, jeśli nie, przejdź dalej.
            // żeby to wykonać napiszemy sobie póki co pustą funkcję sprawdzającą, którą dokończymy za chwilę
        } while !isGridPositionAvailable(gridPosition)

        let viewPosition = ViewPoint(x: CGFloat(gridPosition.column * columnWidth), y: CGFloat(gridPosition.row * rowHeight))
        let cell = createCellAt(viewPosition)
        return cell
    }

    // MARK: - Uruchamianie gry (startowanie)

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
    /// Zmienna przechowująca wartość określającą zmianę kierunku podczas najbliższego odświerzenia gry.
    /// Jesli użytkownik przyciśnie jedną ze strzałek na ekranie zmienna ta zmieni wartość na `.left` (lewo) lub `.right` (prawo), a po kolejnym odświerzeniu ekranu gry zostanie przywrócona wartość `.none`
    var directionChange: DirectionChange = .none

    weak var timer: Timer?

    let start: () -> Void = { [weak boardView] in
        // MARK: Zresetuj grę (przywróć wartości startowe)

        // zatrzymaj poprzednią grę
        timer?.invalidate()

        /// Obecny kierunek ruchu węża.
        var currentDirection: Direction = .down

        /// Położenie głowy weza na siatce. Pozycja startowa w lewym górnym rogu siatki.
        var currentHeadPosition = GridPoint(column: 0, row: 0)

        // usuń węża nadpisując go pustą tablicą
        snake = []

        // przywróc kolor tła pola
        boardView?.backgroundColor = .white

        // usuń poprzednie elementy gry (węża, losową kropkę, pogląd siatki jeśli był załadowany)
        boardView?.subviews.forEach { subview in
            subview.removeFromSuperview()
        }

        let willSnakeBiteHimselfAt: (_ position: GridPoint) -> Bool = { position in
            // Przypominam, że przesuwając węża prznosimy ostatni jego element na początek.

            // Bierzemy więc węża ale bez ostatniego elementu ogona, ponieważ bedzie on teraz stanowił głowę, jednak nie wiemy jeszcze gdzie i czy możemy tą głowę umieścić w nowym miejscu, co właśnie sprawdzimy. Głowa może zostać umieszczona tam gdzie dopiero co był koniec ogona.
            let snakeWithoutHead = snake.dropLast()

            // poszukaj pierwszej która
            let existingCell = snakeWithoutHead.first(where: { cell in
                isCell(cell, position)
            })
            return existingCell != nil
        }

        // Stwórzmy 3 początkowe komórki węża i wrzućmy je na pierwsze pole w siadce (lewy górny róg, punkt (0,0))
        for _ in 1...3 {
            // stwórzmy komórkę
            let cell = createCellAt(.zero)
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
        food = firstFood

        /// Odstęp w sekundach pomiędzy kolejnymi rucha zmieniał swoje położenie (gra zostanie ponownie odświeżona)
        let updateInterval: TimeInterval = 0.3
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
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
                currentHeadPosition.column = currentHeadPosition.column + move.column;
                currentHeadPosition.row = currentHeadPosition.row + move.row;

                // sprawdzamy czy wąż nie wyszedł poza planszę
                if currentHeadPosition.column >= 0, currentHeadPosition.column < numberOfColumns,
                   currentHeadPosition.row >= 0, currentHeadPosition.row < numberOfRows,
                   // sprawdzamy czy wąż nie próbuje ugryźć sam siebie, czyli czy następne położenie głowy węża nie jest w miejscu gdzie znajduje sie już jakaś część węża
                   !willSnakeBiteHimselfAt(currentHeadPosition) {
                    // wąż może iść dalej

                    // bierzemy więc ostatni element węża i przenosimy go w nowe miejsce na głowę
                    if let newHead = snake.popLast() {
                        // Teraz musimy wziąć pod uwagę, że jeśli wąż poruszy się do przodu, a na pozycji `currentGridPosition` znajduje się jedzenie (losowa komórka) wąż powinien ją zjeść. Zjadanie będzie polegalo na tym, że dodamy zjedoną komórkę na początek węża, jednak nie zmienimy jej pozycji na planszy. Dzięki temu komórka ta będzie w tym samy miejscu (przykryta przez ciało węża) do momentu gdy stanie się ona jego ostatnią częścią. Wtedy zostanie odslonięta na planszy, a w astępnym ruchu stanie się głową (zostanie przeniesiona na początek jako najdalsza część ogona)

                        // Teraz sprawdźmy czy przypadkiem jedzenie nie znajduje się w miejscu gdzie ma pojawić się głowa węża
                        if let oldFood = food, isCell(oldFood, currentHeadPosition) {
                            // jeśli tak, dodajemy komórkę jedzenia na początek węża, ale nie zmieniamy jej położenia na planszy, bedzie ona się przesówała pod wężem aż na jego koniec
                            snake.insert(oldFood, at: 0)
                            // jako, że wąż zjadł obecne jedzenie nalezy wygenerować nowe, żeby wąż miał gdzie zmierzać
                            let newFood = generateRandomCell()
                            // następnie umieśćmy nową komórkę z jedzeniem na planszy
                            boardView?.addSubview(newFood)
                            // nie możemy zapomnieć to przypisania jej do zmiennej, bo będziemy jej potrzebować w następnym ruchu
                            food = newFood
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
    // stwórzmy przycisk do resetowania gry
    let button = UIButton(type: .system, primaryAction: resetButtonAction)
    let buttonPosition = ViewPoint(x: (viewWidth - buttonWidth)/2, // środek ekranu
                                   y: viewHeight - bottomMargin - buttonHeight)

    // ustawienie pozycji i wymiarów przycisku na ekranie
    button.frame = CGRect(origin: buttonPosition, size: buttonSize)

    // ustawienie ograzka/icony dla przycisku
    button.setImage(UIImage(systemName: "repeat"), for: .normal)

    // dodanie przycisku do widoku głównego
    view.addSubview(button)

    // Odkomentuj aby zobrazować przycisk
    //button.layer.borderWidth = 1

    // przyciski nawigacyjne w lewo i prawo
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

        // Odkomentuj aby zobrazować przycisk
        //button.layer.borderWidth = 1
    }
}
