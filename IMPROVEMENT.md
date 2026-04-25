# Improvement Log — `gura_now_customer_app`

> Full Clean Architecture refactor executed in one session.
> All acceptance criteria met: `dart analyze lib/` = 0 errors / 0 warnings, `flutter test` passes, 0 `MockData` in presentation, 0 Riverpod `Provider<>` remaining.

---

## Phase A — Foundations & Cleanup

| Item | Change |
|---|---|
| `pubspec.yaml` | Renamed package from `gura_now` to `gura_now_customer_app` |
| `pubspec.yaml` | Removed dead Riverpod packages: `flutter_riverpod`, `riverpod`, `riverpod_generator`, `riverpod_annotation` |
| `pubspec.yaml` | Removed `build_runner` (no longer needed without Riverpod generators) |
| `core/mock/mock_config.dart` | Confirmed `useMockData = true` and `debugMockMode = true` |

---

## Phase B — Dead Code Removal (Riverpod Fragments)

All `Provider<...>` Riverpod declarations and their `flutter_riverpod` imports were removed from:

- `features/auth/data/repositories/auth_repository_impl.dart`
- `features/orders/data/repositories/order_repository_impl.dart`
- `features/shop/data/repositories/shop_repository_impl.dart`
- `features/notifications/data/datasources/notification_remote_datasource.dart`
- `features/payment/data/datasources/payment_remote_datasource.dart`
- `core/network/api_client.dart`
- `core/network/dio_client.dart`
- `core/storage/secure_storage.dart`
- `core/services/websocket_service.dart` ← caught in Phase K verification

GetIt remains the sole DI mechanism across the entire codebase.

---

## Phase C — Targeted Bug Fixes

### `auth_bloc.dart` — Skip-login bypass
- **Before**: `_onSkipLoginRequested` read `MockData` directly in the presentation layer.
- **After**: Calls `_loginUseCase` with demo credentials `(+250788123456, demo)`, routing through the full repository stack.

### `product_detail_screen.dart` — Hardcoded product
- **Before**: Product data was hardcoded as `Product(name: 'T-Shirt Premium', ...)` in `initState`.
- **After**: `initState` dispatches `LoadProductDetail(widget.productId)` to `ProductDetailBloc`; screen reacts to `loading / success / failure` states via `BlocBuilder`.

### `shop_detail_screen.dart` — Local mock product list
- **Before**: Used a local `_mockProducts()` function and `Future.delayed` to fake product loading.
- **After**: `initState` dispatches `ShopProductsRequested(widget.shopId)` to `ShopBloc`; products rendered from `state.shopProducts`.

### `/change-password` route — Missing route
- **Before**: `edit_profile_screen.dart` called `context.push('/change-password')` but the route didn't exist → crash at runtime.
- **After**: `ChangePasswordScreen` stub created, route wired in `app_router_bloc.dart`.

### `main_scaffold.dart` — Switch statement audit
- Confirmed existing `switch` bodies are valid Dart 3 syntax; no changes needed.

---

## Phase D — `product` Feature (Full Clean Architecture Stack)

| Layer | File | Description |
|---|---|---|
| Domain | `domain/repositories/product_repository.dart` | `getProductById(String id)` interface |
| Domain | `domain/usecases/product_usecases.dart` | `GetProductByIdUseCase` + `ProductIdParam` |
| Data | `data/datasources/product_remote_datasource.dart` | Abstract + `ProductRemoteDataSourceImpl` (Dio via `ApiClient`) |
| Mock | `core/mock/mock_product_datasource.dart` | `MockProductRemoteDataSource` using `MockData.getProductById` |
| Data | `data/repositories/product_repository_impl.dart` | Full error-handling impl |
| Presentation | `presentation/bloc/product_detail_bloc.dart` | `LoadProductDetail` event, `ProductDetailStatus` enum |
| Barrel | `product.dart` | Exports all layers |
| DI | `injection_container.dart` → `_initProduct()` | `useMockData ? Mock : Impl` ternary |

`MockData` was extended with `products` list and `getProductById()` / `getProductsByShopId()` helpers.

---

## Phase E — `profile` Feature (Full Clean Architecture Stack)

