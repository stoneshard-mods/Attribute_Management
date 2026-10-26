    case 7:
        // 基础技能是开局免费给的，退点会白拿技能点，与 stone-tool-box 的"不可删除"名单保持一致。
        var _ami_skill_name = object_get_name(object_index);
        var _ami_free = (_ami_skill_name == "o_skill_butchering_ico" || _ami_skill_name == "o_skill_butchering"
            || _ami_skill_name == "o_skill_craft_ico" || _ami_skill_name == "o_skill_craft"
            || _ami_skill_name == "o_skill_trap_search_ico" || _ami_skill_name == "o_skill_trap_search"
            || _ami_skill_name == "o_skill_torch_strike_ico" || _ami_skill_name == "o_skill_torch_strike"
            || _ami_skill_name == "o_pass_skill_Sudden_Attacks");
        
        if (!select && !is_enemy_skill && !global.skill_activate && is_open)
        {
            if (_ami_free)
            {
                with (instance_create_depth(global.guiMouseX, global.guiMouseY - 20, -15000, o_ami_toast))
                {
                    text = scr_ami_tr("blocked_basic");
                    toastColor = make_color_rgb(170, 170, 170);
                }
            }
            else
            {
                // ctr_SkillPoint / ctr_SkillLine 是结构体，不是实例：
                // 判空必须用 != noone，用 instance_exists 会永远为 false。
                var _ami_oi = object_index;
                var _ami_child = noone;
                var _ami_render = noone;
                var _ami_point = noone;
                var _ami_blocked = false;
                
                if (variable_instance_exists(id, "child_skill"))
                    _ami_child = child_skill;
                
                if (instance_exists(owner_creator) && variable_instance_exists(owner_creator, "connectionsRender"))
                {
                    _ami_render = owner_creator.connectionsRender;
                    
                    if (instance_exists(_ami_render))
                    {
                        with (_ami_render)
                        {
                            // 找当前技能对应的节点。按 object_index 匹配，避免节点实例被重载后 id 对不上。
                            for (var _ami_fi = 0; _ami_fi < pointsArrayLength; _ami_fi++)
                            {
                                var _ami_fp = pointsArray[_ami_fi];
                                
                                if (instance_exists(_ami_fp.skill) && _ami_fp.skill.object_index == _ami_oi)
                                {
                                    _ami_point = _ami_fp;
                                    break;
                                }
                            }
                            
                            // 前置技能不能先退：只允许从叶子往根逐级退。
                            if (_ami_point != noone)
                            {
                                for (var _ami_j = 0; _ami_j < pointsArrayLength; _ami_j++)
                                {
                                    var _ami_node = pointsArray[_ami_j];
                                    var _ami_depends = false;
                                    var _ami_parts = _ami_node.pointsArray;
                                    
                                    for (var _ami_k = 0; _ami_k < array_length(_ami_parts); _ami_k++)
                                    {
                                        var _ami_part = _ami_parts[_ami_k];
                                        
                                        for (var _ami_m = 0; _ami_m < array_length(_ami_part); _ami_m++)
                                        {
                                            var _ami_pp = _ami_part[_ami_m];
                                            
                                            if (instance_exists(_ami_pp.skill) && _ami_pp.skill.object_index == _ami_oi)
                                                _ami_depends = true;
                                        }
                                    }
                                    
                                    if (_ami_depends && instance_exists(_ami_node.skill))
                                    {
                                        var _ami_dep_oi = _ami_node.skill.object_index;
                                        
                                        with (_ami_dep_oi)
                                        {
                                            if (is_open)
                                                _ami_blocked = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if (_ami_blocked)
                {
                    with (instance_create_depth(global.guiMouseX, global.guiMouseY - 20, -15000, o_ami_toast))
                    {
                        text = scr_ami_tr("blocked_prereq");
                        toastColor = make_color_rgb(235, 170, 90);
                    }
                }
                else
                {
                    is_open = false;
                    event_user(1);
                    
                    // 连线回退：源头全部熄灭的连线反向播放（由 o_ami_anim 的 Step 驱动）。
                    if (_ami_point != noone)
                    {
                        _ami_point.active = false;
                        
                        if (instance_exists(_ami_render))
                        {
                            with (_ami_render)
                            {
                                for (var _ami_l = 0; _ami_l < linesArrayLength; _ami_l++)
                                {
                                    var _ami_line = linesArray[_ami_l];
                                    
                                    if (!_ami_line.checkConnected(_ami_line.pointsArray))
                                    {
                                        _ami_line.ami_retract = true;
                                    }
                                }
                            }
                        }
                    }
                    
                    // 原版 can_learn 是单向置 true、从不回收：退掉前置后，靠它解锁的后续技能
                    // 仍然显示为可学。这里按前置表重算一次，把不再满足的直接取消 can_learn；
                    // 前置补回后，原版 ctr_SkillPoint.update() 会自动重新置回可学。
                    if (instance_exists(_ami_render))
                    {
                        with (_ami_render)
                        {
                            for (var _ami_q = 0; _ami_q < pointsArrayLength; _ami_q++)
                            {
                                var _ami_qp = pointsArray[_ami_q];
                                var _ami_qskill = _ami_qp.skill;
                                
                                if (!instance_exists(_ami_qskill))
                                    continue;
                                
                                if (_ami_qskill.is_open || _ami_qskill.is_lock || !_ami_qskill.can_learn)
                                    continue;
                                
                                var _ami_qparts = _ami_qp.pointsArray;
                                
                                if (array_length(_ami_qparts) == 0)
                                    continue;
                                
                                // 每个 part 是 AND（组内全要），part 之间是 OR。
                                var _ami_qok = false;
                                
                                for (var _ami_qk = 0; _ami_qk < array_length(_ami_qparts); _ami_qk++)
                                {
                                    var _ami_qpart = _ami_qparts[_ami_qk];
                                    var _ami_qpart_ok = true;
                                    
                                    for (var _ami_qm = 0; _ami_qm < array_length(_ami_qpart); _ami_qm++)
                                    {
                                        var _ami_qpre = _ami_qpart[_ami_qm];
                                        
                                        if (!instance_exists(_ami_qpre.skill) || !_ami_qpre.skill.is_open)
                                            _ami_qpart_ok = false;
                                    }
                                    
                                    if (_ami_qpart_ok)
                                        _ami_qok = true;
                                }
                                
                                if (!_ami_qok)
                                {
                                    with (_ami_qskill)
                                        can_learn = false;
                                }
                            }
                        }
                    }
                    
                    if (_ami_child != noone)
                    {
                        // 清掉快捷栏里对该技能的引用（与 scr_console_resetskills 的做法一致）。
                        with (o_skill_fast_panel)
                        {
                            for (var _ami_set = 0; _ami_set < ds_list_size(skills); _ami_set++)
                            {
                                var _ami_list = ds_list_find_value(skills, _ami_set);
                                
                                for (var _ami_slot_i = 0; _ami_slot_i < ds_list_size(_ami_list); _ami_slot_i++)
                                {
                                    if (ds_list_find_value(_ami_list, _ami_slot_i) == _ami_child)
                                        ds_list_set(_ami_list, _ami_slot_i, -4);
                                }
                            }
                        }
                        
                        // 销毁已经生成出来的该技能实例，否则退点后仍然可以施放。
                        with (o_skill)
                        {
                            if (object_index != o_skill_attack_mode_shot && object_index == _ami_child)
                                instance_destroy();
                        }
                    }
                    
                    // 分类节点重算已学数量（解锁下一层/成就判定用）。
                    if (instance_exists(owner_creator))
                        with (owner_creator)
                            event_user(0);
                    
                    // 与原生学习互逆：技能 -1、可用技能点 +1。
                    scr_atr_incr("SP", 1);
                    scr_atr_calc(5376);
                    audio_play_sound(snd_gui_drop_ico, 3, 0);
                    
                    with (o_character_panel)
                        event_user(10);
                    
                    with (instance_create_depth(global.guiMouseX, global.guiMouseY - 20, -15000, o_ami_toast))
                    {
                        text = scr_ami_tr("skill_refunded");
                        toastColor = make_color_rgb(150, 220, 150);
                    }
                }
            }
        }
        
        break;
