import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Copied from: https://github.com/flutter/flutter/blob/master/packages/flutter/test/widgets/test_widgets.dart
class FlipWidget extends StatefulWidget {
  const FlipWidget({
    super.key,
    required this.left,
    required this.right,
  });

  final Widget left;
  final Widget right;

  @override
  FlipWidgetState createState() => FlipWidgetState();
}

class FlipWidgetState extends State<FlipWidget> {
  bool _showLeft = true;

  void flip() {
    setState(() {
      _showLeft = !_showLeft;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showLeft ? widget.left : widget.right;
  }
}

void flipStatefulWidget(WidgetTester tester, {bool skipOffstage = true}) {
  tester.state<FlipWidgetState>(find.byType(FlipWidget, skipOffstage: skipOffstage)).flip();
}
