// Cart Services - Facade Pattern
//
// The real facade is `Cart` (`lib/models/repository/cart.dart`). It delegates
// to the specialised services below. The former standalone `CartService` was
// dead code (never imported, and accessed a private member of
// `CartStateManager` from another library) and has been removed.

export 'cart/cart_state.dart';
export 'cart/cart_state_manager.dart';
export 'cart/checkout_service.dart';
export 'cart/stash_service.dart';
export 'cart/receipt_service.dart';
