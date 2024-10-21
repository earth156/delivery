
import 'dart:convert';

List<LottoNumbers> lottoNumbersFromJson(String str) => List<LottoNumbers>.from(json.decode(str).map((x) => LottoNumbers.fromJson(x)));

String lottoNumbersToJson(List<LottoNumbers> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LottoNumbers {
    int lottoId;
    String lottoNum;
    dynamic sold;
    dynamic userId;
    dynamic winningNum;
    dynamic prizeMoney;
    dynamic price;

    LottoNumbers({
        required this.lottoId,
        required this.lottoNum,
        required this.sold,
        required this.userId,
        required this.winningNum,
        required this.prizeMoney,
        required this.price,
    });

    LottoNumbers copyWith({
        int? lottoId,
        String? lottoNum,
        dynamic sold,
        dynamic userId,
        dynamic winningNum,
        dynamic prizeMoney,
        dynamic price,
    }) => 
        LottoNumbers(
            lottoId: lottoId ?? this.lottoId,
            lottoNum: lottoNum ?? this.lottoNum,
            sold: sold ?? this.sold,
            userId: userId ?? this.userId,
            winningNum: winningNum ?? this.winningNum,
            prizeMoney: prizeMoney ?? this.prizeMoney,
            price: price ?? this.price,
        );

    factory LottoNumbers.fromJson(Map<String, dynamic> json) => LottoNumbers(
        lottoId: json["lotto_id"],
        lottoNum: json["lotto_num"],
        sold: json["sold"],
        userId: json["user_id"],
        winningNum: json["winning_num"],
        prizeMoney: json["prize_money"],
        price: json["price"],
    );

    Map<String, dynamic> toJson() => {
        "lotto_id": lottoId,
        "lotto_num": lottoNum,
        "sold": sold,
        "user_id": userId,
        "winning_num": winningNum,
        "prize_money": prizeMoney,
        "price": price,
    };
}