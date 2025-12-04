// Implémentation web pour l'enregistrement de la vue 3D
// Ce fichier est utilisé uniquement pour la compilation web

import 'dart:html' as html;
import 'fake_platform_view_registry.dart'
    if (dart.library.html) 'platform_view_registry.dart';

void registerThreeJSViewerWeb() {
  platformViewRegistry.registerViewFactory(
    'threejs-viewer-iframe',
    (int viewId) {
      final html.IFrameElement iframe = html.IFrameElement()
        ..src = 'threejs_viewer.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allowFullscreen = true;
      return iframe;
    },
  );
}

