clearvars -except D d I goal_y goal_th E5_down E5_up n_air n_g n_w dely0 n_A n_B n_C n_check

%Calculation for 3 lines

kankaku_1 = 1E-5;
kankaku_2 = 1E-7;
kankaku_3 = 1E-3;
kankaku_4 = 1E-4;
kankaku_5 = 1E-2;
kankaku_6 = 1E-9;


r_out = D/2;
r_in = d/2;

y0_down = E5_up+dely0;
y0_up = r_out-dely0;

% y0_down = E5_up+0.06;
% y0_up = y0_down+0.001;


nanhon = 1+((y0_up-y0_down)/dely0);
start = -r_out - 0.1*r_out;

line_n = 1;
line_record = zeros(fix(nanhon),1);

x_record = zeros(fix(nanhon*2),1);
y_record = x_record;
m_record = x_record;
I_record = x_record;

for y_0 = y0_down : dely0 : y0_up
    
    clear test_g x_1 y_1 m_1 b_1 I_cal
    
    x_1(1,1) = start;
    y_1(1,1) = y_0;
    m_1(1,1) = 0;
    b_1(1,1) = y_1(1,1);
    I_cal(1,1) = I;
    
    test_g = 0;
    loop_num = 0;
    
    n_1 = n_A;
    n_2 = n_B;
    L=0;
    %%
    Z=1;
    while test_g ~= 1
        sz_x = size(x_1,1);
        if Z == 1 && m_1(sz_x,1)<0 &&  m_1(sz_x,1)<-10%折射+斜率是負+(打到外徑)
            if abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_in^2)>abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_out^2) %折射+斜率是負+打到外徑
                for x_f = x_1(sz_x,1) : -kankaku_1 : -r_out
                    y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);
                    if sz_x ~= 3
                        hit_choose = hit_f_choose(sz_x);
                        [hit,n_1,n_2] = hit_function(hit_choose,x_f,y_f,n_A,n_B,r_out);
                        if hit == 1
                            clear hit
                            x_1(sz_x+1,1) = x_f;
                            y_1(sz_x+1,1) = y_f;
                            clear th_i th_mi th_mn m_n th_t
                            [m_n,th_mi,th_mn,th_i] = cal_th_m(y_1,x_1,sz_x,m_1);
                            [th_c,test_real,th_t,I_cal,Z,th_mt,R_s,R_p,R_1,T_1,m_1,b_1] = function_zenhansha(n_1,n_2,m_n,m_1,sz_x,th_i,I_cal,th_mi,th_mn,x_1,y_1,b_1);
                            break
                        else
                            clear hit
                            continue
                        end
                    else
                        d_g = function_goal(x_f,y_f,goal_y,goal_th);
                        if d_g == 0
                            continue
                        else
                            test_g =1;
                            x_1(sz_x+1,1) = x_f;
                            y_1(sz_x+1,1) = y_f;
                            break
                        end
                    end
                end
            end
            
        else
            
            for x_f = x_1(sz_x,1) : kankaku_3 : D
                y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);
                if sz_x ~=3
                    hit_choose = hit_f_choose(sz_x);
                    [hit,n_1,n_2] = hit_function(hit_choose,x_f,y_f,n_A,n_B,r_out);
                    if hit == 1
                        clear hit
                        x_pre = x_f-kankaku_3;
                        y_pre = x_pre*m_1(sz_x,1)+b_1(sz_x,1);
                        x_now = x_f;
                        y_now = y_f;
                        for x_f2 = x_pre : kankaku_1 : x_now
                            y_f2 = x_f2*m_1(sz_x,1)+b_1(sz_x,1);
                            
                            hit_choose = hit_f_choose(sz_x);
                            [hit,n_1,n_2] = hit_function(hit_choose,x_f2,y_f2,n_A,n_B,r_out);
                            
                            if hit == 1
                                clear hit
                                x_1(sz_x+1,1) = x_f2;
                                y_1(sz_x+1,1) = y_f2;
                                clear th_i th_mi th_mn m_n th_t
                                [m_n,th_mi,th_mn,th_i] = cal_th_m(y_1,x_1,sz_x,m_1);
                                [th_c,test_real,th_t,I_cal,Z,th_mt,R_s,R_p,R_1,T_1,m_1,b_1] = function_zenhansha(n_1,n_2,m_n,m_1,sz_x,th_i,I_cal,th_mi,th_mn,x_1,y_1,b_1);
                                if Z == 0
                                    x_1(sz_x+1,1) = x_f2-kankaku_1;
                                    y_1(sz_x+1,1) = (x_f2-kankaku_1)*m_1(sz_x,1)+b_1(sz_x,1);
                                end
                                break
                            end
                        end
                        break
                    else
                        clear hit
                        continue
                    end
                else
                    d_g = function_goal(x_f,y_f,goal_y,goal_th);
                    if d_g == 0
                        continue
                    else
                        x_pre = x_f-kankaku_3;
                        y_pre = x_pre*m_1(sz_x,1)+b_1(sz_x,1);
                        x_now = x_f;
                        y_now = y_f;
                        for x_f2 = x_pre : kankaku_1 : x_now
                            y_f2 = x_f2*m_1(sz_x,1)+b_1(sz_x,1);
                            d_g = function_goal(x_f2,y_f2,goal_y,goal_th);
                            if d_g == 0
                                continue
                            else
                                test_g =1;
                                x_1(sz_x+1,1) = x_f2;
                                y_1(sz_x+1,1) = y_f2;
                                break
                            end
                        end
                        break
                    end
                    
                end
                
            end
        end
    end

    
    
    sz_f = size(x_1,1);
    line_record(line_n,1)=y_0;
    line_record(line_n,2)=sz_f-1;
    disp(line_n)
    
    if y_1(sz_f,1) > 2*r_out
        y_1(sz_f,1) = 2*r_out;
        x_1(sz_f,1) = (y_1(sz_f,1)- b_1(sz_f-1,1))/m_1(sz_f-1,1);
    end
    
    x_record(line_n,1) = x_1(sz_f,1);
    y_record(line_n,1) = y_1(sz_f,1);
    m_record(line_n,1) = m_1(sz_f-1,1);
    I_record(line_n,1) = I_cal(sz_f-1,1);
    x_record(fix(nanhon)+line_n,1) = x_1(sz_f,1);
    y_record(fix(nanhon)+line_n,1) = -y_1(sz_f,1);
    m_record(fix(nanhon)+line_n,1) = -m_1(sz_f-1,1);
    I_record(fix(nanhon)+line_n,1) = I_cal(sz_f-1,1);
    
    
    line_n=line_n+1;
    


    plot(x_1,y_1)
    hold on
    plot(x_1,-y_1)
    hold on

    
