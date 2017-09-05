function ProcessResults

% Emmanuel Bossy, April 26th, 2012


%% reads received signals
rcv_array=SimSonic2DReadRcv2D('R001_T11.rcv2D');

figure(1)
clf
colormap(gray)
distance_base=(0:rcv_array.NbElements-1)*rcv_array.Pitch*rcv_array.Spatial_step_mm;
time_base=(0:rcv_array.NbTimePoints-1)*rcv_array.Temporal_step_us;
rcv_idx=1;
plot(time_base,rcv_array.Signals(:,rcv_idx));
title(sprintf('signal measured at distance %i mm',distance_base(rcv_idx)))
xlabel('time (µs)')


%% reads Geometry.map2D to overlay with snapshots
geometry=SimSonic2DReadMap2D('Geometry.map2D');

figure(2)
clf
for snp_idx=1:19
    
    %% reads snapshot and overlay with Geometry.map2D
    snapshot=SimSonic2DReadSnp2D(sprintf('V_%0.3i.snp2D',snp_idx));
    alpha=0.3;
    Overlaid=SimSonic2DOverlayGeometrySnp(geometry,snapshot,alpha);
    
    %% plots snapshop/geometry
    clf
    X1_base=(0:snapshot.N1-1)*snapshot.Grid_step_mm;
    X2_base=(0:snapshot.N2-1)*snapshot.Grid_step_mm;
    imagesc(X2_base,X1_base,Overlaid);
    ylabel('mm')
    xlabel('mm')
    set(gca,'dataAspectRatio',[1 1 1]);
    hold on
    plot(((0:rcv_array.NbElements-1)*rcv_array.Pitch+rcv_array.X2_start)*rcv_array.Spatial_step_mm ,rcv_array.X1_start*rcv_array.Spatial_step_mm,'w')
    drawnow
    pause(0.1)
    %pause()
end


function Overlaid=SimSonic2DOverlayGeometrySnp(geometry,snapshot,alpha)

cmin_geometry=0;
cmax_geometry=1;
cmin_snp=0;
cmax_snp=snapshot.Max*1;

[N1,N2]=size(geometry);

scaled_geometry=(double(geometry)-cmin_geometry)/(cmax_geometry-cmin_geometry);
scaled_snp=(snapshot.Data(1:N1,1:N2)-cmin_snp)/(cmax_snp-cmin_snp);

map_geometry=gray(256);
map_snp=hot(256);

geometry_image=ind2rgb(uint8(scaled_geometry*255),map_geometry);
snp_image=ind2rgb(uint8(scaled_snp*255),map_snp);

coeff=repmat(1-alpha*scaled_geometry,[1 1 3]);
Overlaid=coeff.*snp_image+(1-coeff).*geometry_image;

