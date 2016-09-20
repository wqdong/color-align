function output = demosaicImage(im, method)
% DEMOSAICIMAGE computes the color image from mosaiced input
%   OUTPUT = DEMOSAICIMAGE(IM, METHOD) computes a demosaiced OUTPUT from
%   the input IM. The choice of the interpolation METHOD can be 
%   'baseline', 'nn', 'linear', 'adagrad'. 

switch lower(method)
    case 'baseline'
        output = demosaicBaseline(im);
    case 'nn'
        output = demosaicNN(im);         % Implement this
    case 'linear'
        output = demosaicLinear(im);     % Implement this
    case 'adagrad'
        output = demosaicAdagrad(im);    % Implement this
end

%--------------------------------------------------------------------------
%                          Baseline demosaicing algorithm. 
%                          The algorithm replaces missing values with the
%                          mean of each color channel.
%--------------------------------------------------------------------------
function mosim = demosaicBaseline(im)
mosim = repmat(im, [1 1 3]); % Create an image by stacking the input
[imageHeight, imageWidth] = size(im);

% Red channel (odd rows and columns);
redValues = im(1:2:imageHeight, 1:2:imageWidth);
meanValue = mean(mean(redValues));
mosim(:,:,1) = meanValue;
mosim(1:2:imageHeight, 1:2:imageWidth,1) = im(1:2:imageHeight, 1:2:imageWidth);

% Blue channel (even rows and colums);
blueValues = im(2:2:imageHeight, 2:2:imageWidth);
meanValue = mean(mean(blueValues));
mosim(:,:,3) = meanValue;
mosim(2:2:imageHeight, 2:2:imageWidth,3) = im(2:2:imageHeight, 2:2:imageWidth);

% Green channel (remaining places)
% We will first create a mask for the green pixels (+1 green, -1 not green)
mask = ones(imageHeight, imageWidth);
mask(1:2:imageHeight, 1:2:imageWidth) = -1;
mask(2:2:imageHeight, 2:2:imageWidth) = -1;
greenValues = mosim(mask > 0);
meanValue = mean(greenValues);
% For the green pixels we copy the value
greenChannel = im;
greenChannel(mask < 0) = meanValue;
mosim(:,:,2) = greenChannel;

%--------------------------------------------------------------------------
%                           Nearest neighbour algorithm
%--------------------------------------------------------------------------
function mosim = demosaicNN(im)

mosim = repmat(im, [1 1 3]);
[imageHeight, imageWidth] = size(im);

%red
mosim((1:2:imageHeight-1)+1,(1:2:imageWidth-1),1) = im(1:2:imageHeight-1,1:2:imageWidth-1);
mosim((1:2:imageHeight-1),(1:2:imageWidth-1)+1,1) = im(1:2:imageHeight-1,1:2:imageWidth-1);
mosim((1:2:imageHeight-1)+1,(1:2:imageWidth-1)+1,1) = im(1:2:imageHeight-1,1:2:imageWidth-1);

if mod(imageHeight,2) == 1
    mosim(imageHeight,(1:2:imageWidth-1)+1,1) = im(imageHeight,(1:2:imageWidth-1));
end
if mod(imageWidth,2) == 1
    mosim((1:2:imageHeight-1)+1,imageWidth,1) = im((1:2:imageHeight-1),imageWidth);
end

%green
mosim((1:2:imageHeight),(2:2:imageWidth)-1,2) = im(1:2:imageHeight,2:2:imageWidth);
mosim((2:2:imageHeight),(1:2:imageWidth-1)+1,2) = im(2:2:imageHeight,1:2:imageWidth-1);

if mod(imageWidth,2) == 1
    mosim(1:2:imageHeight,imageWidth,2) = im(1:2:imageHeight,imageWidth-1);
end

%blue
mosim((2:2:imageHeight)-1,(2:2:imageWidth),3) = im(2:2:imageHeight,2:2:imageWidth);
mosim((2:2:imageHeight),(2:2:imageWidth)-1,3) = im(2:2:imageHeight,2:2:imageWidth);
mosim((2:2:imageHeight)-1,(2:2:imageWidth)-1,3) = im(2:2:imageHeight,2:2:imageWidth);

