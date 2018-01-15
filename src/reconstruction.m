%reconstruction
%
N1 = 400; %8mm
N2 = 400; %8mm
dx = .02; %mm/step
c = 1500e-3; %mm/us
r0 = 3.8; %mm radius of array
r0g = r0/dx; %r0 in gridsteps
R0 = []; %placement of receivers (grid steps)
R = []; %grid spot of valid reconstruction points (must be interior of array)
T = 6; %us length of simulation
Rnum = 32; %number of receiver elements
%or
% Asig = SimSonic2DReadRcv2D('T11data_T11.rcv2D');
% D=Asig.Signals;
% Dt=Asig.Temporal_step_us;

%% read receiver files %%
for i=1:9
    Asig=SimSonic2DReadRcv2D(strcat('R00',int2str(i),'_T11.rcv2D'));
    D(:,i) = Asig.Signals;
    R0(i,:) = [Asig.X1_start,Asig.X2_start];
end
for i=10:32
    Asig=SimSonic2DReadRcv2D(strcat('R0',int2str(i),'_T11.rcv2D'));
    D(:,i) = Asig.Signals;
    R0(i,:) = [Asig.X1_start,Asig.X2_start];
end
Asig = SimSonic2DReadRcv2D('R001_T11.rcv2D');
Dt=Asig.Temporal_step_us;


%% do time differentian of  pressure %%
%using savgol(x,width,order,deriv)
%experiment with this
Q = []; %change of p over change in time
for i=1:Rnum
    Q(:,i) = savgol(D(:,i),100,2,1);
end

%% reconstruct signal %%
[x,y] = meshgrid(1:N1,1:N2); %create meshgrid of array size
C = find((x-N1/2).^2 + (y-N2/2).^2 < (r0g)^2); %find gridpoints that are within circle 
% NOTE: 'find' only works if the array is square. Otherwise will break
% down
% Also note: C find indices by going down rows and then moves on to new
% column. For example: [0 0; 1 0] with 1 having indice 2
A = zeros(N1,N2); %reconstruction matrix
R = [round(C/N2+.5),mod(C,N2)]; %find indices of reconstruction matrix of valid points

%Going to reconstruct in this fashion (for individual transducer):
%1. Find grid difference between R (valid points) and R0(i)
%2. Convert difference to mm and find time difference
%3. Convert time dif to location on signal plot
%4. Add contributions to reconstruction


for i=1:Rnum
    pdiff = abs(R-repmat(R0(i,:),length(R(:,1)),1)); %step 1 part 1
    diff = (pdiff(:,1).^2+pdiff(:,2).^2).^.5; %step 1 part 2
    T = diff*dx/c; %step 2
    B = Q(round(T/Dt+.5),i)./T; %step 3
    A(C) = A(C) + B; %step 4
end

A = transpose(A);

figure,imagesc(A)


