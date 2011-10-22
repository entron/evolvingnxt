function drivenxtcamel()
%%DRIVENNXTCAMEL drives NXTCamel around and avoid obstacles based on the
%%distance measre inforation. 
%%Oct 2011
%%http://evolvingnxt.blogspot.com
%%Cheng Guo

MinD=80; %The minimum distance of any object.

%%Connect to the NXT
COM_CloseNXT all
h = COM_OpenNXT('bluetooth.ini');
COM_SetDefaultNXT(h);
 
%%Define moter object
mDrive = NXTMotor('B','SpeedRegulation',false,'ActionAtTachoLimit','Coast');
mTurn = NXTMotor('C','SpeedRegulation',false,'ActionAtTachoLimit','Brake');
mSonar = NXTMotor('A','SpeedRegulation',false,'ActionAtTachoLimit','Brake');
mTurn.TachoLimit=100;

%%Open Sensors
%OpenLight(SENSOR_1,'INACTIVE');
OpenUltrasonic(SENSOR_4);
%OpenSwitch(SENSOR_3);
%OpenSound(SENSOR_2, 'DB');

    function [rho,theta]=MeasureDist(sample_num) %Define the distance measure function
        rho=zeros(sample_num,1);
        theta=zeros(sample_num,1);
        for i=1:sample_num
            mSdata=mSonar.ReadFromNXT();
            rho(i)=GetUltrasonic(SENSOR_4);
            theta(i)=-mSdata.Position;
        end
    end

    function [rho,theta]=SonarScan() %Scan sonar once.
        mSonar.Power=-40; mSonar.TachoLimit=360;
        mSonar.SendToNXT();
        [rho,theta]=MeasureDist(10);
        mSonar.WaitFor();
        mSonar.Power=100; mSonar.TachoLimit=360;
        mSonar.SendToNXT();
        mSonar.WaitFor();
    end

    function driveback(time)
        mP=mDrive.Power;
        mDrive.Stop('off');
        mDrive.Power=40; mDrive.SendToNXT();pause(time);mDrive.Stop('off');mDrive.Power=mP;
    end

    function turnleft(time)
        mP=mDrive.Power;
        mDrive.Power=-40;
        mTurn.Power=TurnPower;
        mTurn.SendToNXT();
        mDrive.SendToNXT();
        mTurn.Power=-1*mTurn.Power;
        %mTurn.WaitFor();
        pause(time);
        mTurn.SendToNXT();
        mDrive.Stop('off');
        mDrive.Power=mP;
    end

    function turnright(time)
        mP=mDrive.Power;
        mDrive.Power=-40;
        mTurn.Power=-TurnPower;
        mTurn.SendToNXT();
        mDrive.SendToNXT();
        mTurn.Power=-1*mTurn.Power;
        %mTurn.WaitFor();
        pause(time);
        mTurn.SendToNXT();
        mDrive.Stop('off');
        mDrive.Power=mP;
    end

%Set sonar to the initial position
mSonar.ResetPosition();
mSonar.Power=100; mSonar.TachoLimit=90; 
mSonar.SendToNXT();
mSonar.WaitFor();

%Start driving. stepnumber controls how long you want to drive.
stepnum=10;
TurnPower=80; %Positive is turn left.
DrivePower=30; %Positive is drive backwards
mDrive.Power=-DrivePower;
for step=1:stepnum
    mDrive.SendToNXT();
    [rho,theta]=SonarScan();
    f=rho(5); %front distance
    l=(rho(6)+rho(7))/2; %left distance
    r=(rho(4)+rho(3))/2; %right distance
    if f<MinD
        driveback(2);
        if l>MinD
            turnleft(2)
        else if r>MinD
                turnright(2)
            else
                disp('No place to go, stop now.');
                break;
            end
        end
    end
    mDrive.Stop('off');
end
mDrive.Stop('off');

%Restore sonar to the default position
mSonar.Power=-100; mSonar.TachoLimit=90;
mSonar.SendToNXT();
mSonar.WaitFor();
%%Close Everything
mDrive.Stop('off');
mTurn.Stop('off');
mSonar.Stop('off');
CloseSensor(SENSOR_1);
CloseSensor(SENSOR_2);
CloseSensor(SENSOR_3);
CloseSensor(SENSOR_4);
COM_CloseNXT all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
