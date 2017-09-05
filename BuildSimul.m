%% General parameters %%%

dx=0.02; % mm
Vmax=4.0; % mm/us
alpha=0.99;
dt=alpha*dx/(sqrt(2)*Vmax);% µs

%% Create cylinder
radius = 20; %pixels
N1=400; %1200 for 24 mm and dx=.02
N2=400; %1800 for 36 mm and dx=.02
[x,y] = meshgrid(1:N1,1:N2); %create meshgrid of array size
C = find((x-N1/2-40).^2 + (y-N2/2).^2 < (radius)^2);
C2 = find((x-N1/2+40).^2 + (y-N2/2).^2 < (radius)^2);
C3 = find((x-N1/2).^2 + (y-N2/2-40).^2 < (radius)^2);
C4 = find((x-N1/2).^2 + (y-N2/2+40).^2 < (radius)^2);


%% Building map  %%%


%interface_position=201;
map=repmat(uint8(0),[N1,N2]);
map(C)=uint8(1);
map(C2)=uint8(1);
map(C3)=uint8(1);
map(C4)=uint8(1);
%map(interface_position:end,:)=uint8(1);
SimSonic2DWriteMap2D(map);

%% Building photoacoustic map %%%

photomap = repmat(uint8(0),[N1,N2]);
[x,y] = meshgrid(1:N1,1:N2); %create meshgrid of array size
for i=0:radius-1
    C = find((x-N1/2-40).^2 + (y-N2/2).^2 < (radius-i)^2);
    photomap(C)=uint8(i+1);
    C2 = find((x-N1/2+40).^2 + (y-N2/2).^2 < (radius-i)^2);
    photomap(C2)=uint8(i+1);
    C3 = find((x-N1/2).^2 + (y-N2/2-40).^2 < (radius-i)^2);
    photomap(C3)=uint8(i+1);
    C4 = find((x-N1/2).^2 + (y-N2/2+40).^2 < (radius-i)^2);
    photomap(C4)=uint8(i+1);
end
SimSonic2DWriteMap2D(photomap,'PhotoacousticMap.rcv2D');

%% Building signal  %%%

f0=4.0; % central frequency, MHz
t0=1.5; % pulse center time
%fractional bandwidth means bandwidth divided by center, so 100% means
%bandwidth = f0
bndwdth=4; % pulse -6dB bandwidth.
duration=6;%2*t0; % signal length

timebase=(0:round(duration/dt)-1)'*dt;
[signalI,signalQ]=gauspuls(timebase-t0,f0,bndwdth);signal=signalQ;
%signal=signal/max(signal);
signal=repmat(0,[length(signal) 1]);

SimSonic2DWriteSgl(signal)

%% Building photosignal  %%%

%light
lambda0=700e-1; %900 nm
f0 = 3e8/lambda0/1e6; %3.33e14 Hz --> 3.33e8 MHz
t0=.5; % pulse center time
%fractional bandwidth means bandwidth divided by center, so 100% means
bndwdth=f0; % pulse -6dB bandwidth.
duration=6; % signal length

timebase=(0:round(duration/dt)-1)'*dt;
%[signalI,signalQ]=gauspuls(timebase-t0,f0,bndwdth);photosignal=signalI;
photosignal=repmat(uint8(0),[length(timebase) 1]);
photosignal(12,1) = 1;
%photosignal=1*photosignal/max(photosignal);
%photosignal=repmat(0,[length(photosignal) 1]);


SimSonic2DWriteSgl(photosignal,'PhotoacousticSignal.sgl')


%% check 
figure(1)
imagesc(map)
axis image

figure(2)
imagesc(photomap)
axis image

figure(3)
plot(timebase,signal,'.-')
title('source signal')
xlabel('time (µs)')

figure(4)
plot(timebase,photosignal,'.-')
title('photo signal')
xlabel('time (µs)')
 