import 'package:autoplusapp/pages/newAdPage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:autoplusapp/pages/homePage.dart';
import 'package:autoplusapp/pages/user_pages/userProfilePage.dart';
import 'package:autoplusapp/pages/helpPage.dart';
import 'package:autoplusapp/pages/user_pages/favoritesPage.dart';
class navigationBar extends StatefulWidget{ // Made By Roman
  const navigationBar({Key? key}) : super (key:key);

  @override
  State<navigationBar> createState() => _navigationBar();
}

class _navigationBar extends State<navigationBar>{

  int _selectedIndex = 0;
  void _navigationBarScreen(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const homePage(),
    const newAdPage(),
    const userProfilePage(),
    const favoritesPage(),
    HelpPage(),

  ];

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        color: Colors.red, backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        index: _selectedIndex,
        onTap: _navigationBarScreen,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
        FaIcon(FontAwesomeIcons.house, color: Colors.white),
        FaIcon(FontAwesomeIcons.pencil, color: Colors.white),
        FaIcon(FontAwesomeIcons.user, color: Colors.white),
        FaIcon(FontAwesomeIcons.heart, color: Colors.white),
        FaIcon(FontAwesomeIcons.circleInfo, color: Colors.white),


      ]),
    );
}
}