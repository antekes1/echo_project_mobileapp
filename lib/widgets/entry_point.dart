import 'package:flutter/material.dart';
// import 'package:rive/rive.dart';
import '../utils/constants.dart';
import '../utils/models/rive_assets.dart';
import '../utils/rive_utils.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({Key? key}) : super(key: key);

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  late RiveAsset selectedBottomNav;

  @override
  void initState() {
    super.initState();
    selectedBottomNav = bottomNavs.first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.deepPurpleAccent[700],
            borderRadius: const BorderRadius.all(Radius.circular(24)),
          ),
          child: Text("hej"),
          // child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // children: bottomNavs
          //     .map(
          //       (nav) => GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             selectedBottomNav = nav;
          //           });
          //         },
          //         child: Column(
          //           mainAxisSize: MainAxisSize.min,
          //           children: [
          //             AnimatedContainer(
          //               duration: Duration(milliseconds: 200),
          //               height: 4,
          //               width: nav == selectedBottomNav ? 20 : 0,
          //               margin: EdgeInsets.only(bottom: 2),
          //               decoration: BoxDecoration(
          //                 color: Color(0xFF81B4FF),
          //                 borderRadius: BorderRadius.circular(12),
          //               ),
          //             ),
          //             SizedBox(
          //               height: 36,
          //               width: 36,
          //               child: Opacity(
          //                 opacity: nav == selectedBottomNav ? 1 : 0.5,
          //                 child: RiveAnimation.asset(
          //                   nav.src,
          //                   artboard: nav.artboard,
          //                   onInit: (artboard) {
          //                     StateMachineController controller =
          //                         RiveUtils.getRiveController(
          //                       artboard,
          //                       stateMachineName: nav.stateMachineName,
          //                     );
          //                     nav.input =
          //                         controller.findSMI("active") as SMIBool;
          //                   },
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     )

          //.toList(),
          // ),
        ),
      ),
    );
  }
}
