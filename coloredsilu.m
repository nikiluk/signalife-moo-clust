%
% this function helps to draw colored silhouette for clusters
%

function coloredsilu(k, silh, idx)


colrmap = colormap(jet);
nc = size(colrmap,1);
colridx = max(floor((silh+.2)/1.2*(nc-1))+1, 1);
barcolors = colrmap(colridx,:);

% make the silhouette plot -- this code is modified from silhouette.m
cnames = num2str((1:k)');
barcolors = reshape(barcolors,[length(idx) 1 3]);
space = max(floor(.02*length(idx)), 2);
bars = NaN(space,1);
colors = NaN([space,1,3]);
% obsnum = repmat(NaN,space,1);
for i = 1:k
     thisgroup = find(idx==i);
     [sorted,ord] = sort(silh(thisgroup),'descend');
     bars = [bars; sorted; NaN(space,1)];
%     colors = [colors; barcolors(thisgroup(ord),:,:); NaN([space,1,3])];
colors=[91/255 155/255 213/255];
%      obsnum = [obsnum; thisgroup(ord); repmat(NaN,space,1)];
     tcks(i) = length(bars);
end
tcks = tcks - 0.5*(diff([space tcks]) + space - 1);
barsh = barh(bars, 1.0);
set(get(barsh,'child'),'FaceColor',colors,'CData',colors);
set(gca, 'Xlim',[-Inf 1.1], 'Ylim',[1 length(bars)], 'YDir','reverse','YTick',tcks, 'YTickLabel',cnames);
xlabel('Silhouette Value');
ylabel('Cluster');

% now plot the observation numbers
y = (1:length(bars));
x = bars;
% text(x,y,num2str(obsnum));