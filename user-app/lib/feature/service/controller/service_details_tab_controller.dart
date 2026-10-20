import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';
import 'package:flutter/scheduler.dart';

enum ServiceTabControllerState { serviceOverview, faq, review }

class ServiceTabController extends GetxController
    with GetTickerProviderStateMixin {
  final ServiceDetailsRepo serviceDetailsRepo;
  ServiceTabController({required this.serviceDetailsRepo});

  TabController? controller;
  var servicePageCurrentState = ServiceTabControllerState.serviceOverview;

  void inttTabController({required int length}) {
    if (controller == null) {
      controller = TabController(vsync: this, length: length);
      update();
      return;
    }
    if (controller!.length == length) {
      update();
      return;
    }
    final oldController = controller!;
    controller = TabController(vsync: this, length: length);
    update();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      oldController.dispose();
    });
  }

  void updateServicePageCurrentState(ServiceTabControllerState state) {
    servicePageCurrentState = state;
    update();
  }

  List<Widget> serviceDetailsTabs(Service? service) {
    if (service != null &&
        service.faqs != null &&
        (service.faqs?.isNotEmpty ?? false)) {
      return [
        Tab(child: Text("service_overview".tr, maxLines: 2)),
        Tab(child: Text("faqs".tr, maxLines: 2)),
        Tab(child: Text("reviews".tr, maxLines: 2)),
      ];
    }
    return [
      Tab(child: Text("service_overview".tr, maxLines: 2)),
      Tab(child: Text("reviews".tr, maxLines: 2)),
    ];
  }

  bool _isLoading = false;
  int? _pageSize = 0;
  ReviewContent? reviewContent;
  List<Review>? _reviewList;
  List<Review>? get reviewList => _reviewList;
  bool get isLoading => _isLoading;
  int? get pageSize => _pageSize!;
  Rating? _rating;
  String? _serviceID;
  int? _offset = 1;
  Rating get rating => _rating ?? Rating(averageRating: 0.0, ratingCount: 0);
  int? get offset => _offset;
  String? get serviceID => _serviceID;

  /// [zoneId] — user's current zone id (from LocationController).
  /// Passed to the backend so reviews and rating summary are zone-scoped.
  Future<void> getServiceReview(
    String serviceID,
    int offset, {
    bool reload = true,
    String? zoneId,
  }) async {
    _offset = offset;
    _serviceID = serviceID;
    if (reload) {
      _isLoading = true;
      _reviewList = null;
      update();
    }

    try {
      final Response response = await serviceDetailsRepo.getServiceReviewList(
        serviceID,
        offset,
        zoneId: zoneId,
      );

      final dynamic body = response.body;
      final dynamic content = body is Map ? body['content'] : null;
      if (response.statusCode == 200 &&
          body is Map &&
          body['response_code'] == 'default_200' &&
          content is Map) {
        final parsed = ReviewContent.fromJson(
          Map<String, dynamic>.from(content),
        );
        final List<Review> newReviews =
            parsed.reviews?.reviewList ?? <Review>[];
        if (reload || offset == 1 || _reviewList == null) {
          _reviewList = newReviews;
        } else {
          _reviewList!.addAll(newReviews);
        }
        reviewContent = parsed;
        _rating = parsed.rating;
        final dynamic lastPage = content['reviews'] is Map
            ? content['reviews']['last_page']
            : null;
        _pageSize = int.tryParse(lastPage?.toString() ?? '') ?? 0;
      } else if (reload) {
        _reviewList = <Review>[];
        reviewContent = null;
        _rating = Rating(averageRating: 0.0, ratingCount: 0);
        _pageSize = 0;
      }
    } catch (error, stackTrace) {
      debugPrint('Service reviews failed ($serviceID): $error\n$stackTrace');
      if (reload) {
        _reviewList = <Review>[];
        reviewContent = null;
        _rating = Rating(averageRating: 0.0, ratingCount: 0);
        _pageSize = 0;
      }
    } finally {
      if (reload) _isLoading = false;
      update();
    }
  }

  void updateProviderReviewExpendedStatus({
    int? index,
    bool shouldUpdate = true,
  }) {
    if (index != null) {
      _reviewList?[index].isExpended = 1;
      if (shouldUpdate) {
        update();
      }
    } else {
      if (_reviewList != null && reviewList!.isNotEmpty) {
        for (int i = 0; i < _reviewList!.length; i++) {
          _reviewList?[i].isExpended = 0;
        }
      }
    }
  }
}
