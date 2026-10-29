import 'package:doggylog/app/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class SkinPurchaseOverlay extends StatelessWidget {
  const SkinPurchaseOverlay({
    super.key,
    required this.isPurchasing,
    required this.child,
  });

  final bool isPurchasing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !isPurchasing,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(excluding: isPurchasing, child: child),
          if (isPurchasing) ...[
            const ModalBarrier(
              key: Key('skin-purchase-barrier'),
              dismissible: false,
              color: Color(0x66000000),
            ),
            Center(
              child: Semantics(
                scopesRoute: true,
                explicitChildNodes: true,
                namesRoute: true,
                liveRegion: true,
                label: context.l10n.premiumSkinPurchaseOpeningTitle,
                child: Dialog(
                  key: const Key('skin-purchase-dialog'),
                  insetPadding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            context.l10n.premiumSkinPurchaseOpeningTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.premiumSkinPurchaseOpeningHint,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
