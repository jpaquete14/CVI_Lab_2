clear all, close all

frames = dir('Crowd_PETS09/S2/L1/Time_12-34/View_001/*.jpg');    
grandTruth = xmlread('PETS2009-S2l1.xml');
nFrames = length(frames);
tail = 20;
t = 30;
step = 53;


frameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(1).name];
frame = imread(frameName);
[rows, columns, numberOfColorChannels] = size(frame);

vid4D = zeros([rows columns 3 nFrames/step]);
% Background estimation
k = 1;
for i=1:step:nFrames
    frameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(i).name];
    img = imread(frameName);
    vid4D(:,:,:,k)=img;
    %imshow(img); drawnow
    k = k+1;
    %pause
end
bkg = median(vid4D,4);
% figure('Name', 'Background'),imshow(uint8(bkg));

%% Setup
densityValues = zeros([size(img, 1) size(img, 2)]);
errorsMemory = zeros(1, nFrames);
errorsRatioMemory = zeros(1, nFrames);
colorsForId = [];
idCounter = 1;
overlap_ratio_t = 0.3;

% For the first 
previousResults = cell(nFrames,1);
frameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(1).name];
frame = imread(frameName);
newImg = imsubtract(uint8(bkg), frame);

R = newImg(:,:,1) > t;
B = newImg(:,:,2) > t;
G = newImg(:,:,3) > t;
bw = imclose(R|G|B, strel('disk',3));
[lb num]=bwlabel(bw);
regionProps = regionprops(lb,'centroid', 'area', 'perimeter', 'BoundingBox');

regionsId = [];
regionBoundingBoxes = [];

for i=1:num
    if regionProps(i).Area > 100
         regionsId = [regionsId, idCounter];
         regionBoundingBoxes = [regionBoundingBoxes; regionProps(i).BoundingBox];
         idCounter = idCounter + 1;
         colorsForId = [colorsForId; [rand rand rand]];
    end    
end

previousResults{1} = [regionsId' regionBoundingBoxes];
%% Video looop
figure 

for f=2:nFrames-1
    f
    
    % Remove estimated background
    frameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f).name];
    frame = imread(frameName);
    newImg = imsubtract(uint8(bkg), frame);
    

    R = newImg(:,:,1) > t;
    B = newImg(:,:,2) > t;
    G = newImg(:,:,3) > t;
    bw = imclose(R|G|B, strel('disk',3));
    
    [lb num]=bwlabel(bw);
    
    regionProps = regionprops(lb,'centroid', 'area', 'perimeter', 'BoundingBox');
    imshow(frame);
    
    % Plot results
    regionsId = [];
    regionBoundingBoxes = [];

    hold on;
    for i=1:num
        if regionProps(i).Area > 100
            rectangle('Position',[regionProps(i).BoundingBox(1),regionProps(i).BoundingBox(2),regionProps(i).BoundingBox(3),regionProps(i).BoundingBox(4)],...
            'EdgeColor','r','LineWidth',2 )
