import 'package:demandium_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ConversationSendMessageWidget extends StatelessWidget {
  final String channelId;
  const ConversationSendMessageWidget({super.key, required this.channelId}) ;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(builder: (conversationController){

      final bool hasPickedFiles = conversationController.isLoading == false && conversationController.pickedImageFile != null && conversationController.pickedImageFile!.isNotEmpty
          || (conversationController.objFile != null && conversationController.objFile!.isNotEmpty);

      return Container(
        decoration: BoxDecoration(
          color: hasPickedFiles ? context.kPrimary.withValues(alpha:0.1) : null,
          border: Border(top: BorderSide(color: context.kBorder, width: 1)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),

        child: SafeArea(
          top: false,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            conversationController.pickedImageFile != null && conversationController.pickedImageFile!.isNotEmpty && conversationController.isLoading == false ?

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 70, child: ListView.builder(
                  clipBehavior: Clip.none,
                  shrinkWrap: true, scrollDirection: Axis.horizontal,
                  itemCount: conversationController.pickedImageFile!.length,
                  itemBuilder: (context, index){
                    return Padding(
                      padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                      child: Stack( clipBehavior: Clip.none, children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(kRadiusMd),
                          child: SizedBox(height: 65, width: 65,
                            child: Image.file(
                              File(conversationController.pickedImageFile![index].path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        Positioned(top: -5, right: -5,
                          child: InkWell(
                            child: Image(image: AssetImage(Images.cancelIcon),
                              height: Dimensions.paddingSizeLarge,
                              width: Dimensions.paddingSizeLarge,
                            ),
                            onTap: () => conversationController.pickMultipleImage(true,index: index),
                          ),
                        ),

                      ]),
                    );
                  },
                )),

                if(conversationController.pickedFIleCrossMaxLength)
                  Text( conversationController.pickedFIleCrossMaxLength ? "• ${"can_not_select_more_than".tr} ${AppConstants.maxLimitOfTotalFileSent.floor()} ${'files'.tr}" :"",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall, color: context.kDestructive.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ) : conversationController.objFile != null && conversationController.objFile!.isNotEmpty && conversationController.isLoading == false ?

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 70,
                  child: ListView.separated(
                    shrinkWrap: true, scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(bottom: 5),
                    separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSizeDefault),
                    itemCount: conversationController.objFile!.length,
                    itemBuilder: (context, index){
                      String fileSize =  ImageSize.getFileSizeFromPlatformFileToString(conversationController.objFile![index]);
                      return Container(width: 180,
                        decoration: BoxDecoration(
                          color: context.kCard,
                          borderRadius: BorderRadius.circular(kRadiusMd),
                          border: Border.all(color: context.kBorder, width: 1),
                        ),
                        padding: const EdgeInsets.only(left: 10, right: 5),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [

                          Image.asset(Images.file,height: 30, width: 30,),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [

                            Text(conversationController.objFile![index].name,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: context.kForeground),
                            ),

                            Text(fileSize, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                              color: context.kMutedForeground,
                            )),
                          ])),


                          InkWell(
                            onTap: () {
                              conversationController.pickOtherFile(true, index: index);
                            },
                            child: Padding(padding: const EdgeInsets.only(top: 5),
                              child: Align(alignment: Alignment.topRight,
                                child: Icon(Icons.close,
                                  size: Dimensions.paddingSizeLarge,
                                  color: context.kMutedForeground,
                                ),
                              ),
                            ),
                          )

                        ]),
                      );
                    },
                  ),
                ),

                if(conversationController.pickedFIleCrossMaxLength)
                  Text( conversationController.pickedFIleCrossMaxLength ? "• ${"can_not_select_more_than".tr} ${AppConstants.maxLimitOfTotalFileSent.floor()} ${'files'.tr}" :"",
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall, color: context.kDestructive.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ) : const SizedBox(),


            conversationController.isLoading ? conversationController.pickedImageFile != null && conversationController.pickedImageFile!.isNotEmpty ?

            Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              child: Align(alignment: Alignment.bottomRight,
                child: Text("${'uploading'.tr} ${conversationController.pickedImageFile!.length} ${conversationController.pickedImageFile!.length >1 ? "files".tr : "file"}",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: context.kMutedForeground),
                ),
              ),
            ): conversationController.objFile != null && conversationController.objFile!.isNotEmpty ?

            Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              child: Align(alignment: Alignment.bottomRight,
                child: Text("${'uploading'.tr} ${conversationController.objFile!.length} ${conversationController.objFile!.length >1 ? "files".tr : "file"}",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: context.kMutedForeground),
                ),
              ),
            ): const SizedBox() : const SizedBox(),


            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

              KIconButton(
                icon: Icons.image_outlined,
                onTap: conversationController.isLoading ? null : () async {
                  await conversationController.pickMultipleImage(false);
                },
              ),
              const SizedBox(width: 8),

              KIconButton(
                icon: Icons.attachment_outlined,
                onTap: conversationController.isLoading ? null : () async {
                  await conversationController.pickOtherFile(false);
                },
              ),
              const SizedBox(width: 8),

              Expanded(child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: conversationController.isLoading ? context.kCard.withValues(alpha:0.6) : context.kCard,
                  borderRadius: BorderRadius.circular(kRadiusMd),
                  border: Border.all(
                    color: conversationController.isLoading ? context.kBorder : context.kInputBorder,
                    width: 1,
                  ),
                ),
                child: TextField(
                  enabled: conversationController.isLoading ? false : true,
                  controller: conversationController.conversationController,
                  textCapitalization: TextCapitalization.sentences,
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: context.kForeground,
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: 3, minLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: "type_message".tr,
                    hintStyle: robotoRegular.copyWith(
                      color: context.kMutedForeground,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              )),
              const SizedBox(width: 8),

              Material(
                color: context.kPrimary,
                borderRadius: BorderRadius.circular(kRadiusMd),
                child: InkWell(
                  borderRadius: BorderRadius.circular(kRadiusMd),
                  onTap: (){
                    if(conversationController.conversationController.text.isEmpty
                        && conversationController.pickedImageFile!.isEmpty
                        && conversationController.objFile==null){
                      showCustomSnackBar("write_something".tr, type: ToasterMessageType.info);
                    }else{
                      conversationController.sendMessage(channelId);
                      conversationController.conversationController.clear();
                    }
                  },
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(child: conversationController.isLoading ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.kPrimaryForeground,
                      ),
                    ): Icon(Icons.send_rounded,
                      size: 18,
                      color: context.kPrimaryForeground,
                    ),
                    ),
                  ),
                ),
              ),
            ],),
          ]),
        ),
      );
    });
  }
}
