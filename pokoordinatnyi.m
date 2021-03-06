clear

%Coordinate descend method code:

%Variable matrix values. These were generated by my M_program.
load('TnFile', 'Tn')
load('TdFile', 'Td')
load('ErrorMatrixFile', 'ErrorMatrix')
load('ParametersFile', 'k_d', 'k_u', 'J_2')

%Parameters for the model simulation process.
model='two_wheel_rotary';
load_system(model)
set_param(model, 'SimulationMode', 'Normal')

%"Tic-toc" function for the possibility of later optimization of the code. 
%Returns time it takes for this code to compile.

tStart = tic;

ansAnalytical=820.1;
kfinal=35;
ErrorValue=zeros(2);
point=zeros(3,kfinal);

%Error tolerance is set to one percent.
Epsilon=0.01;

%Initial step values and the coefficient of the step decrease are set to 
%be random, but are also constrained to be within certain boundaries.
%This step size change coefficient will be used later
%to narrow the area at which we are looking for the minimum value.
deltaT1Init=randi([50000 75000])/10000;
deltaT2Init=randi([50000 75000])/10000;
stepsizechange=0.25;

%First points are also set to be randomly distributed within certain area.
%We also run our model to get the initial value of error.

T1init = randi([90 125])/10;
T2init = randi([90 125])/10;

T1=T1init;
T2=T2init;
sim(model);

errorPrev1=error(100001);
errorPrev2=error(100001);
%Initial point visualisation and the surface plot:

close all

fig=figure;
fig.Color = [0 0.5 0.5];
surface=surf(Td,Tn,ErrorMatrix, 'FaceAlpha', 0.5);
surface.EdgeColor = 'interp';
colormap(hot)
caxis([ansAnalytical,1.6e8]);
xlabel('T1')
ylabel('T2')
zlabel('Error Value')

hold on
plot3(T2,T1,error(100001), 'ms', 'markersize', 7.5, 'markerfacecolor', 'm')
plot3(0.02, 2, ansAnalytical, 'ys', 'markersize', 7.5, 'markerfacecolor', 'y');


minError2=errorPrev2;

for k=1:kfinal
    k
    stepmade1=true;
    errorDoublePrev1=errorPrev1;
    %I. Two "steps" in opposite directions from our initial  point
    T1Prev=T1;
    T1=(T1init+deltaT1Init);
    sim(model)
    ErrorValue(1,1)=(error(100001));
    
    T1=(T1init-deltaT1Init);
    sim(model)
    ErrorValue(1,2)=(error(100001));
    
    %II. Lowest value of error from the two values we have is the value 
    %we will need to compare to the previous error value.
    
    [minError1, index1]=min(ErrorValue(1,:));
    
    %III. Conditional statements which will set the new point to be the old
    %one depending on which one we found out to be the optimal.
    
    if minError1>errorPrev1 
        T1=T1Prev;
        deltaT1Init=stepsizechange*deltaT1Init;
        errorPrev1=minError1;
        stepmade1=false;

        disp('Step Size One Changed')
    elseif index1==1 && errorPrev2>minError1
        T1init=(T1init+deltaT1Init);
        T1=T1init;
        errorPrev1=ErrorValue(1,1);

        disp('Successful Step on T1 axis')
    elseif index1==2 && errorPrev2>minError1
        T1init=(T1init-deltaT1Init);
        T1=T1init;
        errorPrev1=ErrorValue(1,2);
  
        disp('Successful Step on T1 axis')
    elseif minError1>minError2 && minError1<errorPrev1
        T1=T1Prev;
        errorPrev1=minError2;
        stepmade1=false;
        disp('At Rest')
    else
        disp('I do not know!')
    end
    
    if (minError1>errorDoublePrev1 || minError1>errorPrev2) && stepmade1==true
        disp('Wrong T1 Step!')
    end
    plot3(T2,T1,minError1, '.gr', 'markersize', 20)
    
    point(1:3,k)=[T1,T2,errorPrev1];
    
    stepmade2=true;
    errorDoublePrev2=errorPrev2;
    
    %Applying the same algorithm on the variable T2:
    T2Prev=T2;
    T2=(T2init+deltaT2Init);
    sim(model)
    ErrorValue(2,1)=(error(100001));  

    T2=(T2init-deltaT2Init);
    sim(model)
    ErrorValue(2,2)=(error(100001));
    
    [minError2, index2]=min(ErrorValue(2,:));
    
    if minError2>errorPrev2 
        T2=T2Prev;
        errorPrev2=minError2;
        deltaT2Init=stepsizechange*deltaT2Init;
        stepmade2=false;
        
        disp('Step Size Two Changed')
    elseif index2==1 && minError2<errorPrev1
        T2init=(T2init+deltaT1Init);
        T2=T2init;
        errorPrev2=ErrorValue(2,1);
        
        disp('Successful Step on T2 axis')
    elseif index2==2 && minError2<errorPrev1
        
        T2init=(T2init-deltaT1Init);
        T2=T2init;
        errorPrev2=ErrorValue(2,2);
        disp('Successful Step on T2 axis')
    elseif minError1<minError2 && minError2<errorPrev2
        T2=T2Prev;
        errorPrev2=minError1;
        stepmade2=false;
        disp('At Rest')
    else
        disp('I do not know!')
    end
        
    if (minError2>errorPrev1 || minError2>errorDoublePrev2) && stepmade2==true
        disp('Wrong T2 Step!')
    elseif abs(minError1-ansAnalytical)/minError1<Epsilon || abs(minError2-ansAnalytical)/minError2<Epsilon 
        disp('Point Reached!')
        break
    
    end
    plot3(T2,T1,minError1, '.gr', 'markersize', 20)
    
    point(1:3,k+1)=[T1,T2,errorPrev2];
end


% plot3(point(1,:),point(2,:),point(3,:), '->gr', 'linewidth', 1, 'markersize', 3)
stepsItTook=k
tElapsed = toc(tStart)



