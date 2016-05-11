function count= blobcount (index,B)
count=0;

for i=1:3
    tf=~isempty(B{index,i});
    count=count+tf;
end
    

