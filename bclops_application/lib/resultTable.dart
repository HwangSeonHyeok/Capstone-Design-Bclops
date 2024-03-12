import 'package:flutter/material.dart';

class ResultTable extends StatelessWidget {
  final String data;
  ResultTable({super.key, required this.data});
  List<String>? csvRows;
  List<String>? csvHeadingRow;

  void _dataColumnSort(int columnIndex, bool ascending) {
    print('_dataColumnSort() $columnIndex, $ascending');
  }

  List<DataColumn> _getColumns() {
    List<DataColumn> dataColumn = [];

    for (var i in csvHeadingRow!) {
      if (i == 'rank') {
        dataColumn.add(DataColumn(
            label: Text(i),
            tooltip: i,
            numeric: true,
            onSort: _dataColumnSort));
      } else {
        dataColumn.add(DataColumn(label: Text(i), tooltip: i));
      }
    }

    return dataColumn;
  }

  List<DataRow> _getRows() {
    List<DataRow> dataRow = [];

    for (var i = 0; i < csvRows!.length; i++) {
      var csvDataCells = csvRows![i].split(',');

      List<DataCell> cells = [];
      if (csvDataCells[0] == '') break;
      for (var j = 0; j < csvDataCells.length; j++) {
        cells.add(DataCell(Text(csvDataCells[j])));
      }

      dataRow.add(DataRow(cells: cells));
    }

    return dataRow;
  }

  @override
  Widget build(BuildContext context) {
    List<String> dataSplit = data.split('\n');
    csvHeadingRow = dataSplit[0].split(',');
    dataSplit.removeAt(0);
    csvRows = dataSplit;
    return DataTable(
      columnSpacing: 28.0,
      columns: _getColumns(),
      rows: _getRows(),
    );
  }
}
