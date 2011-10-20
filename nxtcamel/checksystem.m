function checksystem()
%CHECKSYSTEM is used to check motors and sensors on nxtcamel.
%Cheng Guo
%http://evolvingnxt.blogspot.com
%Oct 2011

disp('Make sure the ultrasonic sensor faces to the right side before you start.');

%%Connect to the NXT
COM_CloseNXT all
h = COM_OpenNXT('bluetooth.ini');
COM_SetDefaultNXT(h);
 
%%Define moter object
mDrive = NXTMotor('B','SpeedRegulation',false,'ActionAtTachoLimit','Coast');
mTurn = NXTMotor('C','SpeedRegulation',false,'ActionAtTachoLimit','Brake');
mSonar = NXTMotor('A','SpeedRegulation',false,'ActionAtTachoLimit','Brake');

%%Open Sensors
OpenLight(SENSOR_1,'INACTIVE');
OpenUltrasonic(SENSOR_4);
OpenSwitch(SENSOR_3);
OpenSound(SENSOR_2, 'DB');


disp('========Now test driving system========');
mDrive.Power=-50; %Positive is going backward.
mTurn.Power=80; %Positive is to turn left.
mTurn.TachoLimit=100; %This value should not be bigger than 100 according the the hardware setup.

disp('Drive forward for 3 second. Press any key to start...');pause;
mDrive.SendToNXT();pause(3);mDrive.Stop('off');

disp('Drive backward for 3 second. Press any key to start...');pause;
mDrive.Power=50;mDrive.SendToNXT();pause(3);mDrive.Stop('off'); mDrive.Power=-50;

disp('Turn left. Press any key to start...');pause;
mDrive.SendToNXT();
mTurn.SendToNXT();
pause(6);
mDrive.Stop('off');
mTurn.Power=-80;
mTurn.SendToNXT();
pause(1)

disp('Turn right. Press any key to start...');pause;
mDrive.SendToNXT();
mTurn.SendToNXT();
pause(6);
mDrive.Stop('off');
mTurn.Power=80;
mTurn.SendToNXT();
pause(1)

disp('Back and turn. Press any key to start...');pause;
mDrive.Power=50;pause(0.1);
mDrive.SendToNXT();
mTurn.Power=-80;
mTurn.SendToNXT();
pause(6);
mDrive.Stop('off');
mTurn.Power=80;
mTurn.SendToNXT();
pause(0.5)

disp('Back and turn to the other direction. Press any key to start...');pause;
mDrive.SendToNXT();
mTurn.SendToNXT();
pause(6);
mDrive.Stop('off');
mTurn.Power=-80;
mTurn.SendToNXT();
pause(0.5)
disp('========Driving system test finished========');


disp('========Now test the sonar system========')
    function [rho,theta]=MeasureDist(sample_num) %Define the distance measure function
        rho=zeros(sample_num,1);
        theta=zeros(sample_num,1);
        for i=1:sample_num
            mSdata=mSonar.ReadFromNXT();
            rho(i)=GetUltrasonic(SENSOR_4);
            theta(i)=-mSdata.Position;
        end
    end
mSpower=40; %Sonar moter power. Positive is to turn right.
disp('Sweep sonar and measure the distance. Press any key to start...');pause;
mSonar.ResetPosition();
mSonar.Power=mSpower; mSonar.TachoLimit=90; 
mSonar.SendToNXT();
mSonar.WaitFor();

%for n=1:3
mSonar.Power=-mSpower; mSonar.TachoLimit=360;
mSonar.SendToNXT();
[rho,theta]=MeasureDist(10);
mSonar.WaitFor();
mSonar.Power=mSpower; mSonar.TachoLimit=360;
mSonar.SendToNXT();
mSonar.WaitFor();
%end

data=cat(2,theta,rho);
data=sortrows(data);
mSonar.Power=-mSpower; mSonar.TachoLimit=90;
mSonar.SendToNXT();
mSonar.WaitFor();
polar(data(:,1)*(pi/180),data(:,2),'o-'); %Plot the distance data. NXTcamel is always facing 12 oclock.
disp('========Sonar test finished========')

%Print light sensor information.
l=GetLight(SENSOR_1);
fprintf('Light intensity is %g%%\n',l/10);


%%Close Everything
mDrive.Stop('off');
mTurn.Stop('off');
mSonar.Stop('off');
CloseSensor(SENSOR_1);
CloseSensor(SENSOR_2);
CloseSensor(SENSOR_3);
CloseSensor(SENSOR_4);
COM_CloseNXT all
disp('========All test finished========');
end