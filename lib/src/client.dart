import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:uuid/uuid.dart';

class Client {
  /// Used to send an appropriate User-Agent header with the HTTP requests
  static const String _userAgent = 'Blockcypher - Dart';
  static const String _mediaType = 'application/json';

  /// Used to keep the connection alive
  static const String _pingMessage = '{"event": "ping"}';

  static const _headers = {
    HttpHeaders.userAgentHeader: _userAgent,
  };

  /// The URL of the Blockcypher server.
  final Uri url;

  /// The API token
  final String token;

  Client.websocket(String url, this.token) : url = Uri.parse(url);

  Client.http(String url, this.token) : url = Uri.parse(url);

  Future<String> blockchain() {
    return _futureFor(Blockchain(token));
  }

  /// Returns a [Stream] of transactions each time a confirmation is created.
  Stream<String> transactionConfirmation(String txHash) {
    return _streamFor(TransactionConfirmation(token, txHash));
  }

  /// Returns a [Stream] of blocks are they get published on the network
  Stream<String> newBlocks() {
    return _streamFor(NewBlocks(token));
  }

  /// Returns a [Stream] of transactions in the mempool. High traffic without
  /// the address filter! You're likely to run into API limits in which case
  /// this case seems to hang.
  Stream<String> unconfirmedTransactions([String address]) {
    return _streamFor(UnconfirmedTransactions(token, address));
  }

  Future<String> _futureFor(Request request) async {
    var client = http.Client();
    var streamedResponse = await client.send(request.toRequest(url));
    client.close();
		return streamedResponse.stream.bytesToString();
  }

  Stream<String> _streamFor(Event event) {
    final channel = IOWebSocketChannel.connect(url,
        headers: _headers, pingInterval: const Duration(seconds: 10));
    channel.sink.add(event.toJson());

    return channel.cast<String>().stream;
  }

  @override
  String toString() => "Client(url: $url)";
}

abstract class Request {
  final String _token;
	final String _path;
  Request(this._token, this._path);

  http.Request toRequest(Uri baseUrl);
}

class Blockchain extends Request {
  Blockchain(String token) : super(token, "/");

  // NOTE: GET requests don't need tokens
  @override
  http.Request toRequest(Uri baseUrl) {
    return http.Request("GET", baseUrl.replace(path: _path));
  }
}

abstract class Event {
  final String _uuid;
  final String _token;
  final String _event;

  Event(this._token, this._event) : _uuid = Uuid().v4();

  String toJson();
}

class UnconfirmedTransactions extends Event {
  final String address;

  UnconfirmedTransactions(String token, [this.address])
      : super(token, "unconfirmed-tx");

  String toJson() {
    Map<String, dynamic> payload = {
      "id": _uuid,
      "event": _event,
      "token": _token,
    };

    if (address != null) {
      payload["address"] = address;
    }

    return json.encode(payload);
  }
}

class TransactionConfirmation extends Event {
  final String txHash;

  TransactionConfirmation(String token, this.txHash)
      : super(token, "tx-confirmation");

  String toJson() {
    return json.encode({
      "id": _uuid,
      "event": _event,
      "hash": txHash,
      "token": _token,
    });
  }
}

class NewBlocks extends Event {
  NewBlocks(String token) : super(token, "new-block");

  String toJson() {
    return json.encode({
      "id": _uuid,
      "event": _event,
      "token": _token,
    });
  }
}
