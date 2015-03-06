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
filein_features = 'inventory-biocytin-raw-37-layerdepth.xlsx'; % file containing neuron features data in cells

sheet = 1;
xlRange = 'E3:AK33'; % AQ angles grouped
xlRange_names = 'E1:AK1';
xlRange_neuron_names = 'C3:C33';

[features_all,~,~] = xlsread(filein_features, sheet, xlRange);
[~,features_names_all,~] = xlsread(filein_features, sheet, xlRange_names);
[~,neuron_names_all,~] = xlsread(filein_features, sheet, xlRange_neuron_names); 


%% FEATURE SELECTION

% All
% {'Diameter','D1','D2','Ramification','Striking','Lambda','Area','Oblate','Prolate','Sphericity','Volume','CB','BP','Dendrites','0-45','45-90','90-135','135-180'}
% 27 - CB and 28 - BP in um

feature_range = [10 20 25 33 30 31];


testcases = 3; % default case that tests ++ +- and == CTIP2/SATB2
ssi = 905; % parameter that affects the filname of the output
PCA = 0; % 0-not use Principal Components; 1-use Principal Components

addpath('SRC/exportfig');

neuron_class=[];
neuron_members=[];
silu=[];
fs=[];

% params
max_clusters = 4;
iterations = 1000;



%% Apical dendrites info: check where features_all(:,25) is NaN and find positive indexes
% have_CBBP=isnan(features_all(:,25));
% have_CBBP_index=find(have_CBBP==0);
% features_all_have_CBBP = features_all(have_CBBP_index,:);
% 
% 
% 
% idx_have_CBBP=[cellstr(num2str(features_all_have_CBBP(:,[1]),'s%02d')) cellstr(num2str(features_all_have_CBBP(:,[2]),'i%02d')) cellstr(num2str(features_all_have_CBBP(:,[3]),'n%02d'))];
% for nn=1:size(idx_have_CBBP,1)
% neuron_names_have_CBBP(nn,:)=strjoin(idx_have_CBBP(nn,:),'');
% end;
% neuron_names_have_CBBP = cellstr(neuron_names_have_CBBP);

nn = size(features_all,1);

%% select all(:) or positive (mrpositive) or (mrnegative)
% take column 6
%markerclass = features_all_have_CBBP(:,6);
markerclass = features_all(:,4);
% find only ++ neurons
mrpositive = find(markerclass==4);
mrnegative = find(markerclass==3);


%markerclass_selected = input('Input == or ++ or +-? [==] ','s');
switch testcases
    case 1 
        markerclass_selected = '+-';
        features_selected = features_all(mrnegative,feature_range); 
       neuron_names_selected = neuron_names_all(mrnegative);
    case 2
        
        markerclass_selected = '++';
        features_selected = features_all(mrpositive,feature_range); 
        neuron_names_selected = neuron_names_all(mrpositive);
    otherwise
        markerclass_selected = '==';
        features_selected = features_all(:,feature_range); 
        neuron_names_selected = neuron_names_all(:);
end

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
features_selected = score;
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
fp = parallelcoords(features_selected, 'group',optimalClustering, 'standardize','on', 'labels',features_names_selected, 'quantile',.75,'LineWidth', 2);
ylim([-2.5 2.5])

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
fileout_classes = [resFolder,'/out_classes_', num2str(ssi,'%03d'),'_', num2str(nn), 'Biocytin_by',features_names_selected_cropped,'_(', num2str(nn_selected), markerclass_selected, ') PCA=',num2str(PCA),' (', num2str(cnumber) , ' classes)']; % file with classes distributed

%output PDF figure with parallel plot
export_fig([fileout_classes '.pdf'], '-pdf');


xlswrite([fileout_classes '.xlsx'], neuron_class(:,cnumber), 1, 'B');
xlswrite([fileout_classes '.xlsx'], neuron_names_selected, 1, 'A');
xlswrite([fileout_classes '.xlsx'], neuron_members([1:cnumber],cnumber), 1, 'C');
xlswrite([fileout_classes '.xlsx'], features_names_selected.', 1, 'D');
close all
cmembers=neuron_members([1:cnumber],cnumber);

