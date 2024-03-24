%cal th_1,th_m1,th_mn

%x_2&y_2


clear th_i th_mi th_mn m_n th_t

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

