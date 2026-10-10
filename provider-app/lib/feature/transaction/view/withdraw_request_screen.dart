import 'dart:convert';
import 'dart:math';
import 'package:jassdbx_provider/feature/payement_information/widgets/payment_info_card.dart';
import 'package:jassdbx_provider/feature/transaction/model/dropdown_method_method.dart';
import 'package:jassdbx_provider/util/core_export.dart';
import 'package:get/get.dart';

class WithdrawRequestScreen extends StatefulWidget {
  final double? amount;
  final String? initialAmount;
  final String? initialMethodId;
  final String? initialMethodName;

   const WithdrawRequestScreen({
     super.key,
     this.amount = 0.0,
     this.initialAmount,
     this.initialMethodId,
     this.initialMethodName,
   });
  @override
  State<WithdrawRequestScreen> createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  final TextEditingController _inputAmountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedMethodId='';
  String _selectedMethodName ='';
  List<MethodField>? _fieldList;
  List<MethodField>? _gridFieldList;
  Map<String, TextEditingController> _textControllers =  {};
  final Map<String, FocusNode> _textControllersFocus =  {};
  Map<String, TextEditingController> _gridTextController =  {};
  final Map<String, FocusNode> _gridTextControllerFocus =  {};
  final FocusNode _inputAmountFocusNode = FocusNode();


  void setFocus() {
    _inputAmountFocusNode.requestFocus();
    Get.back();
  }

  Future<void> selectPaymentMethodField (String id, String name, TransactionController transactionMoneyController) async{

    _selectedMethodId = id;
    _selectedMethodName = name;
    _gridFieldList = [];
    _fieldList = [];

    for (var method in transactionMoneyController.withdrawModel!.withdrawalMethods!.firstWhere((method) =>
    method.id.toString() == id).methodFields!) {
      _gridFieldList!.addIf(method.inputName!.toLowerCase().contains('cvv') || method.inputType!.toLowerCase() == 'date', method);
    }

    for (var method in transactionMoneyController.withdrawModel!.withdrawalMethods!.firstWhere((method) =>
    method.id.toString() == id).methodFields!) {
      _fieldList!.addIf(!method.inputName!.toLowerCase().contains('cvv') && method.inputType != 'date', method);
    }
    _textControllers = _textControllers =  {};
    _gridTextController = _gridTextController =  {};

    for (var method in _fieldList!) {
      _textControllers[method.inputName!] = TextEditingController();
      _textControllersFocus[method.inputName!] = FocusNode();
    }
    for (var method in _gridFieldList!) {
      _gridTextController[method.inputName!] = TextEditingController();
      _gridTextControllerFocus[method.inputName!] = FocusNode();
    }

    transactionMoneyController.update();
  }

  void loadData() async {
    final TransactionController transactionController = Get.find<TransactionController>();

    await transactionController.getWithdrawMethods(isReload: true);
    transactionController.getDropdownMethodList();

    String methodId = widget.initialMethodId ?? "";
    String methodName = widget.initialMethodName ?? "";

    bool methodIdExists = methodId.isNotEmpty && (transactionController.withdrawModel?.withdrawalMethods ?? [])
        .any((method) => method.id == methodId);

    if (!methodIdExists) {
      methodId = transactionController.defaultPaymentMethodId ?? "";
      methodName = transactionController.defaultPaymentMethodName ?? "";
      methodIdExists = methodId.isNotEmpty && (transactionController.withdrawModel?.withdrawalMethods ?? [])
          .any((method) => method.id == methodId);
    }

    if (methodIdExists) {
      _selectedMethodId = methodId;
      _selectedMethodName = methodName;
      await selectPaymentMethodField(methodId, methodName, transactionController);

      for (final DropdownMethodModel method in transactionController.othersMethodList) {
        if (method.id == methodId) {
          transactionController.onChangeMethod(method);
          break;
        }
      }
    } else {
      _selectedMethodId = "";
      _selectedMethodName = "";
    }
  }


  @override
  void initState() {
    super.initState();
    if((widget.initialAmount ?? "").isNotEmpty){
      _inputAmountController.text = widget.initialAmount!;
    }
    loadData();
  }

