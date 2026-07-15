import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class DeeplinkDebugPage extends StatelessWidget {
  const DeeplinkDebugPage({
    super.key,
    @PathParam('linkCode') required this.linkCode,
  });
  final String linkCode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '$linkCode IT WORKS!',
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
