import 'package:flutter/material.dart';
import '../pages/earth_power_page.dart';
import '../pages/statistics_page.dart';

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              '菜单',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.table_chart),
            title: Text('地力表'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EarthPowerPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.table_view),
            title: Text('统计'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatisticsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('关于'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'BPI Calculator',
                applicationVersion: '1.0.0',
                children: [
                  Text('这是一个地力表和BPI管理工具。'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}