%              plot(regionProps(i).Centroid(1),regionProps(i).Centroid(2),'ro');
             center_y = fix(regionProps(i).Centroid(1));
             center_x = fix(regionProps(i).Centroid(2));
             densityValues(center_x, center_y) = 1 + densityValues(center_x, center_y);
             
             % Compare with previous 
             max = 0;
             maxId = 0;
             for prev = previousResults{f-1}.'
                 prev_id = prev(1);
                 prev_bbox = [prev(2) prev(3) prev(4) prev(5)];
                 overlap_ratio = bboxOverlapRatio(prev_bbox, regionProps(i).BoundingBox);
                 if overlap_ratio > max
                       maxId = prev_id;
                       max = overlap_ratio;
                 end
             end
             
             if maxId > 0
                regionsId = [regionsId, maxId];
                regionBoundingBoxes = [regionBoundingBoxes; regionProps(i).BoundingBox];
                text(regionProps(i).BoundingBox(1), regionProps(i).BoundingBox(2) + regionProps(i).BoundingBox(4) + 10, strcat('id:', string(maxId)), 'FontSize',12, 'Color', 'r')
             else
                regionsId = [regionsId, idCounter];
                regionBoundingBoxes = [regionBoundingBoxes; regionProps(i).BoundingBox];
                text(regionProps(i).BoundingBox(1), regionProps(i).BoundingBox(2) + regionProps(i).BoundingBox(4) + 10, strcat('id:', string(idCounter)), 'FontSize',12, 'Color', 'r')
                idCounter = idCounter + 1;
                colorsForId = [colorsForId; [rand rand rand]];
             end 
        end    
        
        previousResults{f} = [regionsId' regionBoundingBoxes];
    end
    
    
    %Plot grand truth 
    currentFrame = grandTruth.getElementsByTagName('frame').item(f);
    gt_object = currentFrame.getElementsByTagName('object');
    
    error = 0;
    comparisions = 0;
    if gt_object.getLength() > 0
        for i = 0:(gt_object.getLength()-1)
            gt_id = gt_object.item(i).getAttribute('id');
            gt_w = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('w'));
            gt_h = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('h'));
            gt_xc = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('xc'));
            gt_yc = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('yc'));

            text(gt_xc-gt_w/2, gt_yc-gt_h/2-10, strcat('id:',char(gt_id)), 'FontSize',12, 'Color', 'g')
            rectangle('Position',[gt_xc-gt_w/2, gt_yc-gt_h/2, gt_w, gt_h], 'EdgeColor','g','LineWidth', 2);
            
            % Compute error
            for prev = previousResults{f-1}.'
                prev_bbox = [prev(2) prev(3) prev(4) prev(5)];
                error = error + bboxOverlapRatio(prev_bbox, [gt_xc, gt_yc, gt_w, gt_h]);
                comparisions = comparisions + 1;
            end
        end
    end
    
    
    errorsMemory(f) = error;
    errorsRatioMemory(f) = error/(comparisions+1); % +1 for normalizatino
    
    text(0, 10, strcat('Error:', string(errorsMemory(f))), 'FontSize',14, 'Color', 'r')
    text(0, 30, strcat('Error ratio:', string(errorsRatioMemory(f))), 'FontSize', 14, 'Color', 'r')
    
    % Plot points 
    for j = 0:min(tail, f-1)
        for prev = previousResults{f-j}.'
            colorsForId(prev(1))
            plot(fix(prev(2) + prev(4)/2), fix(prev(3) + prev(5)/2), 'Color', colorsForId(prev(1), :), 'Marker', '*');
        end 
    end
    
    hold off;
    pause(0.5);
end
%% Heatmap 
heatmap(imgaussfilt(densityValues,5));
ax = gca;
ax.XDisplayLabels = nan(size(ax.XDisplayData));
ax.YDisplayLabels = nan(size(ax.YDisplayData));
colormap hot;
grid off;

%% Show map
imshow(uint8(bkg));

hold on
for f = 1:nFrames
    for prev = previousResults{f}.'
        plot(fix(prev(2) + prev(4)/2), fix(prev(3) + prev(5)/2), 'Color', colorsForId(prev(1), :), 'Marker', '*');
    end 
end
hold off;
%% Plot errors

plot(errorsMemory)
%% Plot errors ratio

plot(errorsRatioMemory)
%%
% %% Motion field
% close all
% 
% figure
% for f=2:nFrames
%     frame1 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f-1).name]);
%     frame2 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f).name]);
% 
%     hold on;
%     opflow = opticalFlow(im2double(im2bw(frame2)),im2double(im2bw(frame1)));
%     plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
%     hold off;
%     pause(0.2)
% end
% 
% %% Diff between two images
% H = fspecial('sobel');
% figure
% subplot(1,4,1)
% frame1 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(1).name]);
% im1 = imfilter(im2bw(frame1), H,'replicate');
% imshow(im1)
% subplot(1,4,2)
% frame2 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(2).name]);
% im2 = imfilter(im2bw(frame2), H, 'replicate');
% imshow(im2)
% subplot(1,4,3)
% diff = imsubtract(im2, im1)
% imshow(diff)
% subplot(1,4,4)
% % blurred = imfilter(im2bw(frame2),H,'replicate'); 
% % imshow(blurred);
% figure
% imshow(diff);
% opflow = opticalFlow(im2double(im1),im2double(im2))
% plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
