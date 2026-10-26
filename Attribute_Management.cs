using ModShardLauncher;
using ModShardLauncher.Mods;
using UndertaleModLib.Models;

namespace Attribute_Management;

public class AttributeManagementMod : Mod
{
    public override string Name => "Attribute_Management";
    public override string Author => "Pixel32E";
    public override string Description => "属性/技能点回退：属性行「-」按钮退还属性点，技能树右键退还技能点；界面支持中/英/俄/日/韩";
    public override string ShortDesc => "Refund attribute points with '-' buttons and skill points with right click (multi-language UI)";
    public override string Version => "v1.3.0.0";

    public override void PatchMod()
    {
        // 本地化：语言选择放在启动器的游戏内设置（MODS 页），
        // 与 Map_TP 同一套机制：下拉框绑定 global.msl_ami_lang_choice，
        // 选择存进 msl_menu_mod.ini，文本由 scr_ami_tr 提供。
        Msl.AddFunction(Code("scr_ami_lang.gml"), "scr_ami_lang");
        Msl.AddFunction(Code("scr_ami_tr.gml"), "scr_ami_tr");
        Msl.AddMenu(
            "Attribute_Management",
            new UIComponent(
                "Language / 语言",
                "msl_ami_lang_choice",
                UIComponentType.ComboBox,
                new[] { "Auto", "English", "中文", "Русский", "日本語", "한국어" }));

        // 右键反馈浮字。独立对象，不依赖游戏 UI 内部结构。
        Msl.AddObject("o_ami_toast", spriteName: "", parentName: "", isVisible: true, isPersistent: false, isAwake: true);
        Msl.AddNewEvent("o_ami_toast", Code("o_ami_toast_Create.gml"), EventType.Create, 0);
        Msl.AddNewEvent("o_ami_toast", Code("o_ami_toast_Step.gml"), EventType.Step, 0);
        Msl.AddNewEvent("o_ami_toast", Code("o_ami_toast_Draw.gml"), EventType.Draw, 0);

        // 连线回退动画控制器：常驻，只读写 ctr 结构体的属性，不改原版 Step。
        Msl.AddObject("o_ami_anim", spriteName: "", parentName: "", isVisible: true, isPersistent: true, isAwake: true);
        Msl.AddNewEvent("o_ami_anim", Code("o_ami_anim_Create.gml"), EventType.Create, 0);
        Msl.AddNewEvent("o_ami_anim", Code("o_ami_anim_Step.gml"), EventType.Step, 0);

        // 属性行左侧的「-」按钮：继承 o_button，贴图 s_attrigute_button_down。
        // 位置由 scr_character_attributes_create 在每行创建时给出。
        Msl.AddObject("o_ami_attr_minus", spriteName: "s_attrigute_button_down", parentName: "o_button", isVisible: true, isPersistent: false, isAwake: true);
        Msl.AddNewEvent("o_ami_attr_minus", Code("o_ami_attr_minus_Create.gml"), EventType.Create, 0);
        Msl.AddNewEvent("o_ami_attr_minus", Code("o_ami_attr_minus_Step.gml"), EventType.Step, 0);
        Msl.AddNewEvent("o_ami_attr_minus", Code("o_ami_attr_minus_Other_10.gml"), EventType.Other, 10);

        InsertAfter(
            "gml_GlobalScript_scr_character_attributes_create",
            "scr_guiCreateInteractive(id, o_attribute_button",
            Code("patch_minus_button_create.gml"),
            "属性行创建减号按钮");

        // 减号放到「+」左侧后，数值在显示减号时左移 20px 让位。
        ReplaceAll(
            "gml_Object_o_character_attribute_Step_2",
            Code("patch_attribute_step.gml"),
            "数值为减号让位");

        // 技能图标：o_skill_ico_Create_0 注册了 0,1,2,3,4,22,25,37，缺 7(右键释放)。
        InsertAfter(
            "gml_Object_o_skill_ico_Create_0",
            "scr_guiInteractiveStateUpdate(id, 0, 1, 2, 3, 4, 22, 25, 37)",
            Code("patch_skill_state.gml"),
            "技能图标注册右键状态");

        // 被动技能对象没有单独的 _ico，直接继承 o_skill_ico，这里补一处兜底；
        // scr_guiInteractiveStateUpdate 内部会去重，重复注册无副作用。
        InsertAfter(
            "gml_Object_o_skill_passive_Create_0",
            "event_inherited()",
            Code("patch_skill_state.gml"),
            "被动技能注册右键状态");

        // 右键回退技能：case 7 插在 case 22 之前。
        InsertBefore(
            "gml_Object_o_skill_ico_Other_24",
            "case 22:",
            Code("patch_skill_refund.gml"),
            "技能右键退点");

        // 启动时拉起动画控制器（GameLogInjection 之后执行，追加在文件末尾）。
        InsertAtEnd(
            "gml_Object_o_gameLoader_Create_0",
            Code("spawn_ami_anim.gml"),
            "创建连线动画控制器");
    }

    private static void InsertAfter(string codeName, string anchor, string code, string what)
    {
        try
        {
            Msl.LoadGML(codeName).MatchFrom(anchor).InsertBelow(code).Save();
        }
        catch (System.Exception ex)
        {
            throw new System.InvalidOperationException(
                "Attribute_Management 打补丁失败：" + what + "（" + codeName + "）。游戏代码可能已更新。", ex);
        }
    }

    private static void InsertBefore(string codeName, string anchor, string code, string what)
    {
        try
        {
            Msl.LoadGML(codeName).MatchFrom(anchor).InsertAbove(code).Save();
        }
        catch (System.Exception ex)
        {
            throw new System.InvalidOperationException(
                "Attribute_Management 打补丁失败：" + what + "（" + codeName + "）。游戏代码可能已更新。", ex);
        }
    }

    private static void ReplaceAll(string codeName, string code, string what)
    {
        try
        {
            Msl.LoadGML(codeName).MatchAll().ReplaceBy(code).Save();
        }
        catch (System.Exception ex)
        {
            throw new System.InvalidOperationException(
                "Attribute_Management 打补丁失败：" + what + "（" + codeName + "）。游戏代码可能已更新。", ex);
        }
    }

    private static void InsertAtEnd(string codeName, string code, string what)
    {
        try
        {
            Msl.LoadGML(codeName).MatchAll().InsertBelow(code).Save();
        }
        catch (System.Exception ex)
        {
            throw new System.InvalidOperationException(
                "Attribute_Management 打补丁失败：" + what + "（" + codeName + "）。游戏代码可能已更新。", ex);
        }
    }

    private string Code(string fileName)
    {
        return ModFiles.GetCode(fileName);
    }
}
