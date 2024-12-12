
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime? {
  String get toDDMMMYYYY {
    if (this != null) {
      return DateFormat('dd MMM, yyyy').format(this!);
    }
    return '-';
  }

  String get toMMMDDYYYY {
    if (this != null) {
      return DateFormat('MMM dd, yyyy').format(this!);
    }
    return '';
  }

  String get toMMMDDYYYYHHMM {
    if (this != null) {
      return DateFormat('MMM dd, yyyy | h:mm a').format(this!);
    }
    return '';
  }

  String get toYYYYMMDD {
    if (this != null) {
      return DateFormat('yyyy-MM-dd').format(this!);
    }
    return '';
  }

  DateTimeRange get thisWeek {
    final now = DateTime.now();
    if (this != null) {
      // final start=  DateTimeRange(
      final start = DateTime(
        now.year,
        now.month,
        now.subtract(Duration(days: now.weekday - 1)).day,
      );
      final end = DateTime(
        now.year,
        now.month,
        now.add(Duration(days: DateTime.daysPerWeek - now.weekday)).day,
      );
      print('start- $start, end- $end');
      return DateTimeRange(start: start, end: end);
    }
    return DateTimeRange(start: now, end: now);
  }

  DateTimeRange get thisMonth {
    final now = DateTime.now();
    if (this != null) {
      return DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(
          now.year,
          now.month,
          DateTime(now.year, now.month, 0).day,
        ),
      );
    }
    return DateTimeRange(start: now, end: now);
  }

  DateTimeRange get thisYear {
    final now = DateTime.now();
    if (this != null) {
      return DateTimeRange(
        start: DateTime(now.year, 1, 1),
        end: DateTime(now.year, 12, 31),
      );
    }
    return DateTimeRange(start: now, end: now);
  }



  String get differenceBwCreateDateAndNow {
    DateTime from = DateTime.now();
    if (this != null) {
      DateTime to = this!;

      Duration difference = from.difference(to);
      int daysDifference = difference.inDays;
      return daysDifference.toString();
    }
    return '1';
  }

  String get getMonthName {
    if (this != null) {
      return DateFormat("MMMM").format(DateTime(0, this!.month));
    }
    return '';
  }
}

extension DurationExtensions on Duration? {
  String? get toHourAndMin {
    if (this != null) {
      return '${this!.inHours} h ${this!.inMinutes.remainder(60)} min';
    }
    return null;
  }
}
