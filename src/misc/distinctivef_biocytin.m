% plot distinctive features of marker 3 and marker 4, calculate mean,
% variance and standard deviation in biocytin neurons
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
filein_features = 'inventory-biocytin-raw-25-electrophydata.xlsx'; % file containing neuron features data in cells

sheet = 1;
xlRange = 'E3:AK33'; % BC = till Angle 16 cell
xlRange_names = 'E1:AK1';
xlRange_neuron_names = 'C3:C33';

[features_all,~,~] = xlsread(filein_features, sheet, xlRange);
[~,features_all_names,~] = xlsread(filein_features, sheet, xlRange_names);
[~,neuron_names_all,~] = xlsread(filein_features, sheet, xlRange_neuron_names); 


%% DATA and FEATURE selection

% Select only ++ neurons, 4; only +- neurons, 3 among markerclass
markerclass = features_all(:,1);
ephy1 = find(markerclass==1);
ephy2 = find(markerclass==2);
ephy3 = find(markerclass==3);

% All
% {'Diameter','Area','BoxA','BoxB','BoxC','Sphericity','Volume','CB','BP','Dendrites'}
feature_range = [5 8 11 18:19 24 27];



features_selected = features_all(:,feature_range); 

features_selected_1 = features_all(ephy1,feature_range);
features_selected_2 = features_all(ephy2,feature_range); 
features_selected_3 = features_all(ephy3,feature_range); 
features_names_selected = features_all_names(feature_range);

marker1=nonzeros(features_selected_1);
marker1(isnan(marker1)) = [];
marker2=nonzeros(features_selected_2);
marker2(isnan(marker2)) = [];
marker3=nonzeros(features_selected_3);
marker3(isnan(marker3)) = [];


%% SHOW selected features
fb = figure;
fb = boxplot(features_selected,'orientation','horizontal','labels',features_names_selected);

%% Descriptive stats
% Calculate the mean of each column
mu1 = mean(features_all(ephy1,feature_range))
% Calculate the standard deviation of each column
sigma1 = std(features_all(ephy1,feature_range))/sqrt(size(features_all(ephy1,feature_range),1))
% Calculate the mean of each column
mu2 = mean(features_all(ephy2,feature_range))
% Calculate the standard deviation of each column
sigma2 = std(features_all(ephy2,feature_range))/sqrt(size(features_all(ephy2,feature_range),1))
% Calculate the mean of each column
mu3 = mean(features_all(ephy3,feature_range))
% Calculate the standard deviation of each column
sigma3 = std(features_all(ephy3,feature_range))/sqrt(size(features_all(ephy3,feature_range),1))


tmus=[mu1; mu2; mu3];
tsigmas=[sigma1; sigma2; sigma3];
mus = transpose([mu1; mu2; mu3]);
sigmas = transpose([sigma1; sigma2; sigma3]);



w_p = []
w_h = []
tt_p = []
tt_h = []


addpath('SRC');


%% Plotly hist

% Plotly setup located in SRC folder
addpath('SRC/MATLAB-api-master');
plotlysetup('nikiluk', '5d2q793g4m')
plotlyupdate
signin('nikiluk', '5d2q793g4m')


cmap = [255 149 47;
        91 155 213;
        166 86 40;
        133 181 0;
        147 194 220;
        28 28 28;
        166 86 40];
cmap = cmap/255; 
for ss=1:size(mus,1)
ds(ss) = figure('units','pixels','outerposition',[50 50 180 600]);
ds(ss) = bar(mus(ss,:),0.8, 'FaceColor',cmap(1,:), 'EdgeColor', 'none');
set(gca,'xticklabel',{'1','2','3'})
set(ds(ss), 'FaceColor',cmap(1,:), 'EdgeColor', 'none');
title(features_names_selected(ss));

% [w_p(ss), w_h(ss)] = ranksum(features_selected_3(:,ss),features_selected_4(:,ss))
% [tt_h(ss),tt_p(ss)] = ttest2(features_selected_3(:,ss),features_selected_4(:,ss));
% 
% title([features_names_selected(ss) 'p_W=', num2str(w_p(:,ss)) 'p_T=', num2str(tt_p(:,ss))])
% 
% if w_p(:,ss) < 0.05
%    w_pstar{ss} = '*'; 
%    end
% if w_p(:,ss) < 0.01
%     w_pstar{ss} = '**'; 
%     end
% if w_p(:,ss) < 0.01
%     w_pstar{ss} = '***';
% end
% if w_p(:,ss) > 0.05
%     w_pstar{ss} = '';
% end    
hold on
ds(ss) = errorbar(mus(ss,:), sigmas(ss,:),'.');
ds(ss).LineWidth = 1;
ds(ss).Color = [0 0 0];
ds(ss).Marker = 'none';
ds(ss).AlignVertexCenters = 'on';

hold off    

