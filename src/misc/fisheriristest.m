clearvars
close all
clear all
clc



load fisheriris
size(species,1)
uu=[];
predicted = {};
for ii=1:size(species,1)
switch species{ii}
    case 'setosa'
        uu(ii) = 1;
    case 'versicolor'
        uu(ii) = 2;
    otherwise
        uu(ii) = 3;
end
end

[B,dev,stats] = mnrfit(meas,uu.');
B

pihat = mnrval(B,meas);

for ii=1:size(species,1) 
[mlp,mle] = max(pihat(ii,:))

switch mle
    case 1
        predicted{ii,1} = 'setosa';
    case 2
        predicted{ii,1} = 'versicolor';
    otherwise
        predicted{ii,1} = 'virginica';
end
end