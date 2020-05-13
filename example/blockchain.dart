import 'package:blockcypher/blockcypher.dart';

//ignore_for_file: avoid_print

Future<void> main() async {
  var client = Client(
    token: 'some-token',
    httpUrl: 'https://api.blockcypher.com/v1/btc/main',
  );
  print(await client.blockchain());
}
