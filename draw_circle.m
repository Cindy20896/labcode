%draw cicle

%outer circle
i=0;

for th = 0:1e-5:2*pi

    i = i+1;
    x(i)=r_out*cos(th);
    y(i)=r_out*sin(th);

end

plot(x,y,"k")
hold on

clear x y th i


%inner circle
i=0;

for th = 0:1e-5:2*pi

    i = i+1;
    x(i)=r_in*cos(th);
    y(i)=r_in*sin(th);

end

plot(x,y,"k")
hold on

clear x y th i