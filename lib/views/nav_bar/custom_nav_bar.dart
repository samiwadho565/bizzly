import 'dart:ui';

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
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primaryTeal.withValues(alpha:0.3)),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                backgroundColor: Colors.transparent,
                currentIndex: currentIndex,
                onTap: onTap,
                selectedItemColor: AppColors.primaryTeal,
                unselectedItemColor: Colors.black,
                showUnselectedLabels: true,
                items: [
                  BottomNavigationBarItem(
                    label: 'Home',
                    icon: Icon(Icons.home_outlined,),
                    activeIcon: Icon(Icons.home,),
                  ),
                  BottomNavigationBarItem(
                    label: 'Projects',
                    icon: Stack(
                      children: [
                        Icon(Icons.grid_view_rounded,),
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
                    activeIcon: Icon(Icons.grid_view)
                  ),
                  BottomNavigationBarItem(
                    label: "Tasks",
                    icon: Icon(Icons.assignment_outlined),
                    activeIcon: Icon(Icons.assignment),
                  )  ,         BottomNavigationBarItem(
                    label: "Invoices",
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    activeIcon: Icon(Icons.account_balance_wallet),
                  ) ,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
