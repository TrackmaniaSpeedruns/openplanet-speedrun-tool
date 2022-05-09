namespace UI
{
    bool WhiteCheckbox(const string &in text, bool isSelected)
    {
        UI::PushStyleColor(UI::Col::FrameBg, vec4(1,1,1,1));
        UI::PushStyleColor(UI::Col::FrameBgHovered, vec4(0.6,1,1,1));
        UI::PushStyleColor(UI::Col::FrameBgActive, vec4(0.4,1,1,1));
        isSelected = UI::Checkbox(text, isSelected);
        UI::PopStyleColor(3);
        return isSelected;
    }
}