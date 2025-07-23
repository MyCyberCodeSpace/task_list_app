import 'package:flutter/material.dart';

class MainCircularProgress extends StatelessWidget {
  const MainCircularProgress({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 100,
        width: 100,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
