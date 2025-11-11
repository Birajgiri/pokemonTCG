class PokemonCard {
  final String id;
  final String name;
  final String imageUrl;
  final String? imageUrlHiRes;
  final String? supertype;
  final String? subtype;
  final String? hp;
  final String? artist;
  final String? rarity;
  final String? series;
  final String? set;
  final String? setCode;
  final String? number;

  PokemonCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.imageUrlHiRes,
    this.supertype,
    this.subtype,
    this.hp,
    this.artist,
    this.rarity,
    this.series,
    this.set,
    this.setCode,
    this.number,
  });

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>?;
    final set = json['set'] as Map<String, dynamic>?;
    final subtypes = json['subtypes'] as List<dynamic>?;

    return PokemonCard(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: images?['small'] ?? '',
      imageUrlHiRes: images?['large'],
      supertype: json['supertype'],
      subtype: subtypes?.isNotEmpty == true ? subtypes!.first : null,
      hp: json['hp'],
      artist: json['artist'],
      rarity: json['rarity'],
      series: json['series'],
      set: set?['name'],
      setCode: set?['id'],
      number: json['number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'imageUrlHiRes': imageUrlHiRes,
      'supertype': supertype,
      'subtype': subtype,
      'hp': hp,
      'artist': artist,
      'rarity': rarity,
      'series': series,
      'set': set,
      'setCode': setCode,
      'number': number,
    };
  }

  factory PokemonCard.fromStorageJson(Map<String, dynamic> json) {
    return PokemonCard(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      imageUrlHiRes: json['imageUrlHiRes'],
      supertype: json['supertype'],
      subtype: json['subtype'],
      hp: json['hp'],
      artist: json['artist'],
      rarity: json['rarity'],
      series: json['series'],
      set: json['set'],
      setCode: json['setCode'],
      number: json['number'],
    );
  }
}
