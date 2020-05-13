import 'package:blockcypher/blockcypher.dart';

//ignore_for_file: avoid_print

Future<void> main(List<String> args) async {
  var token = args[0];
  var client = Client(
      token: token, websocketUrl: 'wss://socket.blockcypher.com/v1/btc/main');

  var confs = client.transactionConfirmation(
      '737ead59ffa50566334ca2323195696f0bb32800f604b516792fa210eb6e0733');
  await confs.forEach(print);
}
