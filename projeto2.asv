clear all, close all

frames = dir('Crowd_PETS09/S2/L1/Time_12-34/View_001/*.jpg');    
grandTruth = xmlread('PETS2009-S2l1.xml');
nFrames = length(frames);
t = 30
tail = 5 % how much of the previous results 
%figure,
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
figure('Name', 'Background'),imshow(uint8(bkg));


%% Bounding boxes
figure
densityValues = zeros([size(img, 1) size(img, 2)])

% Have a counter with ids 
idCounter = 1 

oldFrameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(1).name];
oldFrame = imread(olfFrameName);
oldImg = imsubtract(uint8(bkg), oldFrame);

 
 R = oldImg(:,:,1) > t;
 B = oldImg(:,:,2) > t;
 G = oldImg(:,:,3) > t;
 oldBw = imclose(R|G|B, strel('disk',3));
 arrays = [];
 array_of_results = []; 
     [oldLb oldNum]=bwlabel(oldBw);
     oldRegionProps = regionprops(oldLb,'centroid', 'area', 'perimeter', 'BoundingBox');
 
     for i=1:num
        if oldRegionProps(i).Area > 100
            array_of_results(:, :, idCounter) = [idCounter oldRegionProps(i).BoundingBox];
            idCounter = idCounter+1;
        end
     end
  arrays(:,:,:,1) = array_of_results;
            
%     Assign the ids to bounding boxes
% end
% end

arrays = {arrays array_of_results};



for f=2:nFrames-1
    f
    
    % Simple method
%     frame1 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f-1).name]);
%     frame2 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f).name]);
%     bw = imclose(abs(rgb2gray(frame2)-rgb2gray(frame1)), strel('disk',1));
    
    % Remove estimated background
    frameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f).name];
    frame = imread(frameName);
    newImg = imsubtract(uint8(bkg), frame);
    
    %previousFrameName = ['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f-1).name];
    %previousFrame = imread(previousFrameName);
    %previousImg = imsubtract(uint8(bkg), previousFrame);


    R = newImg(:,:,1) > t;
    B = newImg(:,:,2) > t;
    G = newImg(:,:,3) > t;
    bw = imclose(R|G|B, strel('disk',3));
    
    [lb num]=bwlabel(bw);
    
    regionProps = regionprops(lb,'centroid', 'area', 'perimeter', 'BoundingBox');
    imshow(frame);
    
    % Plot results
    hold on;
    regionCounter=0;
    for i=1:num
        array_of_results = [];
        if regionProps(i).Area > 100
            regionCounter = regionCounter+1;
            rectangle('Position',[regionProps(i).BoundingBox(1),regionProps(i).BoundingBox(2),regionProps(i).BoundingBox(3),regionProps(i).BoundingBox(4)],...
            'EdgeColor','r','LineWidth',2 )
             %plot(regionProps(i).Centroid(1),regionProps(i).Centroid(2),'ro');
             center_y = fix(regionProps(i).Centroid(1));
             center_x = fix(regionProps(i).Centroid(2));
             densityValues(center_x, center_y) = 1 + densityValues(center_x, center_y);
             
             max = 0;
             maxIndex;
             old_array_of_results = arrays(:,:,:,f-1)
%              array_of_results (time frame) 
             for j=1:length(old_array_of_results)
                item = old_array_of_results(:,:,j)
                bbox = item(2)
                id = item(1)
                aux = bboxOverlapRatio(regionProps(i).BoundingBox, bbox, 'Union');
                if aux > max
                    max = aux;
                    maxIndex = id;  
                end
             end
             if max == 0
                 maxIndex = idCounter;
                 idCounter = idCounter+1;
             end
             array_of_results(:,:,regionCounter) = [maxIndex regionProps(i).BoundingBox];
%                 array = {
%                  id =   if (new) idCOunter++ else maxId
%                  bounding box 
%                 }
                 
             %currentBbox = [center_x, center_y, i];
             %currentBboxes = [currentBboxes; currentBbox];
        end    
        arrays(:,:,:,f) = array_of_results;
        % append new array with {id, boundingbox) 
        
        %print path
        for i=1:tail
            array = arrays(:,:,:,end-i);
            for j=1:length(array)
                %plot(array{2}(1),regionProps(i).Centroid(2),'ro');
            end
        end
        % take last $tail + 1 array_of_results and plot the centroids but only
        % for the ones that are still visible  (the ids tha are in current
        % arrat with {id, boundingbox) 
    end
    
    
    %Plot grand truth 
    currentFrame = grandTruth.getElementsByTagName('frame').item(f);
    gt_object = currentFrame.getElementsByTagName('object');
    
    if gt_object.getLength() > 0
        for i = 0:(gt_object.getLength()-1)
            gt_id = gt_object.item(i).getAttribute('id');
            gt_w = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('w'));
            gt_h = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('h'));
            gt_xc = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('xc'));
            gt_yc = str2double(gt_object.item(i).getElementsByTagName('box').item(0).getAttribute('yc'));

            text(gt_xc-gt_w/2, gt_yc-gt_h/2-10, strcat('id:',char(gt_id)), 'FontSize',12, 'Color', 'g')
            rectangle('Position',[gt_xc-gt_w/2, gt_yc-gt_h/2, gt_w, gt_h], 'EdgeColor','g','LineWidth', 2);
            
            %find closest point in current frame
            min = 1000;
            minIndex = 0;
            for i=1:length(array(:,:,f))
                if norm([gt_xc gt_yc] - [xBboxes(i) yBboxes(i)]) < min
                    minIndex = i;
                end
            end
            
            %calculate error
            if bboxOverlapRatio()
            
                %              array_of_results (time frame) 
