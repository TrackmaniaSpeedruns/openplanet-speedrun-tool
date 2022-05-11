string PadLeft(string text, int length, string padChar)
{
    if (text.Length >= length)
        return text;

    string result = text;
    while (result.Length < length)
        result = padChar + result;

    return result;
}