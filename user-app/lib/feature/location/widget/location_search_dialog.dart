import 'package:get/get.dart';
import 'package:jdds/util/core_export.dart';

class LocationSearchDialog extends StatefulWidget {
  final MapController? Function() getMapController;
  final String? pickedLocation;
  final Widget? child;

  const LocationSearchDialog({
    super.key,
    required this.getMapController,
    this.pickedLocation,
    this.child,
  });

  @override
  State<LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<LocationSearchDialog> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<PredictionModel> _predictionList = [];
  List<String> _predictList = [];
  bool _showResults = false;
  bool _isEditing = false;
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(LocationSearchDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pickedLocation != widget.pickedLocation &&
        widget.pickedLocation != null &&
        widget.pickedLocation!.isNotEmpty &&
        _textController.text != widget.pickedLocation &&
        !_isEditing) {
      _textController.text = widget.pickedLocation!;
    }
  }

  void _updateControllerText() {
    if (widget.pickedLocation != null && widget.pickedLocation!.isNotEmpty) {
      _textController.text = widget.pickedLocation!;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _stopEditing() {
    _focusNode.unfocus();
    setState(() {
      _isEditing = false;
      _showResults = false;
      _predictionList = [];
      _predictList = [];
    });
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      setState(() {
        _predictionList = [];
        _predictList = [];
        _showResults = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);

    try {
      LocationController locationController = Get.find<LocationController>();
      _predictionList = await locationController.searchLocation(context, query);

      _predictList = [];
      for (var prediction in _predictionList) {
        _predictList.add(
          prediction.description ?? prediction.placePrediction?.text?.text ?? '',
        );
      }

      if (_predictList.isEmpty) {
        _predictList.add('no_address_found'.tr);
      }
    } catch (e) {
      _predictList = [];
    }

    if (mounted) {
      setState(() {
        _isSearching = false;
        _showResults = _predictList.isNotEmpty;
      });
    }
  }

  void _onSuggestionTap(int index) {
    if (index < _predictionList.length && _predictionList.isNotEmpty) {
      final PredictionModel suggestion = _predictionList[index];
      final String address = _predictList[index];

      _textController.text = address;
      _focusNode.unfocus();
      setState(() {
        _showResults = false;
        _isEditing = false;
      });

      Get.find<LocationController>().setLocation(
        suggestion.placeId ?? suggestion.placePrediction!.placeId!,
        address,
        widget.getMapController(),
      );
    } else {
      _focusNode.unfocus();
      setState(() {
        _showResults = false;
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return _buildEditingView(context);
    } else if (widget.child != null) {
      return GestureDetector(
        onTap: _startEditing,
        child: widget.child!,
      );
    } else {
      return _buildEditingView(context);
    }
  }

  Widget _buildEditingView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeSmall,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                size: 25,
                color: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .color!
                    .withValues(alpha: .6),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Expanded(
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  onChanged: _onSearchChanged,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                  decoration: InputDecoration(
                    hintText: 'search_location'.tr,
                    border: InputBorder.none,
                    hintStyle: robotoRegular.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ),
              ),
              if (_textController.text.isNotEmpty)
                IconButton(
                  onPressed: () {
                    _textController.clear();
                    setState(() {
                      _predictionList = [];
                      _predictList = [];
                      _showResults = false;
                    });
                  },
                  icon: const Icon(Icons.clear, size: 20),
                )
              else
                IconButton(
                  onPressed: _stopEditing,
                  icon: Icon(Icons.close, size: 20,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  ),
                ),
            ],
          ),
        ),
        if (_showResults && _predictList.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.only(top: 4),
            child: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _predictList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () => _onSuggestionTap(index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                index < _predictionList.length
                                    ? Icons.location_on
                                    : Icons.info_outline,
                                size: 20,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _predictList[index],
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
      ],
    );
  }
}
