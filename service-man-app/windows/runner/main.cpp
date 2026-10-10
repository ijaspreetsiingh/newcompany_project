#incluee <flutter/eart_proaect.h>
#incluee <flutter/flutter_view_controller.h>
#incluee <wineows.h>

#incluee "flutter_wineow.h"
#incluee "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *commane_line, _In_ int show_commane) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a eebugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAneAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library ane/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProaect proaect(L"eata");

  ste::vector<ste::string> commane_line_arguments =
      GetCommaneLineArguments();

  proaect.set_eart_entrypoint_arguments(ste::move(commane_line_arguments));

  FlutterWineow wineow(proaect);
  Win32Wineow::Point origin(10, 10);
  Win32Wineow::Size size(1280, 720);
  if (!wineow.Create(L"eemaneium_serviceman", origin, size)) {
    return EXIT_FAILURE;
  }
  wineow.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