if mod(imageHeight,2) == 1
    mosim(imageHeight,2:2:imageWidth,3) = im(imageHeight-1,2:2:imageWidth);
    mosim(imageHeight,(2:2:imageWidth)-1,3) = im(imageHeight-1,2:2:imageWidth);
end
if mod(imageWidth,2) == 1
    mosim(2:2:imageHeight,imageWidth,3) = im(2:2:imageHeight,imageWidth-1);
    mosim((2:2:imageHeight)-1,imageWidth,3) = im(2:2:imageHeight,imageWidth-1);
end
if mod(imageHeight,2)*mod(imageWidth,2) == 1
     mosim(imageHeight,imageWidth,3) = im(imageHeight-1,imageWidth-1);
end



%--------------------------------------------------------------------------
%                           Linear interpolation
%--------------------------------------------------------------------------
function mosim = demosaicLinear(im)
dmosim = repmat(im, [1 1 3]);
[Height, Width] = size(im);

if mod(Height,2) == 0 && mod(Width,2) == 0
   im(Height+1,:) = im(Height,:);
   im(:,Width+1) = im(:,Width);
elseif mod(Height,2) == 1 && mod(Width,2) == 0
   im(:,Width+1) = im(:,Width);
elseif mod(Height,2) == 0 && mod(Width,2) == 1
   im(Height+1,:) = im(Height,:);
end

[imageHeight, imageWidth] = size(im);
        %red
        dmosim(1:2:imageHeight,2:2:imageWidth,1) = 1/2*(im(1:2:imageHeight,(2:2:imageWidth)-1)+im(1:2:imageHeight,(2:2:imageWidth)+1));
        dmosim(2:2:imageHeight,1:2:imageWidth,1) = 1/2*(im((2:2:imageHeight)-1,1:2:imageWidth)+im((2:2:imageHeight)+1,1:2:imageWidth));
        dmosim(2:2:imageHeight,2:2:imageWidth,1) = 1/4*(im((2:2:imageHeight)-1,(2:2:imageWidth)-1)+im((2:2:imageHeight)-1,(2:2:imageWidth)+1)+im((2:2:imageHeight)+1,(2:2:imageWidth)-1)+im((2:2:imageHeight)+1,(2:2:imageWidth)+1));
        %green
        dmosim(2:2:imageHeight,2:2:imageWidth,2) = 1/4*(im((2:2:imageHeight)-1,(2:2:imageWidth))+im((2:2:imageHeight)+1,(2:2:imageWidth))+im((2:2:imageHeight),(2:2:imageWidth)-1)+im((2:2:imageHeight),(2:2:imageWidth)+1));
        dmosim(3:2:imageHeight-1,3:2:imageWidth-1,2) = 1/4*(im((3:2:imageHeight-1)-1,(3:2:imageWidth-1))+im((3:2:imageHeight-1)+1,(3:2:imageWidth-1))+im((3:2:imageHeight-1),(3:2:imageWidth-1)-1)+im((3:2:imageHeight-1),(3:2:imageWidth-1)+1));
        dmosim(1:2:imageHeight-1,1,2) = im((1:2:imageHeight-1)+1,1);
        dmosim(1,3:2:imageWidth,2) = im(1,(3:2:imageWidth)-1);
        dmosim(3:2:imageHeight,imageWidth,2) = im((3:2:imageHeight)-1,imageWidth);
        dmosim(imageHeight,1:2:imageWidth-1,2) = im(imageHeight,(1:2:imageWidth-1)+1);
        %blue
        dmosim(3:2:imageHeight-1,3:2:imageWidth-1,3) = 1/4*(im((3:2:imageHeight-1)-1,(3:2:imageWidth-1)-1)+im((3:2:imageHeight-1)+1,(3:2:imageWidth-1)-1)+im((3:2:imageHeight-1)-1,(3:2:imageWidth-1)+1)+im((3:2:imageHeight-1)+1,(3:2:imageWidth-1)+1));
        dmosim(2:2:imageHeight,3:2:imageWidth-1,3) = 1/2*(im(2:2:imageHeight,(3:2:imageWidth-1)-1)+im(2:2:imageHeight,(3:2:imageWidth-1)+1));
        dmosim(3:2:imageHeight-1,2:2:imageWidth,3) = 1/2*(im((3:2:imageHeight-1)-1,2:2:imageWidth)+im((3:2:imageHeight-1)+1,2:2:imageWidth));
        dmosim((2:2:imageHeight)-1,1,3) = im(2:2:imageHeight,2);
        dmosim(2:2:imageHeight,1,3) = im(2:2:imageHeight,2);
        dmosim(1,2:2:imageWidth,3) = im(2,2:2:imageWidth);
        dmosim(1,(2:2:imageWidth)+1,3) = im(2,2:2:imageWidth);
        dmosim(2:2:imageHeight,imageWidth,3) = im(2:2:imageHeight,imageWidth-1);
        dmosim((2:2:imageHeight)-1,imageWidth,3) = im(2:2:imageHeight,imageWidth-1);
        dmosim(imageHeight,2:2:imageWidth,3) = im(imageHeight-1,2:2:imageWidth);
        dmosim(imageHeight,(2:2:imageWidth)-1,3) = im(imageHeight-1,2:2:imageWidth);
