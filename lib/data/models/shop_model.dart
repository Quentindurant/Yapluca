class Shop {
  final String? address;
  final String? priceMinute;
  final String? city;
  final int? dailyMaxPrice;
  final String? latitude;
  final String? openingTime;
  final int? freeMinutes;
  final String? icon;
  final String? content;
  final String? province;
  final int? price;
  final String? name;
  final int? deposit;
  final String? logo;
  final String? id;
  final String? region;
  final String? longitude;

  Shop({
    this.address,
    this.priceMinute,
    this.city,
    this.dailyMaxPrice,
    this.latitude,
    this.longitude,
    this.openingTime,
    this.freeMinutes,
    this.icon,
    this.content,
    this.province,
    this.price,
    this.name,
    this.deposit,
    this.logo,
    this.id,
    this.region,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      address: json['address'] as String?,
      priceMinute: json['priceMinute'] as String?,
      city: json['city'] as String?,
      dailyMaxPrice: json['dailyMaxPrice'] as int?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      openingTime: json['openingTime'] as String?,
      freeMinutes: json['freeMinutes'] as int?,
      icon: json['icon'] as String?,
      content: json['content'] as String?,
      province: json['province'] as String?,
      price: json['price'] as int?,
      name: json['name'] as String?,
      deposit: json['deposit'] as int?,
      logo: json['logo'] as String?,
      id: json['id'] as String?,
      region: json['region'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'priceMinute': priceMinute,
      'city': city,
      'dailyMaxPrice': dailyMaxPrice,
      'latitude': latitude,
      'longitude': longitude,
      'openingTime': openingTime,
      'freeMinutes': freeMinutes,
      'icon': icon,
      'content': content,
      'province': province,
      'price': price,
      'name': name,
      'deposit': deposit,
      'logo': logo,
      'id': id,
      'region': region,
    };
  }
}
