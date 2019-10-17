import 'package:blockcypher/blockcypher.dart';

void main() async {
  var client = Client.http("https://api.blockcypher.com/v1/btc/main", "some-token");
  print(await client.blockchain());
}
