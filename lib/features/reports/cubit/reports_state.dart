import '../data/report_data.dart';

abstract class ReportsState {}

class InitialReportsState extends ReportsState {}

class LoadingReportsState extends ReportsState {}

class SuccessReportsState extends ReportsState {
  SuccessReportsState({required this.report});

  ReportData report;
}

class ErrorReportsState extends ReportsState {
  ErrorReportsState({required this.message});

  String message;
}
