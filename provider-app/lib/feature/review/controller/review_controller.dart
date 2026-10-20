import 'package:get/get.dart';
import 'package:jassdbx_provider/util/core_export.dart';


class ReviewController extends GetxController implements GetxService{
  final ReviewRepo reviewRepo;
  ReviewController({required this.reviewRepo});

  int? _pageSize;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  bool _isLoading= false;
  bool get isLoading => _isLoading;

  List<Review>? _providerReviewList;
  List<Review>? get providerReviewList => _providerReviewList;

  Rating? _providerRating;
  Rating? get providerRating => _providerRating;


  List<Review>? _serviceReviewList = [];
  List<Review>? get serviceReviewList => _serviceReviewList!;

  Rating? _serviceRating;
  Rating? get serviceRating => _serviceRating;

  final ScrollController scrollController = ScrollController();


  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if(scrollController.position.maxScrollExtent == scrollController.position.pixels) {
        if(_offset < _pageSize! ) {
          getProviderReview(offset+1, isLoading: true);
        }
      }
    });
  }

  Future<void> getProviderReview(int offset,{bool isLoading = false}) async {
    _offset = offset;
    if(isLoading){
      _isLoading = true;
      update();
    }
    Response response = await reviewRepo.getProviderReviewList(offset);
    if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
      _pageSize = response.body['content']['reviews']['last_page'];
      if(offset == 1 ){
        _providerReviewList =[];
        _providerRating==null;
      }
        response.body['content']['reviews']['data'].forEach((review){
          _providerReviewList!.add( Review.fromJson(review));
        });
        _providerRating = Rating.fromJson(response.body['content']['rating']);
    } else {
      _providerReviewList =[];
      _providerRating = null;
    }
    _isLoading = false;
    update();
  }


  Future<void> getServiceReview(String serviceID) async {
    _serviceReviewList =[];
    _serviceRating=null;
    Response response = await reviewRepo.getServiceReviewList(serviceID,1);
    if (response.statusCode == 200 && response.body['response_code'] ==  'default_200') {
      try{
        response.body['content']['reviews']['data'].forEach((review){
          _serviceReviewList!.add( Review.fromJson(review));
        });
      }catch(error){
        if (kDebugMode) {
          print('error : $error');
        }
      }
      try{
        _serviceRating = Rating.fromJson(response.body['content']['rating']);
      }catch(error){
        if (kDebugMode) {
          print('rating get error : $error');
        }
      }
    } else {
      //ApiChecker.checkApi(response);
    }
  }

  // ==================== Serviceman-wise ratings ====================
  List<ServicemanRatingItem>? _servicemenRatingList;
  List<ServicemanRatingItem>? get servicemenRatingList => _servicemenRatingList;

  ServicemanRatingItem? _topServiceman;
  ServicemanRatingItem? get topServiceman => _topServiceman;

  ServicemanRatingItem? _lowestServiceman;
  ServicemanRatingItem? get lowestServiceman => _lowestServiceman;

  List<Review>? _servicemanReviewsList;
  List<Review>? get servicemanReviewsList => _servicemanReviewsList;

  Rating? _servicemanOverallRating;
  Rating? get servicemanOverallRating => _servicemanOverallRating;

  /// Naya screen: top/lowest serviceman + saare reviews + rating summary
  Future<void> getServicemanRatings() async {
    _servicemenRatingList = null;
    update();

    Response response = await reviewRepo.getServicemanRatings();

    if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
      try {
        final dynamic content = response.body['content'];

        _servicemenRatingList = [];
        (content['servicemen'] ?? []).forEach((serviceman) {
          _servicemenRatingList!.add(ServicemanRatingItem.fromJson(serviceman));
        });

        _topServiceman = content['top_serviceman'] != null
            ? ServicemanRatingItem.fromJson(content['top_serviceman'])
            : null;
        _lowestServiceman = content['lowest_serviceman'] != null
            ? ServicemanRatingItem.fromJson(content['lowest_serviceman'])
            : null;

        _servicemanReviewsList = [];
        (content['reviews'] ?? []).forEach((review) {
          _servicemanReviewsList!.add(Review.fromJson(review));
        });

        _servicemanOverallRating = Rating.fromJson(content['rating']);
      } catch (error) {
        if (kDebugMode) {
          print('serviceman ratings parse error: $error');
        }
      }
    } else {
      _servicemenRatingList = [];
      _servicemanReviewsList = [];
      _topServiceman = null;
      _lowestServiceman = null;
      _servicemanOverallRating = null;
    }

    update();
  }

  /// Booking details -> reviews tab ke liye ek booking ke saare reviews
  Future<List<Review>> getBookingReviews(String bookingId) async {
    List<Review> reviews = [];
    Response response = await reviewRepo.getBookingReviewList(bookingId);

    if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
      try {
        final dynamic content = response.body['content'];
        if (content is Map && content['reviews'] is List) {
          content['reviews'].forEach((review) {
            reviews.add(Review.fromJson(review));
          });
        }
      } catch (error) {
        if (kDebugMode) {
          print('booking reviews parse error: $error');
        }
      }
    }
    return reviews;
  }

  Future<ResponseModel> replyReview ({required String reviewId, required String reviewContent, String? fromPage, String? serviceId}) async {
    _isLoading = true;
    update();
    Response  response = await reviewRepo.replyReview(reviewId: reviewId, reviewContent: reviewContent);
    ResponseModel responseModel;
    if(response.statusCode == 200){
      if (fromPage == "service" && serviceId !=null){
         await getServiceReview(serviceId);
      }else{
        await getProviderReview(1);
      }
      responseModel = ResponseModel(true, "success");
    }else{
      responseModel = ResponseModel(false, response.body['message'] ?? "failed");
    }
    _isLoading = false;
    update();

    return responseModel;
  }

}