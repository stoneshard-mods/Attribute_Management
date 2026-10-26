// 技能树连线回退动画。
// 原版 ctr_SkillLine.update() 只单向把 progress 推到 100，这里把 ami_retract 的连线
// 反向推回 0；期间 active 保持 true，原版 update() 不会同时正向推进。
with (o_skillConnectionsRender)
{
    for (var _ami_i = 0; _ami_i < linesArrayLength; _ami_i++)
    {
        var _ami_l = linesArray[_ami_i];
        
        if (variable_struct_exists(_ami_l, "ami_retract") && _ami_l.ami_retract)
        {
            _ami_l.active = true;
            _ami_l.progress = max(0, _ami_l.progress - (_ami_l.progressStep * 2));
            var _ami_n = _ami_l.progress / _ami_l.progressMax;
            _ami_l.progressNormalized = _ami_n;
            
            if (_ami_n < 0.5)
            {
                _ami_l.progressEasing = 4 * _ami_n * _ami_n * _ami_n;
            }
            else
            {
                _ami_l.progressEasing = 1 - (power((-2 * _ami_n) + 2, 3) / 2);
            }
            
            if (_ami_l.progress <= 0)
            {
                _ami_l.progress = 0;
                _ami_l.progressNormalized = 0;
                _ami_l.progressEasing = 0;
                _ami_l.active = false;
                _ami_l.ami_retract = false;
            }
        }
    }
}
