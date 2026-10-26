// 只有"职业初始值以上"的属性才显示减号按钮；没有可退的点就隐藏。
// 用 visible 控制显隐，image_xscale 留给尺寸使用。
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

if ((_ami_key == "STR" || _ami_key == "AGL" || _ami_key == "PRC" || _ami_key == "Vitality" || _ami_key == "WIL") && scr_atr(_ami_key) > _ami_base)
{
    visible = true;
    is_activate = true;
}
else
{
    visible = false;
    is_activate = false;
}
