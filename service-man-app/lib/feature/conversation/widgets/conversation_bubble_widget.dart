import 'dart:ui';

import 'package:jassdbx_serviceman/utils/core_export.dart';
import 'package:get/get.dart';

class ConversationBubbleWidget extends StatefulWidget {
  final ConversationData conversationData;
  final bool isRightMessage;
  final ConversationData? nextConversationData;
  final ConversationData? previousConversationData;
  final String? name;
  final String? image;

  const ConversationBubbleWidget({super.key,
    required this.conversationData,
    required this.isRightMessage,
    this.nextConversationData,
    this.previousConversationData,
    this.name,
    this.image
  });

  @override
  State<ConversationBubbleWidget> createState() => _ConversationBubbleWidgetState();
}

class _ConversationBubbleWidgetState extends State<ConversationBubbleWidget> {
  final ReceivePort _port = ReceivePort();


  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      setState((){ });
    });

  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {

    List<ConversationFile> imageList = [];
    List<ConversationFile> fileList = [];

    if(widget.conversationData.conversationFile != null && widget.conversationData.conversationFile!.isNotEmpty){
      for(ConversationFile conversationFile in widget.conversationData.conversationFile!){
        conversationFile.fileType == 'png' || conversationFile.fileType == 'jpg' ? imageList.add(conversationFile):
        fileList.add(conversationFile);
      }
    }


    List<String> imagePathList = [];

    for (var element in imageList) {
      imagePathList.add(element.storedFileNameFullPath??"");
    }



    return GetBuilder<ConversationController>(
        builder: (conversationController) {


          bool isLTR = Get.find<LocalizationController>().isLtr;
          String chatTime  = conversationController.getChatTime(widget.conversationData.createdAt!, widget.nextConversationData?.createdAt);

          bool isSameUserWithPreviousMessage = conversationController.isSameUserWithPreviousMessage(widget.previousConversationData, widget.conversationData);
          bool isSameUserWithNextMessage = conversationController.isSameUserWithNextMessage(widget.conversationData, widget.nextConversationData);
          String previousMessageHasChatTime = widget.previousConversationData != null? conversationController.getChatTime(widget.previousConversationData!.createdAt!, widget.conversationData.createdAt) : "";

          final bool joinTop = isSameUserWithNextMessage && chatTime == "";
          final bool joinBottom = isSameUserWithPreviousMessage && previousMessageHasChatTime == "";
          final bool tailOnRight = widget.isRightMessage == isLTR;
          final Radius tight = Radius.circular(4);
          final Radius base = Radius.circular(kRadiusMd);
          final BorderRadius bubbleRadius = tailOnRight
              ? BorderRadius.only(
            topRight: joinTop ? tight : base,
            bottomRight: tight,
            topLeft: base,
            bottomLeft: joinBottom ? tight : base,
          )
              : BorderRadius.only(
            topLeft: joinTop ? tight : base,
            bottomLeft: tight,
            topRight: base,
            bottomRight: joinBottom ? tight : base,
          );

          String bubbleTime = '';
          if(widget.conversationData.createdAt != null){
            bubbleTime = DateConverter.convertStringTimeToDate(
                DateConverter.isoUtcStringToLocalDate(widget.conversationData.createdAt!));
          }

          return Column(crossAxisAlignment: widget.isRightMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [


            if(chatTime != "")
              Align(alignment: Alignment.center,
                child: Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, top: 5),
                  child: Text(chatTime,
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      color: context.kMutedForeground,
                    ),
                  ),
                ),
              ),

            Padding(padding: widget.isRightMessage
                ? EdgeInsets.fromLTRB(20, (widget.conversationData.message!=null && isSameUserWithNextMessage) ? 5 : 15, 5,
                (isSameUserWithNextMessage || isSameUserWithPreviousMessage) && (widget.conversationData.message!=null && previousMessageHasChatTime == "") ? 0 : 10)

                : EdgeInsets.fromLTRB(5, 5, 20, (isSameUserWithNextMessage || isSameUserWithPreviousMessage)  && widget.conversationData.message!=null ? 0 : 10),

              child: Column(crossAxisAlignment: widget.isRightMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [

                Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.max, mainAxisAlignment: widget.isRightMessage ? MainAxisAlignment.end : MainAxisAlignment.start, children: [

                  (!widget.isRightMessage && !isSameUserWithPreviousMessage)
                      || ( (!widget.isRightMessage && isSameUserWithPreviousMessage)
                      && conversationController.getChatTimeWithPrevious(widget.conversationData, widget.previousConversationData).isNotEmpty) ?
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge * 2),
                    child: CustomImage(height: Dimensions.paddingSizeExtraLarge + 5,
                      width: Dimensions.paddingSizeExtraLarge + 5,
                      image: widget.image,
                    ),
                  ): !widget.isRightMessage ? const SizedBox(width: Dimensions.paddingSizeExtraLarge + 5,) : const SizedBox(),
                  const SizedBox(width: Dimensions.paddingSizeSmall,),

                  Flexible(child: Column(crossAxisAlignment: widget.isRightMessage? CrossAxisAlignment.end:CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [

                    if(widget.conversationData.message != null) Flexible(child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.isRightMessage ? context.kPrimary : context.kMuted,
                          borderRadius: bubbleRadius,
                        ),

                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: InkWell(
                          onTap: (){
                            conversationController.toggleOnClickMessage(onMessageTimeShowID :
                            widget.conversationData.id!);
                          },
                          child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [

                            Text(widget.conversationData.message??'', style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: widget.isRightMessage ? context.kPrimaryForeground : context.kForeground,
                            )),

                            if(bubbleTime.isNotEmpty)...[
                              const SizedBox(height: 2),
                              Text(bubbleTime,
                                textDirection: TextDirection.ltr,
                                style: robotoRegular.copyWith(
                                  fontSize: 9,
                                  color: widget.isRightMessage
                                      ? context.kPrimaryForeground.withValues(alpha: 0.55)
                                      : context.kMutedForeground,
                                ),
                              ),
                            ],

                          ]),
                        ),

                      ),
                    )),

                    AnimatedContainer(
                      curve: Curves.fastOutSlowIn,
                      duration: const Duration(milliseconds: 500),
                      height: conversationController.onMessageTimeShowID == widget.conversationData.id ? 25.0 : 0.0,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: conversationController.onMessageTimeShowID == widget.conversationData.id ?
                          Dimensions.paddingSizeExtraSmall : 0.0,
                        ),
                        child: Text(conversationController.getOnPressChatTime(widget.conversationData) ?? "",
                          style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: context.kMutedForeground,
                          ),
                        ),
                      ),
                    ),


                    if(widget.conversationData.message != null && widget.conversationData.conversationFile!.isNotEmpty)
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                    widget.conversationData.conversationFile!.isNotEmpty ?
                    Column(crossAxisAlignment: widget.isRightMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [

                      imageList.isNotEmpty ? Directionality(
                        textDirection: widget.isRightMessage  && Get.find<LocalizationController>().isLtr?
                        TextDirection.rtl: !Get.find<LocalizationController>().isLtr && !widget.isRightMessage?
                        TextDirection.rtl: TextDirection.ltr,

                        child: SizedBox(width: 200,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: imageList.length > 3 ? 4 : imageList.length,
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: Dimensions.paddingSizeSmall,
                              crossAxisSpacing: Dimensions.paddingSizeSmall,
                            ),
                            itemBuilder: (context, index) {

                              String imageUrl = '';
                              try{
                                imageUrl = imageList[index].storedFileNameFullPath ?? '';
                              }catch(e) {
                                if (kDebugMode) {
                                  print("");
                                }
                              }


                              if(index == 3  ) { return InkWell(
                                onTap: (){
                                  Get.to(ImageDetailScreen(
                                    imageList: imagePathList,
                                    index: index,
                                    createdAt:  DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(widget.conversationData.createdAt!)),
                                    appbarTitle: widget.conversationData.user?.userType=="super-admin" ? 'technical_support_team'.tr :
                                    widget.conversationData.user?.userType=="provider-serviceman"? "you".tr :
                                    widget.conversationData.user?.userType == 'provider-admin' ? widget.name ?? "" :
                                    "${widget.conversationData.user?.firstName??""} ${widget.conversationData.user?.lastName??""}",
                                  ),
                                  );
                                },
                                onLongPress: (){
                                  conversationController.toggleOnClickImageAndFile(
                                      onImageOrFileTimeShowID : widget.conversationData.id!);
                                },
                                child: Hero(
                                  tag: imageList[index].storedFileNameFullPath??"",
                                  child: Stack(children: [


                                    SizedBox(height: double.infinity, width: double.infinity,
                                        child: ClipRRect(borderRadius: BorderRadius.circular(kRadiusMd),
                                          child: CustomImage(image: imageUrl, fit: BoxFit.contain,),
                                        )),

                                    Container(decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha:0.6),
                                        borderRadius: BorderRadius.circular(kRadiusMd)
                                    )),


                                    Positioned.fill(child: Center(
                                      child: Text("+${imageList.length - index}", style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Dimensions.fontSizeLarge,
                                      ),),
                                    )),


                                  ]),
                                ),
                              );}


                              else if(index > 3) {return const SizedBox();}

                              else{
                                return InkWell(
                                  onTap: () {
                                    Get.to(ImageDetailScreen(
                                      imageList: imagePathList,
                                      index: index,
                                      createdAt:  DateConverter.dateMonthYearTime(DateConverter.isoUtcStringToLocalDate(widget.conversationData.createdAt!)),
                                      appbarTitle: widget.conversationData.user?.userType=="super-admin" ? 'technical_support_team'.tr :
                                      widget.conversationData.user?.userType=="provider-serviceman"? "you".tr :
                                      widget.conversationData.user?.userType == 'provider-admin' ? widget.name ?? "" :
                                      "${widget.conversationData.user?.firstName??""} ${widget.conversationData.user?.lastName??""}",
                                    ),
                                    );
                                  },
                                  onLongPress: (){
                                    conversationController.toggleOnClickImageAndFile(
                                        onImageOrFileTimeShowID : widget.conversationData.id!);
                                  },
                                  child: Hero(
                                    tag: imageList[index].storedFileNameFullPath??"",
                                    child: ClipRRect(borderRadius: BorderRadius.circular(kRadiusMd),
                                        child: CustomImage(image: imageUrl, fit: BoxFit.fill)),
                                  ),
                                );
                              }

                            },
                          ),
                        ),
                      ): const SizedBox(),

                      fileList.isNotEmpty ?
                      Directionality(
                        textDirection: widget.isRightMessage  && Get.find<LocalizationController>().isLtr?
                        TextDirection.rtl : !Get.find<LocalizationController>().isLtr && !widget.isRightMessage?
                        TextDirection.rtl : TextDirection.ltr,

                        child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: fileList.length,
                            padding: imageList.isNotEmpty ? const EdgeInsets.only(top: Dimensions.paddingSizeSmall) : EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisExtent: 60,
                                crossAxisCount: 2,
                                mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
                                crossAxisSpacing: Dimensions.paddingSizeExtraSmall
                            ),
                            itemBuilder: (context, index){

                              return InkWell(
                                onTap: ()async{
                                  final status = await Permission.notification.request();
                                  if (kDebugMode) {
                                    print("Status is $status");
                                  }
                                  if(status.isGranted){
                                    Directory? directory = Directory('/storage/emulated/0/Download');
                                    if (!await directory.exists()){
                                      directory = Platform.isAndroid
                                          ? await getExternalStorageDirectory() //FOR ANDROID
                                          : await getApplicationSupportDirectory();
                                    }
                                    Get.find<ConversationController>().downloadFile(
                                      fileList[index].storedFileNameFullPath ?? '',
                                      directory!.path,
                                    );
                                  }else if(status.isDenied){
                                    await openAppSettings();
                                  }
                                },
                                onLongPress: (){
                                  conversationController.toggleOnClickImageAndFile(
                                      onImageOrFileTimeShowID : widget.conversationData.id!);
                                },
                                child: Container(width: 200, height: 60,
                                    decoration: BoxDecoration(color: context.kMuted,
                                      borderRadius: BorderRadius.circular(kRadiusMd),),
                                    child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                        child: Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Row(children: [


                                            Image(image: AssetImage(Images.file),
                                              height: Dimensions.paddingSizeDefault * 2,
                                              width: Dimensions.paddingSizeDefault * 2,
                                            ),
                                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),


                                            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start, children: [


                                                Text(fileList[index].originalFileName.toString().capitalizeFirst ?? "",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: robotoBold.copyWith(
                                                      fontSize: Dimensions.fontSizeDefault,
                                                      color: context.kForeground,
                                                  ),
                                                ),


                                                Text("${fileList[index].filSize}", style: robotoRegular.copyWith(
                                                    fontSize: Dimensions.fontSizeDefault,
                                                    color: context.kMutedForeground)
                                                ),


                                              ],),


                                            )],

                                          ),
                                        )
                                    )
                                ),
                              );
                            }
                        ),
                      ) : const SizedBox(),

                      AnimatedContainer(
                        curve: Curves.fastOutSlowIn,
                        duration: const Duration(milliseconds: 500),
                        height: conversationController.onImageOrFileTimeShowID == widget.conversationData.id ? 25.0 : 0.0,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: conversationController.onImageOrFileTimeShowID == widget.conversationData.id ?
                            Dimensions.paddingSizeExtraSmall : 0.0,
                          ),
                          child: Text(conversationController.getOnPressChatTime(widget.conversationData) ?? "",
                            style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: context.kMutedForeground,
                            ),
                          ),
                        ),
                      ),

                    ]) :const SizedBox.shrink(),
                  ]),)
                ]),

              ]),
            ),


          ]);
        }
    );
  }
}
