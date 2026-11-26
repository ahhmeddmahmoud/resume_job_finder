import 'jsearch_secrets.dart';
const String jsearchApiKey = String.fromEnvironment(
  'JSEARCH_API_KEY',
  defaultValue: kJsearchApiKey,
);

const String jsearchHost = String.fromEnvironment(
  'JSEARCH_HOST',
  defaultValue: 'jsearch.p.rapidapi.com',
);
