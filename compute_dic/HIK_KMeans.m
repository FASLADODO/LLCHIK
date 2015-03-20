function [postIdxes] = HIK_KMeans(dicSize, allSifts, imageSeparateRecord, maxH)
%ʹ��histogram intersection kernel�����ص���ÿ��cluster����Ӧ��sift��������
%   ����Ӧ�÷���һ��Ԫ�����飬ÿһ�е�ά���ǲ�һ����

%step 1 : ����computeKmeans,���B
[B]= computeKMeans(dicSize, allSifts, imageSeparateRecord);

disp(['Starting compute hik kmeans......']);
 B = B';
[m, n] = size(allSifts);
preIdxes = cell(dicSize, 1);

fid = fopen('log.txt', 'a+');
fprintf(fid, 'computing preidxes...\n');
for jj = 1:n
    curSift = allSifts(:, jj);
    temp = repmat(curSift, [1, dicSize]) - B;
    temp = temp .^ 2;
    temp = sum(temp, 1);
    [Y, I] = min(temp);
    %����Euclidean distance, ��¼ÿ��sift����cluster
    preIdxes{I} = [preIdxes{I}; jj];
end
fprintf(fid, 'computing predixes done!\n');
%step2 : HIK visual codebook generation
epsilon = 1; 
preError = 10000000;
iter = 1;
while(iter <= 13)
    
    fprintf(fid, 'iteration: %d\n', iter);
    fprintf(1, 'iteration: %d\n', iter);
    iter = iter + 1;
    postIdxes = cell(dicSize, 1);
    
    %����ÿ��hikTable{i}�ڲ���
    % sigma_j,k  K(h_j, h_k) / |PI_i| ^ 2;
    iniDises = zeros(dicSize, 1);
    fprintf(fid, 'Computing innerKernelSum......\n');
    fprintf(fid, '%s\n', datestr(now));
   
    for ii = 1:dicSize;
        iniDises(ii) = innerKernelSum(allSifts(:, preIdxes{ii}));
    end

    fprintf(fid, '%s\n', datestr(now));
     fprintf(fid, 'Computing innerKernelSum done!\n');
    %����hikTables
    hikTables = cell(dicSize, 1);
   
    fprintf(fid, 'Computing hikTables ......\n');
    fprintf(fid, '%s\n', datestr(now));
    for ii = 1:dicSize
        hikTables{ii} = buildTable(allSifts(:, preIdxes{ii}), maxH);
    end

    fprintf(fid, '%s\n', datestr(now));
    fprintf(fid, 'Computing hikTables done!\n');
    %��ÿ��������feature space�۵�һ�������
    fprintf(fid, 'Running k means in mapping space......\n');
    fprintf(fid, '%s\n', datestr(now));
    dises = interKernelSum(allSifts, hikTables, preIdxes);
    for ii = 1:dicSize
        dises(ii, :) = -2 * dises(ii, :);
    end
    iniDises = repmat(iniDises, [1, n]);
    dises = dises + iniDises;
    [Y, I] = min(dises, [], 1);
    postError = sum(Y);
    %postError = sum(Y) / n;
    %
    
    %for jj =1:n
    %    postIdxes{I(jj)} = [postIdxes{I(jj)}; jj];
    %    ��εĸ�ֵ����̫��,����һ�δ���ʵ��ͬ���Ĺ���
    %end
  
    for jj = 1:dicSize
        idxes = find(I == jj);
        postIdxes{jj} = idxes;
    end
    fprintf(fid, '%s\n', datestr(now));
    fprintf(fid, 'Running k means done!\n');
    fprintf(fid, 'preError , postError, preError - postError \n');
    fprintf(fid, '%lf        %lf         %lf\n', preError, postError, preError - postError);
    if (abs(preError - postError) <= epsilon)
        break;
    end
    preError = postError;
    preIdxes = postIdxes;
    
end
fprintf(fid, 'Computing hik kmeans done!\n');
disp(['Computing hik kmeans done!\n']);
fclose(fid);
end
