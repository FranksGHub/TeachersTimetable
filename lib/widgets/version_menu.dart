import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionMenu extends StatefulWidget {
  const VersionMenu({super.key});

  @override
  State<VersionMenu> createState() => _VersionMenuState();
}

class _VersionMenuState extends State<VersionMenu> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${info.version}.${info.buildNumber}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('    App-Version: $_version');
  }
}