% %% TESTO BARCHART
% 
% trace1 = struct(...
%   'x', { w_pstar{ss} }, ...
%   'y', mu3(ss), ...
%   'name', '+-', ...
%   'marker', struct(...
%     'color', 'rgb(148, 148, 148)', ...
%     'line', struct(...
%       'color', '#444', ...
%       'width', 0)), ...
%   'error_y', struct(...
%     'type', 'data', ...
%     'array', [sigma3(ss) sigma3(ss)], ...
%     'width', 8, ...
%     'visible', true), ...
%   'type', 'bar');
% trace2 = struct(...
%   'x', { w_pstar{ss} }, ...
%   'y', mu4(ss), ...
%   'name', '++', ...
%   'marker', struct(...
%     'color', 'rgb(94, 94, 94)', ...
%     'line', struct(...
%       'color', '#444', ...
%       'width', 0)), ...
%   'error_y', struct(...
%     'type', 'data', ...
%     'array', [sigma4(ss) sigma4(ss)], ...
%     'width', 8, ...
%     'visible', true), ...
%   'type', 'bar');
% data = {trace1, trace2};
% 
% layout = struct(...
%     'title', features_names_selected(ss), ...
%     'titlefont', struct(...
%       'family', '"Open sans", verdana, arial, sans-serif', ...
%       'size', 17, ...
%       'color', '#444'), ...
%     'font', struct(...
%       'family', '"Open sans", verdana, arial, sans-serif', ...
%       'size', 12, ...
%       'color', '#444'), ...
%     'showlegend', false, ...
%     'autosize', false, ...
%     'width', 869, ...
%     'height', 464, ...
%     'xaxis', struct(...
%       'titlefont', struct(...
%         'family', '"Open sans", verdana, arial, sans-serif', ...
%         'size', 14, ...
%         'color', '#444'), ...
%       'range', [-0.5, 0.5], ...
%       'type', 'category', ...
%       'rangemode', 'normal', ...
%       'autorange', true, ...
%       'showgrid', false, ...
%       'zeroline', false, ...
%       'showline', false, ...
%       'autotick', true, ...
%       'nticks', 0, ...
%       'ticks', '', ...
%       'showticklabels', true, ...
%       'tick0', 0, ...
%       'dtick', 1, ...
%       'tickangle', 'auto', ...
%       'tickfont', struct(...
%         'family', '"Open sans", verdana, arial, sans-serif', ...
%         'size', 18, ...
%         'color', '#444'), ...
%       'exponentformat', 'B', ...
%       'showexponent', 'all', ...
%       'gridcolor', 'white', ...
%       'gridwidth', 1), ...
%     'yaxis', struct(...
%       'titlefont', struct(...
%         'family', '"Open sans", verdana, arial, sans-serif', ...
%         'size', 14, ...
%         'color', '#444'), ...
%       'range', [0, 4.74852421053], ...
%       'type', 'linear', ...
%       'rangemode', 'normal', ...
%       'autorange', true, ...
%       'showgrid', false, ...
%       'zeroline', true, ...
%       'showline', false, ...
%       'autotick', true, ...
%       'nticks', 0, ...
%       'ticks', '', ...
%       'showticklabels', true, ...
%       'tick0', 0, ...
%       'dtick', 1, ...
%       'tickangle', 'auto', ...
%       'tickfont', struct(...
%         'family', '"Open sans", verdana, arial, sans-serif', ...
%         'size', 18, ...
%         'color', '#444'), ...
%       'exponentformat', 'B', ...
%       'showexponent', 'all', ...
%       'gridcolor', '#eee', ...
%       'gridwidth', 1, ...
%       'zerolinecolor', '#444', ...
%       'zerolinewidth', 1), ...
%     'legend', struct(...
%       'x', 1.02, ...
%       'y', 1, ...
%       'traceorder', 'normal', ...
%       'font', struct(...
%         'family', '"Open sans", verdana, arial, sans-serif', ...
%         'size', 12, ...
%         'color', '#444'), ...
%       'bgcolor', '#fff', ...
%       'bordercolor', '#444', ...
%       'borderwidth', 0), ...
%     'margin', struct(...
%       'l', 380, ...
%       'r', 380, ...
%       'b', 50, ...
%       't', 50), ...
%     'paper_bgcolor', '#fff', ...
%     'plot_bgcolor', 'rgba(0, 0, 0, 0)', ...
%     'hovermode', 'closest', ...
%     'dragmode', 'zoom', ...
%     'separators', '.,', ...
%     'barmode', 'group', ...
%     'bargap', 0.2, ...
%     'bargroupgap', 0.1, ...
%     'hidesources', false);

fileout_classes_img = ['bar_distinctivef_byocitin_(' num2str(ss) ') ' features_names_selected{ss} '.pdf'];

% response = plotly(data, struct('layout', layout, 'filename', fileout_classes_img, 'fileopt', 'new'));
% plot_url = response.url

% plotlysave = getplotlyfig('nikiluk', strrep(plot_url, 'https://plot.ly/~nikiluk/', ''));
% saveplotlyfig(plotlysave, strcat('plotly_',fileout_classes_img))



addpath('SRC/exportfig');
export_fig(fileout_classes_img, '-pdf');

close all

% sizeof3 = size(features_selected_3(:,ss),1);
% sizeof4 = size(features_selected_4(:,ss),1);
% combined34 = [features_selected_3(:,ss); features_selected_4(:,ss)].';
% indexes34 = [zeros(1,sizeof3), ones(1,sizeof4)];
% 
% bo(ss) = figure;
% bo(ss) = boxplot(combined34,indexes34 , 'notch','on', 'labels',{'+-','++'});

end;


%% Display difference

%parallelcoords
fp = figure;
set(fp,'DefaultAxesColorOrder',[237/255 125/255 49/255;91/255 155/255 213/255;165/255 165/255 165/255]);
fp = parallelcoords(features_selected, 'group',markerclass, 'standardize','on', 'labels',features_names_selected, 'quantile',.25,'LineWidth', 2)

%andrewsplot
%fa = figure;
%fa = andrewsplot(features_selected, 'group',markerclass_selected, 'standardize','on')