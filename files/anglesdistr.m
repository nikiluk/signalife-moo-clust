%
% this file is building the graph of angle distribution 
%

clearvars
close all
clear all
clc

% file containing features
filein_features = 'inventory67-raw.xlsx'; % file containing neuron features data in cells

sheet = 1;
xlRange = 'AI3:BB143';
[angles_all,~,~] = xlsread(filein_features, sheet, xlRange);
asdsd=nonzeros(angles_all);
asdsd(isnan(asdsd)) = [];
asdsdn=[asdsd];


%% PLOT ANGLES
groups = 8;
color = [255/255 149/255 47/255];

h=rose(degtorad(asdsdn),2*groups);
x = get(h,'Xdata');
y = get(h,'Ydata');
g=patch(x,y,color);


% hist(asdsdn,groups);
% u = findobj(gca,'Type','patch');
% set(u,'FaceColor',color,'EdgeColor',color);


xlabel('Angles') % x-axis label
