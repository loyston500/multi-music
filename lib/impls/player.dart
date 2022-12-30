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
      ..color = json['color'] as int?;

    player.setSpeed(json['speed'] as double);
    player.setUrl(json['url'] as String);
    player.setVolume(json['volume'] as double);
    player.setPitch(json['pitch'] as double);
    player.setLoopMode((json['loop'] as bool) ? LoopMode.one : LoopMode.off);

    return player;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'color': color,
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
