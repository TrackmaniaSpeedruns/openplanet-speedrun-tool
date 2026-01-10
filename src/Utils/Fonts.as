namespace Fonts {
    UI::Font@ Header;

    void Load() {
        @Header = UI::LoadFont("DroidSans.ttf", 20);
    }
}