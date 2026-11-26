/// JSearch v5 (RapidAPI) configuration read via `--dart-define`.
const String jsearchApiKey = String.fromEnvironment(
  'JSEARCH_API_KEY',
  defaultValue: '',
);

const String jsearchHost = String.fromEnvironment(
  'JSEARCH_HOST',
  defaultValue: 'jsearch.p.rapidapi.com',
);
