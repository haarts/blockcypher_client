import 'package:blockcypher/blockcypher.dart';

//ignore_for_file: avoid_print

Future<void> main(List<String> args) async {
  var token = args[0];
  var client = Client(
      token: token, websocketUrl: 'wss://socket.blockcypher.com/v1/btc/test3');

  /// Very high throughput without the optional address filter!
  var txs =
      client.unconfirmedTransactions('mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB');
  await txs.forEach(print);
}
