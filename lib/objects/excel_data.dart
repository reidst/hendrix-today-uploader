import 'package:excel/excel.dart';

import 'package:hendrix_today_uploader/firebase/constants.dart';
import 'package:hendrix_today_uploader/firebase/database_item.dart';

typedef ExcelRow = List<String?>;

extension NullSafeGet on ExcelRow {
  String? get(int index) => index >= 0 && index < length ? this[index] : null;
}

extension Format on ExcelRow {
  ExcelRow get format =>
      orderedFields.map((field) => get(field.column)).toList();
}

extension AsDatabaseItem on ExcelRow {
  DatabaseItem? asDatabaseItem() {
    DateTime? formatDateTime(String? from) => switch (from) {
      null => null,
      String s => DateTime.tryParse(s),
    };
    
    final String? idString = get(idField.column);
    if (idString == null) {
      return null;
    }
    final int? id = int.tryParse(idString);
    if (id == null) {
      return null;
    }
    final String? title = get(titleField.column);
    if (title == null) {
      return null;
    }
    final String? desc = get(descField.column);
    if (desc == null) {
      return null;
    }
    final DatabaseItemType? type = DatabaseItemType.fromString(
      get(typeField.column),
    );
    if (type == null) {
      return null;
    }
    final String? contactName = get(contactNameField.column);
    if (contactName == null) {
      return null;
    }
    final String? contactEmail = get(contactEmailField.column);
    if (contactEmail == null) {
      return null;
    }
    final DateTime? beginPosting = formatDateTime(
      get(beginPostingField.column),
    );
    if (beginPosting == null) {
      return null;
    }
    final DateTime? endPosting = formatDateTime(get(endPostingField.column));
    if (endPosting == null) {
      return null;
    }
    final DateTime? date = formatDateTime(get(dateField.column));
    if (date == null) {
      return null;
    }
    final String? time = get(timeField.column);
    final String? location = get(locationField.column);
    final DateTime? applyDeadline = formatDateTime(
      get(applyDeadlineField.column),
    );
    return DatabaseItem(
      id: id,
      title: title,
      desc: desc,
      type: type,
      contactName: contactName,
      contactEmail: contactEmail,
      beginPosting: beginPosting,
      endPosting: endPosting,
      date: date,
      time: time,
      location: location,
      applyDeadline: applyDeadline
    );
  }
}

class ExcelData {
  ExcelData(Excel xl) {
    final sheet = xl.sheets[xl.getDefaultSheet()]!;
    rows = sheet.rows
        .map((row) => row.map((cell) => cell?.value?.toString()).toList())
        .toList();
    // sort by ID, with null/blank values first
    rows.sort((a, b) => (int.tryParse(a.get(idField.column) ?? '') ?? -1)
        .compareTo(int.tryParse(b.get(idField.column) ?? '') ?? -1));
  }
  late final List<ExcelRow> rows;
  int get rowCount => rows.length;
  int get colCount => rows.firstOrNull?.length ?? 0;

  static String columnLetter(int col) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    // Algorithm source: https://learn.microsoft.com/en-us/office/troubleshoot/excel/convert-excel-column-numbers
    String result = '';
    col += 1;
    while (col > 0) {
      final a = (col - 1) ~/ 26;
      final b = (col - 1) % 26;
      result = alphabet[b] + result;
      col = a;
    }
    return result;
  }
}
