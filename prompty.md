# Instrukcja tworzenia aplikacji LokAI z wykorzystaniem AI asystenta w VS Code

## 0. Przygotowanie środowiska i kontrola wersji

### 0.1. Analiza istniejącego kodu
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

Przed kontynuowaniem pracy nad projektem zawsze zapoznaj się z istniejącym kodem:
- Przejrzyj strukturę projektu i główne pliki
- Zrozum architekturę i style kodowania
- Sprawdź komentarze i dokumentację
- Zapoznaj się z ostatnimi zmianami przez "git log"

RĘCZNIE: Po otrzymaniu kodu od asystenta, przeanalizuj go dokładnie. Upewnij się, że rozumiesz wszystkie elementy przed dodaniem ich do projektu. Wykonaj ręczne poprawki, jeśli kod nie spełnia standardów projektu.
```

### 0.2. Konfiguracja git i GitHub
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

Skonfiguruj repozytorium git dla projektu:
- Inicjalizuj repozytorium: git init
- Dodaj zdalne repozytorium: git remote add origin [URL_REPOZYTORIUM]
- Utwórz plik .gitignore (patrz punkt 0.3)
- Po każdej znaczącej zmianie wykonaj:
  * git add .
  * git commit -m "Tytuł zmiany" -m "Szczegółowy opis wprowadzonych zmian"
  * git push origin main

RĘCZNIE: Upewnij się, że masz zainstalowanego Gita i posiadasz odpowiednie uprawnienia do repozytorium. Po wygenerowaniu kodu przez asystenta, zawsze uruchom aplikację przed commitowaniem zmian, aby potwierdzić działanie kodu.
```

### 0.3. Plik .gitignore dla projektu Flutter
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Utwórz plik .gitignore zawierający:

# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
ios/Pods/
android/app/build/

# IDE
.idea/
.vscode/
*.iml
*.iws
*.ipr
.DS_Store

# Lokalne pliki konfiguracyjne
*.env
*.g.dart
*.freezed.dart

