import 'package:jdds/util/core_export.dart';
import 'package:get/get.dart';

class CodePickerWidget extends StatefulWidget {
  final ValueChanged<CountryCode>? onChanged;
  final ValueChanged<CountryCode>? onInit;
  final String? initialSelection;
  final List<String>? favorite;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final bool? showCountryOnly;
  final InputDecoration? searchDecoration;
  final TextStyle? searchStyle;
  final TextStyle? dialogTextStyle;
  final WidgetBuilder? emptySearchBuilder;
  final Function(CountryCode)? builder;
  final bool? enabled;
  final TextOverflow? textOverflow;
  final Icon? closeIcon;
  final Color? barrierColor;
  final Color? backgroundColor;
  final BoxDecoration? boxDecoration;
  final Size? dialogSize;
  final Color? dialogBackgroundColor;
  final List<String>? countryFilter;
  final bool? showOnlyCountryWhenClosed;
  final bool? alignLeft;
  final bool? showFlag;
  final bool? hideMainText;
  final bool? showFlagMain;
  final bool? showFlagDialog;
  final double? flagWidth;
  final Comparator<CountryCode>? comparator;
  final bool? hideSearch;
  final bool? showDropDownButton;
  final Decoration? flagDecoration;
  final List<Map<String, String>>? countryList;
  const CodePickerWidget({
    this.onChanged,
    this.onInit,
    this.initialSelection,
    this.favorite = const [],
    this.textStyle,
    this.padding = const EdgeInsets.all(8.0),
    this.showCountryOnly = false,
    this.searchDecoration = const InputDecoration(),
    this.searchStyle,
    this.dialogTextStyle,
    this.emptySearchBuilder,
    this.showOnlyCountryWhenClosed = false,
    this.alignLeft = false,
    this.showFlag = true,
    this.showFlagDialog,
    this.hideMainText = false,
    this.showFlagMain,
    this.flagDecoration,
    this.builder,
    this.flagWidth = 25.0,
    this.enabled = true,
    this.textOverflow = TextOverflow.ellipsis,
    this.barrierColor,
    this.backgroundColor,
    this.boxDecoration,
    this.comparator,
    this.countryFilter,
    this.hideSearch = false,
    this.showDropDownButton = false,
    this.dialogSize,
    this.dialogBackgroundColor,
    this.closeIcon = const Icon(Icons.close),
    this.countryList = codes,
    super.key,
  });
  @override
  State<CodePickerWidget> createState() => _CodePickerWidgetState();
}

class _CodePickerWidgetState extends State<CodePickerWidget> {
  CountryCode? selectedItem;
  List<CountryCode>? elements = [];
  List<CountryCode>? favoriteElements = [];

