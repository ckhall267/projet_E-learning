// Helper pour l'intégration web de Three.js
// Ce fichier est utilisé uniquement pour la compilation web

import 'dart:html' as html;
import 'dart:ui' as ui;

void registerThreeJSViewer() {
  html.platformViewRegistry.registerViewFactory(
    'threejs-viewer',
    (int viewId) {
      final html.IFrameElement iframe = html.IFrameElement()
        ..src = 'threejs_viewer.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      return iframe;
    },
  );
}

