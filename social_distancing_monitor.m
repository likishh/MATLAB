function social_distancing_monitor()
    % Create the main figure and center it on the screen
    fig = figure('Name', 'Social Distancing Monitor');
    movegui(fig, 'center'); % Center the figure on the screen
    
    % Create axes for displaying the uploaded image
    axesCanvas = axes('Parent', fig, 'Position', [0.1, 0.3, 0.8, 0.6]);
    
    % Create buttons for uploading an image and checking distance
    btnUploadImage = uicontrol('Style', 'pushbutton', 'String', 'Upload Image', 'Position', [20, 20, 120, 30], 'Callback', @uploadImageCallback);
    btnCheckDistance = uicontrol('Style', 'pushbutton', 'String', 'Check Distance', 'Position', [160, 20, 120, 30], 'Callback', @checkDistanceCallback);
    
    % Initialize variables
    uploadedImage = []; % Store the uploaded image
    
    % Function to upload an image
    function uploadImageCallback(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'}, 'Select an image');
        if isequal(filename, 0)
            return; % User canceled the dialog
        end
        
        fullImagePath = fullfile(pathname, filename);
        uploadedImage = imread(fullImagePath);
        imshow(uploadedImage, 'Parent', axesCanvas);
    end

    % Function to check the distance in the uploaded image
    function checkDistanceCallback(~, ~)
        if isempty(uploadedImage)
            msgbox('Please upload an image first.', 'Error', 'error', 'modal');
            return;
        end
        
        % Perform color-based segmentation to detect people (red color assumption)
        redChannel = uploadedImage(:, :, 1);
        binaryImage = redChannel > 100; % Adjust the threshold as needed
        
        % Apply morphological operations to clean the binary image
        se = strel('disk', 10); % Adjust the disk size as needed
        binaryImage = imopen(binaryImage, se);
        binaryImage = imclose(binaryImage, se);
        
        % Measure the distance between connected components
        labeledImage = bwlabel(binaryImage, 8);
        stats = regionprops(labeledImage, 'Centroid');
        
        % Calculate distances between centroids (simple Euclidean distance)
        distances = pdist(cat(1, stats.Centroid));
        
        % Calculate the minimum distance
        minDistance = min(distances);
        
        % Set a minimum distance threshold (you can adjust this as needed)
        minDistanceThreshold = 100; % Adjust as needed
        
        % Display the result message centered on the screen
        if minDistance < minDistanceThreshold
            msgbox('There is not enough distance between people.', 'Result', 'warn', 'modal');
        else
            msgbox('There is enough distance between people.', 'Result', 'help', 'modal');
        end
    end
end
