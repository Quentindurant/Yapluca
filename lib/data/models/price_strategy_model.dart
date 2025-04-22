class PriceStrategy {
  final int? depositAmount;
  final int? priceMinute;
  final int? autoRefund;
  final int? timeoutAmount;
  final int? timeoutDay;
  final int? dailyMaxPrice;
  final int? freeMinutes;
  final String? currencySymbol;
  final int? price;
  final String? name;
  final String? currency;
  final String? shopId;

  PriceStrategy({
    this.depositAmount,
    this.priceMinute,
    this.autoRefund,
    this.timeoutAmount,
    this.timeoutDay,
    this.dailyMaxPrice,
    this.freeMinutes,
    this.currencySymbol,
    this.price,
    this.name,
    this.currency,
    this.shopId,
  });

  factory PriceStrategy.fromJson(Map<String, dynamic> json) {
    return PriceStrategy(
      depositAmount: json['depositAmount'] as int?,
      priceMinute: json['priceMinute'] as int?,
      autoRefund: json['autoRefund'] as int?,
      timeoutAmount: json['timeoutAmount'] as int?,
      timeoutDay: json['timeoutDay'] as int?,
      dailyMaxPrice: json['dailyMaxPrice'] as int?,
      freeMinutes: json['freeMinutes'] as int?,
      currencySymbol: json['currencySymbol'] as String?,
      price: json['price'] as int?,
      name: json['name'] as String?,
      currency: json['currency'] as String?,
      shopId: json['shopId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depositAmount': depositAmount,
      'priceMinute': priceMinute,
      'autoRefund': autoRefund,
      'timeoutAmount': timeoutAmount,
      'timeoutDay': timeoutDay,
      'dailyMaxPrice': dailyMaxPrice,
      'freeMinutes': freeMinutes,
      'currencySymbol': currencySymbol,
      'price': price,
      'name': name,
      'currency': currency,
      'shopId': shopId,
    };
  }
}
