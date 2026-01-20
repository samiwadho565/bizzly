import 'dart:ui';

import 'package:bizly/assets/images.dart';
import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';



class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final navBarHeight = screenHeight * 0.09;
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10 ),
        child:ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: navBarHeight,
              decoration: BoxDecoration(
                // color: Colors.white.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: AppColors.primary.withValues(alpha:0.3)),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                backgroundColor: Colors.transparent,
                currentIndex: currentIndex,
                onTap: onTap,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.black,
                showUnselectedLabels: true,
                items: [
                  BottomNavigationBarItem(
                    label: 'Home',
                    icon:Image.asset(AppImages.home,height: 22,),
                    activeIcon: Image.asset(AppImages.homeFill,height: 22,),
                  ),
                  BottomNavigationBarItem(
                    label: 'Expenses',
                    icon: Stack(
                      children: [
                      Image.asset(AppImages.expense,height: 22,),

                        // BlocBuilder<ServicesBloc, ServicesState>(
                        //   buildWhen: (pre, nxt) =>
                        //   pre.newOrdersCount != nxt.newOrdersCount,
                        //   builder: (context, state) {
                        //     return state.newOrdersCount != 0
                        //         ? Positioned(
                        //         bottom: 10,
                        //         right: 8,
                        //         child: CircleAvatar(
                        //         radius: 6,
                        //         backgroundColor: AppColors.primary,
                        //           child: Center(
                        //             child: Text(
                        //               state.newOrdersCount.toString(),
                        //               style: TextStyle(fontSize: 9,color: Colors.white),
                        //             ),
                        //           ),
                        //         )
                        //     )
                        //         : const SizedBox.shrink();
                        //   },
                        // )
                      ],

                    ),
                    activeIcon: Image.asset(AppImages.expenseFill,height: 22,),
                  ),
              BottomNavigationBarItem(
                label: "Invoices",
                icon: Image.asset(AppImages.bill,height: 22,),
                activeIcon:  Image.asset(AppImages.billFill,height: 22,),
              ),
                  BottomNavigationBarItem(
                    label: "Tasks",
                    icon: Image.asset(AppImages.task,height: 22,),
                    activeIcon:  Image.asset(AppImages.taskFill,height: 22,),
                  )     ,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
