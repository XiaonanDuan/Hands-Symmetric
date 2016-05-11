function [skin_map]= skin_training(img,BB)

sz=size(img);
img=double(img);
skin_map=zeros(sz(1),sz(2));

for row=BB(2):BB(2)+BB(4)
    for col=BB(1):BB(1)+BB(3)
        r=img(row,col,1);
        g=img(row,col,2);
        b=img(row,col,3);
        if (r/g > 1.185 &&  (r*b)/(r+g+b)^2 > 0.107  && (r*g)/(r+g+b)^2 > 0.112 )
            skin_map(row,col)=1;
        end
    end
end

% figure;
% imshow(uint8(255*skin_map));


