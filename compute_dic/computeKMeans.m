function [B] = computeKMeans(dicSize, allSifts, imageSeparateRecord)
%���룺siftĿ¼
%�����Kmeans�ļ��� $15Scenes_SIFT_Kmeans_1024.mat

path(path, './PG_SPBOW');
path(path, '.\PG_SPBOW');

disp(size(allSifts));
disp(['Computing k means......']);
disp('Transposing......');
allSifts = allSifts';
disp('After transpose!');
%[idx, C] = kmeans(allSifts, 1024, 'OnlinePhase', 'on');
%����GP_SPBOW��kmenas
%disp(imageSeparateRecord);
C = calculateDictionaryLP(dicSize, allSifts, imageSeparateRecord);
B = C;
end
