part of 'product_bloc.dart';

@immutable
sealed class ProductState {}

final class ProductStateInitial extends ProductState {}

final class ProductStateSuccessAdd extends ProductState {}

final class ProductStateSuccessQR extends ProductState {
  final ProductModel product;

  ProductStateSuccessQR({required this.product});
}

final class ProductStateSuccessExport extends ProductState {}

final class ProductStateSuccessEdit extends ProductState {}

final class ProductStateSuccessDelete extends ProductState {}

final class ProductStateLoading extends ProductState {}

final class ProductStateLoadingAdd extends ProductStateLoading {}

final class ProductStateLoadingEdit extends ProductStateLoading {}

final class ProductStateLoadingDelete extends ProductStateLoading {}

final class ProductStateLoadingQR extends ProductStateLoading {}

final class ProductStateLoadingPDF extends ProductStateLoading {}

final class ProductStateError extends ProductState {
  ProductStateError(this.error);

  final String error;
}
