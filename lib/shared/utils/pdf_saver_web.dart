import 'dart:html' as html;
import 'dart:typed_data';

/// Saves and triggers download of PDF in the web browser.
Future<String?> saveAndDownloadPdf(Uint8List bytes, String filename) async {
  try {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..style.display = 'none';
    
    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    
    html.Url.revokeObjectUrl(url);
    return filename; // On web, return filename to indicate success
  } catch (_) {
    return null;
  }
}
