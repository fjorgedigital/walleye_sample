import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:walleye_sample/models/load_state.dart';
import 'package:walleye_sample/models/product.dart';
import 'package:walleye_sample/models/store_state.dart';
import 'package:walleye_sample/utilities/constants.dart';

/// This responsible for managing in-app subscriptions
/// using the Flutter In-App Purchase plugin.
///
/// It handles the initialization of the
/// plugin, loading subscription products, handling purchase updates, verifying
/// purchases, and delivering purchased products.
///
/// When this provider is first called, it attempts to query the stores for the user's
/// subscription status (`_getPastPurchases`). If none is found, `_currentPurchaseDetails`
/// and `_purchasedProduct` remains null, meaning the user has no active subscription.
///
/// To purchase a subscription, the user calls the `buy` function to initiate a purchase.
/// When a successful result has been received from `purchaseUpdated` listener,
/// purchase is verified by `_verifyPurchase` which calls the backend to
/// verify the subscription with the store.
/// If the purchase is not verified, it will be refunded within 3 days to users.
/// The receipt is verified first before actually finishing transaction(`_finishTransaction`).
///
/// ## Purchase subscription
/// 1. User initiates the purchase by triggering `buy()`
/// 2. The billing sdk handles the purchase.
/// 3. We subscribe & listen to updates on the purchase via [FlutterInappPurchase.purchaseUpdated]
/// 4. When a successful result is received from [purchaseUpdated] listener, we verify & acknowledge the purchase
/// with the backend via [_verifyPurchase].
/// 5. If verification was successful, the transaction has to be completed by calling `_finishTransaction` which completes
/// the transaction.
///  6. Finally, [deliverProduct] is called to set `_purchasedProduct` & `_currentSubscriptionDetails`
/// to the product purchased and the current subscription details respectively.
///
/// ## Restoring Subscriptions
/// 1. When the subscription provider is first started, `_getPastPurchases` is called to
/// get the active subscription of the current user.
/// 4. When a successful result is received from [FlutterInappPurchase.instance.getAvailablePurchases], we verify & acknowledge the purchase
/// with the backend via [_verifyPurchase].
/// 5. If verification was successful, the transaction has to be completed by calling
/// `_finishTransaction` which completes the transaction.
///  6. Finally, [deliverProduct] is called to set `_purchasedProduct` & `_currentSubscriptionDetails`
/// to the product purchased and the current subscription details respectively.
class SubscriptionProvider extends ChangeNotifier {
  /// Stream for purchase updates (buy subscription)
  late StreamSubscription<PurchasedItem?> _subscription;

  /// Stream for purchase errors
  late StreamSubscription<PurchaseResult?> _purchaseError;

  /// Stream for store availability
  late StreamSubscription<ConnectionResult> _storeConnection;

  StoreState _storeState = StoreState.loading;

  /// Available IAP items from store
  List<Product> products = <Product>[];

  /// Current user subscription. Set when user buys a subscription
  /// or subscription restores.
  PurchasedItem? _currentPurchaseDetails;

  /// LIst of product IDs
  final List<String> _productIds = <String>[
    WnConstants.monthlySubscription,
    WnConstants.yearlySubscription
  ];

  Product? _purchasedProduct;

  LoadState? _state;

  /// Any error message from the app stores are
  /// stored in this state variable
  String storeErrorMessages = '';

  int tacticalGetPastPurchasesRetryCount = 5;

  static const String savedPurchasesKey = 'subscriptions';

  /// Constructor initializes the in-app purchase plugin and subscribes to events.
  SubscriptionProvider() {
    state = LoadState.loading;
    FlutterInappPurchase.instance.initialize().then((instance) {
      loadProducts();
      _initSubscriptions();
    });
  }

  set state(LoadState? state) {
    _state = state;
    notifyListeners();
  }

  /// Representing loading state of the subscription provider
  LoadState? get state => _state;

  set storeState(StoreState state) {
    _storeState = state;
    notifyListeners();
  }

  StoreState get storeState => _storeState;

  /// Current IAP product purchased by user. Set when user purchases a subscription
  /// or subscription restores.
  Product? get purchasedProduct => _purchasedProduct;

  void setPurchasedProduct(Product? product) {
    _purchasedProduct = product;
    notifyListeners();
  }

  /// Current user subscription. Set when user buys a subscription
  /// or subscription restores.
  PurchasedItem? get currentPurchaseDetails => _currentPurchaseDetails;

  void setCurrentPurchaseDetails(PurchasedItem? purchaseDetails) {
    _currentPurchaseDetails = purchaseDetails;
    notifyListeners();
  }

  /// Refresh subscriptions by re-initializing subscriptions.
  Future<void> refreshSubscriptions() async {
    await _initSubscriptions();
  }

  /// initialize & listen to subscriptions, subscription errors
  /// & store availability.
  Future<void> _initSubscriptions() async {
    try {
      _subscription = FlutterInappPurchase.purchaseUpdated.listen(
        _onPurchaseUpdate,
        onDone: () => _subscription.cancel(),
        onError: (error) {
          log('something failed');
          log(error.toString());
        },
      );

      //Listen errors outside of a purchased Item.(user cancelled,etc)
      _purchaseError = FlutterInappPurchase.purchaseError.listen(
        _onPurchaseError,
        onDone: () => _purchaseError.cancel(),
        onError: (error) {
          log('something failed');
          log(error.toString());
        },
      );

      _storeConnection = FlutterInappPurchase.connectionUpdated.listen(
        (result) {
          storeState = (result.connected ?? false)
              ? StoreState.available
              : StoreState.notAvailable;
        },
        onDone: () => _purchaseError.cancel(),
        onError: (error) {
          log('something failed');
          log(error.toString());
        },
      );
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
    } finally {
      state = LoadState.completed;
    }
  }

  /// Method to handle purchase updates. Supplied to `FlutterInappPurchase.purchaseError`
  void _onPurchaseUpdate(
    PurchasedItem? purchasedItem,
  ) async {
    try {
      log(purchasedItem?.productId ?? '');
    } catch (e, s) {
      log(e.toString());
      log(s.toString());
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _purchaseError.cancel();
    _storeConnection.cancel();
    FlutterInappPurchase.instance.finalize();
    super.dispose();
  }

  /// User initiates this action. Makes a request to the stores to initiate the
  /// payment process
  Future<void> buy(Product product) async {
    try {
      state = LoadState.loading;
      if (Platform.isAndroid) {
        await FlutterInappPurchase.instance.requestSubscription(product.id,
            prorationModeAndroid: AndroidProrationMode.DEFERRED,
            offerTokenIndex: 0);
      } else {
        await FlutterInappPurchase.instance.requestSubscription(product.id);
      }
      log('message bought');
    } on Exception catch (e, s) {
      log(e.toString());
      log(s.toString());
    }
  }

  /// Gets available `IAPitem`s from the store for purchase.
  void loadProducts() async {
    final available = await FlutterInappPurchase.instance.isReady();
    if (!available) {
      storeState = StoreState.notAvailable;
      return;
    }

    final response =
        await FlutterInappPurchase.instance.getSubscriptions(_productIds);

    products = response.map((e) => Product(e)).toList();
    storeState = StoreState.available;
  }

  void _onPurchaseError(PurchaseResult? purchaseResult) {
    if (purchaseResult == null) {
      return;
    }
    storeErrorMessages = purchaseResult.message ?? '';
    state = LoadState.failed;
    log(purchaseResult.responseCode.toString());
    log(purchaseResult.message ?? '');
  }
}
