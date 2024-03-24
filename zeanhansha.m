%zenhansha3 Z=0=全反射 1=折射
%計算臨界角th_c

th_c = asin(n_2/n_1);
test_real = isreal(th_c);

%             if sz_x == 4 && y_0 == 0.050
%                 th_c = th_c
%                 n_2 = n_2
%             end
%                     if y_0 == 0.050 && sz_x == 3
%                         disp("3到4的全反射判定")
%                         th_c = th_c
%                         n_2 = n_2
%                         th_i = th_i
%                     end

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
            %             if sz_x == 4 && y_0 == 0.050
            %                 th_mt = th_mt
            %             end

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



%%


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
