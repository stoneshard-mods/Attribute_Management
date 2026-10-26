event_inherited();

if (active && updateValue)
{
    if (instance_exists(o_player))
    {
        var _buffParam = 0;
        
        with (o_player)
            _buffParam = scr_buff_param(other.attributeKey);
        
        attributeValue = max(0, math_round(scr_atr(attributeKey) + scr_inv_param(attributeKey) + _buffParam + global.magalomania_value));
        
        // 减号可见时固定让出 37px（+ 的 17px + 减号的 20px），
        // 这样 AP 为 0、加号隐藏时数值也不会压到减号上。
        if (variable_instance_exists(id, "ami_minus") && instance_exists(ami_minus) && ami_minus.visible)
        {
            textAreaWidth = image_xscale - buttonWidth - 20;
        }
        else if (scr_atr("AP") && scr_atr(attributeKey) < 30)
        {
            textAreaWidth = image_xscale - buttonWidth;
        }
        else
        {
            textAreaWidth = image_xscale;
        }
    }
}
