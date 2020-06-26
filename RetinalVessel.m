clc
clear all
close all


ImagePath = 'DRIVE\Test\images\';
MaskPath = 'DRIVE\Test\mask\';
ResultPath = 'DRIVE\Test\1st_manual\';

Images = dir(ImagePath);
Masks = dir(MaskPath);
Results = dir(ResultPath);

Accuracy = double(zeros(21, 1));
Specificity = double(zeros(21, 1));
Sensitivity = double(zeros(21, 1));

for n=1: 1: numel(Images)
    if Images(n).isdir == 0
        
        I = imread([ImagePath Images(n).name]);
        M = imread([MaskPath Masks(n).name]);
        C = imread([ResultPath Results(n).name]);

        I = I(:, :, 2); % extract green chanel it has better contrast than other channels
        [row, col] = size(I);

        for i=1: 1: row
            for j=1: 1: col

                I(i, j) = abs(255 - I(i, j)); % compleament green channel to make vessels white and backgroup darker

            end
        end

        I = adapthisteq(I, 'NumTiles', [16 16], 'ClipLimit', 0.02, 'Distribution', 'rayleigh', 'alpha', 0.85); % histogram equalizatoin with CLAHE method
        J = medfilt2(I, [4 4]); % use median filter for omiting some nises
        K = imtophat(J, offsetstrel('ball', 4, 3)); % use open morphological operation and subtract it from original image to make background black and foreground and some noises white
        K = imgaussfilt(K, 0.8); % because of huge numbers of noises it is hard to distingush noise and thin vessels so just use gussian filter to delete some noises

        level = multithresh(im2double(K)); % use outso threshholding
        L1 = imbinarize(1.3*K, level); %with this treshholding numbers of thin vessels are removed so multiply picture with a coeeficient to take them fro mthis treshhold also this add some noises too

        for i=1: 1: row
            for j=1: 1: col

                if M(i, j) == 255 && L1(i, j) == 1 % mask image to delete unneccessery pixels

                    L1(i, j) = 1;
                else

                    L1(i, j) = 0;

                end

            end
        end

        out = precision(C, uint8(L1*255), M); % this calculate TP, TN, FP, FN respectively into out array
        
        % calculate parameters
        Sensitivity (n-2) = double(out(1))/double((out(1) + out(4)));
        Specificity (n-2) = double(out(2))/double((out(2) + out(3)));
        Accuracy (n-2) = double((out(1) + out(2)))/double((out(1) + out(2) + out(3) + out(4)));
    end
end


% write results in a excel sheet
Sensitivity (21) = sum(Sensitivity)/20;
Specificity (21) = sum(Specificity)/20;
Accuracy (21) = sum(Accuracy)/20;
Table = table (Accuracy, Specificity, Sensitivity);
writetable (Table, 'Retinal Vessels.xlsx', 'Sheet', 'Sheet1', 'Range', 'A1');