end
    
    [file_title_d,file_title_D] = title_fun(d,D);
    data_record = [x_record y_record m_record I_record];
    
    save_filename = ['E6_data_line3_' file_title_D '_' file_title_d '.mat'];
    save_path = ['E6_data\' num2str(D) '_' num2str(d) '\'];
    
    save([save_path,save_filename],"data_record")
    
    filename_5 = [save_path 'E6_data_line5_' file_title_D '_' file_title_d '.mat'];
    filename_4 = [save_path 'E6_data_line4_' file_title_D '_' file_title_d '.mat'];
    filename_3 = [save_path 'E6_data_line3_' file_title_D '_' file_title_d '.mat'];
    
    clear data_record
    load(filename_5);
    data_mix = data_record;
    
    clear data_record
    load(filename_4)
    data_mix = [data_mix;data_record];
    
    clear data_record
    load(filename_3)
    data_mix = [data_mix;data_record];
    
    if n_check == 2
    filename_mix = ['E6_datamix_air_' file_title_D '_' file_title_d '.mat'];
    else
        filename_mix = ['E6_datamix_water_' file_title_D '_' file_title_d '.mat'];
    end
    
    save_mix_path = 'data_record/';
    save([save_mix_path,filename_mix],"data_mix")
    

    
    
    %
    % run("find_3_4_5_step2.m")
    %%
function hit_choose = hit_f_choose(sz_x)

if sz_x==1
    hit_choose=6;
end
if sz_x==2
    hit_choose=28;
end

end
%%
function [hit,n_1,n_2] = hit_function(hit_choose,x_f,y_f,n_A,n_B,r_out)

if hit_choose == 6
    if x_f^2+y_f^2-r_out^2<0
        
        hit = 1;
        n_1 = n_A;
        n_2 = n_B;
        
    else
        hit = 0;
        n_1 = n_A;
        n_2 = n_B;
    end
end

if hit_choose == 28
    
    if x_f^2+y_f^2-r_out^2>0
        
        hit = 1;
        n_1 = n_B;
        n_2 = n_A;
        
    else
        hit = 0;
        n_1 = n_B;
        n_2 = n_A;
    end
end

end
%%

function d_g = function_goal(x_f,y_f,goal_y,goal_th)

if x_f > goal_y 
    d_g = 1;

else
    if x_f^2 + y_f^2 > goal_th^2
        d_g = 1;

    else
        d_g = 0;
    end
end

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
        file_title_D = num2str(D*10);
    end

end

end
%%
function [m_n,th_mi,th_mn,th_i] = cal_th_m(y_1,x_1,sz_x,m_1)

%hit點&圓心的斜率
m_n = y_1(sz_x+1,1)/x_1(sz_x+1,1);

%求m1和mn的tan
th_mi = atan(m_1(sz_x,1));
th_mn = atan(m_n);

if th_mi <= 0
    th_mi = th_mi + pi;
end
if th_mn <= 0
    th_mn = th_mn + pi;
end

%夾角 = 求m1和mn的角度差(所以用絕對值)
th_i = abs(th_mi-th_mn);
if th_i > 0.5*pi
    th_i = pi - th_i;
end

end
%%
function [th_c,test_real,th_t,I_cal,Z,th_mt,R_s,R_p,R_1,T_1,m_1,b_1] = function_zenhansha(n_1,n_2,m_n,m_1,sz_x,th_i,I_cal,th_mi,th_mn,x_1,y_1,b_1)

%Z=0=全反射 1=折射

th_c = asin(n_2/n_1);
test_real = isreal(th_c);

%計算th_i 有沒有大於臨界角
if m_n*m_1(sz_x,1) >= 0
    if test_real == 1%th_c是實數
        if th_i >= th_c%全反射
            th_t = th_i;
            I_cal(sz_x+1,1) = I_cal(sz_x,1);
            Z = 0;
            if th_mi>th_mn
                th_mt = th_mn - th_t;
            else
                th_mt = th_mn + th_t;
            end

        else%折射
            th_t = asin(n_1*sin(th_i)/n_2);

            R_s = (sin(th_t-th_i)/sin(th_t+th_i))^2;
            R_p = (tan(th_t-th_i)/tan(th_t+th_i))^2;

            R_1 = (R_p+R_s)/2;
            T_1 = 1 - R_1;

            I_cal(sz_x+1,1) = I_cal(sz_x,1) * T_1;

            Z = 1;

            %不管從什麼介質入射到甚麼介質，th_mt的公式都一樣
            if th_mi > 0.5*pi
                if th_mi > th_mn
                    th_mt = th_mn + th_t;
                else
                    th_mt = th_mn -th_t;
                end
            else
                if th_mi > th_mn
                    th_mt = th_t + th_mn;
                else
                    th_mt = th_mn - th_t;
                end
            end


        end
    end

    if test_real == 0
        th_t = asin(n_1*sin(th_i)/n_2);

        R_s = (sin(th_t-th_i)/sin(th_t+th_i))^2;
        R_p = (tan(th_t-th_i)/tan(th_t+th_i))^2;

        R_1 = (R_p+R_s)/2;
        T_1 = 1 - R_1;

        I_cal(sz_x+1,1) = I_cal(sz_x,1) * T_1;

        Z = 1;

        %不管從什麼介質入射到甚麼介質，th_mt的公式都一樣
        if th_mi == 0
            th_mt = th_mn + th_t;
        else
            if th_mi > 0.5*pi
                if th_mi > th_mn
                    th_mt = th_mn + th_t;
                else
                    th_mt = th_mn -th_t;
                end
            else
                if th_mi > th_mn
                    th_mt = th_t + th_mn;
                else
                    th_mt = th_mn - th_t;
                end
            end
        end
    end
end
%
if m_n*m_1(sz_x,1)<0%法線和入射線的斜率一正一負
    if test_real == 1%th_c是實數
        if th_i >= th_c%全反射
            th_t = th_i;
            I_cal(sz_x+1,1) = I_cal(sz_x,1);
            Z = 0;
            if th_mi>0.5*pi
                th_mt = th_mi - 2*th_t;
            else
                th_mt = th_mi + 2*th_t;
            end


        else%折射

            th_t = asin(n_1*sin(th_i)/n_2);

            R_s = (sin(th_t-th_i)/sin(th_t+th_i))^2;
            R_p = (tan(th_t-th_i)/tan(th_t+th_i))^2;

            R_1 = (R_p+R_s)/2;
            T_1 = 1 - R_1;

            I_cal(sz_x+1,1) = I_cal(sz_x,1) * T_1;

            Z = 1;



            if m_n <= 0
                if th_mi < th_mn-0.5*pi
                    th_mt = th_mi + (th_t-th_i);
                else
                    if th_mi > th_mn-0.5*pi
                        th_mt = th_mi+ (th_i-th_t);
                    end
                end
            end

            if m_n > 0
                if th_mi < th_mn+0.5*pi
                    th_mt = th_mi + (th_t-th_i);
                else
                    if th_mi > th_mn+0.5*pi
                        th_mt = th_mi+ (th_i-th_t);
                    end
                end
            end




        end
    end

    if test_real == 0
        th_t = asin(n_1*sin(th_i)/n_2);

        R_s = (sin(th_t-th_i)/sin(th_t+th_i))^2;
        R_p = (tan(th_t-th_i)/tan(th_t+th_i))^2;

        R_1 = (R_p+R_s)/2;
        T_1 = 1 - R_1;

        I_cal(sz_x+1,1) = I_cal(sz_x,1) * T_1;

        Z = 1;

        %不管從什麼介質入射到甚麼介質，th_mt的公式都一樣

        if m_n <= 0
            if th_mi < th_mn-0.5*pi
                th_mt = th_mi + (th_t-th_i);
            else
                if th_mi > th_mn-0.5*pi
                    th_mt = th_mi+ (th_i-th_t);
                end
            end
        end

        if m_n > 0
            if th_mi < th_mn+0.5*pi
                th_mt = th_mi + (th_t-th_i);
            else
                if th_mi > th_mn+0.5*pi
                    th_mt = th_mi+ (th_i-th_t);
                end
            end
        end




    end
end

%%


m_1(sz_x+1,1) = tan(th_mt);
b_1(sz_x+1,1) = y_1(sz_x+1,1)-x_1(sz_x+1,1)*m_1(sz_x+1,1);

end