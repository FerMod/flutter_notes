import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../data/db.dart';
import '../data/models.dart';
import '../menu/drawer_menu.dart';
import '../menu/loader.dart';

// Example code:
// https://github.com/flutter/gallery/blob/master/lib/demos/material/data_table_demo.dart

class QuestionList extends StatefulWidget {
  QuestionList({Key key}) : super(key: key);

  @override
  _QuestionListState createState() => _QuestionListState();
}

class _QuestionListState extends State<QuestionList> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;

  _DataSource _dataSource;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataSource ??= _DataSource(context);
  }

  void _sort<T>(Comparable<T> Function(Question q) getField, int columnIndex, bool ascending) {
    _dataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  Future<List<Question>> _fetchData() async {
    final _db = DBProvider.instance;
    return await _db.getAllQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Tables'),
      ),
      drawer: DrawerMenu(),
      body: FutureBuilder(
        future: _fetchData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _dataSource.updateData(snapshot.data);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: PaginatedDataTable(
                header: Text('Table Header'),
                rowsPerPage: _rowsPerPage,
                onRowsPerPageChanged: (value) => setState(() {
                  _rowsPerPage = value;
                }),
                sortColumnIndex: _sortColumnIndex,
                sortAscending: _sortAscending,
                columns: [
                  DataColumn(
                    label: Text('Id'),
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort<num>((q) => q.id, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: Text('Question'),
                  ),
                  DataColumn(
                    label: Text('Difficulty'),
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort<num>((q) => q.difficulty, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: Text('Rating'),
                    numeric: true,
                    onSort: (columnIndex, ascending) => _sort<num>((q) => q.rating, columnIndex, ascending),
                  ),
                  DataColumn(
                    label: Text('Subject'),
                    onSort: (columnIndex, ascending) => _sort<String>((q) => q.subject, columnIndex, ascending),
                  ),
                  // DataColumn(
                  //   label: Text('Image'),
                  // ),
                  DataColumn(
                    label: Text('Correct Answer'),
                  ),
                  DataColumn(
                    label: Text('Incorrect Answers'),
                  ),
                ],
                source: _dataSource,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return LoadingScreen();
        },
      ),
    );
  }
}

class _DataSource extends DataTableSource {
  final BuildContext context;
  final int _selectedCount = 0;
  List<Question> _questions;

  _DataSource(this.context);

  void updateData(List dataList) {
    _questions = dataList;
    notifyListeners();
  }

  void _sort<T>(Comparable<T> Function(Question q) getField, bool ascending) {
    _questions.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending ? Comparable.compare(aValue, bValue) : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _questions.length) return null;

    final question = _questions[index];
    return DataRow.byIndex(
      index: index,
      /*
      selected: row.isSelected,
      onSelectChanged: (value) {
        if (row.isSelected != value) {
          _selectedCount += value ? 1 : -1;
          assert(_selectedCount >= 0);
          row.isSelected = value;
          notifyListeners();
        }
      },
      */
      cells: [
        DataCell(Text(question.id.toString())),
        DataCell(Text(question.text)),
        DataCell(Text(question.difficulty.toString())),
        DataCell(Text(question.rating.toString())),
        DataCell(Text(question.subject)),
        // DataCell(Text(question.image)),
        DataCell(Text(question.options.firstWhere((e) => e.isCorrect).value)),
        DataCell(Text(question.options.where((e) => !e.isCorrect).map((e) => e.value).join(', '))),
      ],
    );
  }

  @override
  int get rowCount => _questions.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}
