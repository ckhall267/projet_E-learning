import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

void registerThreeJSViewer() {
  final String viewType = 'threejs-viewer';

  ui_web.platformViewRegistry.registerViewFactory(
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
