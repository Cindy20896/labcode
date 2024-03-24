%hit package
if Z ==1

    if x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_out^2>0
        if x_f^2+y_f^2-r_out^2<0
%             if sz_x == 4 && y_0 == 0.050
%                 disp("4 hitpage cont")
%                 A=x_f^2+y_f^2-r_out^2
%             end
            hit = 1;
            n_1 = n_air;
            n_2 = n_g;
            %         reg = 1;%1=hit 前在外側空氣
        else
            hit = 0;
        end

    else
        if x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_in^2>=0
            if x_f^2+y_f^2-r_in^2<0
                hit = 1;
                n_1 = n_g;
                n_2 = n_air;
                %             reg = 2;%2=hit 前在玻璃
            else
                if x_f^2+y_f^2-r_out^2>0
                    hit = 1;
                    n_1 = n_g;
                    n_2 = n_air;
                else
                    hit = 0;
                end
            end

        else
            if x_f^2+y_f^2-r_in^2>0
                hit = 1;
                n_1 = n_air;
                n_2 = n_g;
                %         reg = 3;%3=hit 前在內側空氣
            else
                hit = 0;
            end
        end
    end


    %%
else%全反射後的hit判定
%     if y_0 == 0.050 && sz_x == 4
%         disp("判定前的Z")
%         disp(Z)
%     end

    if x_f^2+y_f^2-(x_1(sz_x,1)^2+y_1(sz_x,1)^2)>=0.001
        if x_f^2+y_f^2-r_in^2<0
            hit = 1;
            n_1 = n_g;
            n_2 = n_air;
            %             reg = 2;%2=hit 前在玻璃
        else
            if x_f^2+y_f^2-r_out^2>0
                hit = 1;
                n_1 = n_g;
                n_2 = n_air;
            else
                hit = 0;
            end
        end
    else
        hit = 0;
    end
end

%%