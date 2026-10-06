import 'package:demandium_provider/util/core_export.dart';
import 'package:get/get.dart';


class ConversationSendMessageWidget extends StatelessWidget {
  final String channelId;
  const ConversationSendMessageWidget({super.key, required this.channelId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ConversationController>(builder: (conversationController){
      return Container(
        color: conversationController.isLoading == false && ( conversationController.pickedImageFile!=null && conversationController.pickedImageFile!.isNotEmpty
            || (conversationController.objFile!=null && conversationController.objFile!.isNotEmpty)) ?
        InkColors.secondary : null,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),

        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          conversationController.pickedImageFile != null && conversationController.pickedImageFile!.isNotEmpty && conversationController.isLoading == false ?

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 65, child: ListView.separated(
                clipBehavior: Clip.none,
                shrinkWrap: true, scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSizeDefault),
                itemCount: conversationController.pickedImageFile!.length,
                itemBuilder: (context, index){
                  return Stack( clipBehavior: Clip.none, children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
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
                          height: 20,
                          width: 20,
                        ),
                        onTap: () => conversationController.pickMultipleImage(true,index: index),
                      ),
                    ),

                  ]);
                },
              )),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

              if(conversationController.pickedFIleCrossMaxLength)
                Text( conversationController.pickedFIleCrossMaxLength ? "• ${"can_not_select_more_than".tr} ${AppConstants.maxLimitOfTotalFileSent.floor()} ${'files'.tr}" :"",
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
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
                        color: InkColors.card,
                        border: Border.all(color: InkColors.border),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      ),
                      padding: const EdgeInsets.only(left: 10, right: 5),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [

                        Image.asset(Images.fileIcon,height: 30, width: 30,),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.center, children: [

                          Text(conversationController.objFile![index].name,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                          ),

                          Text(fileSize, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                            color: InkColors.mutedForeground,
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
                                color: InkColors.mutedForeground,
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
                    fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ) : const SizedBox(),


          conversationController.isLoading ? conversationController.pickedImageFile != null && conversationController.pickedImageFile!.isNotEmpty ?

          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: Align(alignment: Alignment.bottomRight,
              child: Text("${'uploading'.tr} ${conversationController.pickedImageFile!.length} ${conversationController.pickedImageFile!.length >1 ? "files".tr : "file"}",
                style: robotoLight.copyWith(color: InkColors.mutedForeground),
              ),
            ),
          ): conversationController.objFile != null && conversationController.objFile!.isNotEmpty ?

          Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: Align(alignment: Alignment.bottomRight,
              child: Text("${'uploading'.tr} ${conversationController.objFile!.length} ${conversationController.objFile!.length >1 ? "files".tr : "file"}",
                style: robotoLight.copyWith(color: InkColors.mutedForeground),
              ),
            ),
          ): const SizedBox() : const SizedBox(),


          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

            _AttachButton(
              isLoading: conversationController.isLoading,
              icon: Icons.image_outlined,
              onTap: () => conversationController.pickMultipleImage(false),
            ),

            const SizedBox(width: Dimensions.paddingSizeSmall),

            _AttachButton(
              isLoading: conversationController.isLoading,
              icon: Icons.attach_file_rounded,
              onTap: () => conversationController.pickOtherFile(false),
            ),

            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: conversationController.isLoading ? InkColors.secondary : InkColors.card,
                border: Border.all(color: InkColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),

              child: TextField(
                enabled: !conversationController.isLoading,
                controller: conversationController.conversationController,
                textCapitalization: TextCapitalization.sentences,
                style: robotoRegular.copyWith(
                  fontSize: 13,
                  color: InkColors.foreground,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: 3, minLines: 1,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: "type_a_message".tr,
                  hintStyle: robotoRegular.copyWith(
                    color: InkColors.mutedForeground,
                    fontSize: 13,
                  ),
                ),
              ),
            )),

            const SizedBox(width: Dimensions.paddingSizeSmall),

            GestureDetector(
              onTap: (){
                if(conversationController.conversationController.text.isEmpty
                    && conversationController.pickedImageFile!.isEmpty
                    && conversationController.objFile==null){
                  showCustomSnackBar("write_something".tr, type : ToasterMessageType.info);
                }else{
                  conversationController.sendMessage(channelId);
                  conversationController.conversationController.clear();
                }
              },
              child: Container(
                height: 36,
                width: 36,
                alignment: Alignment.center,
                decoration:  BoxDecoration(
                  shape: BoxShape.circle,
                  color: InkColors.foreground,
                ),
                child: conversationController.isLoading ?  SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: InkColors.background,
                  ),
                ) :  Icon(Icons.send_rounded, size: 16, color: InkColors.background),
              ),
            ),
          ],),
        ]),
      );
    });
  }
}

class _AttachButton extends StatelessWidget {
  final bool isLoading;
  final IconData icon;
  final VoidCallback onTap;
  const _AttachButton({required this.isLoading, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 36,
        width: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: InkColors.card,
          border: Border.all(color: InkColors.border),
        ),
        child: Icon(icon, size: 18, color: isLoading ? InkColors.accent : InkColors.mutedForeground),
      ),
    );
  }
}
