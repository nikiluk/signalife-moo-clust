% this file should perform evaluation of the number of clusters, but it
% doesn't work for Matlab R2013a
% 
% Project name: SIGNALIFE Neuron Morphology Clustering
% Author: Nikita Lukianets
% Email: nikita.lukianets@unice.fr
% Date: 2015-03-16

clearvars
close all
clear all
clc


%% READ

% file containing features
filein_features = 'inventory83-raw-matching-percetage.xlsx'; % file containing neuron features data in cells

sheet = 1;
xlRange = 'A3:BB147'; % BB = till Angle 17 cell
xlRange_names = 'A1:BB1';

[features_all,~,~] = xlsread(filein_features, sheet, xlRange);
[~,features_all_names,~] = xlsread(filein_features, sheet, xlRange_names);

neuron_class=[];
neuron_members=[];
silu=[];
h=[];

%% DATA and FEATURE selection

feature_range = [7 10 13 20 25 26 27 28 29];
%% Apical dendrites info: check where features_all(:,27) is NaN and find positive indexes
have_CBBP=isnan(features_all(:,27));
have_CBBP_index=find(have_CBBP==0);
features_all_have_CBBP = features_all(have_CBBP_index,:);

features_selected = features_all_have_CBBP(:,feature_range); 
features_names_selected = features_all_names(feature_range);

%% STANDARDIZE

[features_selected,gpamean,gpastdev] = zscore(features_selected, [], 1);

figure()
boxplot(features_selected,'orientation','horizontal','labels',features_names_selected);




%% Cluster Evaluation evalclusters() only works starting from MATLAB r2014b
% silhouette and DaviesBouldin are chosen eval criterions as they suit data
% 

eva = evalclusters(features_selected,'kmeans','silhouette','KList',[1:10]);
plot(eva)
