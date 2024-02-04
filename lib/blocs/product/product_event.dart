part of 'product_bloc.dart';

@immutable
sealed class ProductEvent {}

final class ProductEventAdd extends ProductEvent {
  final ProductModel product;

  ProductEventAdd({required this.product});
}

final class ProductEventDelete extends ProductEvent {
  final String productId;

  ProductEventDelete({required this.productId});
}

final class ProductEventEdit extends ProductEvent {
  final ProductModel product;

  ProductEventEdit({required this.product});
}

final class ProductEventExportPdf extends ProductEvent {}

final class ProductEventQrScan extends ProductEvent {}
