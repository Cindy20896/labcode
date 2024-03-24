%suihei/circle data
clearvars -except kyori con_n max_p fig_n D d n_check lan_check data_mix

if exist("kyori","var") == 0

    kyori = 10;%The distance between pinhole and tube
    fig_n=1;
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
    if kyori < 100
        kyori = kyori + 10;%The next distance
        fig_n=fig_n+1;
    else
        
        close all
        return%stop the program
        
    end
end

data_x = data_mix(:,1);
data_y = data_mix(:,2);
data_m = data_mix(:,3);
data_I = data_mix(:,4)*0.05*(1/6)*10^-8*683*0.98*10^6*330*10^-3;%mV

data_su =size(data_x,1);

r_out = D/2;
r_in = d/2;

atsumi = 0.02;%pinhole thickness
del_y = 0.0002;%pinhole movement interval
kei = 0.0005;%Pinhole aperture
kei_front = 0.05;%Extra pinhole(if needed)(If does not need, = 100)

y_record_plus = del_y:del_y:r_out;
y_record_minus = -flip(y_record_plus);
y_record = [y_record_minus 0 y_record_plus];%The coordinates of points that the pinhole will pass.
y_s = transpose(y_record);
si_record = size(y_record,2);

y_range(:,1) = zeros(si_record,1);%the down edge of pinhole
y_range(:,2) = zeros(si_record,1);%the up edge of pinhole

for ii = 1:si_record
    y_range_down = y_record(ii) - 0.5*kei;
    y_range_up = y_record(ii) + 0.5*kei;
    y_range(ii,1) = y_range_down;%the down edge of pinhole
    y_range(ii,2) = y_range_up;%the up edge of pinhole

    if ii == 1
        y_range_down = y_record(ii);
        y_range_up = y_record(ii) + 0.5*kei;

        y_range(ii,1) = y_range_down;%the down edge of pinhole
        y_range(ii,2) = y_range_up;%the up edge of pinhole
    end
    if ii == si_record
        y_range_down = y_record(ii) - 0.5*kei;
        y_range_up = y_record(ii);

        y_range(ii,1) = y_range_down;%the down edge of pinhole
        y_range(ii,2) = y_range_up;%the up edge of pinhole
    end
end

y_range_02mm(:,1) = zeros(si_record,1);
y_range_02mm(:,2) = zeros(si_record,1);

for ii = 1:si_record

    y_range_down = y_record(ii) - 0.5*kei_front;
    y_range_up = y_record(ii) + 0.5*kei_front;

    y_range_02mm(ii,1) = y_range_down;
    y_range_02mm(ii,2) = y_range_up;

    if ii == 1
        y_range_down = y_record(ii);
        y_range_up = y_record(ii) + 0.5*kei_front;

        y_range_02mm(ii,1) = y_range_down;
        y_range_02mm(ii,2) = y_range_up;
    end

    if ii == si_record
        y_range_down = y_record(ii) - 0.5*kei_front;
        y_range_up = y_record(ii);

        y_range_02mm(ii,1) = y_range_down;
        y_range_02mm(ii,2) = y_range_up;
    end
end


%%

I_s = zeros(si_record,1);

m_limit = kei/atsumi;
th_limit = atan(m_limit);

for i = 1:data_su
    if abs(data_m(i)) <= m_limit
        b = data_y(i) - data_m(i) * data_x(i) ;
        y_kyori = data_m(i) * (kyori+r_out) + b;

        for ii = 1:si_record
            if y_range(ii,1)<=y_kyori && y_range(ii,2)>=y_kyori && (~isnan(data_I(i)))
                %test if light intersect with the front range
                y_kyori_2 = data_m(i) * (kyori+r_out+atsumi)+b;
                y_D = y_range(ii,1);
                y_U = y_range(ii,2);
                if y_D<=y_kyori_2 && y_U>=y_kyori_2
                    %test if light intersect with the rear range
                    y_kyori_front = data_m(i) * (1+r_out)+b;
                    y_Dfront = y_range_02mm(ii,1);
                    y_Ufront = y_range_02mm(ii,2);
                    if y_Dfront<=y_kyori_front && y_Ufront>=y_kyori_front
                        y_kyori_front2 = data_m(i) * (2+r_out)+b;
                        y_Dfront = y_range_02mm(ii,1);
                        y_Ufront = y_range_02mm(ii,2);
                        if y_Dfront<=y_kyori_front2 && y_Ufront>=y_kyori_front2
                            I_s(ii) = I_s(ii) + data_I(i);
                            %plus the light intensity the meet all conditions
                        end
                    end
                end
            end
        end
    end
