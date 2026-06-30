import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Manages all game audio — BGM and SFX.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _muted = false;
  double _bgmVolume = 0.4;
  double _sfxVolume = 0.7;

  bool get isMuted => _muted;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.setVolume(_bgmVolume);
    await _sfxPlayer.setVolume(_sfxVolume);
  }

  // ── BGM ───────────────────────────────────────────────────────────────────

  Future<void> playBgm(GameMusic music) async {
    if (_muted) return;
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.play(AssetSource(music.path));
    } catch (e) {
      debugPrint('BGM error: $e');
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  Future<void> resumeBgm() async {
    if (!_muted) await _bgmPlayer.resume();
  }

  // ── SFX ───────────────────────────────────────────────────────────────────

  Future<void> playSfx(GameSfx sfx) async {
    if (_muted) return;
    try {
      await _sfxPlayer.play(AssetSource(sfx.path));
    } catch (e) {
      debugPrint('SFX error: $e');
    }
  }

  // ── Volume & mute ─────────────────────────────────────────────────────────

  Future<void> setMuted(bool muted) async {
    _muted = muted;
    await _bgmPlayer.setVolume(muted ? 0 : _bgmVolume);
    await _sfxPlayer.setVolume(muted ? 0 : _sfxVolume);
  }

  Future<void> setBgmVolume(double volume) async {
    _bgmVolume = volume;
    if (!_muted) await _bgmPlayer.setVolume(volume);
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume;
    if (!_muted) await _sfxPlayer.setVolume(volume);
  }

  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}

// ─── Music tracks ─────────────────────────────────────────────────────────────

enum GameMusic {
  mainMenu,
  dungeon,
  combat,
  boss,
  victory,
  gameOver,
}

extension GameMusicX on GameMusic {
  String get path {
    switch (this) {
      case GameMusic.mainMenu:
        return 'audio/bgm_main_menu.mp3';
      case GameMusic.dungeon:
        return 'audio/bgm_dungeon.mp3';
      case GameMusic.combat:
        return 'audio/bgm_combat.mp3';
      case GameMusic.boss:
        return 'audio/bgm_boss.mp3';
      case GameMusic.victory:
        return 'audio/bgm_victory.mp3';
      case GameMusic.gameOver:
        return 'audio/bgm_game_over.mp3';
    }
  }
}

// ─── Sound effects ────────────────────────────────────────────────────────────

enum GameSfx {
  attack,
  critHit,
  skillCast,
  itemUse,
  playerHurt,
  enemyDeath,
  levelUp,
  menuSelect,
  menuBack,
  chestOpen,
  shopBuy,
  flee,
}

extension GameSfxX on GameSfx {
  String get path {
    switch (this) {
      case GameSfx.attack:
        return 'audio/sfx_attack.mp3';
      case GameSfx.critHit:
        return 'audio/sfx_crit.mp3';
      case GameSfx.skillCast:
        return 'audio/sfx_skill.mp3';
      case GameSfx.itemUse:
        return 'audio/sfx_item.mp3';
      case GameSfx.playerHurt:
        return 'audio/sfx_hurt.mp3';
      case GameSfx.enemyDeath:
        return 'audio/sfx_death.mp3';
      case GameSfx.levelUp:
        return 'audio/sfx_levelup.mp3';
      case GameSfx.menuSelect:
        return 'audio/sfx_select.mp3';
      case GameSfx.menuBack:
        return 'audio/sfx_back.mp3';
      case GameSfx.chestOpen:
        return 'audio/sfx_chest.mp3';
      case GameSfx.shopBuy:
        return 'audio/sfx_buy.mp3';
      case GameSfx.flee:
        return 'audio/sfx_flee.mp3';
    }
  }
}
