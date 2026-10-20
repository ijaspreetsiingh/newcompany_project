import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';

class ReviewRepo{
  final ApiClient apiClient;
  ReviewRepo({required this.apiClient});

  Future<Response> getProviderReviewList(int offset) async {
    return await apiClient.getData('${AppConstants.getProviderReviewList}?offset=$offset&limit=10');
  }

  Future<Response> getServiceReviewList(String serviceID,int offset) async {
    return await apiClient.getData('${AppConstants.getServiceReviewList}/$serviceID?offset=$offset&limit=100&status=all');
  }

  Future<Response> replyReview({required String reviewId, required String reviewContent}) async {
    return await apiClient.postData(AppConstants.reviewReply, {
      "reply_content" : reviewContent,
      "review_id" : reviewId
    });
  }

  /// Ek booking ke saare reviews (booking details -> reviews tab)
  Future<Response> getBookingReviewList(String bookingId) async {
    return await apiClient.getData('${AppConstants.bookingFeedbackList}/$bookingId');
  }

  /// Serviceman-wise rating breakdown + top/lowest + saare reviews
  Future<Response> getServicemanRatings() async {
    return await apiClient.getData(AppConstants.servicemanRatingsList);
  }

}