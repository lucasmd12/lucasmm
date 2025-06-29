import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

/// Implementação de FileService para download de arquivos via HTTP.
class HttpFileService extends FileService {
  @override
  Future<FileServiceResponse> get(String url, {Map<String, String>? headers}) async {
    final http.Response response = await http.get(Uri.parse(url), headers: headers);
    return HttpFileServiceResponse(response);
  }
}

/// Resposta de serviço de arquivo HTTP.
class HttpFileServiceResponse implements FileServiceResponse {
  final http.Response _response;

  HttpFileServiceResponse(this._response);

  @override
  int get statusCode => _response.statusCode;

  @override
  Stream<List<int>> get content => Stream.value(_response.bodyBytes);

  @override
  int? get contentLength => _response.contentLength;

  @override
  DateTime? get validTill {
    final String? cacheControl = _response.headers["cache-control"];
    if (cacheControl != null && cacheControl.contains("no-cache")) {
      return DateTime.now();
    }
    return null; // Deixa o cache manager decidir
  }

  @override
  String? get eTag => _response.headers["etag"];

  @override
  String? get fileExtension => null; // Deixa o cache manager decidir
}


