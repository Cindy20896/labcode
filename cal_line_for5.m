clear

%Calculation for 5 lines

D = input("input outer diameter[mm] = ");
d = input("input inner diameter[mm] = ");
I = 20;%レーザー強度、20＝1ｍVです。
goal_y = 0.75*D;%光が管を通った後、決められた場所につくと止まる。
goal_th = D;%傾きが強いの光に対して、光が原点から一定な距離離れた後、進行が止まる。

n_air = 1;%空気の透過率
n_g = 1.49;%ガラス
n_w = 1.333;%水

[file_title_d,file_title_D] = title_fun(d,D);%Dとdを読み込みと保存の時使うファイル名、functionの説明は一番下

%↓find_3_4_5.mの内容と一緒の場合は書かない（つかれた・・・）

n_check = input("管中央は水：1を入力　/　管中央は空気：2を入力  ");
if n_check == 1%中央は水
    n_A = n_air;
    n_B = n_g;
    n_C = n_w;
    load_up = ['light_data\dataE6_water_' file_title_D '_' file_title_d '_yup.mat'];%線分の数が4から3に変わった座標を読み込む
    load_down = ['light_data\dataE6_water_' file_title_D '_' file_title_d '_ydown.mat'];%線分の数が5から4に変わった座標を読み込む
else%中央は空気
    n_A = n_air;
    n_B = n_g;
    n_C = n_air;
    load_up = ['light_data\dataE6_' file_title_D '_' file_title_d '_yup.mat'];%線分の数が4から3に変わった座標を読み込む
    load_down = ['light_data\dataE6_' file_title_D '_' file_title_d '_ydown.mat'];%線分の数が5から4に変わった座標を読み込む
end

load(load_down);
load(load_up);

E5_down = find_5_to_4(3);%線分の数が5から4に変わった座標
E5_up = find_4_to_3(3);%線分の数が4から3に変わった座標


kankaku_1 = 1E-5;
kankaku_2 = 1E-7;
kankaku_3 = 1E-3;
kankaku_4 = 1E-4;
kankaku_5 = 1E-2;
kankaku_6 = 1E-9;

r_out = D/2;
r_in = d/2;

run("draw_circle.m")
hold on

dely0 = 1E-6;

y0_down = dely0;
y0_up = E5_down-dely0;

nanhon = 1+((y0_up-y0_down)/dely0);
start = -r_out - 0.1*r_out;

line_n = 1;
line_record = zeros(fix(nanhon),1);

