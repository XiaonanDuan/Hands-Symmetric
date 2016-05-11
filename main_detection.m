%Hand recognition and tracking Xiaonan Duan, JOHN R. KENDER Spring 2016

%%
%0. Read the video file

[filename, pathname] = uigetfile('*.mp4;*.avi', 'Select a video file');
v =VideoReader([pathname , filename]);
vidHeight = v.Height;
vidWidth = v.Width;
% v.CurrentTime = 8;
s = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
k = 1;

%% original frame reading
%while hasFrame(v) %v.CurrentTime <= 20;
%    s(k).cdata = readFrame(v);
%    k = k+1;
%end

display('Read from original video...');
numFrames = get(v, 'NumberOfFrames');
vidFrames = read(v);
for k = 1:numFrames
    s(k).cdata = vidFrames(:,:,:,k);
    s(k).colormap = [];
end


    
%%
%1. Training video specific skin model

display('Training from the skin model...');
[mean, sigma]=training_limit(s, filename);


%%
%2.Finding Face boundboxes of each frame
display('Finding bounding boxes...');
Face_BB = face_BB(s);

%%
%2. Blob detection
% hack the blob detection for a new output, firstly know how to bound box and then bound boxes in the face

display('Detect the blobs...');
[B, C, V, skin_map, frame]= blobdetection (s, mean, sigma);


%%
%2. Tracking hands by optical flow

display('Optical flowing...');
NewBlob= opticalflow(B, C, skin_map, frame);

%% find new c
NewC = findNewCent(NewBlob, [vidHeight vidWidth]);

%% find new V
NewV = findNewV(NewBlob);


%%
% 3.Bound Box
display('Bounding boxes...');
BB = boundbox(NewBlob);


%%
% 4. Cluster points
display('Making clusters...');
Cluster = blobcluster(NewC);

%%
% 4.Track hands
display('Tracking hands...');
handsLabel = handsTracking(NewV, NewC, Cluster, Face_BB, s);


%%
%6. save Video
display('Saving video...');
saveVideo(BB, C, handsLabel, s);


%%
%6. finishing
display('Finsihed !See video "result.avi".');

