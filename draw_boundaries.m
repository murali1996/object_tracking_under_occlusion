function [newImg] = draw_boundaries(orgImg,s)
newImg = orgImg;

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
    
end
if ~isempty(xy_cat)
        newImg = insertMarker(newImg,xy_cat,'*','color','red','size',5);
end
%imshow(newImg);
end

