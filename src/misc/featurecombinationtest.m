% Generate all possible test cases in the loop
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
MySet = {7 10 11 12 13 20 25 29};
definite = [26 27 28];
angles = [30 31 32 33];
for wordlength=1:size(MySet,2)

MySetperms = combinator(length(MySet),wordlength,'c'); % Take 3 at a time.
MySetperms = MySet(MySetperms);
featuresets = [];
if wordlength==1
MySetperms =   MySetperms.';  
end    
for combinations=1:size(MySetperms,1)

featuresets(combinations,:) = [cell2mat(MySetperms(combinations,:)) definite];
feature_range = sort(featuresets(combinations,:))
end
end