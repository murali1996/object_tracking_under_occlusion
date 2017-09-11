function [newImg,s]=ellpise_plotting(orgImg,gmm)
% orgImg = imread('Screenshot (81).png');
newImg = orgImg;

%% Finding Blobs by thresholding
[row,col,d]=size(orgImg);
y=double( reshape(orgImg,[row*col,3]) );
pos=pdf(gmm,y);
pos(pos >=3.9064e-07)=255;% 3.9064e-07)=255; %1.27e-06
pos(pos < 3.9064e-07)=0;%3.9064e-07
pos=reshape(pos,[row,col]); 

%% Finding connected components
[conn,n]=bwlabel(pos,8);
count=1;
for i=1:n
    [ind]=find(conn==i);
    if(length(ind)<=0.005*row*col)
        pos(ind)=0;
        count=count+1;
    end
end
[conn,n]=bwlabel(pos,8);
s = regionprops(conn, 'Orientation', 'MajorAxisLength','MinorAxisLength','Centroid', 'Eccentricity');
bw=conn;

%% Initials
phi = linspace(0,2*pi,50);
cosphi = cos(phi);
sinphi = sin(phi);

%% Routine
xy_cat = [];
for k = 1:length(s)
    xbar = s(k).Centroid(1);
    ybar = s(k).Centroid(2);

    a = s(k).MajorAxisLength/2;
    b = s(k).MinorAxisLength/2;

    theta = pi*s(k).Orientation/180;
    R = [ cos(theta)   sin(theta)
         -sin(theta)   cos(theta)];

    xy = [a*cosphi; b*sinphi];
    xy = R*xy;

    x = xy(1,:) + xbar;
    y = xy(2,:) + ybar;
    
    x=round(x); y=round(y);
    xy_cat = [xy_cat; [x;y]'];
    
%% plotting
% plot(x,y,'r','LineWidth',2);
end
if ~isempty(xy_cat)
    newImg = insertMarker(newImg,xy_cat,'*','color','red','size',5);
end
%imshow(newImg);
end