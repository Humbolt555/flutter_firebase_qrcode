class ProductModel {
  String code;
  String name;
  String? productId;
  int quantity;

  ProductModel({
    required this.code,
    required this.name,
    this.productId,
    required this.quantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        code: json["code"],
        name: json["name"],
        productId: json["productId"],
        quantity: json["quantity"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "name": name,
        "productId": productId,
        "quantity": quantity,
      };
}
