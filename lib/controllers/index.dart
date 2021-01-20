import 'package:get/get.dart';

class IndexState extends GetxController {

  RxInt indexCounter = 0.obs ;

  void changeIndex(int newValue) {
    indexCounter.value = newValue;
    update();
  }

}