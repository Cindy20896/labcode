%rout data
clearvars -except kyori h atsumi kei_su max_p max_I con_n d D data_mix n_check lan_check

if exist("h","var") == 0

    h = 10;%The distance between pinhole and tube
    D = input("input outer diameter[mm] = ");
    d = input("input inner diameter[mm] = ");
    n_check = input("管中央は水：1を入力　/　管中央は空気：2を入力  ");
    lan_check = input("日本語の結果：1を入力　/　英語の結果：2を入力　");
    [file_title_d,file_title_D] = title_fun(d,D);
    if n_check == 2
    read_data_title = ['data_record\E6_datamix_air_' file_title_D '_' file_title_d '.mat'];
    else
        read_data_title = ['data_record\E6_datamix_water_' file_title_D '_' file_title_d '.mat'];
    end
    load(read_data_title);
else
    if h < 100
        h = h + 10;%The next distance
    else
        close all
        return%stop the program
    end
end




data_su =size(data_mix,1);

atsumi = 0.02;
kei = 0.005;

data_x = data_mix(:,1);
data_y = data_mix(:,2);
data_m = data_mix(:,3);
data_I = data_mix(:,4);

r_out = D/2;
r_in = d/2;

m_limit = kei/atsumi;
th_limit = atan(m_limit);

%%
j = 1;

del_pi = 0.00175;
del_kei = kei/h;
del_kei_b = kei/(h+atsumi);

th_plus = del_pi:del_pi:0.5*pi;
si_plus = size(th_plus,2);
th_min = -flip(th_plus);
th_t = [th_min 0 th_plus];
th_test = transpose(th_t);
si_th = size(th_test,1);

th_range(2:si_th-1,1) = th_test(2:si_th-1,1)-0.5*del_kei;
th_range(2:si_th-1,2) = th_test(2:si_th-1,1)+0.5*del_kei;
th_range_b(2:si_th-1,1) = th_test(2:si_th-1,1)-0.5*del_kei_b;
th_range_b(2:si_th-1,2) = th_test(2:si_th-1,1)+0.5*del_kei_b;


th_range(1,1:2) = [th_test(1),th_test(1)+0.5*del_kei];
th_range(si_th,1:2) = [th_test(si_th)-0.5*del_kei,th_test(si_th)];
th_range_b(1,1:2) = [th_test(1),th_test(1)+0.5*del_kei_b];
th_range_b(si_th,1:2) = [th_test(si_th)-0.5*del_kei_b,th_test(si_th)];


x_range = h*cos(th_range);
y_range = h*sin(th_range);
x_range_b = (h+atsumi)*cos(th_range_b);
y_range_b = (h+atsumi)*sin(th_range_b);


I_o = zeros(si_th(1),1);
b = data_y - data_m .* data_x ;

A_con = 1+data_m.^2;
B_con = 2*b.*data_m;
C_con = b.^2-h^2;

x_plus = (-B_con+(B_con.^2-4*A_con.*C_con).^0.5)./(2*A_con);
x_minus = (-B_con-(B_con.^2-4*A_con.*C_con).^0.5)./(2*A_con);
y_plus = data_m.*x_plus+b;
y_minus = data_m.*x_minus+b;

see = zeros(data_su,1);
x_o = see;
y_o = see;

for i = 1:data_su
    if x_plus(i) >= 0 && abs(y_plus(i))<=h
        see(i) = 1;
        x_o(i) = x_plus(i);
        y_o(i) = y_plus(i);
    end
    if x_minus(i) >= 0 && abs(y_minus(i))<=h
        see(i) = 2;
        x_o(i) = x_minus(i);
        y_o(i) = y_minus(i);
    end
    if x_plus(i) >= 0 && abs(y_plus(i))<=h && x_minus(i) >= 0 && abs(y_minus(i))<=h
        if x_plus(i) > x_minus(i)
            see(i) = 3;
            x_o(i) = x_plus(i);
            y_o(i) = y_plus(i);
        else
            if x_plus(i) < x_minus(i)
                see(i) = 4;
                x_o(i) = x_minus(i);
                y_o(i) = y_minus(i);
            end
        end
    end
    if see(i) == 0
        x_o(i) = nan;
        y_o(i) = nan;
    end
end
%%
clear A_can B_con C_con x_plus x_minus y_plus y_minus see i
A_con = 1+data_m.^2;
B_con = 2*b.*data_m;
C_con = b.^2-(h+atsumi)^2;