  List<CountryCode> getCountryList(){
    List<Map<String, String>> jsonList = widget.countryList != null? widget.countryList! : [];
    List<CountryCode> elements =
    jsonList.map((json) => CountryCode.fromJson(json)).toList();
    if (widget.comparator != null) {
      elements.sort(widget.comparator);
    }
    if (widget.countryFilter != null && widget.countryFilter!.isNotEmpty) {
      final uppercaseCustomList =
      widget.countryFilter!.map((c) => c.toUpperCase()).toList();
      elements = elements
          .where((c) =>
      uppercaseCustomList.contains(c.code) ||
          uppercaseCustomList.contains(c.name) ||
          uppercaseCustomList.contains(c.dialCode))
          .toList();
    }
    return elements;
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    elements = elements!.map((e) => e.localize(context)).toList();
    _onInit(selectedItem!);
  }
  @override
  void didUpdateWidget(CodePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelection != widget.initialSelection) {
      if (widget.initialSelection != null) {
        selectedItem = elements!.firstWhere(
                (e) =>
            (e.code!.toUpperCase() ==
                widget.initialSelection!.toUpperCase()) ||
                (e.dialCode == widget.initialSelection) ||
                (e.name!.toUpperCase() ==
                    widget.initialSelection!.toUpperCase()),
            orElse: () => elements![0]);
      } else {
        selectedItem = elements![0];
      }
      _onInit(selectedItem!);
    }
  }
  @override
  void initState() {
    super.initState();
    elements = getCountryList();
    if(widget.countryList != null && widget.countryList!.isNotEmpty){
      if (widget.initialSelection != null) {
        selectedItem = elements!.firstWhere(
                (e) =>
            (e.code!.toUpperCase() == widget.initialSelection!.toUpperCase()) ||
                (e.dialCode == widget.initialSelection) ||
                (e.name!.toUpperCase() == widget.initialSelection!.toUpperCase()),
            orElse: () => elements![0]);
      } else {
        selectedItem = elements![0];
      }
      favoriteElements = elements!.where((e) =>
      widget.favorite!.firstWhereOrNull((f) =>
      e.code!.toUpperCase() == f.toUpperCase() ||
          e.dialCode == f ||
          e.name!.toUpperCase() == f.toUpperCase()) !=
          null)
          .toList();
    }
  }

  void showCountryCodePickerDialog() {
    if (!GetPlatform.isAndroid && !GetPlatform.isIOS) {
      showDialog(
        barrierColor: widget.barrierColor ?? Colors.grey.withValues(alpha: 0.5),
        context: context,
        builder: (context) => Center(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 520, maxWidth: 420),
            child: Dialog(
              backgroundColor: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: CountryCodeSelectionView(
                elements: elements!,
                favoriteElements: favoriteElements!,
                selectedItem: selectedItem,
                showFlag: widget.showFlagDialog ?? widget.showFlag ?? true,
                flagWidth: widget.flagWidth!,
                showHandle: false,
                onSelected: (e) {
                  setState(() {
                    selectedItem = e;
                  });
                  _publishSelection(e);
                },
              ),
            ),
          ),
        ),
      );
    } else {
      Get.bottomSheet(
        SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(Get.context!).size.height * 0.65),
            child: CountryCodeSelectionView(
              elements: elements!,
              favoriteElements: favoriteElements!,
              selectedItem: selectedItem,
              showFlag: widget.showFlagDialog ?? widget.showFlag ?? true,
              flagWidth: widget.flagWidth!,
              showHandle: true,
              onSelected: (e) {
                setState(() {
                  selectedItem = e;
                });
                _publishSelection(e);
              },
            ),
          ),
        ),
        useRootNavigator: true,
        backgroundColor: Colors.white,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radiusExtraLarge),
            topRight: Radius.circular(Dimensions.radiusExtraLarge),
          ),
        ),
      );
    }
  }
  void _publishSelection(CountryCode e) {
    if (widget.onChanged != null) {
      widget.onChanged!(e);
    }
  }
  void _onInit(CountryCode e) {
    if (widget.onInit != null) {
      widget.onInit!(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.builder != null) {
      child = InkWell(
        onTap: showCountryCodePickerDialog,
        child: widget.builder!(selectedItem!),
      );
    } else {
      child = InkWell(
        onTap: widget.enabled! ? showCountryCodePickerDialog : null,
        child: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.showFlagMain != null ? widget.showFlagMain! : widget.showFlag!)
              Flexible(
                flex: 0,
                fit: widget.alignLeft! ? FlexFit.tight : FlexFit.loose,
                child: Container(
                  clipBehavior: widget.flagDecoration == null
                      ? Clip.none
                      : Clip.hardEdge,
                  decoration: widget.flagDecoration,
                  margin: widget.alignLeft!
                      ? const EdgeInsets.only(right: 7.0, left: 0)
                      : const EdgeInsets.only(right: 7.0, left: 0),
                  child: Image.asset(
                    selectedItem!.flagUri!,
                    package: 'country_code_picker',
                    width: widget.flagWidth,
                  ),
                ),
              ),
            if (!widget.hideMainText!)
              Flexible(
                fit: widget.alignLeft! ? FlexFit.tight : FlexFit.loose,
                child: Text(
                  widget.showOnlyCountryWhenClosed!
                      ? selectedItem!.toCountryStringOnly()
                      : selectedItem.toString(),
                  style:
                  widget.textStyle ?? Theme.of(context).textTheme.labelLarge,
                  overflow: widget.textOverflow,
                ),
              ),
            if (widget.showDropDownButton!)
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.grey,
                size: 35,
              ),
          ],
        ),
      );
    }
    return child;
  }
}

class CountryCodeSelectionView extends StatefulWidget {
  final List<CountryCode> elements;
  final List<CountryCode> favoriteElements;
  final CountryCode? selectedItem;
  final bool showFlag;
  final double flagWidth;
  final bool showHandle;
  final Function(CountryCode) onSelected;

