function [imShift, predShift] = alignChannels(im, maxShift)
% ALIGNCHANNELS align channels in an image.
%   [IMSHIFT, PREDSHIFT] = ALIGNCHANNELS(IM, MAXSHIFT) aligns the channels in an
%   NxMx3 image IM. The first channel is fixed and the remaining channels
%   are aligned to it within the maximum displacement range of MAXSHIFT (in
%   both directions). The code returns the aligned image IMSHIFT after
%   performing this alignment. The optimal shifts are returned as in
%   PREDSHIFT a 2x2 array. PREDSHIFT(1,:) is the shifts  in I (the first) 
%   and J (the second) dimension of the second channel, and PREDSHIFT(2,:)
%   are the same for the third channel.

% Sanity check
assert(size(im,3) == 3);
assert(all(maxShift > 0));

% Dummy implementation (replace this with your own)
predShift = zeros(2,2);
cov2max = 0;
cov3max = 0;

[imageHeight, imageWidth] = size(im(:,:,1));

%R = im(:,:,1);
 
%Boundary
R = im(16:imageHeight-15,16:imageWidth-15,1);

%Faster
%R = im(1:2:imageHeight,1:2:imageWidth,1);

%Boundary & Faster
%R = im(16:2:imageHeight-15,16:2:imageWidth-15,1);


norm1 = norm(R(:));
for i = -15:15
    for j = -15:15
        imShift = im;
        imShift(:,:,2) = circshift(imShift(:,:,2), [i j]);
        
        %G = imShift(:,:,2);
        
        %Boundary
        G = imShift(16:imageHeight-15,16:imageWidth-15,2);
        
        %Faster
        %G = imShift(1:2:imageHeight,1:2:imageWidth,2);
        
        %Boundary & Faster
        %G = imShift(16:2:imageHeight-15,16:2:imageWidth-15,2);
        
        %NCC
        cov2 = dot(R(:),G(:))/norm1/norm(G(:));
        
        %SSD
        %cov2 = sum((R(:)-G(:)).^2);
        
        if cov2 > cov2max
            cov2max = cov2;
            predShift(1,1) = i;
            predShift(1,2) = j;
        end
        imShift(:,:,3) = circshift(imShift(:,:,3), [i j]);
        
        %B = imShift(:,:,3);
        
        %Boundary
        B = imShift(16:imageHeight-15,16:imageWidth-15,3);
        
        %Faster
        %B = imShift(1:2:imageHeight,1:2:imageWidth,3);
        
        %Boundary & Faster
        %B = imShift(16:2:imageHeight-15,16:2:imageWidth-15,3);

        %NCC
        cov3 =  dot(R(:),B(:))/norm1/norm(B(:));
        
        %SSD
        %cov3 =  sum((R(:)-B(:)).^2);
        
        if cov3 > cov3max 
            cov3max = cov3;
            predShift(2,1) = i;
            predShift(2,2) = j;
        end
    end
end
imShift = im;
imShift(:,:,2) = circshift(imShift(:,:,2), [predShift(1,1) predShift(1,2)]);
imShift(:,:,3) = circshift(imShift(:,:,3), [predShift(2,1) predShift(2,2)]);

%Boundary
imShift = imShift(16:imageHeight-15,16:imageWidth-15,:);
