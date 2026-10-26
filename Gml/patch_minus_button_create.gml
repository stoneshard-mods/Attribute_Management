// 放在「+」左侧：按钮 18px，右边缘 = 行左 + 134，与 + 的左边缘（行左 + 136）留 2px。
// 数值在 Step 里为它让出 20px（见 patch_attribute_step.gml）。
var _ami_minus_id = scr_guiCreateInteractive(id, o_ami_attr_minus, depth - 5, argument0 + 116, (argument1 - 1 + _i * 17));

with (_ami_minus_id)
    attributeKey = _attributeKey;

_attributeID.ami_minus = _ami_minus_id;
