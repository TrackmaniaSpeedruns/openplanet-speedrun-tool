namespace UI
{
    bool ColoredCheckbox(const string &in text, bool selected, float h, float s = 0.6f, float v = 0.6f)
    {
        UI::PushStyleColor(UI::Col::FrameBg, UI::HSV(h, s, v));
        UI::PushStyleColor(UI::Col::FrameBgHovered, UI::HSV(h, s + 0.1f, v + 0.1f));
        UI::PushStyleColor(UI::Col::FrameBgActive, UI::HSV(h, s + 0.2f, v + 0.2f));
        selected = UI::Checkbox(text, selected);
        UI::PopStyleColor(3);
        return selected;
    }

    bool RedCheckbox(const string &in text, bool selected) { return ColoredCheckbox(text, selected, 0.0f); }
    bool GreenCheckbox(const string &in text, bool selected) { return ColoredCheckbox(text, selected, 0.33f); }
    bool OrangeCheckbox(const string &in text, bool selected) { return ColoredCheckbox(text, selected, 0.155f); }
    bool CyanCheckbox(const string &in text, bool selected) { return ColoredCheckbox(text, selected, 0.5f); }
    bool PurpleCheckbox(const string &in text, bool selected) { return ColoredCheckbox(text, selected, 0.8f); }
    bool RoseCheckbox(const string &in text, bool selected) { return ColoredCheckbox(text, selected, 0.9f); }
    bool WhiteCheckbox(const string &in text, bool selected) { return ColoredCheckbox(text, selected, 0.0f, 0.0f, 0.8f); }
}