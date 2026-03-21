const homeShellNavRadius = 26.0;
const homeShellNavHeight = 64.0;
const homeShellNavBottomPadding = 12.0;
const homeShellNavHorizontalPadding = 16.0;
const homeShellContentBottomSpacing = 24.0;

double homeShellContentBottomInset(double safeAreaBottom) {
  return homeShellNavHeight +
      homeShellNavBottomPadding +
      safeAreaBottom +
      homeShellContentBottomSpacing;
}
