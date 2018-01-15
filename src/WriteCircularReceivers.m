%% %%%%%%%%%%%% circular receivers construction%%%%%%%%%%%
N1=400; %1200 for 24 mm and dx=.02
N2=400; %1800 for 36 mm and dx=.02
radius_mm=3.8;
grid_step_mm=0.02; % mm
N_receivers=32;
theta=linspace(0,2*pi,N_receivers+1);
theta=theta(1:end-1);

x1_receivers=round((N1-1)/2+round(radius_mm*cos(theta)/grid_step_mm));
x2_receivers=round((N2-1)/2+round(radius_mm*sin(theta)/grid_step_mm));

figure(1)
hold on
plot(x2_receivers,x1_receivers,'w.')

fid=fopen('Parameters.ini2D','rt+'); 
fseek(fid,0,1);
fprintf(fid,'%s',sprintf('Nb of T11 Receivers Array    : %i\n',length(theta)));
for k=1:length(theta)
    fprintf(fid,'%s',sprintf('R%0.3i\n',k));
    fprintf(fid,'%s',sprintf('1\n'));
    fprintf(fid,'%s',sprintf('%i %i\n',x1_receivers(k),x2_receivers(k)));
    fprintf(fid,'%s',sprintf('1 1 1\n'));
end
fclose(fid)
