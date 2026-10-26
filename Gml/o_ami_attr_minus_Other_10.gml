var _ami_key = attributeKey;
var _ami_base = 10;
var _ami_class_name = object_get_name(global.player_class);

if (ds_map_exists(global.classesMap, _ami_class_name))
{
    var _ami_class = ds_map_find_value(global.classesMap, _ami_class_name);
    var _ami_base_value = ds_map_find_value(_ami_class, _ami_key);
    
    if (is_real(_ami_base_value))
        _ami_base = _ami_base_value;
}

if ((_ami_key != "STR" && _ami_key != "AGL" && _ami_key != "PRC" && _ami_key != "Vitality" && _ami_key != "WIL") || scr_atr(_ami_key) <= _ami_base)
    exit;

// 已学技能的属性门槛：退点后仍必须满足，否则禁止退。
// 与 o_skill_ico_Other_11 同口径：等级达标时属性不是门槛；
// 属性合计按 (属性 - 10) 累加，门槛是 attributes_value_to_open。
var _ami_blocked = false;
var _ami_new_value = scr_atr(_ami_key) - 1;

with (o_skill_ico)
{
    if (!_ami_blocked && is_open && !is_enemy_skill && attributes_value_to_open != 0)
    {
        var _ami_level_ok = (level_to_open != 0 && scr_atr("LVL") >= level_to_open);
        
        if (!_ami_level_ok)
        {
            var _ami_sum_now = 0;
            var _ami_sum_after = 0;
            var _ami_uses = false;
            
            for (var _ami_i = 0; _ami_i < array_length(attributes_names_to_open); _ami_i++)
            {
                var _ami_name = attributes_names_to_open[_ami_i];
                var _ami_value = scr_atr(_ami_name);
                
                if (_ami_name == _ami_key)
                {
                    _ami_uses = true;
                    _ami_sum_after += (_ami_new_value - 10);
                }
                else
                    _ami_sum_after += (_ami_value - 10);
                
                _ami_sum_now += (_ami_value - 10);
            }
            
            if (_ami_uses && _ami_sum_now >= attributes_value_to_open && _ami_sum_after < attributes_value_to_open)
                _ami_blocked = true;
        }
    }
}

if (_ami_blocked)
{
    with (instance_create_depth(global.guiMouseX, global.guiMouseY - 20, -15000, o_ami_toast))
    {
        text = scr_ami_tr("blocked_attr");
        toastColor = make_color_rgb(235, 170, 90);
    }
}
else
{
    // 与原生加点互逆：属性 -1、可用属性点 +1，然后重算派生属性并刷新面板。
    scr_atr_incr(_ami_key, -1);
    scr_atr_incr("AP", 1);
    scr_atr_calc(5376);
    audio_play_sound(snd_gui_drop_ico, 3, 0);
    
    with (o_character_panel)
        event_user(10);
    
    with (o_skill_ico)
        event_user(1);
    
    with (instance_create_depth(global.guiMouseX, global.guiMouseY - 20, -15000, o_ami_toast))
    {
        text = scr_ami_tr("attr_refunded");
        toastColor = make_color_rgb(150, 220, 150);
    }
}
