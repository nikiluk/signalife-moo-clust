% this file is building the graph of dendrites distribution distinguishing
% satb2+ and satb2- populations
% 
% Project name: SIGNALIFE Neuron Morphology Clustering
% Author: Nikita Lukianets
% Email: nikita.lukianets@unice.fr
% Date: 2015-03-16

clearvars
close all
clear all
clc

% file containing features
filein_features = 'inventory83-raw-matching-percetage.xlsx'; % file containing neuron features data in cells

sheet = 1;
xlRange = 'A3:BB147'; % BB = till Angle 17 cell
xlRange_names = 'A1:BB1';

[features_all,~,~] = xlsread(filein_features, sheet, xlRange);
[~,features_all_names,~] = xlsread(filein_features, sheet, xlRange_names);

%% DATA and FEATURE selection
% selecting Ramification range - similar
%feature_range = [10]; 
% selecting Ramification range - similar
%feature_range = [10]; 
% selecting D1-D2 range - similar
feature_range = [28]; 
% selecting Diameter range - different
%feature_range = [7]; 
% selecting Dendrites range - different
%feature_range = [29]; 

% Apical dendrites info: check where features_all(:,27) is NaN and find positive indexes
have_CBBP=isnan(features_all(:,27));
have_CBBP_index=find(have_CBBP==0);
features_all_have_CBBP = features_all(have_CBBP_index,:);

% Select only ++ neurons, 4; only +- neurons, 3 among markerclass
markerclass = features_all_have_CBBP(:,6);
mrpositive = find(markerclass==4);
mrnegative = find(markerclass==3);

features_selected_4 = features_all_have_CBBP(mrpositive,feature_range);
features_selected_3 = features_all_have_CBBP(mrnegative,feature_range); 
features_names_selected = features_all_names(feature_range);

marker4=nonzeros(features_selected_4);
marker4(isnan(marker4)) = [];

marker3=nonzeros(features_selected_3);
marker3(isnan(marker3)) = [];
%marker3 = -1*marker3; %for the sake of simplicity


%% Plotly hist

% % Plotly setup located in SRC folder
% cd SRC/MATLAB-api-master
% plotlysetup('nikiluk', '5d2q793g4m')
% plotlyupdate
% signin('nikiluk', '5d2q793g4m')
% 
% 
% 
% 
% 
% 
% 
% 
% hist_trace3 = struct(...
%   'x', marker3, ...
%   'histnorm', 'probability', ...
%   'name', '+-', ...
%   'nbinsx', 45, ...
%   'xbins', struct(...
%     'start', 35, ...
%     'end', 180, ...
%     'size', 5), ...
%   'error_y', struct(...
%     'color', 'rgb(0, 0, 0)', ...
%     'thickness', 0.5, ...
%     'visible', true), ...
%   'marker', struct(...
%     'color', 'rgb(255, 127, 14)', ...
%     'line', struct(...
%       'color', 'rgb(255, 255, 255)', ...
%       'width', 0.5)), ...
%   'opacity', 0.75, ...
%   'type', 'histogram');
% hist_trace4 = struct(...
%   'x', marker4, ...
%   'histnorm', 'probability', ...
%   'name', '++', ...
%   'nbinsx', 45, ...
%   'xbins', struct(...
%     'start', 25, ...
%     'end', 180, ...
%     'size', 5), ...
%   'error_y', struct(...
%     'color', 'rgb(0, 0, 0)', ...
%     'thickness', 0.5, ...
%     'visible', true), ...
%   'marker', struct(...
%     'color', 'rgb(31, 119, 180)', ...
%     'line', struct(...
%       'color', 'rgb(255, 255, 255)', ...
%       'width', 0.5)), ...
%   'opacity', 0.75, ...
%   'type', 'histogram');
% hist_data = {hist_trace3, hist_trace4};
% hist_layout = struct(...
%     'title', strcat(hist_trace4.type,'-',features_names_selected(1,1),'-',filein_features), ...
%     'barmode', 'overlay');
% 
% hist_response = plotly(hist_data, struct('layout', hist_layout, 'filename',hist_layout.title, 'fileopt', 'new'));
% hist_plot_url = hist_response.url
% 
% 
% 
% 
% 
% 
% 
% 
% box_trace3 = struct(...
%   'x', marker3, ...
%   'name', '+-', ...
%   'line', struct('color', 'rgb(255, 127, 14)'), ...
%   'type', 'box');
% box_trace4 = struct(...
%   'x', marker4, ...
%   'name', '++', ...
%   'line', struct('color', 'rgb(31, 119, 180)'), ...
%   'type', 'box');
% box_data = {box_trace3, box_trace4};
% box_layout = struct(...
%     'title', strcat(box_trace4.type,'-',features_names_selected(1,1),'-',filein_features));
% 
% box_response = plotly(box_data, struct('layout', box_layout, 'filename', box_layout.title, 'fileopt', 'new'));
% box_plot_url = box_response.url
% 
% 
% 
% 
% 
% % Come back from SRC/Plotly folder
% cd ../..

%% Wilcoxon rank sum test
% Tests the null hypothesis that data in marker3 and marker4 are samples 
% from continuous distributions with equal medians, against the 
% alternative that they are not. marker3 and marker4 can have different lengths.
% The test assumes that the two samples are independent. 
% The result h = 1 indicates a rejection of the null hypothesis, 
% and h = 0 indicates a failure to reject the null hypothesis 
% at the 5% significance level.
[w_p, w_h, w_stats] = ranksum(marker3,marker4)

%% Mann-Whitney-Wilcoxon
% This file executes the non parametric Mann-Whitney-Wilcoxon test to...
%     evaluate the difference between unpaired samples. If the number...
%     of combinations is less than 20000, the algorithm calculate the...
%     exact ranks distribution; else it uses a normal distribution ...
%     approximation. The result is not different from 
% RANKSUM MatLab function, but there are more output informations...
% There is an alternative formulation of this test that yields a...
%    statistic commonly denoted by U. Also the U statistic is computed.

mww_stats=mwwtest(marker3,marker4);
mww_p = mww_stats.p*2;


% hist(asdsdn,groups);
% u = findobj(gca,'Type','patch');
% set(u,'FaceColor',color,'EdgeColor',color);

%% Wilcoxon RESULT
disp('Wilcoxon: '); 
if (w_h==1)
w_simtxt = [features_names_selected,' is DIFFERENT, p=',num2str(w_p)];  
disp(w_simtxt);
else
w_diftxt = [features_names_selected,' is SIMILAR, p=',num2str(w_p)];    
    disp(w_diftxt);
end   

%% ttest
[tt_h,tt_p,tt_ci,tt_stats] = ttest2(marker3,marker4);

%% Two-sample t-test RESULT
disp('--------------------------------------------------------------------------------');
disp('Two-sample t-test: '); 
if (tt_h==1)
disp([features_names_selected,' is DIFFERENT, p=',num2str(tt_p)]);
else
    disp([features_names_selected,' is SIMILAR, p=',num2str(tt_p)]);
end  

