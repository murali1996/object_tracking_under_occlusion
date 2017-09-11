%% Input
%readerObj = VideoReader('ten_sec_black_back.mp4');
readerObj = VideoReader('ten_sec_black_back.mp4');
nFrames = 80;%readerObj.NumberOfFrames;
vidHeight= 720; %vidHeight = readerObj.Height;
vidWidth = 1080; % vidWidth = readerObj.Width;
fps = readerObj.FrameRate;

%% Output
output_frames = uint8(zeros(vidHeight,vidWidth,3,nFrames));

%% To generate hypothesis in first 2 frames
cnt=1;
s={};
for i=1:2
    disp(i)
    orgImg = read(readerObj,i);
    orgImg = imresize(orgImg,[vidHeight,vidWidth]);
    [newImg,s{cnt}]=ellpise_plotting(orgImg,GMModel_new1);
    output_frames(:,:,:,i) = newImg;
    cnt=cnt+1;
end; 

%% Update, removal and adding new hypothesis from 3rd frame
for i=3:nFrames
    disp(i);
    orgImg = read(readerObj,i);
    orgImg = imresize(orgImg,[vidHeight,vidWidth]);
    [out_s]=modify_hypothesis_map(orgImg,s,GMModel_new1);
    %s=update_hypothesis(s); % 'Prediction' technique discussed in Paper-1
    newImg=draw_boundaries(orgImg,out_s{2});
    output_frames(:,:,:,i) = newImg; 
end; clear i this_frame new_frame;   

%% Playing the stacked frames
implay(output_frames(:,:,:,1:nFrames),10);