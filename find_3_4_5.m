clear

D = input("input outer diameter[mm] = ");
d = input("input inner diameter[mm] = ");
I = 20;%レーザー強度、20＝1ｍVです。
goal_y = 0.75*D;%光が管を通った後、決められた場所につくと止まる。
goal_th = D;%傾きが強いの光に対して、光が原点から一定な距離離れた後、進行が止まる。

n_air = 1;%空気の透過率
n_g = 1.49;%ガラス
n_w = 1.333;%水

n_check = input("管中央は水：1を入力　/　管中央は空気：2を入力  ");

if n_check == 1%1は管中央が水
    n_A = n_air;%Aは外径の外（外の空気）
    n_B = n_g;%Bは外径と内径の間（ガラス部分）
    n_C = n_w;%管内部（水か空気か）
else%2は管中央が空気
    n_A = n_air;
    n_B = n_g;
    n_C = n_air;
end
%%
%１から６は計算間隔。1E-5なら、x座標は毎１^-5mmで一回の計算をする
%例えば、0から0.00002まで毎１^-5mm計算する時、ｘ＝0の時のy座標、ｘ＝0.00001の時のy座標、x=0.00002の時のy座標のように計算する
%実は全部必要じゃないかも。でも変えるとどこかがバグるの怖くてこのままにした。
kankaku_1 = 1E-5;
kankaku_2 = 1E-7;
kankaku_3 = 1E-3;
kankaku_4 = 1E-4;
kankaku_5 = 1E-2;
kankaku_6 = 1E-9;
%%
r_out = D/2;%外径の半径
r_in = d/2;%内径の半径

run("draw_circle.m")%半径で管の同心円を書く
hold on

dely0 = 1E-2;%y方向の間隔。ここでは毎１^-2mmで一つの光を置く、計算する。
%例えば、dely0 =1E-2で、外径の半径が0.05の時、y座標が0，0.01，0.02，0.03，0.04，0.05のところで一本の光が存在する。

y0_down = dely0;%一番下の光のy座標
y0_up = r_out-dely0;%一番上の光のy座標
%元々は0から外径まで全部の光を計算したいが、ｙ＝0とｙ＝外径のところでバグが発生しやすいから、とばした。

nanhon = 1+((y0_up-y0_down)/dely0);%全部で何本の光があるか
start = -r_out - 0.1*r_out;%光がスタートする時のx座標

line_n = 1;%今は第何本の光かを表示します。
line_record = zeros(fix(nanhon),1);%最後に光が3か4か5のグループに入るの記録するため、先に空き変数を作った。

x_record = zeros(fix(nanhon*2),1);%最後光のx座標を記録するための空き変数
y_record = x_record;%最後に光のｙ座標を記録するための空き変数
m_record = x_record;%最後に光の傾きを記録するための空き変数
I_record = x_record;%最後に光のレーザー強度を記録するための空き変数
%ここのｘ～Ｉは使わないです。最初はdebugのために書いたけど、消すのがめんどくさいし、スピードへの影響も少ないからこのままにした。
%もしストレージがいっぱいになったら消してもいい。保存先はlight_data\の中の各内外径のフォルダのなか。

