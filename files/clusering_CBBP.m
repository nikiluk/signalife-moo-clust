% this function is performing clusterization of neurons into the
% sub-populations and writes result to files
% 
% Project name: SIGNALIFE Neuron Morphology Clustering
% Author: Nikita Lukianets
% Email: nikita.lukianets@unice.fr
% Date: 2015-03-16

function [cmembers, cnumber] = clusering_CBBP(feature_range, features_all, features_all_names, testcases,ssi,PCA)

if ~exist('testcases', 'var')
    testcases = 3;
end
if ~exist('ssi', 'var')
    ssi = 0;
end
if ~exist('PCA', 'var')
    PCA = 0;
end


addpath('SRC/exportfig');

neuron_class=[];
neuron_members=[];
silu=[];
fs=[];

% params
class_number = 5;
iterations = 1000;



%% Apical dendrites info: check where features_all(:,27) is NaN and find positive indexes
have_CBBP=isnan(features_all(:,27));
have_CBBP_index=find(have_CBBP==0);
features_all_have_CBBP = features_all(have_CBBP_index,:);

idx_have_CBBP=[cellstr(num2str(features_all_have_CBBP(:,[1]),'s%02d')) cellstr(num2str(features_all_have_CBBP(:,[2]),'i%02d')) cellstr(num2str(features_all_have_CBBP(:,[3]),'n%02d'))];
for nn=1:size(idx_have_CBBP,1)
neuron_names_have_CBBP(nn,:)=strjoin(idx_have_CBBP(nn,:),'');
end;
neuron_names_have_CBBP = cellstr(neuron_names_have_CBBP);



%% select all(:) or positive (mrpositive) or (mrnegative)
% take column 6
markerclass = features_all_have_CBBP(:,6);
% find only ++ neurons
mrpositive = find(markerclass==4);
mrnegative = find(markerclass==3);


%markerclass_selected = input('Input == or ++ or +-? [==] ','s');
switch testcases
    case 1 
        markerclass_selected = '+-';
        features_selected = features_all_have_CBBP(mrnegative,feature_range); 
        neuron_names_have_CBBP_selected = neuron_names_have_CBBP(mrnegative);
    case 2
        
        markerclass_selected = '++';
        features_selected = features_all_have_CBBP(mrpositive,feature_range); 
        neuron_names_have_CBBP_selected = neuron_names_have_CBBP(mrpositive);
    otherwise
        markerclass_selected = '==';
        features_selected = features_all_have_CBBP(:,feature_range); 
        neuron_names_have_CBBP_selected = neuron_names_have_CBBP(:);
end

features_names_selected = features_all_names(feature_range);
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
for nc=2:class_number

fprintf('CLUSTERS %d \n', nc);
[neuron_class(:,nc), cent, sumdist]=kmeans(features_selected,nc,'Distance','sqeuclidean','Display','final', 'Replicates', iterations); %Run k-means, asking for i group


%fs(nc) = figure; %figure for each cluster number i
% [silu(:,i),h(i)]=silhouette(features_selected,neuron_class(:,i),'cosine');

silu(:,nc)=silhouette(features_selected,neuron_class(:,nc),'sqeuclidean');
%coloredsilu(nc, silu(:,nc), neuron_class(:,nc));
%hold on

cluster(:,nc) = mean(silu(:,nc));

for n=1:class_number
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


fileout_classes = ['out_classes_', num2str(ssi,'%03d'),'_', num2str(nn), 'CBBP_by',features_names_selected_cropped,'_(', num2str(nn_selected), markerclass_selected, ') PCA=',num2str(PCA),' (', num2str(cnumber) , ' classes)']; % file with classes distributed
%fileout_members = ['out_members_', num2str(nn), 'CBBP_by',features_names_selected_string,'_(', num2str(nn_selected), markerclass_selected, ')', '.xlsx']; % class member counted

fileout_classes_img = [fileout_classes '.png'];
export_fig(fileout_classes_img, '-transparent');

close all;

xlswrite([fileout_classes '.xlsx'], neuron_class(:,cnumber), 1, 'B');
xlswrite([fileout_classes '.xlsx'], neuron_names_have_CBBP_selected, 1, 'A');
xlswrite([fileout_classes '.xlsx'], neuron_members([1:cnumber],cnumber), 1, 'C');
xlswrite([fileout_classes '.xlsx'], features_names_selected.', 1, 'D');

cmembers=neuron_members([1:cnumber],cnumber);
