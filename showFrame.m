n = length(frame);
p = 0;

for i = 1:n
    if  mod(i, 10) == 0
        imshow(s(i).cdata);
    end
end