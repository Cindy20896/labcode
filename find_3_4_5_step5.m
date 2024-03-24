%間隔＝10^-6ｍｍ

clearvars -except line_record D d n_check n_A n_B n_C

p_3 = find(line_record(:,2)==3);
min_p3 = min(p_3);

y0_down = line_record(min_p3-1,1);
y0_up = line_record(min_p3,1);

clearvars line_record

dely0 = 1E-6;

I = 20;
goal_y = 0.75*D;
goal_th = D;

kankaku_1 = 1E-5;
kankaku_2 = 1E-7;
kankaku_3 = 1E-3;
% kankaku_4 = 1E-4;
kankaku_4 = 1E-5;
kankaku_5 = 1E-2;
kankaku_6 = 1E-9;

r_out = D/2;
r_in = d/2;

run("draw_circle.m")
hold on

n_air = 1;
n_g = 1.49;

nanhon = 1+((y0_up-y0_down)/dely0);
start = -r_out - 0.1*r_out;

line_n = 1;
line_record = zeros(fix(nanhon),1);

x_record = zeros(fix(nanhon*2),1);
y_record = x_record;
m_record = x_record;
I_record = x_record;

run("y_down_to_up.m")

data_record = [x_record y_record m_record I_record];

[file_title_d,file_title_D] = title_fun(d,D);

if n_check == 2
save_filename = ['xymi_data43_' file_title_D '_' file_title_d '_step5.mat'];
save_filename_line = ['line_number43_' file_title_D '_' file_title_d '_step5.mat'];
save_path = ['light_data\' num2str(D) '_' num2str(d) '/'];
else
save_filename = ['xymi_data43_water_' file_title_D '_' file_title_d '_step5.mat'];
save_filename_line = ['line_number43_water' file_title_D '_' file_title_d '_step5.mat'];
save_path = ['light_data\' num2str(D) '_' num2str(d) '/'];
end

save([save_path,save_filename],"data_record")
save([save_path,save_filename_line],"line_record")

%%
p_3 = find(line_record(:,2)==3);
min_p3 = min(p_3);
cal_4_to_3 = line_record(min_p3,1);

find_4_to_3 = [D d cal_4_to_3];

if n_check == 2
save_path_2 = 'light_data\';
save_filename_record=['dataE6_' file_title_D '_' file_title_d '_yup.mat'];
save([save_path_2,save_filename_record],"find_4_to_3")
else
save_path_2 = 'light_data\';
save_filename_record=['dataE6_water_' file_title_D '_' file_title_d '_yup.mat'];
save([save_path_2,save_filename_record],"find_4_to_3")
end

%%
function [file_title_d,file_title_D] = title_fun(d,D)

file_title_d = ['0' num2str(d*10)];

if D == 0.15||D ==0.45||D == 0.75
file_title_D = ['0' num2str(D*100)];
else
    if D < 1
    file_title_D = ['0' num2str(D*10)];
    else
        file_title_D = [num2str(D*10)];
    end

end

end
%%
