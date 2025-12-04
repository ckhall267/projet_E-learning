// Fichier séparé pour les imports web uniquement
import 'dart:html' as html;
import 'dart:ui' as ui;

void registerThreeJSViewer() {
  final String viewType = 'threejs-viewer';
  html.platformViewRegistry.registerViewFactory(
    viewType,
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

