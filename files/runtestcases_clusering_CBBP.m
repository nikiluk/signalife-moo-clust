% Run all possible test cases in the loop
% 
% Project name: SIGNALIFE Neuron Morphology Clustering
% Author: Nikita Lukianets
% Email: nikita.lukianets@unice.fr
% Date: 2015-03-16

clearvars
close all
clear all
clc

addpath('SRC/combinator');

%% READ

% file containing features
filein_features = 'inventory83-raw-matching-percetage.xlsx'; % file containing neuron features data in cells

sheet = 1;
xlRange = 'A3:BB147'; % BB = till Angle 17 cell
xlRange_names = 'A1:BB1';

[features_all,~,~] = xlsread(filein_features, sheet, xlRange);
[~,features_all_names,~] = xlsread(filein_features, sheet, xlRange_names);

%% DATA and FEATURE selection

PCA=0;
MySet = {7 10 11 12 13 20 25 29};
definite = [26 27 28];
angles = [30 31 32 33];


% All
% {'Diameter','D1','D2','Ramification','Striking','Lambda','Area','Oblate','Prolate','Sphericity','Volume','CB','BP','Dendrites','0-45','45-90','90-135','135-180'}
% 27 - CB and 28 - BP in um
%feature_range = [7 8 9 10 11 12 13 20 21 25 26 27 28 29 30:33];

% Possible
% {'Diameter','D1','D2','Ramification','Striking','Lambda','Area','Oblate','Prolate','Sphericity','Volume','CB','BP','Dendrites','0-45','45-90','90-135','135-180'}
% 27 - CB and 28 - BP in um
%feature_range = [7 10 11 12 13 20 25 26 27 28 29 30:33];

% Distinctive only
% {'Diameter','Volume','BC-Proportion','Depth','Dendrites'}
%feature_range = [13 20 25 26 27 28];

% All
% {'Diameter','Ramification','Area','Oblate','Sphericity','Volume','Bifurcation','Depth','Dendrites'}
%feature_range = [7 10 13 20 25 26 27 28 29];

% Distinctive only
% 'Volume','BC-Proportion','Depth'
%feature_range = [10 25 26 27 28];

%% running
superstats = {}; % construct cell with stats about each clustering
ssi = 0; %superstats horizontal index of all possible combinations

for wordlength=1:size(MySet,2)
    MySetperms = combinator(length(MySet),wordlength,'c'); % Take 3 at a time.
    MySetperms = MySet(MySetperms);
    featuresets = [];
    if wordlength==1
    MySetperms =   MySet.';  
    end    
    for combinations=1:size(MySetperms,1)
        featuresets(combinations,:) = [cell2mat(MySetperms(combinations,:)) definite];
        feature_range = sort(featuresets(combinations,:))
        
        ssi = 1+ssi; % setting superstats index to 1 for the first run, then increase for each new combination in cycle
        % testcases loop tu cluster ++ +- ==
        for testcases=1:3           
        [cmembers, cnumber] = clusering_CBBP(feature_range, features_all, features_all_names, testcases, ssi, PCA);
        
        % making notes on what features are used
        feature_all_range = sort([cell2mat(MySet) definite]);
        [features_all_names_notselected,ia] = setdiff(feature_all_range,feature_range);
        features_index = ones(1,size(feature_all_range,2));
        features_index(ia) = 0;
 
        for iaa=1:size(feature_all_range,2)     
            superstats{6+iaa,ssi} = features_index(iaa);
        end
        % adding numbers
        superstats{testcases,ssi} = cnumber;
        superstats{testcases+3,ssi} = cmembers;
        for ff=1:size(feature_range,2)
        superstats{ff+6+size(feature_all_range,2),ssi} = features_all_names(feature_range(ff));
        end
        
        end
    end
end