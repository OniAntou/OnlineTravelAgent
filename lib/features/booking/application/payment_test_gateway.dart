bool isCashTestPaymentEnabled({
  required bool isReleaseBuild,
  required bool allowTestPayments,
}) {
  return !isReleaseBuild || allowTestPayments;
}
