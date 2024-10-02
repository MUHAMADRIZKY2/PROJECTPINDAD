import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  final int pageIndex;

  LoadingPage({required this.pageIndex});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Widget _pageContent;

  @override
  void initState() {
    super.initState();
    _pageContent = _buildPageContent(widget.pageIndex);
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void didUpdateWidget(LoadingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageIndex != widget.pageIndex) {
      setState(() {
        _pageContent = _buildPageContent(widget.pageIndex);
        _controller.reset();
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildPageContent(int pageIndex) {
    switch (pageIndex) {
      case 1:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 10, backgroundColor: Colors.blue),
            SizedBox(width: 10),
            CircleAvatar(radius: 10, backgroundColor: Colors.blue),
            SizedBox(width: 10),
            CircleAvatar(radius: 10, backgroundColor: Colors.blue),
          ],
        );
      case 2:
        return CircleAvatar(radius: 20, backgroundColor: Colors.blue);
      case 3:
        return Image.asset('lib/assets/images/logo_smp.png', width: 150);
      case 4:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 10, backgroundColor: Colors.blue),
            SizedBox(width: 10),
            CircleAvatar(radius: 10, backgroundColor: Colors.blue),
            SizedBox(width: 10),
            CircleAvatar(radius: 10, backgroundColor: Colors.blue),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _animation,
        child: _pageContent,
      ),
    );
  }
}
