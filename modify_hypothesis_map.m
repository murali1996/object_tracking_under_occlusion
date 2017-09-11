function [out_s] = modify_hypothesis_map(orgImg,inp_s,gmm)
%% Init
s = inp_s{2};
[row,col,d]=size(orgImg);

%% Simple thresholding
y=double( reshape(orgImg,row*col,d) );
pos=pdf(gmm,y);
pos(pos >=3.9064e-07)=255;
pos(pos < 3.9064e-07)=0;
pos=reshape(pos,[row,col]); 
clear y d;

%% Marking connected components
[conn,nComp]=bwlabel(pos,8);
count=1;
for i=1:nComp
    [ind]=find(conn==i);
    if(length(ind)<=0.005*row*col)
        pos(ind)=0;
        count=count+1;
    end
end
[conn,nComp]=bwlabel(pos,8);
clear row col count i ind pos;

%% Obtaining distance for each pixel with ALREADY EXISTING hypothesis
mapDist = zeros(size(conn,1),size(conn,2),size(s,1));
hypoPixelList = zeros(size(conn,1),size(conn,2),size(s,1));
nHypos = size(s,1);
for k=1:nHypos  
    theta = pi*s(k).Orientation/180;
    [rValOrg,cValOrg]=find(conn~=0);
    rVal = (rValOrg-s(k).Centroid(2))/(s(k).MinorAxisLength);
    cVal = (cValOrg-s(k).Centroid(1))/(s(k).MajorAxisLength);
    dist=...
    ((cos(theta)*cVal-sin(theta)*rVal).*(cos(theta)*cVal-sin(theta)*rVal)+...
    (sin(theta)*cVal+cos(theta)*rVal).*(sin(theta)*cVal+cos(theta)*rVal)).^0.5;
    for temp=1:length(dist)
       mapDist(rValOrg(temp),cValOrg(temp),k)=dist(temp);
       if(dist(temp)<1); hypoPixelList(rValOrg(temp),cValOrg(temp),k)=1; end
    end
end
clear k temp theta rValOrg cValOrg cVal rVal dist minDistValue;

%% Object hypothesis generation
for temp=1:nComp
    [indices]=find(conn==temp);
    minDistValue=Inf;
    for k=1:size(s,1)
       minDistValue = min([minDistValue; mapDist(indices+(k-1)*size(conn,1)*size(conn,2))]);
    end
    if( minDistValue>1 )
        %create new hypothesis
        editedImg = uint8(zeros(size(orgImg)));
        [rValOrg,cValOrg] = find(conn==temp);
        for e=1:length(rValOrg)
            editedImg(rValOrg(e),cValOrg(e),:)=orgImg(rValOrg(e),cValOrg(e),:);
        end; clear e;
        [~,appendThis_s]=ellpise_plotting(editedImg,gmm);
        s(end+1)=appendThis_s(1); clear appendThis_s;
    end    
end
clear indices;

%% Obtaining distance for each pixel with UPDATED SET of hypothesis
mapDist(size(conn,1),size(conn,2),nHypos+1:size(s,1)) = zeros(size(conn,1),size(conn,2),nHypos+1:size(s,1));
hypoPixelList(:,:,nHypos+1:size(s,1)) = zeros(size(conn,1),size(conn,2),nHypos+1:size(s,1));
for k=nHypos+1:size(s,1)    
    theta = pi*s(k).Orientation/180;%constMat = [cos(theta) -sin(theta);sin(theta) cos(theta)];
    [rValOrg,cValOrg]=find(conn>0);
    rVal = (rValOrg-s(k).Centroid(2))/(s(k).MinorAxisLength);
    cVal = (cValOrg-s(k).Centroid(1))/(s(k).MajorAxisLength);
    dist=...
    ((cos(theta)*cVal-sin(theta)*rVal).*(cos(theta)*cVal-sin(theta)*rVal)+...
    (sin(theta)*cVal+cos(theta)*rVal).*(sin(theta)*cVal+cos(theta)*rVal)).^0.5;
    for temp=1:length(dist)
       mapDist(rValOrg(temp),cValOrg(temp),k)=dist(temp); 
       if(dist(temp)<1); hypoPixelList(rValOrg(temp),cValOrg(temp),k)=1; end
    end
