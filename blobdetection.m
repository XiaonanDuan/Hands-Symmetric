function [B, C, V, skin_map, frame]= blobdetection (s, mean, sigma)

% s is the structure of frames, s(i).cdata is the img data
% mean and sigma is the parameter calculated in the train_limit

% define some variables
n=length(s);
frame=cell(1,n);
skin_map=cell(1,n);
B=cell(n, 3);
C=zeros(n, 6);
V=zeros(n, 3);


% the bounds of each channel
c1=mean(1)-4.5*sigma(1);
c2=mean(1)+4.5*sigma(1);
c3=mean(2)-4.5*sigma(2);
c4=mean(2)+4.5*sigma(2);

imshow(s(1).cdata);

% main loop
for i=1:n 

    frame{i}=s(i).cdata;    % the frame now is a cell structure to store the frame data
    r=frame{i}(:,:,1);      % the data of r channel
    b=frame{i}(:,:,3);      % the data of b channel
    
    skin_map{i}=zeros(size(r));     % skin_map can be a cell structure of masking picture
    
    in_c1=find(and(r>c1,r<c2));     % find  c1 < r < c2    -------------  A
    in_c3=find(and(b>c3,b<c4));     % find  c3 < b < c4    -------------  B
    
    in=intersect(in_c1,in_c3);      % find points satisfying both A and B
    
    skin_map{i}(in)=1;              % set the masking picture pixel = 1 of the pixels in 'in'
    skin_map{i} = medfilt2(skin_map{i},[10 10]);    % filter the pixels
    
    % the skin_map of this frame is basically made

    D=bwdist(skin_map{i})<4; % dilation

    LI= labelmatrix(bwconncomp(D)); % get the matrix labeled with 1,2,3....., each label presents an area

    LI(~skin_map{i}) = 0;   % set the pixels not in the skin_map 0, I guess
 
    sz=size(skin_map{i});   % sz is the size of skin_map, which is size of the frame
    
    [yq, xq]=find(skin_map{i}>=0);   % [ xq, yq ] is the not-background pixels in the skin_map
    

    % well, I will only use the first 3 blobs

    numBlobs = 0;
    tempBlobs = cell(1);
    tempBlobVolume = zeros(1,numBlobs);

    for j=1:max(LI(:))  % max(LI(:)) means the max number of area
        [yl, xl]=find(LI==j);    % [xl, yl] is the points of area j 
        if numel(xl)>100     % if the area contents above 10 points
            numBlobs = numBlobs + 1;
            blob = [yl, xl];
            szBlob = size(blob);
            tempBlobs{numBlobs} = blob; %mat2cell(blob, szBlob(1), szBlob(2));

            % record the Volume of the area
            tempBlobVolume(numBlobs)=numel(xl);
            V(i,numBlobs) = numel(xl);
        end
        clear xl yl blob
    end
    
    % sort the blobs by its volume and select first 3 

    if numBlobs > 3
        numBlobs = 3;
    end

    [ r , sortedBlobLabels ] = sort(tempBlobVolume, 'descend');
    sortedBlobLabels = sortedBlobLabels(1:numBlobs);

    for j = 1:numBlobs
        B{i,j} = tempBlobs{sortedBlobLabels(j)};
        [cy, cx] = findRegionCentroid(B{i,j}, sz);
        C(i, 2*j-1) = cy;
        C(i, 2*j) = cx;
    end
    clear numBlobs, tempBlobs, tempBlobVolume;

end

save('BLOBS', 'B');
save('SKINMAP','skin_map');
save('FRAMES','frame');
save('CENTROIDS','C');

clear c1 c2 c3 c4 in in_c1 in_c3