import 'package:admin_market/home/banner/banner_page.dart';
import 'package:admin_market/home/order/order_page.dart';
import 'package:admin_market/home/product/product_page.dart';
import 'package:admin_market/home/voucher/voucher_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PageController _controller;
  late List<Widget> _listWidget;

  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = PageController();
    _listWidget = const [
      ProductPage(),
      OrderPage(),
      VoucherPage(),
      BannerPage()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _controller,
        children: _listWidget,
        onPageChanged: (newIndex) {
          setState(() {
            _currentPageIndex = newIndex;
          });
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (newIndex) {
          setState(() {
            _currentPageIndex = newIndex;
          });
          _controller.jumpToPage(_currentPageIndex);
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.all_inbox_rounded),
            icon: Icon(Icons.all_inbox_outlined),
            label: 'Product',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.local_shipping_rounded),
            icon: Icon(Icons.local_shipping_outlined),
            label: 'Order',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.tickets_fill),
            icon: Icon(CupertinoIcons.tickets),
            label: 'Voucher',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bookmarks_rounded),
            icon: Icon(Icons.bookmarks_outlined),
            label: 'Banner',
          ),
        ],
      ),
    );
  }
}
