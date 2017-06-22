/// Enter the DSN issued by Sentry.io.
const String _dsnValue = null;

String get dsn {
  if (_dsnValue == null)
    throw new StateError(
      '_dsnValue is not set. Please edit this file (dsn.dart) and paste the '
          'value into the constant at the top of this file. This file is '
          '.gitignored and will not be committed.'
    );

  return _dsnValue;
}
