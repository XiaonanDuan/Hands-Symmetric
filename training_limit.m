%1. Training to obtain video specific skin color limits

%functions: skin_training, facedetection
%output: mean and sigma for red and blue channels

function [mean, sigma]=training_limit(s,filename)

n=length(s);	%length of frames

%init cell data for n frames
skin_map=cell(1,n);	
R_in=cell(1,n);
B_in=cell(1,n);

for i=1:n/10	%chose 10% frames for training
    
    img=s(i+9).cdata;
    
    %Face detection for image: Bounding box, quite useful ^_^
    BB= facedetection(img);
    
    %Find skin map for face
    skin_map{i}=skin_training(img,BB);
    
    % imwrite(skin_map{i}, [filename 'skin_map_' int2str(i) '.jpg']);
    
    %Get all query points of skin map
    [xq,yq]=find(skin_map{i}>=0);
    
    %Find convex hull of FACE
    [xf,yf]=find(skin_map{i});
    kf=convhull(xf,yf);
    INface=inpolygon(yq, xq, yf(kf), xf(kf));
    
%     fh=figure;
%     imshow(uint8(img));
%     hold on
%     plot(yq(INface), xq(INface), 'r*');
%     inhull=(saveAnnotatedImg(fh));
%     imwrite(inhull,['inhull_' img_list{i} '.jpg']);
    
    R=img(:,:,1);
    R_in{i}=R(INface);
    
    B=img(:,:,3);
    B_in{i}=B(INface);
    
    clear R;
    clear B;
    
end

Red=cat(1,R_in{:});
Blue=cat(1,B_in{:});

range=0:1:255;

R_pd = fitdist(Red,'Normal');
B_pd = fitdist(Blue,'Normal');

mean(1)=R_pd.mu;
sigma(1)=R_pd.sigma;

mean(2)=B_pd.mu;
sigma(2)=B_pd.sigma;
    
R_pdf=pdf(R_pd,range);
B_pdf=pdf(B_pd,range);

% figure();plot(range,R_pdf,'LineWidth',2,'Color',[1 0 0]);
% figure();plot(range,B_pdf,'LineWidth',2,'Color',[0 0 1]);

% close all

save('mean', 'mean');
save('sigma', 'sigma');
