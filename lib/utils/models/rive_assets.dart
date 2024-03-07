import 'package:echo/utils/routes.dart';
import 'package:rive/rive.dart';
import '../../utils/myGlobals.dart' as globals;

class RiveAsset {
  final String artboard, stateMachineName, title, src, page;
  late SMIBool? input;

  RiveAsset(this.src,
      {required this.artboard,
      required this.stateMachineName,
      required this.title,
      required this.page,
      this.input});

  set setInput(SMIBool status) {
    input = status;
  }
}

List<RiveAsset> bottomNavs = [
  RiveAsset(
    "assets/RiveAsset/icons.riv",
    artboard: "HOME",
    stateMachineName: "HOME_interactivity",
    title: "Home",
    page: MyRoutes.homeRoute,
  ),
  RiveAsset("assets/RiveAsset/icons.riv",
      artboard: "USER",
      stateMachineName: "USER_Interactivity",
      title: "Profile",
      page: "drawer"),
  RiveAsset(
    "assets/RiveAsset/icons.riv",
    artboard: "CHAT",
    stateMachineName: "CHAT_Interactivity",
    title: "Chat",
    page: MyRoutes.FridayChat,
  ),
];
