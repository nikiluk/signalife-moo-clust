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
filein_features = 'inventory83-raw-matching-percetage.xlsx'; % file containing neuron features data in cells

sheet = 1;
xlRange = 'A3:BB147'; % BB = till Angle 17 cell
xlRange_names = 'A1:BB1';

[features_all,~,~] = xlsread(filein_features, sheet, xlRange);
[~,features_all_names,~] = xlsread(filein_features, sheet, xlRange_names);

%% FEATURE SELECTION

% Diameter
% Ramification
% Area
% Oblate
% Sphericity
% Volume
% Bifurction
% Depth
% Dendrites
feature_range = [7 10 13 20 25 26 27 28 29];

testcases = 1;
ssi = 224;
PCA = 0;

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

%% PARALLELPLOT

%parallelcoords
fp = figure('units','normalized','outerposition',[0 0 1 1]);
set(fp,'DefaultAxesColorOrder',cmap);
fp = parallelcoords(features_selected, 'group',optimalClustering, 'standardize','on', 'labels',features_names_selected, 'quantile',.25,'LineWidth', 2);
ylim([-2.5 2.5])

% %andrewsplot
% fa = figure;
% set(fa,'DefaultAxesColorOrder',cmap);
% fa = andrewsplot(features_selected, 'group',optimalClustering, 'standardize','on','quantile',.25);

%% BOXPLOT

% fbp1 = figure('units','pixels','outerposition',[50 50 1100 500]);
% boxplot(features_selected(find(optimalClustering == 1),:),'labels',features_names_selected,'whisker',3,'boxstyle', 'outline','colors',[1 0 0],'widths',0.1);
% ylim([-3 3])
% fbp2 = figure('units','pixels','outerposition',[50 50 1100 500]);
% boxplot(features_selected(find(optimalClustering == 2),:),'labels',features_names_selected,'whisker',3,'boxstyle', 'outline','colors',[0 0 1],'widths',0.1);
% ylim([-3 3])
% if testcases==2
% fbp3 = figure('units','pixels','outerposition',[50 50 1100 500]);
% boxplot(features_selected(find(optimalClustering == 3),:),'labels',features_names_selected,'whisker',3,'boxstyle', 'outline','colors',[0 1 0],'widths',0.1); 
% ylim([-3 3])
% end

% %% BARPLOT for each of the 3 clusters 
% 
% 
% addpath('SRC');
% 
% 
% mu1 = mean(features_selected(find(optimalClustering == 1),:));
% number1 = size(features_selected(find(optimalClustering == 1),:), 1);
% sem1 = std(features_selected(find(optimalClustering == 1),:))/sqrt(number1);
% fba1 = figure('units','pixels','outerposition',[50 50 1400 500]);
% bar(mu1, 0.2, 'FaceColor',cmap(1,:), 'EdgeColor', 'none');
% set(gca,'xticklabel',features_names_selected);
% ylim([-3 3])
% hold on
% fba1 = errorbar(mu1, sem1, '.');
% fba1.LineWidth = 1;
% fba1.Color = [0 0 0];
% fba1.Marker = 'none';
% fba1_img = [num2str(testcases) '-1' '.pdf'];
% export_fig(fba1_img, '-pdf');
% 
% mu2 = mean(features_selected(find(optimalClustering == 2),:));
% number2 = size(features_selected(find(optimalClustering == 2),:), 1);
% sem2 = std(features_selected(find(optimalClustering == 2),:))/sqrt(number2);
% fba2 = figure('units','pixels','outerposition',[50 50 1400 500]);
% bar(mu2, 0.2, 'FaceColor',cmap(2,:), 'EdgeColor', 'none');
% set(gca,'xticklabel',features_names_selected);
% ylim([-3 3])
% hold on
% fba2 = errorbar(mu2, sem2, '.');
% fba2.LineWidth = 1;
% fba2.Color = [0 0 0];
% fba2.Marker = 'none';
% fba2_img = [num2str(testcases) '-2' '.pdf'];
% export_fig(fba2_img, '-pdf');
% 
% if testcases==2
% % just adding this case for ++, when we have 3 clusters    
% mu3 = mean(features_selected(find(optimalClustering == 3),:));
% number3 = size(features_selected(find(optimalClustering == 3),:), 1);
% sem3 = std(features_selected(find(optimalClustering == 3),:))/sqrt(number3);
% fba3 = figure('units','pixels','outerposition',[50 50 1400 500]);
% bar(mu3, 0.2, 'FaceColor',cmap(3,:), 'EdgeColor', 'none');
% set(gca,'xticklabel',features_names_selected);
% ylim([-3 3])
% hold on
% fba3 = errorbar(mu3, sem3, '.');
% fba3.LineWidth = 1;
% fba3.Color = [0 0 0];
% fba3.Marker = 'none';
% fba3_img = [num2str(testcases) '-3' '.pdf'];
% export_fig(fba3_img, '-pdf');
% 
% end
    
%% WRITE TO FILE
%adjusting comments in the filename
features_names_selected_string = strjoin(features_names_selected,'-');
features_names_selected_cropped = [];
for cr=1:size(features_names_selected,2)
features_names_selected_cropped = [features_names_selected_cropped, '-', features_names_selected{cr}(1:min(4, length(features_names_selected{cr})))];
end;


fileout_classes = ['out_classes_', num2str(ssi,'%03d'),'_', num2str(nn), 'CBBP_by',features_names_selected_cropped,'_(', num2str(nn_selected), markerclass_selected, ') PCA=',num2str(PCA),' (', num2str(cnumber) , ' classes)']; % file with classes distributed
%fileout_members = ['out_members_', num2str(nn), 'CBBP_by',features_names_selected_string,'_(', num2str(nn_selected), markerclass_selected, ')', '.xlsx']; % class member counted

fileout_classes_img = [fileout_classes '.pdf'];
export_fig(fileout_classes_img, '-pdf');


xlswrite([fileout_classes '.xlsx'], neuron_class(:,cnumber), 1, 'B');
xlswrite([fileout_classes '.xlsx'], neuron_names_have_CBBP_selected, 1, 'A');
xlswrite([fileout_classes '.xlsx'], neuron_members([1:cnumber],cnumber), 1, 'C');
xlswrite([fileout_classes '.xlsx'], features_names_selected.', 1, 'D');

cmembers=neuron_members([1:cnumber],cnumber);

