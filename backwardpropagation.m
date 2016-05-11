function B=backwardpropagation (del_row, del_col, ~,skin_map, B, current_index)

%find all blob location indices in the previous frame for intersection
index_blobs=[];
sz=size(skin_map{1});
newblob_img=zeros(sz); %to display new blobs 

for i=1:3
    e=isempty(B{current_index-1,i});
    if e==0
        blob=B{current_index-1,i};
        index=sub2ind(sz,blob(:,1), blob(:,2));
    else
        continue
    end
    index_blobs=cat(1,index_blobs, index);
    clear index blob
end

row=1:sz(1);
row=repmat(row',[1 sz(2)]); %each cell contains the row index

col=1:sz(2);
col=repmat(col,[sz(1) 1]); %each cell contains the column index

[xq,yq]=find(skin_map{1}>=0); %query points for convex hull

% %%
% figure;
% subplot(2,2,1); imshow(frame{current_index});
% hold on
% curr_blob=B{current_index,1};
% plot(curr_blob(:,2),curr_blob(:,1),'r.');
% curr_blob=B{current_index,2};
% if ~isempty(curr_blob)
%     plot(curr_blob(:,2),curr_blob(:,1),'r.');
% end
% curr_blob=B{current_index,3};
% if ~isempty(curr_blob)
%     plot(curr_blob(:,2),curr_blob(:,1),'r.');
% end
% title('Top frame with blobs')
% 
% subplot(2,2,2); imshow(frame{current_index-1});
% hold on
% curr_blob=B{current_index-1,1};
% plot(curr_blob(:,2),curr_blob(:,1),'b.');
% curr_blob=B{current_index-1,2};
% if ~isempty(curr_blob)
%     plot(curr_blob(:,2),curr_blob(:,1),'b.');
% end
% curr_blob=B{current_index-1,3};
% if ~isempty(curr_blob)
%     plot(curr_blob(:,2),curr_blob(:,1),'b.');
% end
% title('Previous frame with blobs')

%%
for b=1:3
    e=isempty(B{current_index,b});
    if e==0
        curr_blob=B{current_index,b};
    else
        B{current_index-1,b}=[];
        continue
    end
    index=sub2ind(sz,curr_blob(:,1), curr_blob(:,2));
    newblobr=ceil(row(index)-del_row(index)); %add velocity to get new row location vector
    newblobc=ceil(col(index)-del_col(index)); %add velocity to get new column location vector
    
    %eliminate values that go outside image bounds
    r1=(newblobr>sz(1));
    newblobr(r1)=[];newblobc(r1)=[];
    r2=(newblobr<1);
    newblobr(r2)=[];newblobc(r2)=[];
    c1=(newblobc>sz(2));
    newblobr(c1)=[];newblobc(c1)=[];
    c2=(newblobc<1);
    newblobr(c2)=[];newblobc(c2)=[];
    
    nindex0=sub2ind(sz,newblobr, newblobc);
    nindex=intersect(nindex0, index_blobs,'rows');
    newblob_img(nindex0)=255;
    
    [newblobr, newblobc]=ind2sub(sz,nindex);
    newblob=[newblobr newblobc]; %blob indices of F_i to next frame
    
    %Find convex hull of new blob
    empty=isempty(newblob);
    
    if empty==0 && numel(newblobr)>10
        try
            kl=convhull(newblobr,newblobc);
        catch
            kl = [];
            for pi = 1:numel(newblobr)
                kl = [kl,pi];
            end
            kl = kl';
        end

        in=inpolygon(yq, xq, newblobc(kl), newblobr(kl));
        
%         imshow(frame{current_index-1});
%         hold on
%         plot(yq(in), xq(in), 'r*');
%         hold off
        
        B{current_index-1,b}=[xq(in), yq(in)];
    end
    
    clear index1 index2 index nindex
   
    
end
% subplot(2,2,3)
% imshow(uint8(newblob_img)); %display new blobs in the next frame
% title('Propagation')
% 
% subplot(2,2,4)
% imshow(frame{current_index-1});
% hold on
% curr_blob=B{current_index-1,1};
% plot(curr_blob(:,2),curr_blob(:,1),'r.');
% curr_blob=B{current_index-1,2};
% plot(curr_blob(:,2),curr_blob(:,1),'g.');
% curr_blob=B{current_index-1,3};
% if ~isempty(curr_blob)
%     plot(curr_blob(:,2),curr_blob(:,1),'b.');
% end
% title('Previous frame with propagated blobs')
% hold off