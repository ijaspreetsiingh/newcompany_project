import 'package:universal_html/html.dart' as html;
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jdds/helper/file_validation_helper.dart';
import 'package:jdds/util/core_export.dart';

class ConversationController extends GetxController
    with GetSingleTickerProviderStateMixin
    implements GetxService {
  final ConversationRepo conversationRepo;
  ConversationController({required this.conversationRepo});

  TabController? tabController;

  List<XFile>? _pickedImageFiles = [];
  List<XFile>? get pickedImageFile => _pickedImageFiles;

  FilePickerResult? _otherFile;
  FilePickerResult? get otherFile => _otherFile;

  String _onMessageTimeShowID = '';
  String get onMessageTimeShowID => _onMessageTimeShowID;

  String _onImageOrFileTimeShowID = '';
  String get onImageOrFileTimeShowID => _onImageOrFileTimeShowID;

  bool _isClickedOnMessage = false;
  bool get isClickedOnMessage => _isClickedOnMessage;

  bool _isClickedOnImageOrFile = false;
  bool get isClickedOnImageOrFile => _isClickedOnImageOrFile;

  File? _file;
  List<PlatformFile>? objFile;
  File? get file => _file;

  List<MultipartBody> _selectedImageList = [];
  List<MultipartBody> get selectedImageList => _selectedImageList;
  bool _paginationLoading = true;
  bool get paginationLoading => _paginationLoading;

  int? _messagePageSize;
  int? _messageOffset = 1;
  int? get messagePageSize => _messagePageSize;
  int? get messageOffset => _messageOffset;

  int _providerChannelPageSize = 1;
  int _providerChannelOffset = 1;
  int _servicemanChannelPageSize = 1;
  int _servicemanChannelOffset = 1;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final String _name = '';
  String get name => _name;
  final String _image = '';
  String get image => _image;

  bool _isActiveSuffixIcon = false;
  bool get isActiveSuffixIcon => _isActiveSuffixIcon;

  bool _isSearchComplete = true;
  bool get isSearchComplete => _isSearchComplete;

  bool _pickedFIleCrossMaxLength = false;
  bool get pickedFIleCrossMaxLength => _pickedFIleCrossMaxLength;

  List<ChannelData>? _providerChannelList;
  List<ChannelData>? get providerChannelList => _providerChannelList;

  List<ChannelData>? _servicemanChannelList;
  List<ChannelData>? get servicemanChannelList => _servicemanChannelList;

  List<ChannelData>? _searchedChannelList = [];
  List<ChannelData>? get searchedChannelList => _searchedChannelList;

  List<ChannelData>? _searchedProviderChannelList = [];
  List<ChannelData>? get searchedProviderChannelList =>
      _searchedProviderChannelList;

  List<ChannelData>? _searchedServicemanChannelList = [];
  List<ChannelData>? get searchedServicemanChannelList =>
      _searchedServicemanChannelList;

  List<ConversationData>? _conversationList;
  List<ConversationData>? get conversationList => _conversationList;

  // ConversationUserModel? _adminConversationModel;
  // ConversationUserModel? get adminConversationModel => _adminConversationModel;

  ChannelData? _adminConversation;
  ChannelData? get adminConversationModel => _adminConversation;

  final ScrollController channelScrollController1 = ScrollController();
  final ScrollController channelScrollController2 = ScrollController();
  final ScrollController messageScrollController = ScrollController();
  int? get pageSize => _providerChannelPageSize;
  int? get offset => _providerChannelOffset;

  var conversationController = TextEditingController();
  var searchController = TextEditingController();

  String _channelId = '';
  String get channelId => _channelId;
  String _userTypeImage = '';
  String get userTypeImage => _userTypeImage;

  void setChannelId(String channelId) {
    _channelId = channelId;
  }

  @override
  void onInit() {
    super.onInit();
    conversationController.text = '';
    tabController = TabController(vsync: this, length: 2);
    channelScrollController1.addListener(() {
      _loadMoreChannelList(channelScrollController1, type: 'provider');
    });
    channelScrollController2.addListener(() {
      _loadMoreChannelList(channelScrollController2, type: 'serviceman');
    });

    messageScrollController.addListener(() {
      if (messageScrollController.position.pixels ==
          messageScrollController.position.maxScrollExtent) {
        if (_messagePageSize != null &&
            _messageOffset != null &&
            _messageOffset! < _messagePageSize!) {
          getConversation(
            _channelId,
            _messageOffset! + 1,
            isFromPagination: true,
          );
        }
      }
    });
  }

  void _loadMoreChannelList(
    ScrollController controller, {
    required String type,
  }) {
    if (!controller.hasClients ||
        controller.position.pixels != controller.position.maxScrollExtent) {
      return;
    }

    final bool isProvider = type == 'provider';
    final int currentOffset = isProvider
        ? _providerChannelOffset
        : _servicemanChannelOffset;
    final int pageSize = isProvider
        ? _providerChannelPageSize
        : _servicemanChannelPageSize;
    if (currentOffset < pageSize) {
      getChannelList(currentOffset + 1, type: type, isFromPagination: true);
    }
  }

  Future<void> pickMultipleImage(bool isRemove, {int? index}) async {
    _pickedFIleCrossMaxLength = false;
    if (isRemove) {
      if (index != null) {
        _pickedImageFiles!.removeAt(index);
        _selectedImageList.removeAt(index);
      }
    } else {
      // Use FileValidationHelper for inttial validation (extension and per-file size)
      List<XFile> pickImages =
          await FileValidationHelper.validateAndPickMultipleImages();
      _pickedImageFiles = [];
      _selectedImageList = [];
      objFile = [];

      if (pickImages.isEmpty) {
        update();
        return;
      }

      // Apply conversation-specific validation (file count and total size)
      for (var element in pickImages) {
        if (_pickedImageFiles!.length < AppConstants.maxLimitOfTotalFileSent) {
          _pickedImageFiles!.add(element);
          _selectedImageList.add(
            MultipartBody('files[${_selectedImageList.length}]', element),
          );
        }
      }

      // Set flag for file count limit
      if (_pickedImageFiles!.length == AppConstants.maxLimitOfTotalFileSent &&
          pickImages.length > AppConstants.maxLimitOfTotalFileSent) {
        _pickedFIleCrossMaxLength = true;
      }
    }
    update();
  }

  Future<void> pickOtherFile(bool isRemove, {int? index}) async {
    _pickedFIleCrossMaxLength = false;
    if (isRemove) {
      if (objFile != null) {
        objFile!.removeAt(index!);
      }
    } else {
      // Use FileValidationHelper for validation (extension and file size)
      List<PlatformFile> platformFiles =
          await FileValidationHelper.validateAndPickDocuments();

      objFile = [];
      _pickedImageFiles = [];
      _selectedImageList = [];

      if (platformFiles.isEmpty) {
        update();
        return;
      }

      // Apply conversation-specific validation (file count limit)
      for (var element in platformFiles) {
        if (objFile!.length < AppConstants.maxLimitOfTotalFileSent) {
          objFile!.add(element);
        }
      }

      // Set flag for file count limit
      if (objFile!.length == AppConstants.maxLimitOfTotalFileSent &&
          platformFiles.length > AppConstants.maxLimitOfTotalFileSent) {
        _pickedFIleCrossMaxLength = true;
      }
    }
    update();
  }

  void removeFile() async {
    _otherFile = null;
    update();
  }

  Future<void> getChannelList(
    int offset, {
    bool isFromPagination = false,
    bool reload = false,
    bool isFirst = false,
    String type = 'provider',
  }) async {
    final bool isProvider = type == 'provider';
    if (isProvider) {
      _providerChannelOffset = offset;
    } else {
      _servicemanChannelOffset = offset;
    }

    if (reload) {
      // _customerChannelList = null;
      // _servicemanChannelList = null;
      if (!isFirst) {
        update();
      }
    }

    Response response = await conversationRepo.getChannelList(
      offset,
      type: type,
    );

    if (response.statusCode == 200) {
      final dynamic content = response.body is Map
          ? response.body['content']
          : null;
      final dynamic channelPage = content is Map
          ? content['channelList']
          : null;
      final dynamic rawChannels = channelPage is Map
          ? channelPage['data']
          : null;
      final List<dynamic> channelData = rawChannels is List
          ? rawChannels
          : const <dynamic>[];
      final int lastPage =
          int.tryParse(
            channelPage is Map ? '${channelPage['last_page'] ?? ''}' : '',
          ) ??
          1;

      if (isProvider) {
        if (offset == 1) _providerChannelList = <ChannelData>[];
        _providerChannelList ??= <ChannelData>[];
        for (final channel in channelData) {
          if (channel is Map) {
            _providerChannelList!.add(
              ChannelData.fromJson(Map<String, dynamic>.from(channel)),
            );
          }
        }
        _providerChannelPageSize = lastPage;
      } else {
        if (offset == 1) _servicemanChannelList = <ChannelData>[];
        _servicemanChannelList ??= <ChannelData>[];
        for (final channel in channelData) {
          if (channel is Map) {
            _servicemanChannelList!.add(
              ChannelData.fromJson(Map<String, dynamic>.from(channel)),
            );
          }
        }
        _servicemanChannelPageSize = lastPage;
      }

      final dynamic adminChannel = content is Map
          ? content['adminChannel']
          : null;
      if (adminChannel is Map) {
        _adminConversation = ChannelData.fromJson(
          Map<String, dynamic>.from(adminChannel),
        );
      }
    } else {
      if (isProvider) {
        _providerChannelList ??= <ChannelData>[];
      } else {
        if (offset == 1 && response.statusCode == 401) {
          _servicemanChannelList = <ChannelData>[];
        }
        _servicemanChannelList ??= <ChannelData>[];
      }
      // Some accounts are not permitted to query the partner-only inbox list.
      // Treat that optional tab as empty without clearing a valid customer login.
      if (response.statusCode != 401 || isProvider) {
        ApiChecker.checkApi(response);
      }
    }

    _paginationLoading = false;
    _isLoading = false;
    update();
  }

  Future<void> getSearchedChannelList({String? query}) async {
    _searchedChannelList = null;
    _isSearchComplete = false;
    _searchedProviderChannelList = [];
    _searchedServicemanChannelList = [];
    update();

    Response response = await conversationRepo.searchChannelList(
      queryText: query,
    );

    if (response.statusCode == 200) {
      _searchedChannelList = [];
      final dynamic content = response.body is Map
          ? response.body['content']
          : null;
      final dynamic rawChannels = content is Map ? content['data'] : null;
      if (rawChannels is List) {
        for (final channel in rawChannels) {
          if (channel is Map) {
            _searchedChannelList!.add(
              ChannelData.fromJson(Map<String, dynamic>.from(channel)),
            );
          }
        }
      }

      if (_searchedChannelList!.isNotEmpty) {
        for (var item in _searchedChannelList!) {
          ConversationUserModel? conversationUser;
          for (final channelUser
              in item.channelUsers ?? <ConversationUserModel>[]) {
            if (channelUser.user?.userType != 'customer') {
              conversationUser = channelUser;
              break;
            }
          }
          if (conversationUser?.user?.userType == 'provider-admin') {
            _searchedProviderChannelList?.add(item);
          } else if (conversationUser?.user?.userType ==
              'provider-serviceman') {
            _searchedServicemanChannelList?.add(item);
          }
        }
      }

      if (tabController?.index == 0 &&
          _searchedProviderChannelList!.isEmpty &&
          _searchedServicemanChannelList!.isNotEmpty) {
        tabController?.index = 1;
      } else if (tabController?.index == 1 &&
          _searchedProviderChannelList!.isNotEmpty &&
          _searchedServicemanChannelList!.isEmpty) {
        tabController?.index = 0;
      }
    } else {
      ApiChecker.checkApi(response);
    }

    _isSearchComplete = true;
    update();
  }

  Future<void> createChannel(
    String userID,
    String referenceID, {
    String name = 'Chatting Page',
    String image = '',
    bool fromBookingDetailsPage = false,
    String phone = '',
    bool shouldUpdate = true,
    String userType = "",
  }) async {
    _isLoading = true;
    if (shouldUpdate) {
      update();
    }
    Response response = await conversationRepo.createChannel(
      userID,
      referenceID,
    );
    if (response.statusCode == 200) {
      if (fromBookingDetailsPage) {
        Get.back();
        Get.toNamed(
          RouteHelper.getChatScreenRoute(
            response.body['content']['id'],
            name,
            image,
            phone,
            userType,
          ),
        );
      } else {
        Get.toNamed(
          RouteHelper.getChatScreenRoute(
            response.body['content']['id'],
            name,
            image,
            phone,
            userType,
          ),
        );
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void cleanOldData() {
    conversationController.text = "";
    _pickedImageFiles = [];
    objFile = [];
    _selectedImageList = [];
    _otherFile = null;
    _file = null;
  }

  Future<void> getConversation(
    String channelID,
    int offset, {
    bool isFromPagination = false,
    bool isinttial = false,
  }) async {
    if (!isFromPagination && isinttial) {
      _conversationList = null;
    }
    _messageOffset = offset;
    Response response = await conversationRepo.getConversation(
      channelID,
      offset,
    );
    if (response.statusCode == 200) {
      if (!isFromPagination) {
        _conversationList = [];
      }
      response.body['content']['data'].forEach((conversation) {
        _conversationList!.add(ConversationData.fromJson(conversation));
        _messagePageSize = response.body['content']['last_page'];
      });
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> sendMessage(String channelID) async {
    _isLoading = true;
    update();
    Response response = await conversationRepo.sendMessage(
      conversationController.value.text,
      channelID,
      _selectedImageList,
      objFile,
    );
    if (response.statusCode == 200) {
      getConversation(channelID, 1);
      conversationController.text = '';
      _pickedImageFiles = [];
      _selectedImageList = [];
      _otherFile = null;
      objFile = null;
      _file = null;
    } else if (response.statusCode == 400) {
      String message = response.body['errors'][0]['message'];
      if (message.contains("png  jpg  jpeg  csv  txt  xlx  xls  pdf")) {
        message = "the_files_types_must_be";
      }
      if (message.contains("failed to upload")) {
        message = "failed_to_upload";
      }
      _pickedImageFiles = [];
      _selectedImageList = [];
      _otherFile = null;
      objFile = null;
      _file = null;
      customSnackBar(message.tr);
    } else {
      _pickedImageFiles = [];
      _selectedImageList = [];
      _otherFile = null;
      objFile = null;
      _file = null;
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  void downloadFile(String url, String dtr) async {
    await FlutterDownloader.enqueue(
      url: url,
      savedDir: dtr,
      showNotification: true,
      saveInPublicStorage: true,
      openFileFromNotification: true,
    );
  }

  void downloadFileForWeb(String url) {
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }

  void setUserImageType(String userType) {
    _userTypeImage = userType;
    update();
  }

  void showSuffixIcon(BuildContext context, String text) {
    if (text.isNotEmpty) {
      _isActiveSuffixIcon = true;
    } else if (text.isEmpty) {
      _isActiveSuffixIcon = false;
      searchController.clear();
      _isSearchComplete = false;
    }
    update();
  }

  void clearSearchController({bool shouldUpdate = true}) {
    searchController.clear();
    _isSearchComplete = false;
    _isActiveSuffixIcon = false;
    tabController?.index = 0;
    if (shouldUpdate) {
      update();
    }
  }

  void resetImageFile() {
    _pickedImageFiles = [];
    update();
  }

  String getChatTime(String todayChatTimeInUtc, String? nextChatTimeInUtc) {
    String chatTime = '';
    DateTime todayConversationDateTime = DateConverter.isoUtcStringToLocalDate(
      todayChatTimeInUtc,
    );

    if (kDebugMode) {
      print("Current Message DataTime: $todayConversationDateTime");
    }

    DateTime nextConversationDateTime;
    DateTime currentDate = DateTime.now();

    if (nextChatTimeInUtc == null) {
      return chatTime = DateConverter.isoStringToLocalDateAndTime(
        todayChatTimeInUtc,
      );
    } else {
      nextConversationDateTime = DateConverter.isoUtcStringToLocalDate(
        nextChatTimeInUtc,
      );
      if (kDebugMode) {
        print("Next Message DateTime: $nextConversationDateTime");
        print(
          "The Difference between this two : ${todayConversationDateTime.difference(nextConversationDateTime)}",
        );
        print(
          "Today message Weekday: ${todayConversationDateTime.weekday}\n Next Message WeekDay: ${nextConversationDateTime.weekday}",
        );
      }

      if (todayConversationDateTime.difference(nextConversationDateTime) <
              const Duration(minutes: 30) &&
          todayConversationDateTime.weekday ==
              nextConversationDateTime.weekday) {
        chatTime = '';
      } else if (currentDate.weekday != todayConversationDateTime.weekday &&
          DateConverter.countDays(todayConversationDateTime) < 6) {
        if ((currentDate.weekday - 1 == 0 ? 7 : currentDate.weekday - 1) ==
            todayConversationDateTime.weekday) {
          chatTime = DateConverter.convert24HourTimeTo12HourTimeWithDay(
            todayConversationDateTime,
            false,
          );
        } else {
          chatTime = DateConverter.convertStringTimeToDateTime(
            todayConversationDateTime,
          );
        }
      } else if (currentDate.weekday == todayConversationDateTime.weekday &&
          DateConverter.countDays(todayConversationDateTime) < 6) {
        chatTime = DateConverter.convert24HourTimeTo12HourTimeWithDay(
          todayConversationDateTime,
          true,
        );
      } else {
        chatTime = DateConverter.isoStringToLocalDateAndTime(
          todayChatTimeInUtc,
        );
      }
    }
    return chatTime;
  }

  String getChatTimeWithPrevious(
    ConversationData currentChat,
    ConversationData? previousChat,
  ) {
    DateTime todayConversationDateTime = DateConverter.isoUtcStringToLocalDate(
      currentChat.createdAt ?? "",
    );

    DateTime previousConversationDateTime;

    if (previousChat?.createdAt == null) {
      return 'Not-Same';
    } else {
      previousConversationDateTime = DateConverter.isoUtcStringToLocalDate(
        previousChat!.createdAt!,
      );
      if (kDebugMode) {
        print(
          "The Difference is ${previousConversationDateTime.difference(todayConversationDateTime) < const Duration(minutes: 30)}",
        );
      }
      if (previousConversationDateTime.difference(todayConversationDateTime) <
              const Duration(minutes: 30) &&
          todayConversationDateTime.weekday ==
              previousConversationDateTime.weekday &&
          isSameUserWithPreviousMessage(currentChat, previousChat)) {
        return '';
      } else {
        return 'Not-Same';
      }
    }
  }

  bool isSameUserWithPreviousMessage(
    ConversationData? previousConversation,
    ConversationData? currentConversation,
  ) {
    if (previousConversation?.userId == currentConversation?.userId &&
        previousConversation?.message != null &&
        currentConversation?.message != null) {
      return true;
    }
    return false;
  }

  bool isSameUserWithNextMessage(
    ConversationData? currentConversation,
    ConversationData? nextConversation,
  ) {
    if (currentConversation?.userId == nextConversation?.userId &&
        nextConversation?.message != null &&
        currentConversation?.message != null) {
      return true;
    }
    return false;
  }

  String? getOnPressChatTime(ConversationData currentConversation) {
    if (currentConversation.id == _onMessageTimeShowID ||
        currentConversation.id == _onImageOrFileTimeShowID) {
      DateTime currentDate = DateTime.now();
      DateTime todayConversationDateTime =
          DateConverter.isoUtcStringToLocalDate(
            currentConversation.createdAt ?? "",
          );

      if (currentDate.weekday != todayConversationDateTime.weekday &&
          DateConverter.countDays(todayConversationDateTime) <= 7) {
        return DateConverter.convertStringTimeToDate(todayConversationDateTime);
      } else if (currentDate.weekday == todayConversationDateTime.weekday &&
          DateConverter.countDays(todayConversationDateTime) <= 7) {
        return DateConverter.convert24HourTimeTo12HourTime(
          todayConversationDateTime,
        );
      } else {
        return DateConverter.isoStringToLocalDateAndTime(
          currentConversation.createdAt!,
        );
      }
    } else {
      return null;
    }
  }

  void toggleOnClickMessage({required String onMessageTimeShowID}) {
    _onImageOrFileTimeShowID = '';
    _isClickedOnImageOrFile = false;
    if (_isClickedOnMessage && _onMessageTimeShowID != onMessageTimeShowID) {
      _onMessageTimeShowID = onMessageTimeShowID;
    } else if (_isClickedOnMessage &&
        _onMessageTimeShowID == onMessageTimeShowID) {
      _isClickedOnMessage = false;
      _onMessageTimeShowID = '';
    } else {
      _isClickedOnMessage = true;
      _onMessageTimeShowID = onMessageTimeShowID;
    }
    update();
  }

  void toggleOnClickImageAndFile({required String onImageOrFileTimeShowID}) {
    _onMessageTimeShowID = '';
    _isClickedOnMessage = false;
    if (_isClickedOnImageOrFile &&
        _onImageOrFileTimeShowID != onImageOrFileTimeShowID) {
      _onImageOrFileTimeShowID = onImageOrFileTimeShowID;
    } else if (_isClickedOnImageOrFile &&
        _onImageOrFileTimeShowID == onImageOrFileTimeShowID) {
      _isClickedOnImageOrFile = false;
      _onImageOrFileTimeShowID = '';
    } else {
      _isClickedOnImageOrFile = true;
      _onImageOrFileTimeShowID = onImageOrFileTimeShowID;
    }
    update();
  }
}
