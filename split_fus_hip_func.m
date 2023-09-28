function split_fus_hip_func(subnumbers)
%subnumbers=[1101];
setenv('FSLOUTPUTTYPE','NIFTI_GZ');
startdir=pwd;
for s=1:length(subnumbers)
subNr=subnumbers(s);
roidir =sprintf('~/Data/katzer3/sub-%d/anat/antsreg/masks', subNr);
cd(roidir)
%% split freesurfer fusiform along anterior-posterior boundary
% use most anterior boundary of PHC as the splitting slice
cmnd = 'fslstats r_fus -w';
[~,roisize]=system(cmnd);
fusroi=strread(roisize,'%d');
cmnd = 'fslstats r_phc -w';
[~,roisize]=system(cmnd);
phcroi=strread(roisize,'%d');
bndslice = phcroi(3)+phcroi(4); % the most anterior boundary slice of PHC
npost = bndslice-fusroi(3); % how many slices for posterior fusiform
nant = fusroi(3)+fusroi(4)-bndslice; % how many slices for anterior fus
cmnd = sprintf('fslmaths r_fus -roi %d %d %d %d %d %d %d %d r_pfus', fusroi(1:3), npost, fusroi(5:8));
system(cmnd);
cmnd = sprintf('fslmaths r_fus -roi %d %d %d %d %d %d %d %d r_afus', fusroi(1:2), bndslice, nant, fusroi(5:8));
system(cmnd);

cmnd = 'fslstats l_fus -w';
[~,roisize]=system(cmnd);
fusroi=strread(roisize,'%d');
cmnd = 'fslstats l_phc -w';
[~,roisize]=system(cmnd);
phcroi=strread(roisize,'%d');
bndslice = phcroi(3)+phcroi(4); % the most anterior boundary slice of PHC
npost = bndslice-fusroi(3); % how many slices for posterior fusiform
nant = fusroi(3)+fusroi(4)-bndslice; % how many slices for anterior fus
cmnd = sprintf('fslmaths l_fus -roi %d %d %d %d %d %d %d %d l_pfus', fusroi(1:3), npost, fusroi(5:8));
system(cmnd);
cmnd = sprintf('fslmaths l_fus -roi %d %d %d %d %d %d %d %d l_afus', fusroi(1:2), bndslice, nant, fusroi(5:8));
system(cmnd);

system('fslmaths r_afus -add l_afus b_afus');
system('fslmaths r_pfus -add l_pfus b_pfus');
system('fslmaths r_afus -add r_erc r_amtl');
system('fslmaths l_afus -add l_erc l_amtl');
system('fslmaths r_amtl -add l_amtl b_amtl');
%% split hippocampus in half into anterior and posterior
% if odd number of slices, have posterior longer
cmnd = 'fslstats r_hip -w';
[~, roisize]=system(cmnd);
hiproi=strread(roisize,'%d');
npslices = ceil(hiproi(4)./2);
naslices = hiproi(4)-npslices;
bnd=hiproi(3)+npslices;
cmnd=sprintf('fslmaths r_hip -roi %d %d %d %d %d %d %d %d r_phip', hiproi(1:3), npslices, hiproi(5:8));
system(cmnd);
cmnd=sprintf('fslmaths r_hip -roi %d %d %d %d %d %d %d %d r_ahip', hiproi(1:2), bnd, naslices, hiproi(5:8));
system(cmnd);

cmnd = 'fslstats l_hip -w';
[status, roisize]=system(cmnd);
hiproi=strread(roisize,'%d');
npslices = ceil(hiproi(4)./2);
naslices = hiproi(4)-npslices;
bnd=hiproi(3)+npslices;
cmnd=sprintf('fslmaths l_hip -roi %d %d %d %d %d %d %d %d l_phip', hiproi(1:3), npslices, hiproi(5:8));
system(cmnd);
cmnd=sprintf('fslmaths l_hip -roi %d %d %d %d %d %d %d %d l_ahip', hiproi(1:2), bnd, naslices, hiproi(5:8));
system(cmnd);

system('fslmaths r_phip -add l_phip b_phip');
system('fslmaths r_ahip -add l_ahip b_ahip');
end
cd(startdir);

