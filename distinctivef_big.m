clearvars
close all
clear all
clc

% file containing features
filein_features = 'inventory68-raw.xlsx'; % file containing neuron features data in cells

sheet = 1;
xlRange = 'A3:AZ143'; % AY = till Angle 17 cell
xlRange_names = 'A1:AZ1';

[features_all,~,~] = xlsread(filein_features, sheet, xlRange);
[~,features_all_names,~] = xlsread(filein_features, sheet, xlRange_names);


%% DATA and FEATURE selection
bigornot = features_all(:,31);
bigneurons = find(bigornot==1);

markerclass = features_all(bigneurons,6);

% Select only ++ neurons
mrpositive = find(markerclass==4);
mrnegative = find(markerclass==3);

ctip2marker = sort([mrpositive;mrnegative]);

% All
% D,D1,D2,Striking,Lambda,Area,Oblate,Prolate,Sphericity,Volume,Dendrites,Angles
feature_range = [8 9 10 11 19 20 24 26 27:30];

features_selected = features_all(ctip2marker,feature_range); 
features_names_selected = features_all_names(feature_range);
markerclass_selected = features_all(ctip2marker,6);


%% SHOW selected features
fb = figure;
fb = boxplot(features_selected,'orientation','horizontal','labels',features_names_selected);

%% Display difference

%parallelcoords
fp = figure;
set(fp,'DefaultAxesColorOrder',[237/255 125/255 49/255;91/255 155/255 213/255;165/255 165/255 165/255]);
fp = parallelcoords(features_selected, 'group',markerclass_selected, 'standardize','on', 'labels',features_names_selected, 'quantile',.25,'LineWidth', 2)

%andrewsplot
fa = figure;
set(fa,'DefaultAxesColorOrder',[237/255 125/255 49/255;91/255 155/255 213/255;165/255 165/255 165/255]);
fa = andrewsplot(features_selected, 'group',markerclass_selected, 'standardize','on')