| Layer | File | Description |
|---|---|---|
| Domain | `domain/entities/address.dart` | New `Address` entity (moved from inline in `addresses_screen.dart`) |
| Domain | `domain/repositories/profile_repository.dart` | 8 operations: `getProfile`, `updateProfile`, `changePassword`, `getAddresses`, `addAddress`, `removeAddress`, `setDefaultAddress`, `updatePreferences` |
| Domain | `domain/usecases/profile_usecases.dart` | One use case per operation |
| Data | `data/datasources/profile_remote_datasource.dart` | Abstract + `ProfileRemoteDataSourceImpl` |
| Mock | `core/mock/mock_profile_datasource.dart` | `MockProfileRemoteDataSource` using `MockData.addresses` |
| Data | `data/repositories/profile_repository_impl.dart` | Full error-handling impl |
| Presentation | `presentation/bloc/profile_bloc.dart` | `ProfileBloc` + `ProfileEvent` + `ProfileState` |
| Barrel | `profile.dart` | Updated to export all new layers |
| DI | `_initProfile()` | `useMockData ? Mock : Impl` ternary |

`MockData` extended with `addresses` list and `getAddressesForUser()` helper.

### Screen adaptations
- **`edit_profile_screen.dart`**: `_saveProfile()` now dispatches `ProfileUpdateRequested`; wrapped in `BlocListener<ProfileBloc>` for success/failure snackbars. `_isSaving` state replaced by reading `ProfileActionStatus` from the bloc.
- **`addresses_screen.dart`**: Removed local `Address` class. `initState` dispatches `ProfileAddressesLoadRequested`. `_deleteAddress` / `_setDefaultAddress` / `_showAddressForm` dispatch the corresponding bloc events. Wrapped in `BlocBuilder<ProfileBloc>` with loading state.
- **`settings_screen.dart`**: Notifications toggle dispatches `ProfilePreferencesUpdateRequested({'notifications_enabled': val})` alongside `setState` for immediate UI feedback.

---

## Phase F — `review` Feature (Full Clean Architecture Stack)

| Layer | File | Description |
|---|---|---|
| Domain | `domain/entities/review.dart` | `Review` + `RatingSummary` entities |
| Domain | `domain/repositories/review_repository.dart` | `getShopReviews`, `getProductReviews`, `submitReview`, `getRatingSummary` |
| Domain | `domain/usecases/review_usecases.dart` | 4 use cases |
| Data | `data/models/review_model.dart` | `ReviewModel` with JSON serialization |
| Data | `data/datasources/review_remote_datasource.dart` | Abstract + `ReviewRemoteDataSourceImpl` |
| Mock | `core/mock/mock_review_datasource.dart` | `MockReviewRemoteDataSource` using `MockData.reviews` |
| Data | `data/repositories/review_repository_impl.dart` | Full error-handling impl |
| Presentation | `presentation/bloc/review_bloc.dart` | `ReviewBloc` + events + `ReviewListStatus` / `ReviewSubmitStatus` enums |
| Presentation | `presentation/pages/reviews_list_screen.dart` | New page: review list for shop or product, with inline write-review trigger |
| Barrel | `review.dart` | Updated to export all new layers |
| DI | `_initReview()` | `useMockData ? Mock : Impl` ternary |

`MockData` extended with `reviews` list and `getShopReviews()` / `getProductReviews()` helpers.

### `review_form_modal.dart` adaptation
- `_submit()` now dispatches `ReviewSubmitRequested(...)` to `ReviewBloc` (accessed via `context.read<ReviewBloc>()`) before calling the optional `onSubmit` callback.
- Backward-compatible: the `onSubmit` callback still works for direct callers.

### New routes
- `/reviews/shop/:shopId` → `ReviewsListScreen(targetType: 'shop')`
- `/reviews/product/:productId` → `ReviewsListScreen(targetType: 'product')`

---

## Phase G — `cart` Feature (Full Clean Architecture Stack)

| Layer | File | Description |
|---|---|---|
| Domain | `domain/repositories/cart_repository.dart` | `getCart`, `addItem`, `removeItem`, `updateQuantity`, `clearCart` |
| Domain | `domain/usecases/cart_usecases.dart` | 5 use cases |
| Data | `data/datasources/cart_local_datasource.dart` | `CartLocalDataSource` + `CartLocalDataSourceImpl` wrapping `SharedPreferences` |
| Data | `data/repositories/cart_repository_impl.dart` | Full impl; all mutation logic moved out of bloc |
| Barrel | `cart.dart` | Updated to export new layers |
| DI | `_initCart()` | Registers datasource → repo → use cases → bloc |

### `CartBloc` refactor
- **Before**: Injected `SharedPreferences` directly; all JSON encode/decode logic lived in the bloc.
- **After**: Injected 5 use cases (`GetCart`, `AddToCart`, `RemoveFromCart`, `UpdateCartQuantity`, `ClearCart`). Bloc only handles events and updates in-memory state; persistence is handled transparently by the repository.

---

## Phase H — Payment Routing & Bloc Refactors

