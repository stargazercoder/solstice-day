{{flutter_js}}
{{flutter_build_config}}

// Don't Break the Chain — Flutter Web Bootstrap (Flutter 3.41+)
//
// HTML renderer Flutter 3.22'den itibaren kaldırıldı.
// Artık CanvasKit (varsayılan) kullanılıyor.
//
// DevTools erişimi için:
//   → main.dart'ta SemanticsBinding.instance.ensureSemantics() aktif
//   → Chrome DevTools → Elements panelinde flt-semantics elementleri görünür
//   → aria-label, role, aria-expanded gibi özellikler DOM'da mevcut
//   → Console: document.querySelectorAll('[role]') ile elementlere erişim

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
});
