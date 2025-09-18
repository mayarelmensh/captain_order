
import 'package:food_2_go/features/captin/pages/confirm_order/logic/model/product_model.dart';

abstract class ConfirmOrderState {}

class ConfirmOrderInitial extends ConfirmOrderState {}

class ConfirmOrderLoading extends ConfirmOrderState {}

class ConfirmOrderSuccess extends ConfirmOrderState {
  final String message;
  final ProductResponse productResponse;
  ConfirmOrderSuccess(this.message, this.productResponse);
}

class ConfirmOrderError extends ConfirmOrderState {
  final String message;
  ConfirmOrderError(this.message);
}