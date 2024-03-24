for y_0 = y0_down : dely0 : y0_up

    clear test_g x_1 y_1 m_1 b_1 I_cal

    x_1(1,1) = start;
    y_1(1,1) = y_0;
    m_1(1,1) = 0;
    b_1(1,1) = y_1(1,1);
    I_cal(1,1) = I;

    test_g = 0;
    loop_num = 0;

    n_1 = n_air;
    n_2 = n_g;
    %%
    Z=1;
    while test_g ~= 1
        sz_x = size(x_1,1);

        if Z == 0 && m_1(sz_x,1)<0 && abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_in^2)<abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_out^2) && m_1(sz_x,1)<-10%全反射+斜率是負+打到內徑
            for x_f = x_1(sz_x,1) : -kankaku_4 : -r_out
                y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);
                [hit,n_1,n_2] = hit_check(Z,x_1,y_1,sz_x,r_out,x_f,y_f,n_A,n_B,n_C,r_in);
                if hit == 1
                    clear hit
                    x_1(sz_x+1,1) = x_f;
                    y_1(sz_x+1,1) = y_f;
                    run("cal_1_th1_m1_mn.m")
                    run("zeanhansha.m")
                    break
                else
                    clear hit
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


        else
            if Z == 1 && m_1(sz_x,1)<0 && abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_in^2)>abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_out^2) && m_1(sz_x,1)<-10%折射+斜率是負+打到外徑
            for x_f = x_1(sz_x,1) : -kankaku_4 : -r_out
                y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);
                [hit,n_1,n_2] = hit_check(Z,x_1,y_1,sz_x,r_out,x_f,y_f,n_A,n_B,n_C,r_in);
                if hit == 1
                    clear hit
                    x_1(sz_x+1,1) = x_f;
                    y_1(sz_x+1,1) = y_f;
                    run("cal_1_th1_m1_mn.m")
                    run("zeanhansha.m")
                    break
                else
                    clear hit
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
            else

            for x_f = x_1(sz_x,1) : kankaku_4 : 1000
                y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);
                [hit,n_1,n_2] = hit_check(Z,x_1,y_1,sz_x,r_out,x_f,y_f,n_A,n_B,n_C,r_in);
                if hit == 1
                    clear hit
                    x_1(sz_x+1,1) = x_f;
                    y_1(sz_x+1,1) = y_f;
                    run("cal_1_th1_m1_mn.m")
                    run("zeanhansha.m")
                    break
                else
                    clear hit
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
        end
    end

    sz_f = size(x_1,1);
    line_record(line_n,1)=y_0;
    line_record(line_n,2)=sz_f-1;
    disp(line_n)

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

%%

function [hit,n_1,n_2] = hit_check(Z,x_1,y_1,sz_x,r_out,x_f,y_f,n_A,n_B,n_C,r_in)
if Z ==1

    if x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_out^2>0
        if x_f^2+y_f^2-r_out^2<0
            hit = 1;
            n_1 = n_A;
            n_2 = n_B;
            %         reg = 1;%1=hit 前在外側空氣
        else
            hit = 0;
            n_1 = n_A;
            n_2 = n_B;
        end

    else
        if x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_in^2>=0
            if x_f^2+y_f^2-r_in^2<0
                hit = 1;
                n_1 = n_B;
                n_2 = n_C;
                %             reg = 2;%2=hit 前在玻璃
            else
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

        else%x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_in^2<0
            if x_f^2+y_f^2-r_in^2>0
                hit = 1;
                n_1 = n_C;
                n_2 = n_B;
                %         reg = 3;%3=hit 前在內側空氣
            else
                hit = 0;               
                n_1 = n_C;
                n_2 = n_B;
            end
        end
    end


else%全反射後的hit判定


    if x_f^2+y_f^2-(x_1(sz_x,1)^2+y_1(sz_x,1)^2)>=0.001
        if x_f^2+y_f^2-r_in^2<0
            hit = 1;
            n_1 = n_B;
            n_2 = n_C;
            %             reg = 2;%2=hit 前在玻璃
        else
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
    else
        hit = 0;                
        n_1 = n_A;
        n_2 = n_B;
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