function [parameters]=estimate_ellipse(orgImg)

%% Finding connected components
[row,col]=size(orgImg);
[conn,nComp]=bwlabel(orgImg,8);
count=1;
for i=1:nComp
    [ind]=find(conn==i);
    if(length(ind)<=0.005*row*col)
        orgImg(ind)=0;
        count=count+1;
    end
end
[conn,nComp]=bwlabel(orgImg,8);

%% Selecting the top-1
maxm=length(find(conn==1));
maxc=1;
for i=1:nComp
    t=find(conn==i);
    if(length(t)>maxm)
        maxc=i;
    end
end
conn(conn~=maxc)=0;
[conn,nComp]=bwlabel(conn,8);
parameters=regionprops(conn, 'Orientation', 'MajorAxisLength','MinorAxisLength','Centroid', 'Eccentricity');
end

