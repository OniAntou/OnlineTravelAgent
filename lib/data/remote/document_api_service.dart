import '../../models/document_item.dart';
import 'api_http_client.dart';

class DocumentApiService {
  final ApiHttpClient _client;
  DocumentApiService(this._client);

  Future<DocumentItem> addDocument({
    required String title,
    required String description,
    required String icon,
    required String color,
  }) async {
    final data = await _client.postJson('/api/documents', {
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
    });
    return DocumentItem.fromJson(data);
  }

  Future<bool> deleteDocument(String documentId) async {
    await _client.delete('/api/documents/$documentId');
    return true;
  }
}
