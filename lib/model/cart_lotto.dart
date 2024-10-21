import 'dart:convert';

List<CartLotto> cartLottoFromJson(String str) => List<CartLotto>.from(json.decode(str).map((x) => CartLotto.fromJson(x)));

String cartLottoToJson(List<CartLotto> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartLotto {
    int lottoId;
    String lottoNum;
    dynamic sold;
    dynamic userId;
    dynamic winningNum;
    dynamic prizeMoney;
    dynamic price;
    bool isChecked; // New field added

    CartLotto({
        required this.lottoId,
        required this.lottoNum,
        required this.sold,
        required this.userId,
        required this.winningNum,
        required this.prizeMoney,
        required this.price,
        this.isChecked = false, // Initialize isChecked with default value
    });

    CartLotto copyWith({
        int? lottoId,
        String? lottoNum,
        dynamic sold,
        dynamic userId,
        dynamic winningNum,
        dynamic prizeMoney,
        dynamic price,
        bool? isChecked, // Include isChecked in copyWith
    }) => 
        CartLotto(
            lottoId: lottoId ?? this.lottoId,
            lottoNum: lottoNum ?? this.lottoNum,
            sold: sold ?? this.sold,
            userId: userId ?? this.userId,
            winningNum: winningNum ?? this.winningNum,
            prizeMoney: prizeMoney ?? this.prizeMoney,
            price: price ?? this.price,
            isChecked: isChecked ?? this.isChecked, // Set isChecked
        );

    factory CartLotto.fromJson(Map<String, dynamic> json) => CartLotto(
        lottoId: json["lotto_id"],
        lottoNum: json["lotto_num"],
        sold: json["sold"],
        userId: json["user_id"],
        winningNum: json["winning_num"],
        prizeMoney: json["prize_money"],
        price: json["price"],
        isChecked: json["is_checked"] ?? false, // Handle default value for isChecked
    );

    Map<String, dynamic> toJson() => {
        "lotto_id": lottoId,
        "lotto_num": lottoNum,
        "sold": sold,
        "user_id": userId,
        "winning_num": winningNum,
        "prize_money": prizeMoney,
        "price": price,
        "is_checked": isChecked, // Include isChecked in JSON serialization
    };
}
