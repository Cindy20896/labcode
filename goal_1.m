%goal 
%d_g = 1 goal
%d_g = 0 not goal

if x_f > goal_y 
    d_g = 1;

else
    if x_f^2 + y_f^2 > goal_th^2
        d_g = 1;

    else
        d_g = 0;
    end
end

