enum ReportPeriod { weekly, monthly, yearly }

extension ReportPeriodLabel on ReportPeriod {
  String get label {
    if (this == ReportPeriod.weekly) return 'Weekly';
    if (this == ReportPeriod.monthly) return 'Monthly';
    return 'Yearly';
  }
}