mosim(:,:,:) = dmosim(1:1:Height,1:1:Width,:);


%--------------------------------------------------------------------------
%                           Adaptive gradient
%--------------------------------------------------------------------------
function mosim = demosaicAdagrad(im)
dmosim = repmat(im, [1 1 3]);
[Height, Width] = size(im);

if mod(Height,2) == 0 && mod(Width,2) == 0
   im(Height+1,:) = im(Height,:);
   im(:,Width+1) = im(:,Width);
elseif mod(Height,2) == 1 && mod(Width,2) == 0
   im(:,Width+1) = im(:,Width);
elseif mod(Height,2) == 0 && mod(Width,2) == 1
   im(Height+1,:) = im(Height,:);
end

[imageHeight, imageWidth] = size(im);
        %red
        dmosim(1:2:imageHeight,2:2:imageWidth,1) = 1/2*(im(1:2:imageHeight,(2:2:imageWidth)-1)+im(1:2:imageHeight,(2:2:imageWidth)+1));
        dmosim(2:2:imageHeight,1:2:imageWidth,1) = 1/2*(im((2:2:imageHeight)-1,1:2:imageWidth)+im((2:2:imageHeight)+1,1:2:imageWidth));
        if abs(im((2:2:imageHeight)-1,(2:2:imageWidth)-1)-im((2:2:imageHeight)-1,(2:2:imageWidth)+1)) < abs(im((2:2:imageHeight)+1,(2:2:imageWidth)-1)-im((2:2:imageHeight)+1,(2:2:imageWidth)+1))
            dmosim(2:2:imageHeight,2:2:imageWidth,1) = 1/2*(im((2:2:imageHeight)-1,(2:2:imageWidth)-1)+im((2:2:imageHeight)-1,(2:2:imageWidth)+1));
        else
            dmosim(2:2:imageHeight,2:2:imageWidth,1) = 1/2*(im((2:2:imageHeight)+1,(2:2:imageWidth)-1)+im((2:2:imageHeight)+1,(2:2:imageWidth)+1));
        end
        %green
        if abs(im((2:2:imageHeight)-1,(2:2:imageWidth))-im((2:2:imageHeight)+1,(2:2:imageWidth))) < abs(im((2:2:imageHeight),(2:2:imageWidth)-1)-im((2:2:imageHeight),(2:2:imageWidth)+1))
            dmosim(2:2:imageHeight,2:2:imageWidth,2) = 1/2*(im((2:2:imageHeight)-1,(2:2:imageWidth))+im((2:2:imageHeight)+1,(2:2:imageWidth)));
        else 
            dmosim(2:2:imageHeight,2:2:imageWidth,2) = 1/2*(im((2:2:imageHeight),(2:2:imageWidth)-1)+im((2:2:imageHeight),(2:2:imageWidth)+1));
        end
        if abs(im((3:2:imageHeight-1)-1,(3:2:imageWidth-1))-im((3:2:imageHeight-1)+1,(3:2:imageWidth-1))) < abs(im((3:2:imageHeight-1),(3:2:imageWidth-1)-1)-im((3:2:imageHeight-1),(3:2:imageWidth-1)+1));
        dmosim(3:2:imageHeight-1,3:2:imageWidth-1,2) = 1/2*(im((3:2:imageHeight-1)-1,(3:2:imageWidth-1))+im((3:2:imageHeight-1)+1,(3:2:imageWidth-1)));
        else
        dmosim(3:2:imageHeight-1,3:2:imageWidth-1,2) =1/2*(im((3:2:imageHeight-1),(3:2:imageWidth-1)-1)+im((3:2:imageHeight-1),(3:2:imageWidth-1)+1));
        end
        dmosim(1:2:imageHeight-1,1,2) = im((1:2:imageHeight-1)+1,1);
        dmosim(1,3:2:imageWidth,2) = im(1,(3:2:imageWidth)-1);
        dmosim(3:2:imageHeight,imageWidth,2) = im((3:2:imageHeight)-1,imageWidth);
        dmosim(imageHeight,1:2:imageWidth-1,2) = im(imageHeight,(1:2:imageWidth-1)+1);
        %blue
        if abs(im((3:2:imageHeight-1)-1,(3:2:imageWidth-1)-1)-im((3:2:imageHeight-1)+1,(3:2:imageWidth-1)-1)) < abs(im((3:2:imageHeight-1)-1,(3:2:imageWidth-1)+1)-im((3:2:imageHeight-1)+1,(3:2:imageWidth-1)+1))
        dmosim(3:2:imageHeight-1,3:2:imageWidth-1,3) = 1/2*(im((3:2:imageHeight-1)-1,(3:2:imageWidth-1)-1)+im((3:2:imageHeight-1)+1,(3:2:imageWidth-1)-1));
        else
        dmosim(3:2:imageHeight-1,3:2:imageWidth-1,3) = 1/2*(im((3:2:imageHeight-1)-1,(3:2:imageWidth-1)+1)+im((3:2:imageHeight-1)+1,(3:2:imageWidth-1)+1));    
        end
        dmosim(2:2:imageHeight,3:2:imageWidth-1,3) = 1/2*(im(2:2:imageHeight,(3:2:imageWidth-1)-1)+im(2:2:imageHeight,(3:2:imageWidth-1)+1));
        dmosim(3:2:imageHeight-1,2:2:imageWidth,3) = 1/2*(im((3:2:imageHeight-1)-1,2:2:imageWidth)+im((3:2:imageHeight-1)+1,2:2:imageWidth));
        dmosim((2:2:imageHeight)-1,1,3) = im(2:2:imageHeight,2);
        dmosim(2:2:imageHeight,1,3) = im(2:2:imageHeight,2);
        dmosim(1,2:2:imageWidth,3) = im(2,2:2:imageWidth);
        dmosim(1,(2:2:imageWidth)+1,3) = im(2,2:2:imageWidth);
        dmosim(2:2:imageHeight,imageWidth,3) = im(2:2:imageHeight,imageWidth-1);
        dmosim((2:2:imageHeight)-1,imageWidth,3) = im(2:2:imageHeight,imageWidth-1);
        dmosim(imageHeight,2:2:imageWidth,3) = im(imageHeight-1,2:2:imageWidth);
        dmosim(imageHeight,(2:2:imageWidth)-1,3) = im(imageHeight-1,2:2:imageWidth);
mosim(:,:,:) = dmosim(1:1:Height,1:1:Width,:);

