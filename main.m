close all;
tic;
all_images = dir('input_images\');           %% 读取\input_images目录下所有图象文件。可在MATLAB环境下直接键入all_images看该结构体的结构。注意，果有99个图片文件，则all_images中含有101个分量，因为还包括"."和".."

cd('input_images\');
image_0 = imread(all_images(3).name);        %% 读取第一幅图片，注意序号从"3"开始。
cd('..\');

[row, col, channel] = size(image_0);         %% 读取图片的大小、颜色信息
Y = zeros(row*col, length(all_images)-2);    %% 为Y变量预留内存空间。
if (channel == 3)                            %% channel返回3说明是颜色图片，否则是灰度图片 
    is_color = 1;
else
    is_color = 0;
end
 
for k = 3:length(all_images)
    %% 读取第k幅图片
    file_name = all_images(k).name;
    cd('input_images\');    
    image = imread(file_name,'bmp');
    cd('..\');
    
    if (is_color)
        image = rgb2gray(image);             %% 如果是颜色图片，则要转化为灰度图片
    end
            
    Y(:,k-2) = double(reshape(image,row*col,1));    %% 将图片的矩阵表达转化为向量表达，即将一个120*170的矩阵转化为一个20400*1的列矩阵，并作为Y的第k-2列。
    
end
Ymean = mean(Y,2);
Y = Y - Ymean * ones(1,size(Y,2));

%%% To get Ahat, Chat, ......     
T = size(Y, 2);
[U, Z, V] = svd(Y, 0);
%plot(diag(Z));
n = 50;
U = U(:, 1:n);
Chat = U;
Xhat = Z(1:n, 1:n) * V(:,1:n)';
x0 = Xhat(:,1);
Ahat = Xhat(:,2:T) * pinv(Xhat(:,1:(T - 1)));
Vhat = Xhat(:,2:T) - Ahat * Xhat(:, 1:(T - 1));
[Uv, Zv, Vv] = svd(Vhat, 0);
%plot(diag(Zv));
nv = 20;
Bhat = Uv(:, 1:nv) * Zv(1:nv, 1:nv) / sqrt(T - 1);

% 生成avi文件
video = VideoWriter('result.avi');
video.FrameRate = 20;
open(video);

X = x0;
for k = 1:2000 
    X = Ahat * X + Bhat * randn(nv,1);
    I = Chat * X + Ymean;
    I = floor(I);
    syn_img = reshape(I,[row,col]);
    
    % 调试用
%     imshow(syn_img,[0,255]);
%     title(strcat('Frame ',num2str(k)));
%     pause(0.001);
    % 对syn_img进行处理，使之可以被写入writeVideo中
    for i=1:size(syn_img,1)
         for j=1:size(syn_img,2)
             
             syn_img(i,j)=syn_img(i,j)/255;
             if syn_img(i,j)<0
                 syn_img(i,j)=0;
             end
             if syn_img(i,j)>1
                 syn_img(i,j)=1;
             end
         end
     end
    writeVideo(video, syn_img);
end
close(video);
toc