for y_0 = y0_down : dely0 : y0_up%光を一本一本計算

    clear test_g x_1 y_1 m_1 b_1 I_cal%バグ防止のためにいらない変数を消す

    x_1(1,1) = start;%x_1～I_cal は光の進行方向が変わったとき（ガラスに入射、管に出る、終点にたどり着くなど）のx座標、y座標、傾き、ｂ、レーザー強度
    y_1(1,1) = y_0;
    m_1(1,1) = 0;
    b_1(1,1) = y_1(1,1);%光は直線方程式　ｙ＝ｍｘ+ｂ　で計算する。ここのb_1は直線方程式のなかのｂ
    I_cal(1,1) = I;

    test_g = 0;%test_g = 1は終点についたの意味
    loop_num = 0;%忘れた。。。

    n_1 = n_air;%ｎ＿1は入射前の物質の透過率
    n_2 = n_g;%もう一つの物質の透過率
    %%
    Z=1;%Ｚ＝1は屈折が発生、Ｚ＝０は全反射が発生
    while test_g ~= 1%光が終点につくと止まる設定
        sz_x = size(x_1,1);%x_1は今いくつのデータを持ってる。もし線分は一個だけ存在すると、x_1は今2つのデータがある。

        if Z == 0 && m_1(sz_x,1)<0 && abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_in^2)<abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_out^2) && m_1(sz_x,1)<-10
        %全反射+mはマイナス+内径と接触してる
            for x_f = x_1(sz_x,1) : -kankaku_4 : -r_out%この時は光がxマイナスの方向で進行するから、別で書いてる
                y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);%line84～line105は、line135～で説明
                [hit,n_1,n_2] = hit_check(Z,x_1,y_1,sz_x,r_out,x_f,y_f,n_A,n_B,n_C,r_in);
                if hit == 1
                    clear hit
                    x_1(sz_x+1,1) = x_f;
                    y_1(sz_x+1,1) = y_f;
                    run("cal_1_th1_m1_mn.m")
                    run("zeanhansha.m")
                    break%line83からのfor循環を脱出、line78に戻って屈折、反射後の光を続いて計算
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
            if Z == 1 && m_1(sz_x,1)<0 && abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_in^2)>abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_out^2) && m_1(sz_x,1)<-10
            %屈折+mはマイナス+外径を接触
            %入射前は外径と近い光が管に出た後終点にに向かう時、ｍがマイナスになる場合もありますから、別で書きました。
            for x_f = x_1(sz_x,1) : -kankaku_4 : -r_out%この時は光がxマイナスの方向で進行する
                y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);%line111～line132は、line135～で説明
                [hit,n_1,n_2] = hit_check(Z,x_1,y_1,sz_x,r_out,x_f,y_f,n_A,n_B,n_C,r_in);
                if hit == 1
                    clear hit
                    x_1(sz_x+1,1) = x_f;
                    y_1(sz_x+1,1) = y_f;
                    run("cal_1_th1_m1_mn.m")
                    run("zeanhansha.m")
                    break%line112からのfor循環を脱出、line78に戻って屈折、反射後の光を続いて計算
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

            for x_f = x_1(sz_x,1) : kankaku_4 : 1000%光が指定した間隔で進行する
                y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);%ｙ＝ｍｘ+ｂでy座標を計算
                [hit,n_1,n_2] = hit_check(Z,x_1,y_1,sz_x,r_out,x_f,y_f,n_A,n_B,n_C,r_in);%物質の境界面にたどり着いたかを判断
                %詳しい計算方法はcal_line_for5.mの最後のfunction　hit_functionで説明
                if hit == 1%hit＝1は物質の境界面にたどり着いたのこと
                    clear hit%hitを一旦けして
                    x_1(sz_x+1,1) = x_f;%今のx座標（x_f）を次のx_1にする
                    y_1(sz_x+1,1) = y_f;%今のｙ座標（ｙ_f）を次のｙ_1にする
                    run("cal_1_th1_m1_mn.m")%入射角を計算、詳しい内容はcal_line_for5.mの最後のfunction　cal_th_mで説明
                    run("zeanhansha.m")%全反射の判断＆次のm_1とb_1を計算。cal_line_for5.mの最後のfunction　function_zenhanshaで説明
                    break%line137からのfor循環を脱出、line78に戻って屈折、反射後の光を続いて計算
                else
                    clear hit%hitはしない時もhitを消す
                    d_g = function_goal(x_f,y_f,goal_y,goal_th);%終点についたかどうかを判断。cal_line_for5.mの最後のfunction　function_goalで説明
                    if d_g == 0%d_g = 0はまだ終点についてない
                        continue%line137に戻って、forの次のx_fを計算する
                    else%d_g = 1は終点に着いた
                        test_g =1;%test_g を1にして、whileから脱出する
                        x_1(sz_x+1,1) = x_f;%最後のx_1に今のx座標（x_f）を代入
                        y_1(sz_x+1,1) = y_f;%最後のy_1に今のy座標（y_f）を代入
                        break
                    end
                end
            end
            
            end
        end
    end

    sz_f = size(x_1,1);%最終のx_1のサイズ（線分の数算出用）
    line_record(line_n,1)=y_0;%光は出発する時のy座標を記録
    line_record(line_n,2)=sz_f-1;%この光の線分の数（3or4or5)
    disp(line_n)

    %x_record～I_record、念のための記録。（消してもいい）
    x_record(line_n,1) = x_1(sz_f,1);
    y_record(line_n,1) = y_1(sz_f,1);
    m_record(line_n,1) = m_1(sz_f-1,1);
    I_record(line_n,1) = I_cal(sz_f-1,1);
    x_record(fix(nanhon)+line_n,1) = x_1(sz_f,1);
    y_record(fix(nanhon)+line_n,1) = -y_1(sz_f,1);
    m_record(fix(nanhon)+line_n,1) = -m_1(sz_f-1,1);
    I_record(fix(nanhon)+line_n,1) = I_cal(sz_f-1,1);
    %
    
   
    line_n=line_n+1;%次のlineに進む

    plot(x_1,y_1)%光路を書く
    hold on
    plot(x_1,-y_1)
    hold on

end%back to line61,次の光を計算する


    data_record = [x_record y_record m_record I_record];

    [file_title_d,file_title_D] = title_fun(d,D);
if n_check == 2%管中央は空気の場合のファイル名設定
    save_filename = ['xymi_data_' file_title_D '_' file_title_d '.mat'];
    save_filename_line = ['line_number_' file_title_D '_' file_title_d '.mat'];
    save_path = ['light_data\' num2str(D) '_' num2str(d) '/'];
else%管中央は水の場合のファイル名設定
    save_filename = ['xymi_data_water_' file_title_D '_' file_title_d '.mat'];
    save_filename_line = ['line_number_water_' file_title_D '_' file_title_d '.mat'];
    save_path = ['light_data\' num2str(D) '_' num2str(d) '/'];
end

    save([save_path,save_filename],"data_record")%ｘ、ｙ、ｍ、Iを記録（ここは使わないから記録しなくてもいい）
    save([save_path,save_filename_line],"line_record")%線分の数を保存

%外径が内径の1.5倍の条件では、線分の数が3の光は少ないので、詳しい計算はしな、line210～234は1.5倍の条件とその他の条件を区別するためです
p_3 = find(line_record(:,2)==3);
si_p3 = size(p_3,1);

if si_p3 == 0
    find_4_to_3 = [D d D*0.5-1E-6];
    [file_title_d,file_title_D] = title_fun(d,D);
    save_path_2 = 'light_data\';
    save_filename_record=['dataE6_' file_title_D '_' file_title_d '_yup.mat'];
    save([save_path_2,save_filename_record],"find_4_to_3")
    run("find_3_4_5_step6.m")
    run("find_3_4_5_step7.m")
    run("find_3_4_5_step8.m")
    run("find_3_4_5_step9.m")
    return
   
else
    run("find_3_4_5_step2.m")
    run("find_3_4_5_step3.m")
    run("find_3_4_5_step4.m")
    run("find_3_4_5_step5.m")
    run("find_3_4_5_step6.m")
    run("find_3_4_5_step7.m")
    run("find_3_4_5_step8.m")
    run("find_3_4_5_step9.m")
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
function [file_title_d,file_title_D] = title_fun(d,D)

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