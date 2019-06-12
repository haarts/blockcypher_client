import 'package:blockcypher/blockcypher.dart';

void main(List<String> args) async {
  var token = args[0];
  var client =
      Client.websocket("wss://socket.blockcypher.com/v1/btc/test3", token);

  Stream<String> confs = await client
      .transactionConfirmation("mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB");
  await for (String conf in confs) {
    print(conf);
  }
}
