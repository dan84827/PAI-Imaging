function ProcessResults2
figure(1)
%SimSonic2DReadSnp2D('Scatterer\V_001.snp2D','plot');

%% Receivers parameters, as used to build the simulation %%%%
radius_mm=1;
N_receivers=32;   
theta=linspace(0,2*pi,N_receivers+1);
theta=theta(1:end-1);

%% read all the individual .rcv2D file and store in a single matrix
Dir='';
Ref=SimSonic2DReadRcv2D([Dir '\R001_T11.rcv2D']);
Nbpts_signals=length(Ref.Signals);
Ref_T11_signals=zeros(Nbpts_signals,N_receivers);
for k=1:N_receivers    
temp=SimSonic2DReadRcv2D(sprintf('%s\\R%0.3i_T11.rcv2D',Dir,k));
Ref_T11_signals(:,k)=temp.Signals;
end

%% read all the individual .rcv2D file and store in a single matrix
Dir='';
Scat=SimSonic2DReadRcv2D([Dir '\R001_T11.rcv2D']);
Nbpts_signals=length(Scat.Signals);
Scat_T11_signals=zeros(Nbpts_signals,N_receivers);
for k=1:N_receivers
temp=SimSonic2DReadRcv2D(sprintf('%s\\R%0.3i_T11.rcv2D',Dir,k));
Scat_T11_signals(:,k)=temp.Signals;
end

%% Builds the time base
Timebase=(0:Nbpts_signals-1)*temp.Temporal_step_us;

%% Substraction of the incident wave to get the scattered wave only
ScatteredSignal=Ref_T11_signals;

%% Fourier Analysis of the signals

WindowedScatteredSignal=ScatteredSignal.*(hamming(Nbpts_signals)*ones(1,N_receivers));
WindowedRefSignal=0;%Ref_T11_signals.*(hamming(Nbpts_signals)*ones(1,N_receivers));
N=nextpow2(Nbpts_signals)+1;
Spectrum=fftshift(fft(WindowedScatteredSignal,2^N));
Spectrum_ref=fft(WindowedRefSignal,2^N);
Frequencybase=(0:2^N-1)/(2^N*temp.Temporal_step_us);

figure(2)
clf
DeltaF=Frequencybase(2)-Frequencybase(1);
Freq=0.98;
Freq_idx=round(Freq/DeltaF);
rounded_freq=Frequencybase(Freq_idx);
h=polar(theta-1*pi/2,1.0*abs(Spectrum(Freq_idx,:))./max(abs(Spectrum(Freq_idx,:))),'b-');
title(sprintf('frequency = %.2f MHz',rounded_freq))

figure,plot(Ref_T11_signals(:,5))

pt=Ref_T11_signals(:,5);
pf=fftshift(fft(pt));
figure,plot(pf);
end

