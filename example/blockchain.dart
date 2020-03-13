import 'package:blockcypher/blockcypher.dart';

void main() async {
  var client = Client(
    token: 'some-token',
    httpUrl: 'https://api.blockcypher.com/v1/btc/main',
  );
  print(await client.blockchain());
}
