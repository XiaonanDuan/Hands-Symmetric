function newBlob=opticalflow(B, C, skin_map, frame)

n=length(C);
sz=size(skin_map{1});

%%
% Sorting

%Prioritize frames on the basis of number of blobs and then on distance
%between blobs
sort_matrix=zeros(n,3);
for i=1:n
    sort_matrix(i,1)=i; %frame index

    maxBlobs = 0;
    for j = 1:size(C,2)
        if C(i,j) ~= 0
            maxBlobs = j;
        end
    end
    maxBlobs = maxBlobs / 2;

    sort_matrix(i,2)= maxBlobs;  %max(C(i,:)); %number of blobs
    
    d=0;
    if C(i,1)~=0
        if C(i,3)~=0
            d=d+sqrt((C(i,1)-C(i,3))^2+(C(i,2)-C(i,4))^2); %distance between blob 1 and 2
            if C(i,5) ~=0
                d=d+sqrt((C(i,1)-C(i,5))^2+(C(i,2)-C(i,6))^2); %distance between blob 1 and 3
                d=d+sqrt((C(i,3)-C(i,5))^2+(C(i,4)-C(i,6))^2); %distance between blob 2 and 3
            end
        end
    end
    sort_matrix(i,3)=d;
end
clear d

%Sort matrix according to number of blobs and total pairwise distance of blob centroids

sort_matrix=sortrows(sort_matrix, [-3 -2]);


%%
%Propagation
loop_iter = 1;

while ~isempty(sort_matrix)
    
    % loop_iter = loop_iter + 1

    prop_next=0;
    prop_prev=0;
    
    top=sort_matrix(1,1); %index of top frame
    top_next=top+1;
    top_prev=top-1;
    
    %Check whether neighboring frames are in the priority queue (ie not
    %processed)
    
    nb_next=~isempty(find(sort_matrix(:,1)==top_next, 1)); %gives 1 if next frame hasn't been popped
    nb_prev=~isempty(find(sort_matrix(:,1)==top_prev, 1)); %gives 1 if prev frame hasn't been popped
    
    %calculate optical flow of popped frame
    [del_row, del_col]=calcopticalflow(frame{top});
    
    
    %forward propagation from current frame
    if nb_next==1 && top<n
        in_next=find(sort_matrix(:,1)==top_next);
        if sort_matrix(1,2)>sort_matrix(in_next,2)
            B=forwardpropagation(del_row, del_col, frame,  skin_map, B, top);
            prop_next=1;
        end
    end
    
    
    %backward propagation from current frame
    if nb_prev==1 && top>1
        in_prev=find(sort_matrix(:,1)==top_prev);
        if sort_matrix(1,2)>sort_matrix(in_prev,2)
            B=backwardpropagation(del_row, del_col, frame,  skin_map, B, top);
            prop_prev=1;
        end
    end
    
    %%
    %If next/prev has propagated blobs, reprioritize the frames in the
    %sort_matrix
    
    if prop_next==1
        %1. Count the number of blobs
        blob_next=blobcount(top_next,B);
        
        %2. Find the sum of distances between blob centroids
        
        k=1;
        
        C=zeros(1,6); %centroid
        while k<4 && ~isempty(B{top_next,k})
            blob_img=zeros(sz);
            curr_blob=B{top_next,k};
            index=sub2ind(sz,curr_blob(:,1), curr_blob(:,2));
            blob_img(index)=1;
            cent=regionprops(blob_img, 'centroid');
            C(2*k-1)=cent.Centroid(2); %centroid row
            C(2*k)=cent.Centroid(1); %centroid column
            
            k=k+1;
        end
        
        d=0;
        if C(1,1)~=0
            if C(1,3)~=0
                d=d+sqrt((C(1,1)-C(1,3))^2+(C(1,2)-C(1,4))^2); %distance between blob 1 and 2
                if C(1,5) ~=0
                    d=d+sqrt((C(1,1)-C(1,5))^2+(C(1,2)-C(1,6))^2); %distance between blob 1 and 3
                    d=d+sqrt((C(1,3)-C(1,5))^2+(C(1,4)-C(1,6))^2); %distance between blob 2 and 3
                end
            end
        end
        
        %Update the sort_matrix next frame entry
        index=find(sort_matrix(:,1)==top_next);
        sort_matrix(index,2)=blob_next;
        sort_matrix(index,3)=d;
    end
    
    if prop_prev==1
        %1. Count the number of blobs
        blob_prev=blobcount(top_prev,B);
        
        %2. Find the sum of distances between blob centroids
        k=1;
        
        C=zeros(1,6); %centroid
        while k<4 && ~isempty(B{top_prev,k})
            blob_img=zeros(sz);
            curr_blob=B{top_prev,k};
            index=sub2ind(sz,curr_blob(:,1), curr_blob(:,2));
            blob_img(index)=1;
            cent=regionprops(blob_img, 'centroid');
            C(2*k-1)=cent.Centroid(2); %centroid row
            C(2*k)=cent.Centroid(1); %centroid column
            
            k=k+1;
        end
        
        d=0;
        if C(1,1)~=0
            if C(1,3)~=0
                d=d+sqrt((C(1,1)-C(1,3))^2+(C(1,2)-C(1,4))^2); %distance between blob 1 and 2
                if C(1,5) ~=0
                    d=d+sqrt((C(1,1)-C(1,5))^2+(C(1,2)-C(1,6))^2); %distance between blob 1 and 3
                    d=d+sqrt((C(1,3)-C(1,5))^2+(C(1,4)-C(1,6))^2); %distance between blob 2 and 3
                end
            end
        end
        
        %Update the sort_matrix next frame entry
        index=find(sort_matrix(:,1)==top_prev);
        sort_matrix(index,2)=blob_prev;
        sort_matrix(index,3)=d;
    end
    
    
    %Delete the popped frame from sort_matrix
    sort_matrix(1,:)=[];
    
    sort_matrix=sortrows(sort_matrix, [-3 -2]);
    
    
end
newBlob=B;
save('NEWBLOBS','B');



