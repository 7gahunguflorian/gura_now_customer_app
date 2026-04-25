/// Payment remote data source for Gura Now application.
library;

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/payment_history_model.dart';
import '../models/payment_proof_model.dart';
import '../models/shop_balance_model.dart';

/// Abstract interface for payment remote operations.
abstract class PaymentRemoteDataSource {
  /// Submit payment proof with images.
  Future<PaymentProofModel> submitPaymentProof({
    required String orderId,
    required String paymentMethod,
    required List<File> images,
    String? referenceNumber,
    String? notes,
  });

  /// Get list of payment proofs.
  Future<PaginatedPaymentProofs> getPaymentProofs({
    int page = 1,
    int perPage = 20,
    String? shopId,
    String? status,
  });

  /// Get a specific payment proof.
  Future<PaymentProofModel> getPaymentProof(String proofId);

  /// Validate (approve/reject) a payment proof.
  Future<PaymentProofModel> validatePaymentProof(
    String proofId,
    PaymentProofValidateRequest request,
  );

  /// Get payment history.
  Future<PaymentHistory> getPaymentHistory({
    int page = 1,
    int perPage = 20,
  });

  /// Get shop balance.
  Future<ShopBalanceModel> getShopBalance(String shopId);
}

/// Implementation of payment remote data source.
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  PaymentRemoteDataSourceImpl(this._apiClient);
  final ApiClient _apiClient;

  @override
  Future<PaymentProofModel> submitPaymentProof({
    required String orderId,
    required String paymentMethod,
    required List<File> images,
    String? referenceNumber,
    String? notes,
  }) async {
    // Build multipart form data
    final formData = FormData.fromMap({
      'order_id': orderId,
      'payment_method': paymentMethod,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (notes != null) 'notes': notes,
      'images': await Future.wait(
        images.map((file) async {
          final fileName = file.path.split('/').last;
          return MultipartFile.fromFile(file.path, filename: fileName);
        }),
      ),
    });

    final response = await _apiClient.postMultipart(
      ApiEndpoints.paymentsSubmitProof,
      formData,
    );
    return PaymentProofModel.fromJson(response);
  }

  @override
  Future<PaginatedPaymentProofs> getPaymentProofs({
    int page = 1,
    int perPage = 20,
    String? shopId,
    String? status,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.paymentsProofs,
      queryParams: {
        'page': page,
        'per_page': perPage,
        if (shopId != null) 'shop_id': shopId,
        if (status != null) 'status': status,
      },
    );
    return PaginatedPaymentProofs.fromJson(response);
  }

  @override
  Future<PaymentProofModel> getPaymentProof(String proofId) async {
    final endpoint = ApiEndpoints.replacePathParam(
      ApiEndpoints.paymentsProofDetail,
      'proof_id',
      proofId,
    );
    final response = await _apiClient.get(endpoint);
    return PaymentProofModel.fromJson(response);
  }

  @override
  Future<PaymentProofModel> validatePaymentProof(
    String proofId,
    PaymentProofValidateRequest request,
  ) async {
    final endpoint = ApiEndpoints.replacePathParam(
      ApiEndpoints.paymentsProofValidate,
      'proof_id',
      proofId,
    );
    final response = await _apiClient.patch(endpoint, body: request.toJson());
    return PaymentProofModel.fromJson(response);
  }

  @override
  Future<PaymentHistory> getPaymentHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.paymentsHistory,
      queryParams: {
        'page': page,
        'per_page': perPage,
      },
    );
    return PaymentHistory.fromJson(response);
  }

  @override
  Future<ShopBalanceModel> getShopBalance(String shopId) async {
    final endpoint = ApiEndpoints.replacePathParam(
      ApiEndpoints.paymentsShopBalance,
      'shop_id',
      shopId,
    );
    final response = await _apiClient.get(endpoint);
    return ShopBalanceModel.fromJson(response);
  }
}
