function BB= facedetection(I)

%Face detection 

Face = vision.CascadeObjectDetector;

%Bounding Box
B = step(Face,I);

in= B(:,3)==max(B(:,3));
BB=B(in,:);

% imshow(I); hold on
% for i = 1:size(BB,1)
%     rectangle('Position',BB(i,:),'LineWidth',5,'LineStyle','-','EdgeColor','r');
% end
% title('Face Detection');
% hold off;
