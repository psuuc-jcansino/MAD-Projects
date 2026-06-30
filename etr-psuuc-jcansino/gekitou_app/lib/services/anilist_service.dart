import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/character_model.dart';
import '../config/constants.dart';

class AniListService {
  static const String _baseUrl = ANILIST_API_URL;

  static const String _topCharactersQuery = '''
    query {
      Page(page: 1, perPage: 50) {
        characters(sort: [FAVOURITES_DESC]) {
          id
          name {
            full
          }
          image {
            large
          }
        }
      }
    }
  ''';

  Future<List<Character>> getTopCharacters() async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'query': _topCharactersQuery}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['errors'] != null) {
          throw Exception('GraphQL Error: ${json['errors']}');
        }

        final characters = <Character>[];
        final characterList = json['data']['Page']['characters'] as List;

        for (int i = 0; i < characterList.length; i++) {
          final charData = characterList[i];
          try {
            final character = Character.fromAniList(
              id: charData['id'].toString(),
              name: charData['name']['full'] ?? 'Unknown',
              imageUrl: charData['image']?['large'],
              popularity: i + 1,
            );
            characters.add(character);
          } catch (e) {
            print('Error parsing character: $e');
            continue;
          }
        }

        return characters;
      } else {
        throw Exception('Failed to load characters: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching characters: $e');
    }
  }

  Future<List<Character>> getCharactersByDifficulty(String difficulty) async {
    final allCharacters = await getTopCharacters();

    final range = DIFFICULTY_TIERS[difficulty] as Map<String, dynamic>;
    final minPopularity = range['minPopularity'] as int;
    final maxPopularity = range['maxPopularity'] as int;

    return allCharacters.where((char) {
      return char.popularity >= minPopularity &&
          char.popularity <= maxPopularity;
    }).toList();
  }

  Future<Character> getRandomCharacter({String? difficulty}) async {
    late List<Character> characters;

    if (difficulty != null) {
      characters = await getCharactersByDifficulty(difficulty);
    } else {
      characters = await getTopCharacters();
    }

    if (characters.isEmpty) {
      throw Exception('No characters available');
    }

    final random = DateTime.now().millisecond % characters.length;
    return characters[random];
  }

  Future<List<Character>> getCharactersByPopularityRange({
    required int minPopularity,
    required int maxPopularity,
  }) async {
    final allCharacters = await getTopCharacters();

    return allCharacters.where((char) {
      return char.popularity >= minPopularity &&
          char.popularity <= maxPopularity;
    }).toList();
  }

  Future<Character?> getCharacterById(String id) async {
    final allCharacters = await getTopCharacters();

    try {
      return allCharacters.firstWhere((char) => char.id == id);
    } catch (e) {
      return null;
    }
  }
}
