%
% this file is performing clusterization of neurons into the
% sub-populations and writes result to files
%

clearvars
close all
clear all
clc

%% READ

% file containing features
filein_features = 'inventory-biocytin-electrophy-raw-4.xlsx'; % file containing neuron electrophy features data in cells

sheet = 1;
xlRange = 'B2:AA34';
xlRange_names = 'B1:AA1';
xlRange_neuron_names = 'A2:A34';

[features_all,~,~] = xlsread(filein_features, sheet, xlRange);
[~,features_names_all,~] = xlsread(filein_features, sheet, xlRange_names);
[~,neuron_names_all,~] = xlsread(filein_features, sheet, xlRange_neuron_names); 

addpath('SRC/exportfig');
%% FEATURE SELECTION

feature_range = [1 2 8 9:13 20:26];

%% PARAMS
max_clusters = 4;
iterations = 100;
testcases = 3; % default case that tests ++ +- and == CTIP2/SATB2
ssi = 0; % parameter that affects the filname of the output
PCA = 0; % 0-not use Principal Components; 1-use Principal Components



neuron_class=[];
neuron_members=[];
silu=[];
fs=[];





nn = size(features_all,1);

features_selected = features_all(:,feature_range); 
neuron_names_selected = neuron_names_all(:);
features_names_selected = features_names_all(feature_range);
nn_selected=size(features_selected,1);


%% STANDARDIZE

[features_selected,gpamean,gpastdev] = zscore(features_selected, [], 1);

%% PCA
% shtukers - poglyadim na kolichestvo komponentov

%PCA = input('Do you want to use PCA? (1=yes, 0=no) [0] ');
if (PCA==1)
shtukers = [];
[coeff,score,latent,tsquared] = pca(features_selected);
shtukers = cumsum(latent)./sum(latent);
features_selected = score(:, 1:10);
features_names_selected = {'PC1','PC2','PC3','PC4','PC5','PC6','PC7','PC8','PC9','PC10'};
else
PCA = 0;
end; 
 
%% SHOW selected features
%fb = figure;
%fb = boxplot(features_selected,'orientation','horizontal','labels',features_names_selected);

%% CLUSTERING
for nc=2:max_clusters

fprintf('CLUSTERS %d \n', nc);
[neuron_class(:,nc), cent, sumdist]=kmeans(features_selected,nc,'Distance','sqeuclidean','Display','final', 'Replicates', iterations); %Run k-means, asking for i group


%fs(nc) = figure; %figure for each cluster number i
% [silu(:,i),h(i)]=silhouette(features_selected,neuron_class(:,i),'cosine');

silu(:,nc)=silhouette(features_selected,neuron_class(:,nc),'sqeuclidean');
%coloredsilu(nc, silu(:,nc), neuron_class(:,nc));
%hold on

cluster(:,nc) = mean(silu(:,nc));

for n=1:max_clusters
neuron_members(n,nc)=sum(neuron_class(:,nc) == n); %Calc #of cells in each class
end;
%hold off

end;

%% DEFINE OPTIMAL CLUSTER NUMBER cnumber
% fn = figure;
% fn = plot(cluster,'g','LineWidth',2,'MarkerSize',10);
% xlabel('Cluster') % x-axis label
% ylabel('Mean Silhouette Profile') % y-axis label
[cvalue,cnumber] = max(cluster);


%% Cross-correlated data

optimalClustering=neuron_class(:,cnumber);
features_number = length(features_names_selected);
coords = [];
coords_step = 1/features_number;
for cc=1:features_number
coords = [coords (cc-1)*coords_step];
end

%fg = figure('units','normalized','outerposition',[0 0 1 1]);
cmap = [255 149 47;
        91 155 213;
        166 86 40;
        133 181 0;
        147 194 220;
        28 28 28;
        166 86 40];


cmap = cmap/255;    
%cmap = colormap(prism(5));
% cmap = [[15/255,48/255,39/255];[252/255,141/255,89/255];[254/255,224/255,144/255];[224/255,243/255,248/255];[145/255,191/255,219/255];[69/255,117/255,180/255]]


%fg = gplotmatrix(features_selected,[],optimalClustering,cmap,[],[],'hist');
%hh = findobj(gca,'Type','patch');
%text(coords, repmat(-.1,1,features_number), features_names_selected, 'FontSize',6);
%text(repmat(-.12,1,features_number), sort(coords,'descend'), features_names_selected, 'FontSize',6, 'Rotation',90);


%% Display difference

%parallelcoords
fp = figure('units','normalized','outerposition',[0 0 1 1]);
set(fp,'DefaultAxesColorOrder',cmap);
fp = parallelcoords(features_selected, 'group',optimalClustering, 'standardize','on', 'labels',features_names_selected, 'quantile',.25,'LineWidth', 2);
a = gca;
a.XTickLabelRotation=45;



% %andrewsplot
% fa = figure;
% set(fa,'DefaultAxesColorOrder',cmap);
% fa = andrewsplot(features_selected, 'group',optimalClustering, 'standardize','on','quantile',.25);


%% WRITE TO FILE
%adjusting comments in the filename
features_names_selected_string = strjoin(features_names_selected,'-');
features_names_selected_cropped = [];
for cr=1:size(features_names_selected,2)
features_names_selected_cropped = [features_names_selected_cropped, '-', features_names_selected{cr}(1:min(4, length(features_names_selected{cr})))];
end;

% output to results folder
resFolder=['res-' datestr(now,'yyyy-mm-dd')];
mkdir(resFolder);
fileout_classes = [resFolder,'/out_classes_', num2str(ssi,'%03d'),'_', num2str(nn), 'Biocytin_electrophy_by',features_names_selected_cropped,'_(', num2str(nn_selected), ') PCA=',num2str(PCA),' (', num2str(cnumber) , ' classes)']; % file with classes distributed

%output PDF figure with parallel plot
export_fig([fileout_classes '.pdf'], '-pdf');


xlswrite([fileout_classes '.xlsx'], neuron_class(:,cnumber), 1, 'B');
xlswrite([fileout_classes '.xlsx'], neuron_names_selected, 1, 'A');
xlswrite([fileout_classes '.xlsx'], neuron_members([1:cnumber],cnumber), 1, 'C');
xlswrite([fileout_classes '.xlsx'], features_names_selected.', 1, 'D');

cmembers=neuron_members([1:cnumber],cnumber);

