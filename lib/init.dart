import 'package:parse_server_sdk/parse_server_sdk.dart';

Future<void> initializeParse() async {
  await Parse().initialize(
    '<AppId>',
    'https://parseapi.back4app.com',
    clientKey: '<ClientKey>',
    autoSendSessionId: true,
    debug: true,
  );
}