end
clear nHypos temp k theta rValOrg cValOrg cVal rVal dist minDistValue;


%% Get pixel list for each hypothesis
% Of the 2 types of inclusion, those that have dist value<1 are already
% marked positive in 'hypoPixelList'
% The second type are those where for a given coordinate location, if all
% dist are >1, then assign that point to min(dist) hypothesis- as follows:
[rowDim,colDim]=find(conn~=0);
for i=1:length(rowDim)
   if(min(mapDist(rowDim(i),colDim(i),:))>1)
        [~,minHypo]=min(mapDist(rowDim(i),colDim(i),:));
        hypoPixelList(rowDim(i),colDim(i),minHypo)=1;
   end
end
clear i rowDim colDim;

%% Generate BH matrix;
bhMatrix = zeros(nComp,size(s,1));
% MinVotingThres % Min of mnthres pixels must vote to that hypothesis
for i=1:nComp
for k=1:size(s,1)    
    theta = pi*s(k).Orientation/180;
    [rValOrg,cValOrg]=find(conn==i);
    rVal = (rValOrg-s(k).Centroid(2))/(s(k).MinorAxisLength);
    cVal = (cValOrg-s(k).Centroid(1))/(s(k).MajorAxisLength);
    dist=...
    ((cos(theta)*cVal-sin(theta)*rVal).*(cos(theta)*cVal-sin(theta)*rVal)+...
    (sin(theta)*cVal+cos(theta)*rVal).*(sin(theta)*cVal+cos(theta)*rVal)).^0.5;
    MinVotingThres = 0.5*length(dist);
    if(sum(dist<1)>=MinVotingThres); bhMatrix(i,k)=1; end
end
end
clear i k theta rValOrg cValOrg cVal rVal dist MinVotingThres;

%% Addressing the special case: a blob mapping to ONLY 1 hypo but the hypo is 
% mapped to 2 or more blobs, then that hypo and the former blob are made corresponding 
% and the pixel list of this hypo will now be changed.
for i=1:nComp
   if(sum(bhMatrix(i,:))==1)
       corrHypo = find(bhMatrix(i,:)==1);
       if(sum(bhMatrix(:,corrHypo))>1)
          bhMatrix(:,corrHypo)=zeros(nComp,1); bhMatrix(i,corrHypo)=1;
          %and change pixel list 
          hypoPixelList(:,:,corrHypo)=(conn==i);
       end
   end
end
clear i corrHypo;

%% Removing hypothesis
hypo_counter=ones(1,size(s,1));
for k=1:size(s,1)
    if(sum(bhMatrix(:,k))==0)
        hypo_counter(k)=0;
    else 
%         [indices]=find(conn~=0);
%         minDistHypo = min( mapDist(indices+(k-1)*size(conn,1)*size(conn,2)) );
%         if(minDistHypo>1); hypo_counter(k)=0; end; %Remove the hypothesis
    end
end
s(hypo_counter==0)=[];
hypoPixelList(:,:,hypo_counter==0)=[];
inp_s{1}(hypo_counter==0)=[];

k=1;
while k<=size(s,1)
    if(hypo_counter(k)==0)
        bhMatrix(:,k)=[];
        hypo_counter(k)=[];
    else
        k=k+1; 
    end
end
clear hypo_counter k;

%% Case when one hypo-1 blob in bhMatrix
for i=1:size(bhMatrix,1)
   if(sum(bhMatrix(i,:))==1)
        corrHypo = find(bhMatrix(i,:)==1);
        hypoPixelList(:,:,corrHypo) = (conn==i);
   end
end

%% Reestimating the hypothesis based on the pixel list
cnt=1;
for k=1:size(s,1)
   [param_s]=estimate_ellipse(hypoPixelList(:,:,k));
   if(~isempty(param_s)); reestimate_s(cnt,1)=param_s; cnt=cnt+1; end
   %if(isempty(param_s)); inp_s{1}(k)=[]; end;
   clear param_s;
end
clear cnt k;

%% Output
inp_s{2}=reestimate_s;
out_s=inp_s;
end