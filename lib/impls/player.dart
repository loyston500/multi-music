import 'package:just_audio/just_audio.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Player extends AudioPlayer {
  String? name;
  int? color;
  String? url;
  Player();

  factory Player.fromJson(Map<String, dynamic> json) {
    var player = Player()
      ..name = json['name'] as String?
      ..color = json['color'] != null
          ? int.tryParse(json['color'] as String, radix: 16)
          : null;

    player.setSpeed(json['speed'] as double? ?? 1.0);
    if (json['url'] != null) player.setUrl(json['url'] as String);
    player.setVolume(json['volume'] as double? ?? 1.0);
    player.setPitch(json['pitch'] as double? ?? 1.0);
    player.setLoopMode(
        (json['loop'] as bool? ?? false) ? LoopMode.one : LoopMode.off);

    return player;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'color': color != null ? color!.toRadixString(16) : null,
        'url': url,
        'speed': super.speed,
        'volume': super.volume,
        'pitch': super.pitch,
        'loop': super.loopMode == LoopMode.one,
      };

  @override
  Future<Duration?> setUrl(String url,
      {Map<String, String>? headers,
      Duration? initialPosition,
      bool preload = true}) {
    this.url = url;
    return super.setUrl(url,
        headers: headers, initialPosition: initialPosition, preload: preload);
  }
}
