import 'package:blockcypher/blockcypher.dart';

void main(List<String> args) async {
  var token = args[0];
  var client =
      Client.websocket("wss://socket.blockcypher.com/v1/btc/main", token);

  Stream<String> confs = await client
      .transactionConfirmation("3ETUD57Zm1oKrGUikFLsh5xFRieWJzN1sc");
  await for (String conf in confs) {
    print(conf);
  }
}