### New payment use cases (completing coverage)
- `GetPaymentProofUseCase` — fetch single proof by ID
- `GetPaymentHistoryUseCase` — paginated payment history
- `SubmitPaymentProofUseCase` — upload proof images
- `ValidatePaymentProofUseCase` — approve/reject a proof

### New notification use cases (completing coverage)
- `MarkAllNotificationsReadUseCase`
- `DeleteNotificationUseCase`

### `PaymentBloc` refactor
- **Before**: Constructor took `PaymentRepository` directly; called `_repository.*` in every handler.
- **After**: Constructor takes 6 use cases; no repository reference remains.

### `NotificationBloc` refactor
- **Before**: Constructor took `NotificationRepository` directly.
- **After**: Constructor takes 5 use cases; no repository reference remains.

### Orphan routes wired in `app_router_bloc.dart`
| Route | Screen |
|---|---|
| `/payment/history` | `PaymentHistoryScreen` |
| `/payment/validation` | `PaymentValidationScreen` |
| `/payment/proof-upload/:orderId` | `PaymentProofUploadScreen` |
| `/reviews/shop/:shopId` | `ReviewsListScreen` |
| `/reviews/product/:productId` | `ReviewsListScreen` |

---

## Phase I — DI & MultiBlocProvider Finalization

### `injection_container.dart` — complete rewrite
- Every `_initX()` function now follows strict ordering: **datasource → repository → use cases → bloc**.
- `useMockData` ternary applied consistently to `shop`, `product`, `profile`, `review` datasource registrations. Auth, orders, notifications, payment remain mock-only pending real API integration.
- `DioClient` now correctly receives `SecureStorageService` from DI instead of being instantiated bare.
- Added: `_initProduct()`, `_initProfile()`, `_initReview()`.
- Updated: `_initCart()`, `_initShop()` (+ `GetShopProductsUseCase`), `_initNotifications()`, `_initPayment()`.

### `app.dart` — MultiBlocProvider
Added three new global blocs:
- `ProductDetailBloc`
- `ProfileBloc`
- `ReviewBloc`

---

## Phase J — Smoke Test

Created `test/widget_test.dart`:
- Mocks `flutter_secure_storage` channel (`readAll` → `{}`)
- Sets `SharedPreferences.setMockInitialValues({})`
- Calls `di.init()` to bootstrap the full DI graph
- Pumps `GuraNowApp`, waits 3 seconds for splash to settle
- Result: **All tests passed** ✅

---

## Phase K — Verification Results

| Check | Result |
|---|---|
| `dart analyze lib/` errors | **0** |
| `dart analyze lib/` warnings | **0** |
| `flutter test` | **Passed** |
| `MockData.` in `presentation/**` | **0 hits** |
| `Provider<` (Riverpod) in `features/**` | **0 hits** |

---

## Architecture Overview (Post-Refactor)

Every feature now follows the same pattern:

```
features/{feature}/
  domain/
    entities/         ← Pure Dart, no Flutter deps
    repositories/     ← Abstract interfaces only
    usecases/         ← One class per operation, UseCase<T, P>
  data/
    models/           ← extends entity, adds fromJson/toJson
    datasources/      ← abstract + real impl (Dio/SharedPreferences)
    repositories/     ← impl of domain interface, wraps exceptions → Failure
  presentation/
    bloc/             ← BLoC only; no MockData, no repository refs
    pages/
    widgets/
  {feature}.dart      ← barrel export
```

Mock layer stays centralized in `core/mock/`:
- `mock_config.dart` — `useMockData` flag
- `mock_data.dart` — all static mock data
- `mock_{feature}_datasource.dart` — implements the abstract datasource

DI wires everything in `core/di/injection_container.dart` using the ternary:
```dart
useMockData ? MockXxxRemoteDataSource() : XxxRemoteDataSourceImpl(sl<ApiClient>())
```

---

## Features Status Summary

| Feature | Data | Domain | Presentation | Bloc | DI |
|---|---|---|---|---|---|
| auth | ✅ | ✅ | ✅ | ✅ | ✅ |
| cart | ✅ | ✅ | ✅ | ✅ | ✅ |
| home | — (exempt) | — | ✅ | — | — |
| notifications | ✅ | ✅ | ✅ | ✅ | ✅ |
| orders | ✅ | ✅ | ✅ | ✅ | ✅ |
| payment | ✅ | ✅ | ✅ | ✅ | ✅ |
| product | ✅ | ✅ | ✅ | ✅ | ✅ |
| profile | ✅ | ✅ | ✅ | ✅ | ✅ |
| review | ✅ | ✅ | ✅ | ✅ | ✅ |
| shop | ✅ | ✅ | ✅ | ✅ | ✅ |
