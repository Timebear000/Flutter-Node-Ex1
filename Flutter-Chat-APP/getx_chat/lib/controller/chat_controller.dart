import 'package:get/get.dart';
import 'package:getx_chat/model/message.dart';

class ChatController extends GetxController {
  RxList<Message> chatMessage = <Message>[].obs;
  Rx<int> connentedUser = 0.obs;
}
