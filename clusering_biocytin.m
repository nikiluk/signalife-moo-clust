%
% this file is performing clusterization of biocytin neurons into the
% sub-populations and writes result to files
%

clearvars
close all
clear all
clc


%% READ

% file containing features
filein_features = 'inventory-biocytin-raw-21.xlsx'; % file containing neuron features data in cells

sheet = 1;
xlRange = 'A3:BB36'; % BB = till Angle 17 cell
xlRange_names = 'A1:BB1';

[features_all,~,~] = xlsread(filein_features, sheet, xlRange);
[~,features_all_names,~] = xlsread(filein_features, sheet, xlRange_names);

neuron_class=[];
neuron_members=[];
silu=[];
fs=[];

% params
class_number = 5;
iterations = 100;

%% DATA and FEATURE selection


% All
% {'Diameter','D1','D2','Ramification','Striking','Lambda','Area','Oblate','Prolate','Sphericity','Volume','CB','BP','Dendrites','0-45','45-90','90-135','135-180'}
% 27 - CB and 28 - BP in um
%feature_range = [7 8 9 10 11 12 13 20 21 25 26 27 28 29 30:33];

% {'Ramification','Striking','Lambda','Area','Oblate','Prolate','Sphericity','Volume','CB','BP','Dendrites','0-45','45-90','90-135','135-180'}
% 27 - CB and 28 - BP in um
% results in 4 classes among all with characteristic
%feature_range = [10 11 12 13 20 21 25 26 27 28 29 30:33];

% {'Ramification','Area','Oblate','Prolate','Sphericity','Volume','0-45','45-90','90-135','135-180'}
% 27 - CB and 28 - BP in um
% results in 2 classes among all (:)
%feature_range = [10 13 20 21 25 26 30:33];

% {'Ramification','','Oblate','','','Volume','0-45','45-90','90-135','135-180'}
% 27 - CB and 28 - BP in um
% results in 2 classes among all (:)
feature_range = [10 20 26];

% {'Ramification','CB'}
% 27 - CB and 28 - BP in um
% results in 4 classes among all
%feature_range = [10 27];

% All
% D,D1,D2,Striking,Lambda,Area,Oblate,Prolate,Sphericity,Volume,Dendrites,Angles
%feature_range = [7 8 9 10 11 12 19 20 24 25 26 27:30];

% Dendrites,Angles
%feature_range = [26 27:30];

% D1,D2,Striking,Lambda,Area,Volume,Angles - not very promissing, nothing
% except size
%feature_range = [8 9 10 11 12 25 27:30];

% D1,D2,Striking,Lambda, volume
%feature_range = [8 9 10 11 19 20 25];

% % take column 6
% markerclass = features_all(:,6);
% % find only ++ neurons
% mrpositive = find(markerclass==4);
% 
% % Apical dendrites info: check where features_all(:,27) is NaN and find positive indexes
% have_CBBP=isnan(features_all(:,27));
% have_CBBP_index=find(have_CBBP==0);

% select all(:) or positive (mrpositive)
features_selected = features_all(:,feature_range); 
features_names_selected = features_all_names(feature_range);



%% STANDARDIZE

[features_selected,gpamean,gpastdev] = zscore(features_selected, [], 1);

%% PCA
% shtukers - poglyadim na kolichestvo komponentov
shtukers = [];
[coeff,score,latent,tsquared] = pca(features_selected);
shtukers = cumsum(latent)./sum(latent);
 
 
%% SHOW selected features
fb = figure;
fb = boxplot(features_selected,'orientation','horizontal','labels',features_names_selected);

%% CLUSTERING
for nc=2:class_number

fprintf('CLUSTERS %d \n', nc);
[neuron_class(:,nc), cent, sumdist]=kmeans(features_selected,nc,'Distance','sqeuclidean','Display','final', 'Replicates', iterations); %Run k-means, asking for i group


fs(nc) = figure; %figure for each cluster number i
% [silu(:,i),h(i)]=silhouette(features_selected,neuron_class(:,i),'cosine');

silu(:,nc)=silhouette(features_selected,neuron_class(:,nc),'sqeuclidean');
coloredsilu(nc, silu(:,nc), neuron_class(:,nc));
hold on

cluster(:,nc) = mean(silu(:,nc));

for n=1:class_number
neuron_members(n,nc)=sum(neuron_class(:,nc) == n); %Calc #of cells in each class
end;
hold off

end;

%% DEFINE OPTIMAL CLUSTER NUMBER cnumber
fn = figure;
fn = plot(cluster,'g','LineWidth',2,'MarkerSize',10);
xlabel('Cluster') % x-axis label
ylabel('Mean Silhouette Profile') % y-axis label
[cvalue,cnumber] = max(cluster)


%% Cross-correlated data

classes3=neuron_class(:,cnumber);
features_number = length(features_names_selected);
coords = [];
coords_step = 1/features_number;
for cc=1:features_number
coords = [coords (cc-1)*coords_step];
end

fg = figure;
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


fg = gplotmatrix(features_selected,[],classes3,cmap,[],[],'hist')
hh = findobj(gca,'Type','patch');
text(coords, repmat(-.1,1,features_number), features_names_selected, 'FontSize',6);
text(repmat(-.12,1,features_number), sort(coords,'descend'), features_names_selected, 'FontSize',6, 'Rotation',90);


%% Display difference

%parallelcoords
fp = figure;
set(fp,'DefaultAxesColorOrder',cmap);
fp = parallelcoords(features_selected, 'group',classes3, 'standardize','on', 'labels',features_names_selected, 'quantile',.25,'LineWidth', 2)

%andrewsplot
fa = figure;
fa = andrewsplot(features_selected, 'group',classes3, 'standardize','on')


%% WRITE TO FILE
fileout_classes = 'out_classes.xlsx'; % file with classes distributed
fileout_members = 'out_members.xlsx'; % class member counted

xlswrite(fileout_classes, neuron_class, sheet);
xlswrite(fileout_members, neuron_members, sheet);

