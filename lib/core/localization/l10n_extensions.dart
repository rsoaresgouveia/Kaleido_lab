import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// Convenience accessor so widgets can call `context.l10n.someString` instead of
/// `AppLocalizations.of(context).someString`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