  @override
  void dispose() {
    _inputAmountController.dispose();
    _noteController.dispose();
    _inputAmountFocusNode.dispose();
    _textControllers.forEach((key, textController) {
      textController.dispose();
    });
    _gridTextController.forEach((key, textController) {
      textController.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: InkColors.background,
      body: SafeArea(
        child: Column(children: [

          InkTopBar(title: 'withdraw_request'.tr, onBack: () => Get.back()),

          Expanded(
            child: GetBuilder<TransactionController>(
              builder: (transactionMoneyController) {
                return SingleChildScrollView(
                  child: Column( children: [
                    InkCard(
                      padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
                      margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,Dimensions.paddingSizeSmall,Dimensions.paddingSizeSmall,3),
                      child: Form(
                        key: transactionMoneyController.formKey,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                          Text("business_information".tr,
                            style: robotoBold.copyWith(color: InkColors.foreground, fontSize: Dimensions.fontSizeLarge),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge,),

                          TextFieldTitle(title:'select_withdraw_method'.tr,
                            requiredMark: true,
                            fontSize: Dimensions.fontSizeExtraSmall,
                            isPadding: false,
                          ),

                          Container(width: Get.width, height: 40,
                            decoration:  BoxDecoration(
                              border: Border(bottom: BorderSide(color: InkColors.border)),
                            ),
                      child: DropdownButtonHideUnderline(
                        child: Builder(
                          builder: (context) {
                            final allItems = [
                              ...transactionMoneyController.savedMethodList,
                              ...transactionMoneyController.othersMethodList,
                            ];
                            final selectedValue = transactionMoneyController.selectedMethod;
                            final validValue = (selectedValue != null && allItems.contains(selectedValue))
                                ? selectedValue
                                : null;

                            return DropdownButton<DropdownMethodModel>(
                              borderRadius: BorderRadius.circular(5),
                              menuMaxHeight: Get.height * 0.5,
                              dropdownColor: InkColors.card,
                              hint: Text('select_a_method'.tr, style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: InkColors.mutedForeground,
                              )),
                              value: validValue,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: [

                               if(transactionMoneyController.savedMethodList.isNotEmpty) ...[
                                 DropdownMenuItem<DropdownMethodModel>(
                                   enabled: false,
                                   child: Padding(
                                     padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                     child: Text('my_methods'.tr, style: robotoMedium.copyWith(
                                       color: InkColors.foreground,
                                     )),
                                   ),
                                 ),

                                 ...transactionMoneyController.savedMethodList.map((option) {
                                   return DropdownMenuItem<DropdownMethodModel>(value: option, child: Padding(
                                     padding: EdgeInsets.only(left: Dimensions.paddingSizeExtraLarge),
                                     child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                       Text(option.inputName ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),

                                       if(option.isDefault ?? false) Container(
                                         padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: 3),
                                         decoration: BoxDecoration(
                                           borderRadius: BorderRadius.circular(50),
                                           border: Border.all(color: InkColors.foreground),
                                         ),
                                         child: Text('default'.tr, style: robotoRegular.copyWith(
                                           color: InkColors.foreground,
                                           fontSize: Dimensions.fontSizeSmall,
                                         )),
                                       ),
                                     ]),
                                   ));
                                 }),

                                 // Divider
                                 DropdownMenuItem<DropdownMethodModel>(enabled: false, child: Divider(height: 1)),
                               ],

                                DropdownMenuItem<DropdownMethodModel>(
                                  enabled: false,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                    child: Text('others'.tr, style: robotoMedium.copyWith(
                                      color: InkColors.foreground,
                                    )),
                                  ),
                                ),

                                ...transactionMoneyController.othersMethodList.map((option) {
                                  return DropdownMenuItem<DropdownMethodModel>(
                                    value: option,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: Dimensions.paddingSizeExtraLarge),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        Text(option.inputName ?? '', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),

                                        if(option.isDefault ?? false) Container(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: 3),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(50),
                                            border: Border.all(color: InkColors.foreground),
                                          ),
                                          child: Text('default'.tr, style: robotoRegular.copyWith(
                                            color: InkColors.foreground,
                                            fontSize: Dimensions.fontSizeSmall,
                                          )),
                                        ),
                                      ]),
                                    ),
                                  );
                                }),
                              ],
                              isExpanded: true,
                              underline: const SizedBox(),
                              onChanged: (value) {
                                if(value?.type == MethodType.others) {
                                  _selectedMethodName = value!.withdrawalMethod!.methodName.toString();
                                  _selectedMethodId = value.withdrawalMethod!.id.toString();

                                  selectPaymentMethodField(value.withdrawalMethod!.id.toString(), value.withdrawalMethod!.methodName.toString(), transactionMoneyController);
                                }
                                transactionMoneyController.onChangeMethod(value);

                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                    if(transactionMoneyController.selectedMethod?.type == MethodType.others)...[
                      if(_fieldList != null && _fieldList!.isNotEmpty) ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _fieldList!.length,
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraSmall, horizontal: 0,
                        ),
                        itemBuilder: (context, index) => FieldItemView(
                          methodField:_fieldList![index],
                          textControllers: _textControllers,
                          focusNodes: _textControllersFocus,
                        ),
                      ),

                      if(_gridFieldList != null && _gridFieldList!.isNotEmpty)
                        GridView.builder(
                          padding: const EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: _gridFieldList!.length,
                          itemBuilder: (context, index) => FieldItemView(
                            methodField: _gridFieldList![index],
                            textControllers: _gridTextController,
                            focusNodes: _gridTextControllerFocus,
                          ),
                        ),
                    ],

                    if(transactionMoneyController.selectedMethod?.type == MethodType.myMethods)
                      PaymentInfoCard(paymentMethod: transactionMoneyController.selectedMethod?.paymentMethod),

                    const SizedBox(height: Dimensions.paddingSizeDefault,),
                    CustomTextFormField(
                      inputType: TextInputType.text,
                      controller: _noteController,
                      hintText: "write_note_your_here".tr,
                      capitalization: TextCapitalization.words,
                      maxLines: 2,
                      maxLength: 255,
                    ),

                    InputBoxView(
                      inputAmountController: _inputAmountController,
                      focusNode: _inputAmountFocusNode,
                      amount: widget.amount,
                    ),

                  ]),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge*4,),

                    ]),
                  );
                }
              ),
            ),
          ]),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GetBuilder<TransactionController>(
        builder: (transactionMoneyController) {
          return Container(
            height: 70,
            decoration:  BoxDecoration(
              color: InkColors.card,
              border: Border(top: BorderSide(color: InkColors.border)),
            ),
            child: Center(
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: InkColors.border),
                  color: InkColors.card,
                ),
                child: Transform.rotate(
                  angle: Get.find<LocalizationController>().isLtr ? pi * 2 : pi, // in radians
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: SliderButton(
                      width: Get.width - 20,
                      dismissible: false,
                      action: _handleWithdrawRequest,
                      label: Transform.rotate(
                        angle: Get.find<LocalizationController>().isLtr ? pi * 2 : pi,
                        child: Text(
                          'send_withdraw_request'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: InkColors.foreground,
                          ),
                        ),
                      ),
                      alignLabel: Alignment.center,
                      dismissThresholds: 0.5,
                      icon:  Center(
                        child: Icon(Icons.arrow_forward_rounded, size: 22, color: InkColors.background),
                      ),
                      radius: 50,
                      boxShadow: const BoxShadow(blurRadius: 0.0),
                      buttonColor: InkColors.foreground,
                      backgroundColor: InkColors.card,
                      baseColor: InkColors.mutedForeground,
                      highlightedColor: InkColors.foreground,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      )
    );
  }

  Future<void> _handleWithdrawRequest() async {
    final splashController = Get.find<SplashController>();
    final transactionController = Get.find<TransactionController>();

    final minimumWithdrawAmount = splashController.configModel.content?.minimumWithdrawAmount ?? 0;
    final maximumWithdrawAmount = splashController.configModel.content?.maximumWithdrawAmount ?? 0;

    // Validate empty amount
    if (_inputAmountController.text.isEmpty) {
      showCustomSnackBar('please_input_amount'.tr, type: ToasterMessageType.info);
      return;
    }

    final amount = PriceConverter.getAmountFromInputFormatter(_inputAmountController.text);

    // Validate amount range
    if (amount < minimumWithdrawAmount) {
      showCustomSnackBar(
        '${'withdraw_amount_grater_than'.tr} ${PriceConverter.convertPrice(minimumWithdrawAmount)}',
        type: ToasterMessageType.info,
      );
      return;
    }

    if (amount > maximumWithdrawAmount) {
      showCustomSnackBar(
        "${'maximum_withdraw_amount_is'.tr} ${PriceConverter.convertPrice(maximumWithdrawAmount)}",
        type: ToasterMessageType.info,
      );
      return;
    }

    if (amount < maximumWithdrawAmount && amount > widget.amount!) {
      showCustomSnackBar('insufficient_balance'.tr, type: ToasterMessageType.info);
      return;
    }



    // Handle "my methods" case
    if (transactionController.selectedMethod?.type == MethodType.myMethods) {
      final withdrawRequestBody = {
        'amount': '$amount',
        'withdrawal_method_id': '${transactionController.selectedMethod?.id}',
        'withdrawal_method_fields': base64Url.encode(
          utf8.encode(
            jsonEncode([transactionController.selectedMethod?.methodInfo]),
          ),
        ),
        'note': _noteController.text,
      };
      showCustomDialog(child: const CustomLoader());

      await transactionController.withDrawRequest(placeBody: withdrawRequestBody);
      return;
    }

    // Handle other methods case
    if (!transactionController.formKey.currentState!.validate()) return;

    String? validationMessage;
    final withdrawMethod = transactionController.withdrawModel!.withdrawalMethods!
        .firstWhere((method) => _selectedMethodId == method.id.toString());


    String validationKey = '';
    final methodFieldValue = <Map<String, String>>[];
    final fieldValues = <String, String>{};
    Map<String, String> fieldTypeMap = {};


    //
    // Setup validation
    for (var method in withdrawMethod.methodFields!) {
      fieldTypeMap['${method.inputName}_is_required'] = method.isRequired.toString();
      if (method.inputType == 'email' || method.inputType == 'date') {
        validationKey = method.inputType!;
      }
    }

    // Validate text fields
    _textControllers.forEach((key, textController) {
      fieldValues.addAll({key: textController.text});
      final bool isRequired = fieldTypeMap['${key}_is_required'] == '1';


      if ((validationKey == key) && !GetUtils.isEmail(textController.text)) {
        validationMessage = 'please_provide_valid_email'.tr;
      } else if ((validationKey == key) && textController.text.contains('-')) {
        validationMessage = 'please_provide_valid_date'.tr;
      }

      if (textController.text.isEmpty && validationMessage == null && isRequired) {
        validationMessage = 'please fill ${key.replaceAll('_', ' ')} field';
      }
    });

    // Validate grid text fields
    _gridTextController.forEach((key, textController) {
      fieldValues.addAll({key: textController.text});
      final bool isRequired = fieldTypeMap['${key}_is_required'] == '1';


      if (validationKey == 'date' && textController.text.contains('-')) {
        validationMessage = 'please_provide_valid_date'.tr;
      }
      if (textController.text.isEmpty && validationMessage == null && isRequired) {
        validationMessage = 'Please fill ${key.replaceAll('_', ' ')} field';
      }
    });

    if (validationMessage != null) {
      showCustomSnackBar(validationMessage);
      return;
    }

    methodFieldValue.add(fieldValues);

    showCustomDialog(child: const CustomLoader());

    final withdrawRequestBody = {
      'amount': '$amount',
      'withdrawal_method_id': '${withdrawMethod.id}',
      'withdrawal_method_fields': base64Url.encode(
        utf8.encode(jsonEncode(methodFieldValue)),
      ),
      'note': _noteController.text,
    };

    await transactionController.withDrawRequest(placeBody: withdrawRequestBody);
  }
}