x_plus = (-B_con+(B_con.^2-4*A_con.*C_con).^0.5)./(2*A_con);
x_minus = (-B_con-(B_con.^2-4*A_con.*C_con).^0.5)./(2*A_con);
y_plus = data_m.*x_plus+b;
y_minus = data_m.*x_minus+b;

see = zeros(data_su,1);
x_o_b = see;
y_o_b = see;

for i = 1:data_su

    if x_plus(i) >= 0 && abs(y_plus(i))<=h
        see(i) = 1;
        x_o_b(i) = x_plus(i);
        y_o_b(i) = y_plus(i);
    end
    if x_minus(i) >= 0 && abs(y_minus(i))<=h
        see(i) = 2;
        x_o_b(i) = x_minus(i);
        y_o_b(i) = y_minus(i);
    end
    if x_plus(i) >= 0 && abs(y_plus(i))<=h && x_minus(i) >= 0 && abs(y_minus(i))<=h
        if x_plus(i) > x_minus(i)
            see(i) = 3;
            x_o_b(i) = x_plus(i);
            y_o_b(i) = y_plus(i);
        else
            if x_plus(i) < x_minus(i)
                see(i) = 4;
                x_o_b(i) = x_minus(i);
                y_o_b(i) = y_minus(i);
            end
        end
    end

    if see(i) == 0
        x_o_b(i) = nan;
        y_o_b(i) = nan;
    end
end
%%
I_op = data_I;
m_see = data_m;
f_nan = find(isnan(x_o));
b_nan = find(isnan(x_o_b));
I_nan = find(isnan(I_op));

nan_n = [f_nan;b_nan;I_nan];

I_op(nan_n) = nan;
x_o_b(nan_n) = nan;
y_o_b(nan_n) = nan;
x_o(nan_n) = nan;
y_o(nan_n) = nan;
m_see(nan_n) = nan;

x_o_front = x_o(~isnan(x_o));
y_o_front = y_o(~isnan(y_o));
x_o_back = x_o_b(~isnan(x_o_b));
y_o_back = y_o_b(~isnan(y_o_b));
I_o = I_op(~isnan(I_op));
m_o = m_see(~isnan(m_see));

data_su_o = size(y_o_front,1);
%%
clear i

I_record = zeros(si_th,1);

for i=1:data_su_o
    for j = 1:si_th
        if y_o_front(i) >= y_range(j,1) && y_o_front(i) <= y_range(j,2)
            if x_range(j,1)==x_range(j,2)
                if x_o_front(i)>=x_range(j,1)&&x_o_front(i)<=h
                    %%
                    if y_o_back(i) >= y_range_b(j,1) && y_o_back(i) <= y_range_b(j,2)

                        if x_range_b(j,1)==x_range_b(j,2)
                            if x_o_back(i)>=x_range_b(j,1)&&x_o_back(i)<=h+atsumi
                                I_record(j) = I_record(j) + I_o(i);
                                continue
                            end
                        else
                            x_r_min = min(x_range_b(j,:));
                            x_r_max = max(x_range_b(j,:));
                            if x_o_back(i) >= x_r_min && x_o_back(i) <= x_r_max
                                I_record(j) = I_record(j) + I_o(i);
                                continue
                            end
                        end
                    end
                    %%
                end
            else
                x_r_min = min(x_range(j,:));
                x_r_max = max(x_range(j,:));
                if x_o_front(i) >= x_r_min && x_o_front(i) <= x_r_max
                    %%
                    if y_o_back(i) >= y_range_b(j,1) && y_o_back(i) <= y_range_b(j,2)
                        if x_range_b(j,1)==x_range_b(j,2)
                            if x_o_back(i)>=x_range_b(j,1)&&x_o_back(i)<=h+atsumi
                                I_record(j) = I_record(j) + I_o(i);
                                continue
                            end
                        else
                            x_r_min = min(x_range_b(j,:));
                            x_r_max = max(x_range_b(j,:));
                            if x_o_back(i) >= x_r_min && x_o_back(i) <= x_r_max
                                I_record(j) = I_record(j) + I_o(i);
                                continue
                            end
                        end
                    end
                end
            end
        end
    end
end

data_out =  [th_test I_record];
I_record_2=smoothdata(I_record);