# Pliki modeli AI (duże pliki)
assets/models/*.tflite
assets/models/*.onnx

# Pliki dokumentacji
prompty.md

# Inne
*.log
*.bak

RĘCZNIE: Sprawdź, czy .gitignore został poprawnie skonfigurowany. Upewnij się, że duże pliki modeli, dane testowe i dokumentacja wewnętrzna nie są dodawane do repozytorium.
```

## 1. Konfiguracja projektu i środowiska pracy

### 1.1. Utworzenie projektu Flutter
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

Utwórz nowy projekt Flutter z następującymi parametrami:
- Nazwa aplikacji: LokAI
- Organizacja: com.lokai
- Platforma docelowa: Android i iOS
- Język: Dart
- Włącz obsługę Material 3: tak

RĘCZNIE: Po utworzeniu projektu, otwórz go w edytorze i sprawdź strukturę. Uruchom aplikację na emulatorze lub urządzeniu, aby upewnić się, że szkielet aplikacji działa poprawnie przed wprowadzeniem dodatkowych zmian.
```

### 1.2. Konfiguracja zależności
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Dodaj do pliku pubspec.yaml następujące zależności:
- tflite_flutter: ^0.10.0
- hive: ^2.2.3
- hive_flutter: ^1.1.0
- path_provider: ^2.1.1
- provider: ^6.0.5 (lub flutter_bloc/riverpod)
- go_router: ^10.1.2
- flutter_tts: ^3.8.3
- speech_to_text: ^6.3.0
- shared_preferences: ^2.2.0
- flutter_native_splash: ^2.3.2
- easy_localization: ^3.0.3
- http: ^1.1.0
- google_fonts: ^5.1.0
- flutter_markdown: ^0.6.18

RĘCZNIE: Po dodaniu zależności wykonaj `flutter pub get` aby je pobrać. Sprawdź, czy wystąpiły konflikty między zależnościami i ewentualnie dostosuj ich wersje. Przetestuj aplikację po dodaniu każdej ważnej zależności.
```

### 1.3. Struktura projektu
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

Stwórz następującą strukturę folderów w projekcie:
- lib/ui (dla widgetów i ekranów)
- lib/data (dla modeli danych i repozytoriów)
- lib/services (dla usług i dostawców)
- lib/utils (dla narzędzi pomocniczych)
- lib/models (dla klas modeli danych)
- lib/providers (dla zarządzania stanem aplikacji)
- lib/routing (dla nawigacji)
- lib/ai (dla integracji z modelami AI)

RĘCZNIE: Utwórz puste pliki index.dart w każdym folderze, aby utrzymać strukturę w repozytorium Git. Dodaj do nich podstawowe eksporty. Sprawdź, czy struktura folderów jest zgodna z przyjętymi konwencjami projektu.
```

Po zakończeniu konfiguracji projektu wykonaj komendę "flutter run" aby sprawdzić, czy aplikacja uruchamia się poprawnie. Po udanym uruchomieniu wykonaj commit:
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

git add .
git commit -m "Konfiguracja projektu Flutter" -m "Utworzenie struktury projektu, dodanie zależności i podstawowa konfiguracja"
git push origin main

RĘCZNIE: Upewnij się, że aplikacja działa na różnych urządzeniach testowych (przynajmniej jeden Android i jeden iOS jeśli to możliwe). Rozwiąż wszystkie problemy z konfiguracją przed zatwierdzeniem zmian.
```

## 2. Implementacja architektury aplikacji

### 2.1. Modele danych
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Stwórz klasy modeli danych dla:
- Conversation (id, title, createdAt, updatedAt)
- Message (id, text, isUser, conversationId, timestamp)
- AIModel (id, name, description, size, filePath, downloadedAt, version)
- UserSettings (preferences, selectedModel, themeMode)

RĘCZNIE: Sprawdź, czy modele zawierają wszystkie niezbędne pola i metody. Dostosuj konstruktory i dodaj metody do_json/from_json. Zweryfikuj, czy modele są zgodne z planem architektury danych aplikacji.
```

### 2.2. Implementacja lokalnej bazy danych
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Utwórz adaptery Hive dla modeli danych:
- ConversationAdapter (CRUD dla konwersacji)
- MessageAdapter (CRUD dla wiadomości)
- ModelAdapter (CRUD dla modeli AI)
- SettingsAdapter (zapisywanie ustawień)

Alternatywnie: Zaimplementuj bazę danych SQLite z użyciem pakietu sqflite.

RĘCZNIE: Zainicjalizuj bazę danych w głównym pliku aplikacji. Przetestuj podstawowe operacje CRUD dla każdego modelu, aby upewnić się, że dane są poprawnie zapisywane i odczytywane.
```

### 2.3. Zarządzanie stanem i repozytorium
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Zaimplementuj wzorzec repozytorium dla:
- ConversationRepository (zarządzanie konwersacjami)
- MessageRepository (zarządzanie wiadomościami)
- ModelRepository (zarządzanie modelami AI)
- SettingsRepository (zarządzanie ustawieniami)

Następnie zaimplementuj dostawców stanu (Provider, Bloc lub Riverpod) dla każdego repozytorium.

RĘCZNIE: Przetestuj każde repozytorium, wykonując podstawowe operacje. Upewnij się, że zarządzanie stanem działa poprawnie, a zmiany są prawidłowo propagowane do UI. Napisz proste testy dla najważniejszych funkcji.
```

Po implementacji każdej klasy modelu czy repozytorium upewnij się, że kod kompiluje się poprawnie. Po zakończeniu tej sekcji wykonaj commit:
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

git add .
git commit -m "Implementacja architektury aplikacji" -m "Dodanie modeli danych, repozytoriów i konfiguracja bazy danych"
git push origin main

RĘCZNIE: Upewnij się, że wszystkie testy przechodzą i aplikacja nadal się uruchamia. Sprawdź, czy nie ma wycieków pamięci przy operacjach na danych. Zweryfikuj, że struktura bazy danych jest zgodna z dokumentacją projektu.
```

## 3. Interfejs użytkownika

### 3.1. Implementacja nawigacji
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Utwórz system nawigacji z użyciem go_router lub Navigator 2.0:
- /home (ekran główny)
- /chat/:id (ekran konwersacji)
- /models (biblioteka modeli)
- /settings (ustawienia)

RĘCZNIE: Przetestuj wszystkie ścieżki nawigacji, w tym przechodzenie wstecz i przekazywanie parametrów. Upewnij się, że historia nawigacji jest utrzymywana poprawnie i że można nawigować z każdego ekranu do każdego innego.
```

### 3.2. Ekran główny
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Zaprojektuj i zaimplementuj HomeScreen z:
- ListView z ostatnimi konwersacjami
- FloatingActionButton do tworzenia nowej rozmowy
- Karty z popularnych modeli AI
- CustomScrollView z SliverAppBar dla lepszego UX

RĘCZNIE: Przetestuj UI na różnych rozmiarach ekranów. Sprawdź, czy elementy są prawidłowo układane i czy aplikacja jest responsywna. Upewnij się, że interfejs jest zgodny z zasadami Material Design.
```

### 3.3. Ekran konwersacji
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Stwórz ChatScreen zawierający:
- ListView.builder do wyświetlania wiadomości
- Niestandardowe widgety dla wiadomości użytkownika i AI
- TextField z ikoną wysyłania
- Przycisk aktywacji funkcji głosowych
- CircularProgressIndicator podczas generowania odpowiedzi

RĘCZNIE: Sprawdź, czy wiadomości są poprawnie wyświetlane i przewijane. Przetestuj wprowadzanie tekstu i wysyłanie wiadomości. Upewnij się, że wskaźnik postępu działa poprawnie. Sprawdź, czy interfejs jest przyjazny i intuicyjny.
```

Po implementacji każdego ekranu testuj jego działanie na emulatorze lub urządzeniu fizycznym. Po zakończeniu tej sekcji wykonaj commit:
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

git add .
git commit -m "Implementacja interfejsu użytkownika" -m "Dodanie ekranów głównego i konwersacji, implementacja nawigacji"
git push origin main

RĘCZNIE: Przeprowadź dokładne testy UX z kilkoma użytkownikami testowymi. Zbierz uwagi i wprowadź niezbędne poprawki. Sprawdź wydajność UI na słabszych urządzeniach.
```

## 4. Integracja modeli AI

### 4.1. Zarządzanie modelami
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Stwórz klasę ModelManager do:
- Pobierania modeli z repozytoriów (z użyciem http i path_provider)
- Instalacji i weryfikacji pobranych plików
- Zarządzania cyklem życia modeli
- Monitorowania zajętej przestrzeni dyskowej

RĘCZNIE: Testuj pobieranie modeli używając przykładowych, małych modeli. Sprawdź, czy pliki są poprawnie zapisywane w odpowiednim katalogu. Przetestuj mechanizm weryfikacji integralności pobranych plików.
```

### 4.2. Inicjalizacja TensorFlow Lite
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Zaimplementuj klasę TFLiteService z użyciem tflite_flutter:
- Inicjalizacji interpretera TensorFlow Lite
- Ładowania modeli do pamięci
- Optymalizacji wykonywania operacji z wykorzystaniem GPU/NPU
- Zarządzania zasobami i obsługi błędów

RĘCZNIE: Rozpocznij od prostego modelu testowego, aby zweryfikować działanie interpretera. Monitoruj zużycie zasobów podczas ładowania i używania modeli. Testuj na różnych urządzeniach, aby sprawdzić kompatybilność.
```

Po implementacji mechanizmów zarządzania modelami upewnij się, że aplikacja poprawnie inicjalizuje i ładuje przykładowy model. Po zakończeniu tej sekcji wykonaj commit:
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

git add .
git commit -m "Integracja modeli AI" -m "Implementacja zarządzania modelami i integracja TensorFlow Lite"
git push origin main

RĘCZNIE: Przeprowadź dokładne testy wydajności z różnymi modelami. Zbierz metryki dotyczące czasu ładowania, zużycia pamięci i obciążenia procesora/GPU. Optymalizuj krytyczne ścieżki kodu.
```

## 5. Implementacja głównych funkcjonalności

### 5.1. Mechanizm konwersacji
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Zaimplementuj ConversationService, który będzie:
- Zarządzać aktywną konwersacją
- Przechowywać kontekst rozmowy
- Przekazywać zapytania do odpowiedniego modelu AI
- Zapisywać historię w lokalnej bazie

RĘCZNIE: Przetestuj kompletny przepływ konwersacji, od utworzenia nowej rozmowy po zapisanie historii. Sprawdź, czy kontekst jest poprawnie utrzymywany. Przeprowadź testy z różnymi zapytaniami, aby zweryfikować działanie AI.
```

### 5.2. Tryby pracy
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Zaimplementuj różne tryby pracy aplikacji:
- StandardMode (wykorzystujący tylko lokalne modele)
- PowerSaverMode (optymalizacja pod kątem oszczędzania baterii)
- TurboMode (optymalizacja pod kątem wydajności)

RĘCZNIE: Przeprowadź testy wydajności i zużycia baterii dla każdego trybu. Mierz czas odpowiedzi i zużycie zasobów. Upewnij się, że przełączanie między trybami działa płynnie i nie wpływa negatywnie na bieżącą konwersację.
```

Po implementacji każdej funkcjonalności testuj jej działanie w kontekście całej aplikacji. Po zakończeniu tej sekcji wykonaj commit:
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

git add .
git commit -m "Implementacja głównych funkcjonalności" -m "Dodanie mechanizmu konwersacji i różnych trybów pracy"
git push origin main

RĘCZNIE: Przeprowadź testy funkcjonalne na całej aplikacji. Zweryfikuj, czy wszystkie komponenty współpracują ze sobą. Znajdź i napraw wszelkie problemy z integracją różnych części systemu.
```

## 6. Optymalizacja i dostrajanie

### 6.1. Optymalizacja modeli AI
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Zaimplementuj ModelOptimizer z funkcjami:
- quantizeModel() - kwantyzacja modelu do mniejszej precyzji
- pruneModel() - usuwanie mniej istotnych wag
- compressModel() - kompresja modelu
- benchmarkModel() - testowanie wydajności modelu

RĘCZNIE: Porównaj wydajność i jakość wyników przed i po optymalizacji. Przeprowadź testy na różnych urządzeniach. Przygotuj raporty z wynikami benchmarków. Znajdź optymalny kompromis między rozmiarem, wydajnością a jakością.
```

### 6.2. Zarządzanie pamięcią
```plaintext
# MODEL: GitHub Copilot 3.7 - Edits

Stwórz MemoryManager do:
- Monitorowania zużycia pamięći RAM
- Automatycznego zwalniania nieużywanych zasobów
- Inteligentnego cachowania danych
- Optymalizacji wydajności aplikacji

RĘCZNIE: Użyj narzędzi profilujących do monitorowania zużycia pamięci. Testuj aplikację pod długotrwałym użytkowaniem, aby wykryć wycieki pamięci. Optymalizuj słabe punkty w zarządzaniu zasobami.
```

Przeprowadź testy wydajnościowe po optymalizacji modeli i zarządzania pamięcią. Po zakończeniu tej sekcji wykonaj commit:
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

git add .
git commit -m "Optymalizacja i dostrajanie" -m "Implementacja optymalizacji modeli i zarządzania pamięcią"
git push origin main

RĘCZNIE: Przeprowadź dogłębne testy optymalizacji na różnych urządzeniach. Zmierz i porównaj wskaźniki wydajności przed i po optymalizacji. Dokładnie monitoruj wpływ zmian na stabilność aplikacji.
```

## 7. Finalizacja i publikacja

### 7.1. Przygotowanie wersji produkcyjnej
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

Skonfiguruj aplikację do wydania:
- Optymalizacja rozmiaru pakietu
- Code shrinking i obfuskacja
- Konfiguracja podpisów dla Android i iOS
- Generowanie plików instalacyjnych (AAB/APK dla Android, IPA dla iOS)

RĘCZNIE: Sprawdź rozmiar finalnej aplikacji. Przetestuj działanie wersji produkcyjnej na wielu urządzeniach. Upewnij się, że obfuskacja nie wpłynęła negatywnie na funkcjonalność. Przygotuj klucze podpisujące i konfigurację wydania.
```

### 7.2. Testowanie przedprodukcyjne
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

Przeprowadź ostateczne testy:
- Testy wydajności na różnych urządzeniach
- Testy zużycia baterii i pamięci
- Testy kompatybilności z różnymi wersjami systemów
- Testy dostępności

RĘCZNIE: Przeprowadź kompleksowe testowanie na wszystkich docelowych platformach i wersjach systemów. Zaangażuj grupę beta-testerów. Zbierz i analizuj zgłoszenia błędów. Sprawdź zgodność z wytycznymi dostępności.
```

### 7.3. Materiały do publikacji
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

Przygotuj zasoby do sklepów:
- Ikony aplikacji (Android Adaptive Icons, iOS App Icons)
- Zrzuty ekranu dla różnych rozmiarów urządzeń
- Film promocyjny
- Opisy aplikacji dla różnych języków

RĘCZNIE: Upewnij się, że wszystkie materiały marketingowe są wysokiej jakości. Sprawdź, czy zrzuty ekranu są aktualne i przedstawiają najnowszą wersję aplikacji. Zweryfikuj, czy opisy są zgodne z faktycznymi funkcjami.
```

Przed finalnym committem przeprowadź kompleksowe testy na różnych urządzeniach i platformach. Po zakończeniu przygotowań do publikacji wykonaj commit:
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

git add .
git commit -m "Przygotowanie do publikacji" -m "Finalizacja aplikacji, optymalizacja, przygotowanie materiałów marketingowych"
git push origin main

RĘCZNIE: Wykonaj ostateczne sprawdzenie wszystkich aspektów aplikacji. Upewnij się, że wszystkie wymagane zasoby są dołączone do pakietu. Przetestuj proces publikacji w środowisku testowym, jeśli to możliwe.
```

Każdy z powyższych punktów można przekształcić w polecenie dla asystenta AI w VS Code, np.: 
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

"Wygeneruj strukturę projektu Flutter z folderami wymienionymi w punkcie 1.3, a następnie skonfiguruj plik .gitignore zgodnie z punktem 0.3" 
lub "Zaimplementuj klasę ConversationService zgodnie z wymaganiami w punkcie 5.1, a następnie przeprowadź podstawowe testy, aby upewnić się, że implementacja działa poprawnie".
```

## Wskazówki do pracy z projektem:

### Testowanie aplikacji
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

Po każdej znaczącej zmianie testuj aplikację, aby upewnić się, że:
- Aplikacja uruchamia się bez błędów
- Nowe funkcjonalności działają zgodnie z oczekiwaniami
- Istniejące funkcjonalności nie zostały uszkodzone (regresja)
- UI jest responsywny i zgodny z projektem

RĘCZNIE: Stwórz listę kontrolną kluczowych funkcji do przetestowania po każdej większej zmianie. Automatyzuj testy, gdzie to możliwe. Utrzymuj dziennik napotkanych błędów i ich rozwiązań.
```

### Inkrementalne budowanie funkcjonalności
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

Implementuj funkcjonalności małymi krokami:
- Zacznij od minimalnej działającej wersji
- Testuj po każdym kroku
- Refaktoryzuj kod, jeśli jest to konieczne
- Rozwijaj funkcjonalność iteracyjnie

RĘCZNIE: Planuj rozwój każdej funkcjonalności z podziałem na małe, testowalne części. Nie przechodź do kolejnego etapu, dopóki obecny nie działa poprawnie. Regularnie refaktoryzuj kod, aby utrzymać jego czystość.
```

### Reagowanie na błędy
```plaintext
# MODEL: GitHub Copilot 3.7 - Agent

W przypadku napotkania błędów:
- Analizuj logi błędów (flutter logs)
- Używaj debuggera do zlokalizowania problemu
- Twórz testy jednostkowe dla naprawionych błędów
- Dokumentuj rozwiązania napotkanych problemów

RĘCZNIE: Utrzymuj repozytorium znanych błędów wraz z ich rozwiązaniami. Implementuj zabezpieczenia przed powtórzeniem się naprawionych błędów. Regularnie przeglądaj kod pod kątem potencjalnych problemów.
```