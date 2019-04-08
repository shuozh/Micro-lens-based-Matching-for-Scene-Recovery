clear;clc;
addpath(genpath('guidedfilter'));
addpath(genpath('preprocess'));
%% Parameters
nD = 64;         % the number of depth labels
tau = 25;        % tau in Eq.1
sigma = 100;     % sigma in Eq.3

input_path  = 'input/Buddha/';
output_path = 'output/'; 
mkdir(output_path);

%% image load
img = double(imread(strcat(input_path,'lf.bmp')));             % the 4D light field image
run (strcat(input_path,'depth_opt.m'));                        % parameter of the light field image
                                   
%% micro-lens matching cost and depth computation
fprintf('Depth Estimation Begin');
depth_label = CostVolume(img, output_path, nD, tau, sigma, opts); 
fprintf('Depth Estimation Finished');
%% view synthesis
add_angular_number = 1;                                        % the angular resolution of light field image increase 2*add_novel

sgn_view_decrease = 1;                                           % 1: the angular resolution is first decreased with add_angular_number
if sgn_view_decrease == 1
    [img, opts] =  AngularResolutionChange(img, opts, opts.NumView - add_angular_number*2);
    fprintf('Depth Estimation for Angular Resolution Reduced Light Images');
    depth_label = CostVolume(img, output_path, nD, tau, sigma, opts); 
end

fprintf('View Synthesis Begin');
tic;
ViewSynthesis(img, output_path, depth_label, add_angular_number, nD, opts);
toc;
fprintf('View Synthesis Finished');

%% super-resolution
scale = 2;                                                      % the scale of the super-resolved image

sgn_downsampling = 1;                                           % 1: the spatial resolution is first downsampling
if sgn_downsampling == 1
    [img, opts] = SpatialDownsampling(img, scale, opts);        
     fprintf('Depth Estimation for Spatial Resolution Downsampled Light Images');
    depth_label = CostVolume(img, output_path, nD, tau, sigma, opts); 
end
fprintf('Super Resolution Begin');
tic;
SuperResolution(img, output_path, depth_label, scale, sigma, nD, opts);
toc;
