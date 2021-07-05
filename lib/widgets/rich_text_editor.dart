import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RichTextEditor extends StatefulWidget {
  const RichTextEditor({Key? key, this.onSubmitted}) : super(key: key);

  final ValueChanged? onSubmitted;

  @override
  State<StatefulWidget> createState() => _RichTextEditorState();
}

// https://webdeasy.de/en/program-your-own-wysiwyg-editor-in-10-minutes/#css
class _RichTextEditorState extends State<RichTextEditor> {
  @deprecated
  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Widget _buildIconButton(IconData icon, String tooltip) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: () => _showSnackBar(tooltip),
    );
  }

  Wrap _buildActionBar() {
    return Wrap(
      clipBehavior: Clip.antiAlias,
      alignment: WrapAlignment.start,
      children: _buildIconButtons(),
    );
  }

  List<Widget> _buildIconButtons() {
    return <Widget>[
      _buildIconButton(Icons.format_bold, 'Bold'),
      _buildIconButton(Icons.format_italic, 'Italic'),
      _buildIconButton(Icons.format_underline, 'Underline'),
      _buildIconButton(Icons.format_strikethrough, 'Strike through'),
      const VerticalDivider(),
      _buildIconButton(Icons.format_align_left, 'Justify left'),
      _buildIconButton(Icons.format_align_center, 'Justify center'),
      _buildIconButton(Icons.format_align_right, 'Justify right'),
      _buildIconButton(Icons.format_align_justify, 'Justify block'),
      const VerticalDivider(),
      _buildIconButton(Icons.format_list_numbered, 'Insert ordered list'),
      _buildIconButton(Icons.format_list_bulleted, 'Insert unordered list'),
      _buildIconButton(Icons.format_indent_increase, 'Indent'),
      _buildIconButton(Icons.format_indent_decrease, 'Outdent'),
      _buildIconButton(Icons.horizontal_rule, 'Insert horizontal rule'),
      _buildIconButton(Icons.format_clear, 'Remove format'),
      _buildIconButton(Icons.link, 'Insert link'),
      _buildIconButton(Icons.link_off, 'Remove link')
    ];
  }

  Widget _buildTextField() {
    return TextField(
      onSubmitted: widget.onSubmitted,
      textAlignVertical: TextAlignVertical.top,
      autofocus: false,
      decoration: const InputDecoration(
        border: OutlineInputBorder(borderSide: BorderSide.none),
      ),
      maxLines: null,
      expands: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            // padding: EdgeInsets.zero,
            alignment: Alignment.center,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(color: Theme.of(context).bottomAppBarColor),
            child: _buildActionBar(),
          ),
          Expanded(
            child: _buildTextField(),
          ),
        ],
      ),
    );
  }
}
