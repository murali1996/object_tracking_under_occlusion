function [validityStatus]=isvalid_hypothesis(orgImg,gmm,s)
%% Fixed apriori
[row,col,d]=size(orgImg);

%% Simple thresholding
y=double( reshape(orgImg,[row*col,d]) );
pos=pdf(gmm,y);
pos(pos >=3.9064e-07)=255;
pos(pos < 3.9064e-07)=0;
pos=reshape(pos,[row,col]); 

%% Marking connected components
[conn,n]=bwlabel(pos,8);
count=1;
for i=1:n
    [validityStatus,c]=find(conn==i);
    if(length(validityStatus)<=0.0015*row*col)
        pos(validityStatus,c)=0;
        count=count+1;
    end
end
[conn,n]=bwlabel(pos,8);

%% check each component
theta = pi*s(k).Orientation/180;
constMat = [ cos(theta)   -sin(theta)
        sin(theta)   cos(theta)];
for i=1:n %n connected components
    [row,col]=find(conn==i);
    for j=1:length(row)
        %distance to the hypothesis
        dist = constMat*[(row-s(k).Centroid(1))/s(k).MajorAxisLength (col-s(k).Centroid(2))/s(k).MinorAxisLength]';
        dist = norm(dist);
        if(dist<=1); validityStatus = 1; return; 
        end
    end
end
validityStatus = 0; 
end



