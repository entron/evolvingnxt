%%This matlab program is to let Lego NXT approach the light using a
%%random walker scheme. For more information and the step up please visit
%%http://legonxt.spacetimewave.net/
%%April 23, 2011
%%Cheng Guo


%%Connect to the NXT
COM_CloseNXT all
h = COM_OpenNXT('bluetooth.ini');
COM_SetDefaultNXT(h);

%%Define moter object
mR = NXTMotor('A','SpeedRegulation',false,'ActionAtTachoLimit','Coast');
mL = NXTMotor('C','SpeedRegulation',false,'ActionAtTachoLimit','Coast');
mLR = NXTMotor('AC','SpeedRegulation',false,'ActionAtTachoLimit','Coast');
mR.Power=80;
mL.Power=80;
mLR.Power=-80;

%%Open Sensors
OpenLight(SENSOR_1,'INACTIVE');
OpenUltrasonic(SENSOR_4);

%%Find light
step=1;lightdata=0;
lightdata(step)=GetLight(SENSOR_1);
distdata(step)=GetUltrasonic(SENSOR_4);
while lightdata(step)<800
    if randi(2,1)==1 %Randomly choose one of the two motors.
        mCurrent=mR;
    else
        mCurrent=mL;
    end
    mCurrent.SendToNXT();
    pause(0.18);
    mCurrent.Stop('off');
    step=step+1;
    lightdata(step)=GetLight(SENSOR_1);
    distdata(step)=GetUltrasonic(SENSOR_4);
    plot(lightdata,'-o');drawnow; %
    if distdata(step)<50 || abs(lightdata(step)-lightdata(step-1))<5 %Avoid obstakles or detect whether get stucked
        mLR.SendToNXT();pause(0.5);mLR.Stop('off'); %Go back a little bit.
    end
end

%%Adjust direction (Poiting the light sensor to the brightest point.)
step=step+1;lightdata(step)=GetLight(SENSOR_1);
while lightdata(step)<max(lightdata(1:step-1))-50
    mCurrent=mL;
    mCurrent.TachoLimit=10;
    mCurrent.SendToNXT();
    step=step+1;
    lightdata(step)=GetLight(SENSOR_1);
    distdata(step)=GetUltrasonic(SENSOR_4);
    plot(lightdata,'-o');drawnow;
end

%%Close Everything
mR.Stop('off');
mL.Stop('off');
mLR.Stop('off');
CloseSensor(SENSOR_1);
CloseSensor(SENSOR_4);
COM_CloseNXT all