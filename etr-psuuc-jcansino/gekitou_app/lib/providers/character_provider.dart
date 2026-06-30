import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/anilist_service.dart';

class CharacterProvider extends ChangeNotifier {
  final AniListService _aniListService = AniListService();

  List<Character> _allCharacters = [];
  List<Character> _filteredCharacters = [];
  Character? _selectedCharacter;
  bool _isLoading = false;
  String? _error;
  String _selectedDifficulty = 'normal';

  List<Character> get allCharacters => _allCharacters;
  List<Character> get filteredCharacters => _filteredCharacters;
  Character? get selectedCharacter => _selectedCharacter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedDifficulty => _selectedDifficulty;

  Future<void> fetchCharacters() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _allCharacters = await _aniListService.getTopCharacters();
      _filteredCharacters = _allCharacters;

      filterByDifficulty('normal');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByDifficulty(String difficulty) {
    try {
      _selectedDifficulty = difficulty;

      if (difficulty == 'all') {
        _filteredCharacters = _allCharacters;
      } else {
        _filteredCharacters = _allCharacters
            .where((char) => char.difficulty == difficulty)
            .toList();
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Character?> getRandomCharacter({String? difficulty}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final character = difficulty != null
          ? await _aniListService.getRandomCharacter(difficulty: difficulty)
          : await _aniListService.getRandomCharacter();

      _isLoading = false;
      notifyListeners();

      return character;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void selectCharacter(Character character) {
    _selectedCharacter = character;
    _error = null;
    notifyListeners();
  }

  Future<List<Character>> getCharactersByDifficulty(String difficulty) async {
    try {
      return await _aniListService.getCharactersByDifficulty(difficulty);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  void searchCharacters(String query) {
    if (query.isEmpty) {
      _filteredCharacters = _allCharacters;
    } else {
      _filteredCharacters = _allCharacters
          .where(
            (char) => char.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  Future<Character?> getCharacterById(String id) async {
    try {
      return await _aniListService.getCharacterById(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Map<String, int> getDifficultyStats() {
    return {
      'easy': _allCharacters.where((c) => c.difficulty == 'easy').length,
      'normal': _allCharacters.where((c) => c.difficulty == 'normal').length,
      'hard': _allCharacters.where((c) => c.difficulty == 'hard').length,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetSelection() {
    _selectedCharacter = null;
    notifyListeners();
  }
}