%              for j=1:old_num
%                 if previousRegionProps(j).Area > 100
%                     aux = bboxOverlapRatio(regionProps(i).BoundingBox, previousRegionProps(j).BoundingBox, 'Union');
%                     if aux > max
%                         max = aux;
%                         maxIndex = j;  
%                     end
%                 end
%              end to compute error erroArray -> nFrames 
             
            %add bbox to dictionaries
            if isKey(, gt_id) == 1
                dict(gt_id) = [dict(gt_id) currentBboxes{minIndex}(1:end-1)]
            else
                dict(gt_id) = [currentBboxes{minIndex}(1:end-1)];
            end
            
        end
    end
    
    hold off;
    
    %Plot previous points
    %{
    for i=1:length(previous_locations)
        plot(previous_locations{i}(1),previous_locations{i}(2),'r.');
    end
    %}
    
  
    pause(0.1);
end
%% Heatmap 
heatmap(imgaussfilt(densityValues,5));
ax = gca;
ax.XDisplayLabels = nan(size(ax.XDisplayData));
ax.YDisplayLabels = nan(size(ax.YDisplayData));
colormap hot;
grid off;

%% Motion field
close all

figure
for f=2:nFrames
    frame1 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f-1).name]);
    frame2 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(f).name]);

    hold on;
    opflow = opticalFlow(im2double(im2bw(frame2)),im2double(im2bw(frame1)));
    plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
    hold off;
    pause(0.2)
end

%% Diff between two images
H = fspecial('sobel');
figure
subplot(1,4,1)
frame1 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(1).name]);
im1 = imfilter(im2bw(frame1), H,'replicate');
imshow(im1)
subplot(1,4,2)
frame2 = imread(['Crowd_PETS09/S2/L1/Time_12-34/View_001/' frames(2).name]);
im2 = imfilter(im2bw(frame2), H, 'replicate');
imshow(im2)
subplot(1,4,3)
diff = imsubtract(im2, im1)
imshow(diff)
subplot(1,4,4)
% blurred = imfilter(im2bw(frame2),H,'replicate'); 
% imshow(blurred);
figure
imshow(diff);
opflow = opticalFlow(im2double(im1),im2double(im2))
plot(opflow,'DecimationFactor',[10 10],'ScaleFactor',10);
