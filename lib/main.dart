import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());//metoda uruchamiająca całą aplikacje
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {//podstawowy budowniczy aplikacji po nim wszystkie widety dziedzicza czyba że to zmienimy
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'newRandomWord',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),//Jaki kontent sie uruchamia wraz z włączeniem aplikacji
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();//zmienna przechowująca parę randomowych słów

  void getNext() {//metoda która tworzy kolejną parę słów
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];//tablica przechwująca ulubione słowa

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();//funkcja lambda przechowująca obecny widok aplikacji
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;//zmienna przechowująca obecny widok aplikacji 0- home, 1- favorites

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {//blok switch do przechodzenia pomiędzy widokami
      case 0:
        page = GeneratorPage();//generowanie nowych słów
      case 1:
        page = FavoritesPage();//przechowywanie ulubionych
      default:
        throw UnimplementedError('no widget for $selectedIndex');//wynik błędu gdyby pojawił się inny index niż 0 lub 1
    }

    return LayoutBuilder(builder: (context, constraints) {//budowniczy całego widoku aplikacji
      return Scaffold(
        body: Row(
          children: [
            SafeArea(//side bar z ikonami dzieki którym możemy przechodzić na inne widoki
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(//obszar na którym wyświetlane są pary słów
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {// widok generatora par
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;// zmienna przechowująca interesujące nas słowo

    IconData icon;
    if (appState.favorites.contains(pair)) {//blok if do zmiany ikony like
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(//stylowanie widoku aplikacji
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(// przycisk, po kliknięciu wywołuję metode getNext do stworzenia nowej pray słów
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {// nie zrozumiałem do końca po co to jest, myślę że to coś do tworzenia i wyświetlania par słów
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {// Widok ulubionych słów
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {// informacja dla użytkownika że jeszcze nie polubił żadnego słowa
      return Center(
        child: Text('Nie posiadasz jeszcze żadnych ulubionych słów.'),
      );
    }

    return ListView(// lista ulubionych par słów
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('Już masz '
              '${appState.favorites.length} ulubionych:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}