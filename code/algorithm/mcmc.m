clear; paths; close all

repeat_count = 100;
task_count   = 20;
task_frames  = 450;

target_life  = 30;

rpt_frame_target_count = zeros(1,repeat_count);
rpt_total_target_count = zeros(1,repeat_count);
rpt_touch_count        = zeros(1,repeat_count);

screen_width  = 300;
screen_height = 600;
target_radius = round(sqrt(.0157/pi * screen_width * screen_height * 150^2/100^2));

%on 1st frame a target has a             .0157 chance of being touched
%on 2nd frame a target has a (1-.0157) * .0157 chance of being touched for the first time

for r = 1:repeat_count
    
    s = [0; 0; 0; 0; 0; 0; 0; 0; screen_width; screen_height; target_radius];

    touch_count = 0;
    target_count = 0;

    for o = 1:(task_frames*task_count)
        a = round(rand(2,1).*[screen_width; screen_height])-s(1:2);
        s = huge_trans_pre(s,a);

        target_count = target_count + (size(s,1)-11)/3;
        touch_count  = touch_count + sum(is_touching_target(s));
    end

    rpt_frame_target_count(r) = target_count/(task_frames*task_count);
    rpt_total_target_count(r) = target_count/(target_life*task_count);
    rpt_touch_count       (r) = touch_count /(            task_count);

end

disp([mean(rpt_frame_target_count), std(rpt_frame_target_count)/sqrt(repeat_count)]);
disp([mean(rpt_total_target_count), std(rpt_total_target_count)/sqrt(repeat_count)]);
disp([mean(rpt_touch_count       ), std(rpt_touch_count       )/sqrt(repeat_count)]);

function t = is_touching_target(states)
    r2 = states(11, 1).^2;

    [cd, pd] = distance_from_targets(states);

    ct = cd <= r2;
    pt = pd <= r2;
    nt = states(14:3:end, 1) <= 30; %in theory this could be 33 (aka, one observation 30 times a second)

    t = ct&(~pt|nt);
end

function [cd, pd] = distance_from_targets(states)
    cp = states(1:2,:);
    pp = states(1:2,:) - states(3:4,:);
    tp = [states(12:3:end, 1)';states(13:3:end, 1)'];

    dtp = dot(tp,tp,1);
    dcp = dot(cp,cp,1);
    dpp = dot(pp,pp,1);

    cd = dcp+dtp'-2*(tp'*cp);
    pd = dpp+dtp'-2*(tp'*pp);
end