  const CountryCodeSelectionView({
    super.key,
    required this.elements,
    required this.favoriteElements,
    this.selectedItem,
    this.showFlag = true,
    this.flagWidth = 25,
    this.showHandle = true,
    required this.onSelected,
  });

  @override
  State<CountryCodeSelectionView> createState() => _CountryCodeSelectionViewState();
}

class _CountryCodeSelectionViewState extends State<CountryCodeSelectionView> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CountryCode> get _filtered {
    final String query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.elements;
    return widget.elements
        .where((e) =>
            (e.name ?? '').toLowerCase().contains(query) ||
            (e.dialCode ?? '').toLowerCase().contains(query) ||
            (e.code ?? '').toLowerCase().contains(query))
        .toList();
  }

  List<CountryCode> get _favorites {
    if (_query.trim().isNotEmpty || widget.favoriteElements.isEmpty) return [];
    final mapped = widget.favoriteElements
        .map((f) => widget.elements.firstWhere(
              (e) => e.dialCode == f.dialCode && e.code == f.code,
              orElse: () => f,
            ))
        .toList();
    final result = <CountryCode>[];
    final CountryCode? india =
        mapped.where((e) => e.code?.toUpperCase() == 'IN').firstOrNull;
    if (india != null) result.add(india);
    result.addAll(mapped.where((e) => e.code?.toUpperCase() != 'IN'));
    return result;
  }

  bool _isSelected(CountryCode e) {
    return widget.selectedItem != null &&
        e.dialCode == widget.selectedItem!.dialCode &&
        e.code == widget.selectedItem!.code;
  }

  void _select(CountryCode e) {
    Navigator.of(context).pop();
    widget.onSelected(e);
  }

  Widget _flag(CountryCode e) {
    return Container(
      width: 34,
      height: 24,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xffEAECF0)),
      ),
      child: Image.asset(
        e.flagUri!,
        package: 'country_code_picker',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _item(CountryCode e) {
    final bool selected = _isSelected(e);
    return InkWell(
      onTap: () => _select(e),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffFFF1EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (widget.showFlag) ...[
              _flag(e),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                e.toCountryStringOnly(),
                style: robotoMedium.copyWith(
                  fontSize: 15,
                  color: const Color(0xff101828),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '+${e.dialCode ?? ''}',
              style: robotoSemiBold.copyWith(
                fontSize: 15,
                color: selected ? const Color(0xffFF6B2C) : const Color(0xff667085),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, size: 20, color: Color(0xffFF6B2C)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        text,
        style: robotoSemiBold.copyWith(
          fontSize: 12,
          letterSpacing: 0.5,
          color: const Color(0xff98A2B3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<CountryCode> favorites = _favorites;
    final List<CountryCode> filtered = _filtered;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHandle) ...[
          Container(
            margin: const EdgeInsets.only(top: 10),
            height: 4,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xffD0D5DD),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
        Padding(
          padding: EdgeInsets.fromLTRB(20, widget.showHandle ? 14 : 20, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Select Country',
                  style: robotoBold.copyWith(fontSize: 17, color: const Color(0xff101828)),
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xffF2F4F7)),
                  child: const Icon(Icons.close, size: 18, color: Color(0xff667085)),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            style: robotoRegular.copyWith(fontSize: 15, color: const Color(0xff101828)),
            decoration: InputDecoration(
              hintText: 'Search country or code',
              hintStyle: robotoRegular.copyWith(fontSize: 15, color: const Color(0xff98A2B3)),
              prefixIcon: const Icon(Icons.search, size: 22, color: Color(0xff98A2B3)),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.cancel, size: 20, color: Color(0xff98A2B3)),
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xffF9FAFB),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffEAECF0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xffFF6B2C)),
              ),
            ),
          ),
        ),
        Flexible(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            shrinkWrap: true,
            children: [
              if (favorites.isNotEmpty) ...[
                _sectionHeader('POPULAR'),
                ...favorites.map(_item),
                _sectionHeader('ALL COUNTRIES'),
                ...widget.elements.map(_item),
              ] else if (filtered.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No country found',
                      style: robotoRegular.copyWith(fontSize: 15, color: const Color(0xff98A2B3)),
                    ),
                  ),
                ),
              ] else
                ...filtered.map(_item),
            ],
          ),
        ),
      ],
    );
  }
}