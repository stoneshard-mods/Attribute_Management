/// Attribute_Management — localized UI text: English / Chinese / Russian / Japanese / Korean.
/// Attribute_Management — 界面文本：英 / 中 / 俄 / 日 / 韩。
/// Unknown keys are returned unchanged, and any language falls back to English.
/// 未知键原样返回；任何语言缺项时回退英文。
/// (The body reads parameters via argumentN because the compiler renames declared params.)
/// 函数体用 argumentN 取参（编译器会把形参改名）。
function scr_ami_tr(_key)
{
    var _key0 = argument0;
    var _lang = scr_ami_lang();

    switch (_key0)
    {
        case "attr_refunded":
            if (_lang == "zh") return "属性点 +1";
            if (_lang == "ru") return "Очко характеристик +1";
            if (_lang == "ja") return "能力値ポイント +1";
            if (_lang == "ko") return "능력치 포인트 +1";
            return "Attribute point +1";

        case "skill_refunded":
            if (_lang == "zh") return "技能点 +1";
            if (_lang == "ru") return "Очко навыков +1";
            if (_lang == "ja") return "スキルポイント +1";
            if (_lang == "ko") return "스킬 포인트 +1";
            return "Skill point +1";

        case "blocked_attr":
            if (_lang == "zh") return "有已学技能依赖该属性";
            if (_lang == "ru") return "Изученный навык зависит от этой характеристики";
            if (_lang == "ja") return "習得済みスキルがこの能力値を必要としています";
            if (_lang == "ko") return "습득한 스킬이 이 능력치에 의존합니다";
            return "A learned skill depends on this attribute";

        case "blocked_prereq":
            if (_lang == "zh") return "请先退还后续技能";
            if (_lang == "ru") return "Сначала верните последующие навыки";
            if (_lang == "ja") return "先に後続スキルを返還してください";
            if (_lang == "ko") return "먼저 후속 스킬을 반환하세요";
            return "Refund later skills first";

        case "blocked_basic":
            if (_lang == "zh") return "基础技能不可退还";
            if (_lang == "ru") return "Базовые навыки нельзя вернуть";
            if (_lang == "ja") return "基本スキルは返還できません";
            if (_lang == "ko") return "기본 스킬은 반환할 수 없습니다";
            return "Basic skills cannot be refunded";
    }

    return _key0;
}