figure(h/10)
width=550;%width of figure
height=500;%height of figure
left=200;%Horizontal distance from the bottom-left corner of the screen
bottem=100;%Vertical distance from the bottom-left corner of the screen
set(gcf,'position',[left,bottem,width,height])
plot(th_test,I_record,"LineWidth",1)

if lan_check == 2%english
    xlabel("Angle [rad]","FontSize",20)
    ylabel("Voltage [mV]","FontSize",20)
    title_1st = ['D=' num2str(D) 'mm d=' num2str(d) 'mm'];
    title_2nd = ['pinhole-tube ' num2str(h) 'mm'];
    
    if n_check == 2%air
        title_3rd = 'Air in tube';        
    else%water
        title_3rd = 'Water in tube';        
    end
    title({title_1st;title_2nd;title_3rd},"FontSize",20)
    
else%japanese
    xlabel("角度 [rad]","FontSize",20)
    ylabel("電圧 [mV]","FontSize",20)
    title_1st = ['D=' num2str(D) 'mm d=' num2str(d) 'mm'];
    title_2nd = ['ピンホールと細管の距離 ' num2str(h) 'mm'];
    
    if n_check == 2%air
        title_3rd = '管内：空気';        
    else%water
        title_3rd = '管内：水';        
    end
    title({title_1st;title_2nd;title_3rd},"FontSize",20)
end


[file_title_d,file_title_D] = title_fun(d,D);
[fig_title_d,fig_title_D] = title_fun(d,D);

if lan_check == 2%english
    if n_check == 2%air
        fig_save_m = ['air_angle_' fig_title_D '_' fig_title_d '_' num2str(h) 'mm'];
        save_path_m = ['angle\eng\fig\' num2str(D) '_' num2str(d) '\'];
        fig_save_j = ['air_angle_' fig_title_D '_' fig_title_d '_' num2str(h) 'mm.jpg'];
        save_path_j = ['angle\eng\jpg\' num2str(D) '_' num2str(d) '\'];
    else
        fig_save_m = ['water_angle_' fig_title_D '_' fig_title_d '_' num2str(h) 'mm'];
        save_path_m = ['angle\eng\fig\' num2str(D) '_' num2str(d) '\'];
        fig_save_j = ['water_angle_' fig_title_D '_' fig_title_d '_' num2str(h) 'mm.jpg'];
        save_path_j = ['angle\eng\jpg\' num2str(D) '_' num2str(d) '\'];
    end
else%japanese
    if n_check == 2%air
        fig_save_m = ['air_angle_' fig_title_D '_' fig_title_d '_' num2str(h) 'mm'];
        save_path_m = ['angle\jp\fig\' num2str(D) '_' num2str(d) '\'];
        fig_save_j = ['air_angle_' fig_title_D '_' fig_title_d '_' num2str(h) 'mm.jpg'];
        save_path_j = ['angle\jp\jpg\' num2str(D) '_' num2str(d) '\'];
    else
        fig_save_m = ['water_angle_' fig_title_D '_' fig_title_d '_' num2str(h) 'mm'];
        save_path_m = ['angle\jp\fig\' num2str(D) '_' num2str(d) '\'];
        fig_save_j = ['water_angle_' fig_title_D '_' fig_title_d '_' num2str(h) 'mm.jpg'];
        save_path_j = ['angle\jp\jpg\' num2str(D) '_' num2str(d) '\'];
    end
end

saveas(figure(h/10),[save_path_m,fig_save_m])
saveas(figure(h/10),[save_path_j,fig_save_j])
I_05=I_record(find(th_test>=0.5));
% max_p(h/10,con_n)=abs(max(th_test(I_record==max(I_05))));
% max_I(h/10,con_n)=max(I_record)/1000;
max_p(h/10,1)=abs(max(th_test(I_record==max(I_05))));
max_I(h/10,1)=max(I_record)/1000;

run("transmission_angle_ronbunyou.m")%Run currently code again for next distance between pinhole and tube

%%

function [file_title_d,file_title_D] = title_fun(d,D)

file_title_d = ['0' num2str(d*10)];

if D == 0.15||D ==0.45||D == 0.75
file_title_D = ['0' num2str(D*100)];
else
    if D < 1
    file_title_D = ['0' num2str(D*10)];
    else
        file_title_D = num2str(D*10);
    end

end

end