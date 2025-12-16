// Helper pour envoyer des messages JavaScript à Three.js
// Utilisé uniquement pour web

import 'dart:html' as html;

void sendMessageTo3D(Map<String, dynamic> message) {
  try {
    // Trouver l'iframe Three.js
    final iframes = html.window.document.querySelectorAll('iframe');
    for (var element in iframes) {
      if (element is html.IFrameElement) {
        final src = element.src;
        if (src != null && (src.contains('threejs_viewer.html') || src.contains('threejs'))) {
          element.contentWindow?.postMessage(message, '*');
          return;
        }
      }
    }
    
    // Si l'iframe n'est pas trouvée, essayer d'envoyer via window
    // (pour le cas où l'iframe est dans un autre contexte)
    html.window.postMessage(message, '*');
  } catch (e) {
    print('Erreur lors de l\'envoi du message: $e');
  }
}

