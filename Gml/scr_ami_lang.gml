/// Attribute_Management — UI language: "en" / "zh" / "ru" / "ja" / "ko".
/// Attribute_Management — 界面语言："en" / "zh" / "ru" / "ja" / "ko"。
/// The language is picked in the launcher's in-game settings (MODS tab → Attribute_Management → Language),
/// which stores global.msl_ami_lang_choice as one of the option labels below.
/// 语言在启动器的游戏内设置里选（MODS 页 → Attribute_Management → Language），
/// global.msl_ami_lang_choice 存的就是下拉框里的选项文本。
/// "Auto" follows the OS locale; unsupported locales fall back to English.
/// "Auto" 跟随系统语言，没有对应语言时回退英文。
function scr_ami_lang()
{
    // 选过的语言存在 msl_menu_mod.ini；本次启动还没打开过 MODS 页时全局变量不存在，
    // 这里直接读一次 ini，保证第一次触发浮字就用对语言。
    if (!variable_global_exists("msl_ami_lang_choice"))
    {
        ini_open("msl_menu_mod.ini");
        global.msl_ami_lang_choice = ini_read_string("Attribute_Management", "msl_ami_lang_choice", "Auto");
        ini_close();
    }

    var _choice = global.msl_ami_lang_choice;

    if (string_pos("中", _choice) > 0) return "zh";
    if (string_pos("Рус", _choice) > 0) return "ru";
    if (string_pos("日本", _choice) > 0) return "ja";
    if (string_pos("한국", _choice) > 0) return "ko";
    if (string_pos("English", _choice) > 0) return "en";

    // Auto: resolve the OS locale once and keep it.
    // Auto：系统语言只判定一次并缓存。
    if (!variable_global_exists("msl_ami_lang_auto"))
    {
        var _os = string_lower(os_get_language());
        var _auto = "en";

        if (string_pos("zh", _os) > 0) _auto = "zh";
        else if (string_pos("ru", _os) > 0) _auto = "ru";
        else if (string_pos("ja", _os) > 0) _auto = "ja";
        else if (string_pos("ko", _os) > 0) _auto = "ko";

        global.msl_ami_lang_auto = _auto;
    }

    return global.msl_ami_lang_auto;
}
