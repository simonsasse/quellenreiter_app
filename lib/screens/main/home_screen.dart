import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quellenreiter_app/models/quellenreiter_app_state.dart';
import 'package:quellenreiter_app/screens/main/friends_screen.dart';
import 'package:quellenreiter_app/screens/main/settings_screen.dart';
import 'package:quellenreiter_app/screens/main/start_screen.dart';

import '../../constants/constants.dart';
import '../../widgets/error_banner.dart';
import 'archive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.appState}) : super(key: key);
  final QuellenreiterAppState appState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? timer;
  late Widget body;
  late String title;
  int index = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    switch (widget.appState.route) {
      case Routes.friends:
        index = 1;
        break;
      case Routes.archive:
        index = 2;
        break;
      case Routes.addFriends:
        index = 1;
        break;
      case Routes.settings:
        index = 3;
        break;
      default:
        index = 0;
    }
    //periodically refetch friends and so on.
    timer = Timer.periodic(const Duration(seconds: 60), (Timer t) {
      print("timer called");
      // check if app is in foreground
      if (_notification == AppLifecycleState.resumed) {
        widget.appState.getFriends();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    // remove observer for applifecyclestate
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  AppLifecycleState _notification = AppLifecycleState.resumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _notification = state;
    });
  }

  void onTap(int indexTapped) {
    HapticFeedback.lightImpact();
    //reset the error message.
    widget.appState.error = null;
    switch (indexTapped) {
      case 0:
        widget.appState.route = Routes.home;
        setState(() {
          index = 0;
        });
        break;
      case 1:
        widget.appState.route = Routes.friends;
        setState(() {
          index = 1;
        });
        break;
      case 2:
        widget.appState.route = Routes.archive;
        setState(() {
          index = 2;
        });
        break;
      case 3:
        widget.appState.route = Routes.settings;
        setState(() {
          index = 3;
        });

        break;
      default:
        widget.appState.route = Routes.home;
        setState(() {
          index = 0;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show error is there is one !
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appState.showError(context);
    });
    switch (index) {
      case 0:
        body = StartScreen(
          appState: widget.appState,
        );
        title = "Büro";
        break;
      case 1:
        body = FriendsScreen(
          appState: widget.appState,
        );
        title = "Freund:innen";
        break;
      case 2:
        body = ArchiveScreen(
          appState: widget.appState,
        );
        title = "Archiv";
        break;
      case 3:
        body = SettingsScreen(
          appState: widget.appState,
        );
        title = "Einstellungen";
        break;
      default:
        body = StartScreen(
          appState: widget.appState,
        );
        title = "Büro";
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.purple[100],
          items: [
            const BottomNavigationBarItem(
              activeIcon: Icon(Icons.rocket_launch),
              icon: Icon(Icons.rocket_outlined),
              label: 'Büro',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.group_outlined),
                  if (widget.appState.enemyRequests != null &&
                      widget.appState.enemyRequests!.enemies.isNotEmpty)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${widget.appState.enemyRequests?.enemies.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
              ),
              activeIcon: Stack(
                children: [
                  const Icon(Icons.group),
                  if (widget.appState.enemyRequests != null &&
                      widget.appState.enemyRequests!.enemies.isNotEmpty)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${widget.appState.enemyRequests?.enemies.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
              ),
              label: 'Freund:innen',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.archive_outlined),
              activeIcon: Icon(Icons.archive),
              label: 'Archiv',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Einstellungen',
            ),
          ],
          currentIndex: index,
          onTap: onTap,
        ),
        appBar: AppBar(
          title: Text(title),
        ),
        body: body,
      ),
    );
  }
}
