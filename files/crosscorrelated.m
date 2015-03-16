%
% this file is looking at cross-correlations between features
%

clearvars
close all
clear all
clc


%% READ

% file containing features
filein_features = 'inventory82-raw-matching.xlsx'; % file containing neuron features data in cells

sheet = 1;
xlRange = 'A3:BB147'; % BB = till Angle 17 cell
xlRange_names = 'A1:BB1';

[features_all,~,~] = xlsread(filein_features, sheet, xlRange);
[~,features_all_names,~] = xlsread(filein_features, sheet, xlRange_names);

neuron_class=[];
neuron_members=[];
silu=[];
fs=[];

% params
class_number = 7;
iterations = 1000;

%% DATA and FEATURE selection


% All
% {'Diameter','D1','D2','Ramification','Striking','Lambda','Area','Oblate','Prolate','Sphericity','Volume','CB','BP','Dendrites','0-45','45-90','90-135','135-180'}
% 27 - CB and 28 - BP in um
%feature_range = [7 8 9 10 11 12 13 20 21 25 26 27 28 29 30:33];

% {'Ramification','Striking','Lambda','Area','Oblate','Prolate','Sphericity','Volume','CB','BP','Dendrites','0-45','45-90','90-135','135-180'}
% 27 - CB and 28 - BP in um
% results in 4 classes among all
%feature_range = [10 11 12 13 20 21 25 26 27 28 29 30:33];

% {'Ramification','Area','Oblate','Prolate','Sphericity','Volume','CB','BP','Dendrites','0-45','45-90','90-135','135-180'}
% 27 - CB and 28 - BP in um
% results in 4 classes among all
%feature_range = [10 13 20 21 25 26 27 28 29 30:33];



% {'Ramification','Area','Oblate','Prolate','Sphericity','Volume','CB','BP','Dendrites','0-45','45-90','90-135','135-180'}
% 27 - CB and 28 - BP in um
% results in 4 classes among all
feature_range = [10 27];

% All
% D,D1,D2,Striking,Lambda,Area,Oblate,Prolate,Sphericity,Volume,Dendrites,Angles
%feature_range = [7 8 9 10 11 12 19 20 24 25 26 27:30];

% Dendrites,Angles
%feature_range = [26 27:30];

% D1,D2,Striking,Lambda,Area,Volume,Angles - not very promissing, nothing
% except size
%feature_range = [8 9 10 11 12 25 27:30];

% D1,D2,Striking,Lambda, volume
%feature_range = [8 9 10 11 19 20 25];

% take column 6
markerclass = features_all(:,6);
% find only ++ neurons
mrpositive = find(markerclass==4);

% Apical dendrites info: check where features_all(:,27) is NaN and find positive indexes
have_CBBP=isnan(features_all(:,27));
have_CBBP_index=find(have_CBBP==0);

% select all(:) or positive (mrpositive)
features_selected = features_all(have_CBBP_index,feature_range); 
features_names_selected = features_all_names(feature_range);

%% PLOTTING

features_number = length(features_names_selected);
coords = [];
coords_step = 1/features_number;
for cc=1:features_number
coords = [coords (cc-1)*coords_step];
end
cmap = [237/255 125/255 49/255];

gplotmatrix(features_selected,[],[],cmap,[],[],'hist')
text(coords, repmat(-.1,1,features_number), features_names_selected, 'FontSize',10);
text(repmat(-.12,1,features_number), sort(coords,'descend'), features_names_selected, 'FontSize',10, 'Rotation',90);
