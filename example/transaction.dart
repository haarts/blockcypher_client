import 'package:blockcypher/blockcypher.dart';

//ignore_for_file: avoid_print

Future<void> main() async {
  var client = Client(
    token: 'some-token',
    httpUrl: 'https://api.blockcypher.com/v1/btc/main',
  );
  print(await client.transaction(
      '7c629a291d5657c22ef1c74b786ddfe05e473dda8fc5df2933bf8b27fe758fdc'));
}
