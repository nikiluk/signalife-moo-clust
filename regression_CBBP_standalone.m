%
% this file is performing regression of biocytin neurons based on a trained
% set from CBBP neurons
%

clearvars
close all
clear all
clc

%% READ

% file containing features
filein_training_features = 'inventory84-raw-matching-percetage.xlsx'; % file containing neuron features data in cells
filein_regression_features = 'inventory-biocytin-raw-25-electrophydata.xlsx'; % file containing neuron features data in cells

sheet_regresion = 1;
sheet_training = 1;

xlRange_training = 'A2:AH53'; % BB = till Angle 17 cell
xlRange_regression = 'E3:AE33';
xlRange_regression_names = 'E1:AE1';

xlRange_training_names = 'A1:AH1';
xlRange_neuron_names = 'AI2:AI53';

[features_all_training,~,~] = xlsread(filein_training_features, sheet_training, xlRange_training);
[features_all_regression,~,~] = xlsread(filein_regression_features, sheet_regresion, xlRange_regression);

[~,features_all_training_names,~] = xlsread(filein_training_features, sheet_training, xlRange_training_names);
[~,features_all_regression_names,~] = xlsread(filein_regression_features, sheet_regresion, xlRange_regression_names);

[~,neuron_names_all,~] = xlsread(filein_training_features, sheet_training, xlRange_neuron_names);

%% FEATURE SELECTION FOR LOGISTIC REGRESSION

% {'Diameter','Ramification','Area','Oblate','Prolate','Sphericity','Volume','Dendrites'}
feature_training_range = [7 10 13 20 21 25 26 29];
feature_regression_range = [5 8 11 18 19 23 24 27];

features_training_selected = features_all_training(:,feature_training_range);
features_regression_selected = features_all_regression(:,feature_regression_range);
features_regression_names_selected = features_all_regression_names(:,feature_regression_range);
features_training_names_selected = features_all_training_names(:,feature_training_range);

optimalClustering = features_all_training(:,34);

ssi = 0;
addpath('SRC/exportfig');


% %% STANDARDIZE
% 
% [features_training_selected,gpamean_training,gpastdev_training] = zscore(features_training_selected, [], 1);
% [features_regression_selected,gpamean_regression,gpastdev_regression] = zscore(features_regression_selected, [], 1);


%% SHOW selected features
fb = figure;
fb = boxplot(features_regression_selected,'orientation','horizontal','labels',features_regression_names_selected);

%fg = figure('units','normalized','outerposition',[0 0 1 1]);
cmap = [255 149 47;
        91 155 213;
        166 86 40;
        133 181 0;
        147 194 220;
        28 28 28;
        166 86 40];
cmap = cmap/255;    

%% Display difference

%parallelcoords
fp = figure('units','normalized','outerposition',[0 0 1 1]);
set(fp,'DefaultAxesColorOrder',cmap);
fp = parallelcoords(features_training_selected,'group',optimalClustering, 'standardize','on', 'labels',features_training_names_selected, 'quantile',.25,'LineWidth', 2);

[B,dev,stats] = mnrfit(features_training_selected,optimalClustering);
B

pihat = mnrval(B,features_regression_selected);

for ii=1:size(features_regression_selected,1) 
[mlp(ii,1),mle(ii,1)] = max(pihat(ii,:));
end