%ここのx_record～I_recordは必要！！消してはいけない！
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
    
    n_1 = n_air;
    n_2 = n_g;
    L=0;%この変数はたぶんdebugの時用か前のversionから残ったやつ。忘れたけどこわいからこのままにした
    %%
    Z=1;
    while test_g ~= 1
        sz_x = size(x_1,1);
        if Z == 1 && m_1(sz_x,1)<0 &&  m_1(sz_x,1)<-10%屈折+ｍはマイナス
            if abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_in^2)>abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_out^2) %（屈折+ｍはマイナス）+外径と接触
            %入射前は外径と近い光が管に出た後終点にに向かう時、ｍがマイナスになる場合もあります
                for x_f = x_1(sz_x,1) : -kankaku_1 : -r_out%ｘはマイナスの方向
                %line94～line181はline183～の説明と同じ
                    y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);
                    if sz_x ~=5
                    hit_choose = hit_f_choose(sz_x);
                    [hit,n_1,n_2] = hit_function(hit_choose,x_f,y_f,n_A,n_B,n_C,r_out,r_in);
                    if hit == 1
                        clear hit
                        x_1(sz_x+1,1) = x_f;
                        y_1(sz_x+1,1) = y_f;
                        clear th_i th_mi th_mn m_n th_t
                        [m_n,th_mi,th_mn,th_i] = cal_th_m(y_1,x_1,sz_x,m_1) ;
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
                
            else
                if abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_in^2)<abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_out^2) %（屈折+ｍはマイナス）+内径と接触
                %これどこで発生したの忘れた・・・・・・
                    for x_f = x_1(sz_x,1) : -kankaku_1 : -r_out
                        y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);
                        hit_choose = hit_f_choose(sz_x);
                        [hit,n_1,n_2] = hit_function(hit_choose,x_f,y_f,n_A,n_B,n_C,r_out,r_in);
                        if hit == 1
                            clear hit
                            x_1(sz_x+1,1) = x_f;
                            y_1(sz_x+1,1) = y_f;
                            clear th_i th_mi th_mn m_n th_t
                            [m_n,th_mi,th_mn,th_i] = cal_th_m(y_1,x_1,sz_x,m_1) ;
                            [th_c,test_real,th_t,I_cal,Z,th_mt,R_s,R_p,R_1,T_1,m_1,b_1] = function_zenhansha(n_1,n_2,m_n,m_1,sz_x,th_i,I_cal,th_mi,th_mn,x_1,y_1,b_1);
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
        else
            if Z == 0 && m_1(sz_x,1)<0 && abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_in^2)<abs(x_1(sz_x,1)^2+y_1(sz_x,1)^2-r_out^2) && m_1(sz_x,1)<-10
            %%全反射+mはマイナス+内径と接触してる
                for x_f = x_1(sz_x,1) : -kankaku_1 : -r_out
                    y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);
                    hit_choose = hit_f_choose(sz_x);
                    [hit,n_1,n_2] = hit_function(hit_choose,x_f,y_f,n_A,n_B,n_C,r_out,r_in);
                    if hit == 1
                        clear hit
                        x_1(sz_x+1,1) = x_f;
                        y_1(sz_x+1,1) = y_f;
                        clear th_i th_mi th_mn m_n th_t
                        [m_n,th_mi,th_mn,th_i] = cal_th_m(y_1,x_1,sz_x,m_1) ;
                        [th_c,test_real,th_t,I_cal,Z,th_mt,R_s,R_p,R_1,T_1,m_1,b_1] = function_zenhansha(n_1,n_2,m_n,m_1,sz_x,th_i,I_cal,th_mi,th_mn,x_1,y_1,b_1);
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
                
                for x_f = x_1(sz_x,1) : kankaku_3 : 1000%普通の計算（マイナスなどはない）
                    y_f = x_f*m_1(sz_x,1)+b_1(sz_x,1);%直線方程式
                    if sz_x ~=5%線分の数が5なので、ｘのサイズが5になるまでは終点に行かない、なので終点に着いたかどうかの判定はやらない
                        hit_choose = hit_f_choose(sz_x);%hit_functionですかう変数hit_chooseを得る。関数は一番下で説明
                        [hit,n_1,n_2] = hit_function(hit_choose,x_f,y_f,n_A,n_B,n_C,r_out,r_in);%物質の境界面にたどり着いたかを判断。関数は一番下で説明
                        if hit == 1%hit＝1は物質の境界面にたどり着いたのこと
                            clear hit%いったんhit消す
                            x_pre = x_f-kankaku_3;%hitする前のx座標に戻る（より精密な計算をするため）
                            y_pre = x_pre*m_1(sz_x,1)+b_1(sz_x,1);%hitする前のｙ座標に戻る（より精密な計算をするため）
                            x_now = x_f;%hitした後のx座標
                            y_now = y_f;%hitした後のｙ座標
                            for x_f2 = x_pre : kankaku_1 : x_now%hitする前のx座標からhitした後のx座標まで、10^-5の精度で計算する
                                y_f2 = x_f2*m_1(sz_x,1)+b_1(sz_x,1);%直線方程式
                                
                                hit_choose = hit_f_choose(sz_x);%前と一緒
                                [hit,n_1,n_2] = hit_function(hit_choose,x_f2,y_f2,n_A,n_B,n_C,r_out,r_in);
                                
                                if hit == 1%もう一回hitする
                                    clear hit%消す
                                    x_1(sz_x+1,1) = x_f2;%二回目のxy座標を記録
                                    y_1(sz_x+1,1) = y_f2;
                                    clear th_i th_mi th_mn m_n th_t
                                    [m_n,th_mi,th_mn,th_i] = cal_th_m(y_1,x_1,sz_x,m_1);%入射角などを計算、関数は一番下で説明
                                    [th_c,test_real,th_t,I_cal,Z,th_mt,R_s,R_p,R_1,T_1,m_1,b_1] = function_zenhansha(n_1,n_2,m_n,m_1,sz_x,th_i,I_cal,th_mi,th_mn,x_1,y_1,b_1);
                                    %全反射かどうかを判断と屈折、反射後の光のm_1とb_1を計算。関数は一番下で説明
                                    if Z == 0%もし全反射だとしたら
                                        x_1(sz_x+1,1) = x_f2-kankaku_1;%x_1は一個前の座標にして
                                        y_1(sz_x+1,1) = (x_f2-kankaku_1)*m_1(sz_x,1)+b_1(sz_x,1);%ｙも
                                        %hitの判定は出発の時の物質と違う物質のエリアの入ったら、入った後の一番最初の点を次の出発点にする。
                                        %ただし全反射は元の物質ののなかでまだ進行するので、一個前に戻さないと、次の光は出発したすぐまだ違う物質（元の物質）に入るので、
                                        %すぐ次のhit判定が発生し、誤った結果を出す。
                                    end
                                    break%line196の二回目のforから脱出
                                end
                            end
                            break%line185の一回目のforから脱出
                        else%一回目（line189）のhit判定はhit=0(hitしてなかった)のとき
                            clear hit
                            continue%line185に戻って次のx_fを計算
                        end
                    else%x_1のサイズが5、つまり五つ目の線分が始まると、goalにたどり着くので、goal判定だけおこなう
                        d_g = function_goal(x_f,y_f,goal_y,goal_th);%ゴールしたかの判定。関数は一番下で説明
                        if d_g == 0%goalしてない
                            continue%line185に戻って次のx_fを計算
                        else%goalした
                            x_pre = x_f-kankaku_3;%同じく一つ前に戻る操作をする
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
                                    x_1(sz_x+1,1) = x_f2;%二回目の結果を記録
                                    y_1(sz_x+1,1) = y_f2;
                                    break%line234の二回目のforから脱出
                                end
                            end
                            break%line185の一回目のforから脱出
                        end
                        
                    end
                    
                end
            end
        end
    end
    
    %記録作業。find_3_4_5.mと似たようなところが多い
    sz_f = size(x_1,1);
    line_record(line_n,1)=y_0;
    line_record(line_n,2)=sz_f-1;
    disp(line_n)
    
    if y_1(sz_f,1) > 2*r_out%mが無限に近づくと、yもでかすぎるので、ちょっと調整
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
    
    
    data_record = [x_record y_record m_record I_record];
    
    save_filename = ['E6_data_line5_' file_title_D '_' file_title_d '.mat'];
    save_path = ['E6_data\' num2str(D) '_' num2str(d) '\'];
    
    save([save_path,save_filename],"data_record")
    
    if abs(E5_up-0.5*d)<=1E-5%外径が内径の1.5倍なら、3の計算しない（無視する）
        run("cal_line_for4.m");
    else
        run("cal_line_for4.m");
        run("cal_line_for3.m");
    end
    

    %%
    %%%%%%%%%%%%%%%%以下は関数
function hit_choose = hit_f_choose(sz_x)
%今は第何個目の線を決めるだけの関数です。（hit_choose=の数字は適当です）
if sz_x==1
    hit_choose=6;
end
if sz_x==2
    hit_choose=28;
end
if sz_x==3
    hit_choose=496;
end
if sz_x==4
    hit_choose=8128;
end

end
%%
function [hit,n_1,n_2] = hit_function(hit_choose,x_f,y_f,n_A,n_B,n_C,r_out,r_in)

if hit_choose == 6%一個目の線なので、必ず外の空気からガラスに入る
    if x_f^2+y_f^2-r_out^2<0%最初は外径より外なので、ずっとx_f^2+y_f^2＞r_out^2です。もしx_f^2+y_f^2＜r_out^2になったら、hitすることです。
        
        hit = 1;
        n_1 = n_A;
        n_2 = n_B;
        
    else
        hit = 0;
        n_1 = n_A;%ここのn_1とn_2は適当、関数は必ずoutput値が必要なので適当に出力した。
        n_2 = n_B;
    end
end

if hit_choose == 28%二個目の線なので、必ずガラス部分から管中央部（空気か水か）に入る（今は５線分のグループなので、必ず屈折して中に入る）
    
    if x_f^2+y_f^2-r_in^2<0%元々は内径と外径のなか（r_in^2＜x_f^2+y_f^2＜r_out^2）なので、x_f^2+y_f^2＜r_in^2になったらhitすることです
        
        hit = 1;
        n_1 = n_B;
        n_2 = n_C;
        
    else
        hit = 0;
        n_1 = n_B;
        n_2 = n_C;
    end
end

if hit_choose == 496%三個目。管中央部から屈折してガラスに入る。
    
    if x_f^2+y_f^2-r_in^2>0%先はx_f^2+y_f^2＜r_in^2なので、x_f^2+y_f^2＞r_in^2のようになったらhit。
        
        hit = 1;
        n_1 = n_C;
        n_2 = n_B;
        
    else
        hit = 0;       
        n_1 = n_C;
        n_2 = n_B;
    end
end

if hit_choose == 8128%四個目。ガラスから外の空気に入る（管を出る）
    
    if x_f^2+y_f^2-r_out^2>0%x_f^2+y_f^2>r_out^2ならitです
        
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
%終点にたどり着いたかどうかの判断
function d_g = function_goal(x_f,y_f,goal_y,goal_th)

if x_f > goal_y %x座標が指定のｘ座標に超えたらgoalです。
    d_g = 1;

else
    if x_f^2 + y_f^2 > goal_th^2%あるいは円心との距離がgoal_thより長いもgoalです。
        d_g = 1;

    else
        d_g = 0;
    end
end

end
%%
%ファイル名を決める関数
function [file_title_d,file_title_D] = title_fun(d,D)

file_title_d = ['0' num2str(d*10)];

if D == 0.15||D ==0.45||D == 0.75%この三つの外径はいつもバグるから、別で書いてる。もし外径条件変えたいならここも変える必要あるかも。
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
%入射角を計算する
function [m_n,th_mi,th_mn,th_i] = cal_th_m(y_1,x_1,sz_x,m_1)

m_n = y_1(sz_x+1,1)/x_1(sz_x+1,1);%hit点&円心を繋いて、その線の傾き（slope）
%法線です

th_mi = atan(m_1(sz_x,1));%m_1（直線方程式のm）をtanに変換
th_mn = atan(m_n);%m_nをtanに変換

if th_mi <= 0%もしマイナスなら+180°
    th_mi = th_mi + pi;
end
if th_mn <= 0
    th_mn = th_mn + pi;
end

%角度の差（入射角） = 法線と入射線の角度の差を求める(差を求めるなので絕對值)
th_i = abs(th_mi-th_mn);
if th_i > 0.5*pi%入射角が90°より大きいなら、180°-th_iでもう一個の角度を求める
    th_i = pi - th_i;
end

end
%%
function [th_c,test_real,th_t,I_cal,Z,th_mt,R_s,R_p,R_1,T_1,m_1,b_1] = function_zenhansha(n_1,n_2,m_n,m_1,sz_x,th_i,I_cal,th_mi,th_mn,x_1,y_1,b_1)

%Z=0=全反射 1=屈折

th_c = asin(n_2/n_1);%臨界角を計算
test_real = isreal(th_c);%臨界角は複数かどうか（入射前の物質の屈折はより低いなら、臨界角は複数、全反射はない）

%th_i は臨界角より大きいか
if m_n*m_1(sz_x,1) >= 0%th_i は臨界角より大きい
    if test_real == 1%かつth_cは実数
        if th_i >= th_c%全反射
            th_t = th_i;%反射角=入射角
            I_cal(sz_x+1,1) = I_cal(sz_x,1);%強度は変わらない
            Z = 0;%Z=0　=　全反射
            if th_mi>th_mn
                th_mt = th_mn - th_t;%新しい線の傾き（m_1）の角度を計算（line629でtan(th_mt)=m_1を計算）
            else
                th_mt = th_mn + th_t;
            end

        else%屈折
            th_t = asin(n_1*sin(th_i)/n_2);%n1sinθ1=n2sinθ2で屈折角を計算

            R_s = (sin(th_t-th_i)/sin(th_t+th_i))^2;%屈折率と反射率の計算
            R_p = (tan(th_t-th_i)/tan(th_t+th_i))^2;

            R_1 = (R_p+R_s)/2;
            T_1 = 1 - R_1;

            I_cal(sz_x+1,1) = I_cal(sz_x,1) * T_1;%新しい光強度

            Z = 1;%屈折をあらわす　

            %th_mtを計算する（自分でまとめた式なので、間違いがあるかもしれない）
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

    if test_real == 0%100％が屈折
        th_t = asin(n_1*sin(th_i)/n_2);

        R_s = (sin(th_t-th_i)/sin(th_t+th_i))^2;
        R_p = (tan(th_t-th_i)/tan(th_t+th_i))^2;

        R_1 = (R_p+R_s)/2;
        T_1 = 1 - R_1;

        I_cal(sz_x+1,1) = I_cal(sz_x,1) * T_1;

        Z = 1;

        %上と一緒
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
if m_n*m_1(sz_x,1)<0%法線と入射線のｍが一個がプラス一個がマイナスのとき
    if test_real == 1%th_cは実数
        if th_i >= th_c%全反射
            th_t = th_i;
            I_cal(sz_x+1,1) = I_cal(sz_x,1);
            Z = 0;
            if th_mi>0.5*pi
                th_mt = th_mi - 2*th_t;%ここは違う
            else
                th_mt = th_mi + 2*th_t;
            end


        else%屈折

            th_t = asin(n_1*sin(th_i)/n_2);

            R_s = (sin(th_t-th_i)/sin(th_t+th_i))^2;
            R_p = (tan(th_t-th_i)/tan(th_t+th_i))^2;

            R_1 = (R_p+R_s)/2;
            T_1 = 1 - R_1;

            I_cal(sz_x+1,1) = I_cal(sz_x,1) * T_1;

            Z = 1;



            if m_n <= 0%m_n＜0か＞0はちょっと違いがある
                if th_mi < th_mn-0.5*pi
                    th_mt = th_mi + (th_t-th_i);%ここも違う
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

    if test_real == 0%ここももし法線と入射線のｍが一個がプラス一個がマイナスのとき
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

%%


m_1(sz_x+1,1) = tan(th_mt);%次の線のm_1
b_1(sz_x+1,1) = y_1(sz_x+1,1)-x_1(sz_x+1,1)*m_1(sz_x+1,1);%次の線のb_1

end