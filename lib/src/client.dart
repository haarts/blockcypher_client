import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:uuid/uuid.dart';

class Client {
  /// Used to send an appropriate User-Agent header with the HTTP requests
  static const String _userAgent = 'Blockcypher - Dart';
  // TODO set mediaType header
  //ignore: unused_field
  static const String _mediaType = 'application/json';

  static const _headers = {
    HttpHeaders.userAgentHeader: _userAgent,
  };

  /// The websocket URL of the Blockcypher server.
  final Uri websocketUrl;

  /// The http URL of the Blockcypher server.
  final Uri httpUrl;

  /// The API token
  final String token;

  Client(this.token, {String httpUrl = '', String websocketUrl = ''})
      : httpUrl = Uri.parse(httpUrl),
        websocketUrl = Uri.parse(websocketUrl);

  Future<String> blockchain() {
    return _futureFor(Blockchain(token));
  }

  Future<String> transaction(String txid) {
    return _futureFor(Transaction(txid, token));
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
    var streamedResponse = await client.send(request.toRequest(httpUrl));
    client.close();
    return streamedResponse.stream.bytesToString();
  }

  Stream<String> _streamFor(Event event) {
    final channel = IOWebSocketChannel.connect(websocketUrl,
        headers: _headers, pingInterval: const Duration(seconds: 10));
    channel.sink.add(json.encode(event));

    return channel.cast<String>().stream;
  }

  @override
  String toString() => 'Client(urls: $httpUrl/$websocketUrl)';
}

abstract class Request {
  // TODO: deal with token
  // ignore: unused_field
  final String _token;
  final String _path;
  Request(this._token, this._path);

  // NOTE: GET requests don't need tokens
  http.Request toRequest(Uri baseUrl) {
    return http.Request(
        'GET', baseUrl.replace(path: baseUrl.path + _path + urlSuffix));
  }

  String urlSuffix = '';
}

class Blockchain extends Request {
  static const path = '';
  Blockchain(String token) : super(token, path);
}

class Transaction extends Request {
  static const path = '/txs/';
  final String txid;
  Transaction(this.txid, String token) : super(token, path);

  @override
  String get urlSuffix => txid;

  @override
  http.Request toRequest(Uri baseUrl) {
    return http.Request('GET', baseUrl.replace(path: baseUrl.path + _path));
  }
}

abstract class Event {
  final String _uuid;
  final String _token;
  final String _event;

  Event(this._token, this._event) : _uuid = Uuid().v4();

  Map<String, dynamic> toJson();
}

class UnconfirmedTransactions extends Event {
  final String address;

  UnconfirmedTransactions(String token, [this.address])
      : super(token, 'unconfirmed-tx');

  @override
  Map<String, dynamic> toJson() {
    var payload = {
      'id': _uuid,
      'event': _event,
      'token': _token,
    };

    if (address != null) {
      payload['address'] = address;
    }

    return payload;
  }
}

class TransactionConfirmation extends Event {
  final String txHash;

  TransactionConfirmation(String token, this.txHash)
      : super(token, 'tx-confirmation');

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _uuid,
      'event': _event,
      'hash': txHash,
      'token': _token,
    };
  }
}

class NewBlocks extends Event {
  NewBlocks(String token) : super(token, 'new-block');

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _uuid,
      'event': _event,
      'token': _token,
    };
  }
}
