function [delta_row, delta_col]= calcopticalflow (frame)

framegray=im2double(rgb2gray(frame));
    
opticFlow = opticalFlowFarneback;
flow = estimateFlow(opticFlow,framegray);

%Display optical flow
% imshow(frame)
% hold on
% plot(flow,'DecimationFactor',[5 5],'ScaleFactor',2)
% hold off

%Velocity of pixels
delta_row=flow.Vy;
delta_col=flow.Vx;