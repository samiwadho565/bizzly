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
    const double navBarHeight = 60;
    final BorderRadius borderRadius = BorderRadius.circular(30);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20 ),
        child:ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: navBarHeight,
              decoration: BoxDecoration(
                // color: Colors.white.withValues(alpha:0.1),
                borderRadius: borderRadius,
                border: Border.all(color: AppColors.primary.withValues(alpha:0.3)),
              ),
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  selectedItemColor:AppColors.primary,
                  //selectedIconTheme: IconThemeData(color: AppColors.primary),
                  //unselectedItemColor: Colors.yellow,
                  showSelectedLabels: true,
                  showUnselectedLabels: false,
                  selectedFontSize: 12,
                  unselectedFontSize: 0,
                  iconSize: 22,
                  items: [
                    BottomNavigationBarItem(
                      label: 'Home',
                      icon: Image.asset(
                        AppImages.home,
                        height: 22,
                        color: Colors.black,
                      ),
                      activeIcon: Image.asset(
                        AppImages.homeFill,
                        height: 22,
                        color: AppColors.primary,
                      ),
                    ),
                    BottomNavigationBarItem(
                      label: 'Expenses',
                      icon: Stack(
                        children: [
                        Image.asset(
                          AppImages.expense,
                          height: 22,
                          color: Colors.black,
                        ),

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
                      activeIcon: Image.asset(
                        AppImages.expenseFill,
                        height: 22,
                        color: AppColors.primary,
                      ),
                    ),
                BottomNavigationBarItem(
                  label: "Invoices",
                  icon: Image.asset(
                    AppImages.bill,
                    height: 22,
                    color: Colors.black,
                  ),
                  activeIcon: Image.asset(
                    AppImages.billFill,
                    height: 22,
                    color: AppColors.primary,
                  ),
                ),
                    BottomNavigationBarItem(
                      label: "Tasks",
                      icon: Image.asset(
                        AppImages.task,
                        height: 22,
                        color: Colors.black,
                      ),
                      activeIcon: Image.asset(
                        AppImages.taskFill,
                        height: 22,
                        color: AppColors.primary,
                      ),
                    )     ,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
