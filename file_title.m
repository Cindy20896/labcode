%file_title

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