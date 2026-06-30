// API Endpoints
const String ANILIST_API_URL = 'https://graphql.anilist.co';

// Character settings
const int TOP_CHARACTERS_COUNT = 50;
const int CHARACTER_IMAGE_SIZE = 400; // pixels

// Difficulty tiers - based on AniList popularity ranking
const Map<String, Map<String, int>> DIFFICULTY_TIERS = {
  'easy': {'minPopularity': 0, 'maxPopularity': 15},
  'normal': {'minPopularity': 15, 'maxPopularity': 35},
  'hard': {'minPopularity': 35, 'maxPopularity': 50},
};

// Battle settings
const int BASE_PLAYER_HP = 100;
const int HEAL_AMOUNT = 25;
const double SPECIAL_MULTIPLIER = 1.5;
const int TURNS_TIMEOUT_SECONDS = 30;

// Stat scaling
const int MIN_STAT_HP = 80;
const int MAX_STAT_HP = 120;
const int MIN_STAT_ATTACK = 15;
const int MAX_STAT_ATTACK = 25;
const int MIN_STAT_DEFENSE = 10;
const int MAX_STAT_DEFENSE = 18;
const int MIN_STAT_SPEED = 12;
const int MAX_STAT_SPEED = 20;

// UI settings
const int ANIMATION_DURATION_MS = 300;
const int BATTLE_TURN_DELAY_MS = 1000;

// Firestore collections
const String USERS_COLLECTION = 'users';
const String BATTLES_SUBCOLLECTION = 'battles';
const String CHARACTERS_COLLECTION = 'characters';
const String LEADERBOARD_COLLECTION = 'leaderboard';

// Error messages
const String ERROR_NO_CHARACTERS = 'No characters available at the moment.';
const String ERROR_NETWORK = 'Network error. Please check your connection.';
const String ERROR_AUTH_FAILED = 'Authentication failed.';
const String ERROR_FIRESTORE = 'Database error. Please try again.';