end

I_s_2 = smoothdata(I_s);
data_suihei = [y_s I_s_2];


figure(fig_n)
width=550;%width of figure
height=500;%height of figure
left=200;%Horizontal distance from the bottom-left corner of the screen
bottem=100;%Vertical distance from the bottom-left corner of the screen
set(gcf,'position',[left,bottem,width,height])

plot(y_s,I_s_2,"LineWidth",1.5)
hold on

% title_1st = ['D=' num2str(D) 'mm d=' num2str(d) 'mm'];
% title_2nd = ['tube-pinhole ' num2str(kyori) 'mm'];
% 
% title({title_1st;title_2nd},"FontSize",20)
% xlabel("Distance [mm]","FontSize",20)
% ylabel("Voltage [mV]","FontSize",20)

[file_title_d,file_title_D] = title_fun(d,D);
%%
if lan_check == 2%english
    title_1st = ['D=' num2str(D) 'mm d=' num2str(d) 'mm'];
    title_2nd = ['tube-pinhole ' num2str(kyori) 'mm'];
    xlabel("Distance [mm]","FontSize",20)
    ylabel("Voltage [mV]","FontSize",20)
    
    if n_check == 2%air
        fig_line = ['air_distance_' file_title_D '_' file_title_d '_pinhole_to_tube_' num2str(kyori) 'mm'];
        fig_jpg = ['air_distance_' file_title_D '_' file_title_d '_pinhole _to_tube_' num2str(kyori) 'mm.jpg'];
        save_path = ['distance\eng\fig\' num2str(D) '_' num2str(d) '\'];
        save_jpg = ['distance\eng\jpg\' num2str(D) '_' num2str(d) '\'];
        
        title_3rd = 'Air in tube'; 
        
    else
        fig_line = ['water_distance_' file_title_D '_' file_title_d '_pinhole_to_tube_' num2str(kyori) 'mm'];
        fig_jpg = ['water_distance_' file_title_D '_' file_title_d '_pinhole _to_tube_' num2str(kyori) 'mm.jpg'];
        save_path = ['distance\eng\fig\' num2str(D) '_' num2str(d) '\'];
        save_jpg = ['distance\eng\jpg\' num2str(D) '_' num2str(d) '\'];
        title_3rd = 'water in tube'; 
    end
else%japanese
    xlabel("距離 [mm]","FontSize",20)
    ylabel("電圧 [mV]","FontSize",20)
    title_1st = ['D=' num2str(D) 'mm d=' num2str(d) 'mm'];
    title_2nd = ['ピンホールと細管の距離 ' num2str(h) 'mm'];
    
    if n_check == 2%air
        fig_line = ['air_distance_' file_title_D '_' file_title_d '_pinhole_to_tube_' num2str(kyori) 'mm'];
        fig_jpg = ['air_distance_' file_title_D '_' file_title_d '_pinhole _to_tube_' num2str(kyori) 'mm.jpg'];
        save_path = ['distance\jp\fig\' num2str(D) '_' num2str(d) '\'];
        save_jpg = ['distance\jp\jpg\' num2str(D) '_' num2str(d) '\'];
        title_3rd = '管内：空気'; 
    else
        fig_line = ['water_distance_' file_title_D '_' file_title_d '_pinhole_to_tube_' num2str(kyori) 'mm'];
        fig_jpg = ['water_distance_' file_title_D '_' file_title_d '_pinhole _to_tube_' num2str(kyori) 'mm.jpg'];
        save_path = ['distance\jp\fig\' num2str(D) '_' num2str(d) '\'];
        save_jpg = ['distance\jp\jpg\' num2str(D) '_' num2str(d) '\'];
        title_3rd = '管内：水'; 
    end
end

title({title_1st;title_2nd;title_3rd},"FontSize",20)


saveas(figure(fig_n),[save_path,fig_line])%save figure in "fig" file type
saveas(figure(fig_n),[save_jpg,fig_jpg])%save figure in "jpg" file type


mp_f = find(y_s>=(1.1*d/2));
max_p(fig_n,1)= y_s(max(find(I_s_2==max(I_s_2(mp_f)))));


run("transmission_distance_ronbunyou.m")%Run currently code again for next distance between pinhole and tube
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