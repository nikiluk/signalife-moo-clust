% this file is performing clusterization of "big" neurons into the
% sub-populations and writes result to files
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
filein_features = 'inventory68-raw.xlsx'; % file containing neuron features data in cells

sheet = 1;
xlRange = 'A3:AZ143'; % AY = till Angle 17 cell
xlRange_names = 'A1:AZ1';

[features_all,~,~] = xlsread(filein_features, sheet, xlRange);
[~,features_all_names,~] = xlsread(filein_features, sheet, xlRange_names);

neuron_class=[];
neuron_members=[];
silu=[];
fs=[];

% params
class_number = 3;
iterations = 100;

%% DATA and FEATURE selection


% All
% D,D1,D2,Striking,Lambda,Area,Oblate,Prolate,Sphericity,Volume,Dendrites,Angles
%feature_range = [7 8 9 10 11 12 19 20 24 25 26 27:30];

% For big sorting
% Striking,Lambda,Oblate,Prolate,Sphericity,Dendrites
feature_range = [8 9 10 11 19 20 24 26 27:30];

% Dendrites,Angles
%feature_range = [26 27:30];

% D1,D2,Striking,Lambda,Area,Volume,Angles - not very promissing, nothing
% except size
%feature_range = [8 9 10 11 12 25 27:30];

% D1,D2,Striking,Lambda, volume
%feature_range = [8 9 10 11 19 20 25];


markerclass = features_all(:,6);
bigornot = features_all(:,31);
% find only ++ neurons
mrpositive = find((markerclass==4 | markerclass==3) & bigornot==1);

% select all(:) or positive (mrpositive)
features_selected = features_all(mrpositive,feature_range); 
features_names_selected = features_all_names(feature_range);

%% STANDARDIZE

[features_selected,gpamean,gpastdev] = zscore(features_selected, [], 1);

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
cmap = colormap(prism(5));
cmap = [237/255 125/255 49/255;91/255 155/255 213/255;165/255 165/255 165/255];
% cmap = [[15/255,48/255,39/255];[252/255,141/255,89/255];[254/255,224/255,144/255];[224/255,243/255,248/255];[145/255,191/255,219/255];[69/255,117/255,180/255]]
fg = gplotmatrix(features_selected,[],classes3,cmap,[],[],'hist')
text(coords, repmat(-.1,1,features_number), features_names_selected, 'FontSize',6);
text(repmat(-.12,1,features_number), sort(coords,'descend'), features_names_selected, 'FontSize',6, 'Rotation',90);


%% Display difference

%parallelcoords
fp = figure;
fp = parallelcoords(features_selected, 'group',classes3, 'standardize','on', 'labels',features_names_selected, 'quantile',.25,'LineWidth', 2)

%andrewsplot
fa = figure;
set(fa,'DefaultAxesColorOrder',[237/255 125/255 49/255;91/255 155/255 213/255;165/255 165/255 165/255]);
fa = andrewsplot(features_selected, 'group',classes3, 'standardize','on')


%% WRITE TO FILE
fileout_classes = 'out_classes.xlsx'; % file with classes distributed
fileout_members = 'out_members.xlsx'; % class member counted

xlswrite(fileout_classes, neuron_class, sheet);
xlswrite(fileout_members, neuron_members, sheet);

