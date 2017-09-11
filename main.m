dirt = dir('C:\Users\Lenovo\Documents\MATLAB\CV\Skin');
skin = [0 0 0];
for i = 4:504
disp(i);
img  = imread(dirt(i).name);
r = img(:,:,1); g = img(:,:,2); b = img(:,:,3); 
ind = find( ((r<250)&(g<250)&(b<250))==1 );
% figure; imshow(img);
% figure; plot(row,col,'*');
% skin = [skin; [r(ind) g(ind) b(ind)]];
skin = cat(1, skin, [r(ind) g(ind) b(ind)]);
end; skin(1,:)=[]; clear r g b ind i img;
save('setOne_4-504.mat','skin');

%% Obtaining the best fit
nComp = [10 20 30];
nSkinValues = 10000;
gm = cell(1,size(nComp,2));
randInd = randi(size(skin,1),[nSkinValues,1]);
aic = zeros(1,size(nComp,2));
bic = zeros(1,size(nComp,2));
for i=1:size(nComp,2)
gm{1,i}=...
fitgmdist(double(skin(randInd,:)),nComp(i),'Options', statset('Display','iter','MaxIter',1000)); 
aic(i) = gm{1,i}.AIC;
bic(i) = gm{1,i}.BIC;
end
    
%% Code for GMModel fitting
skin = double(skin);
GMModel = fitgmdist(skin(1:5000000,:),10,'Options', statset('Display','iter','MaxIter',1000)); 

mu=GMModel.mu;
sigma=GMModel.Sigma;
pcomponents=GMModel.PComponents;

S=struct('mu',mu,'Sigma',sigma,'ComponentProportion',pcomponents);
GMModel_new=fitgmdist(skin(5000000:10000000,:),10,'Start',S,'Options',statset('Display','iter','MaxIter',1000));

mu=GMModel_new.mu;
sigma=GMModel_new.Sigma;
pcomponents=GMModel_new.PComponents;

S=struct('mu',mu,'Sigma',sigma,'ComponentProportion',pcomponents);
GMModel_new1=fitgmdist(skin(10000000:15000000,:),10,'Start',S,'Options',statset('Display','iter','MaxIter',1000));
