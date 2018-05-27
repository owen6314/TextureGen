close all;
tic;
all_images = dir('input_images\');           %% ��ȡ\input_imagesĿ¼������ͼ���ļ�������MATLAB������ֱ�Ӽ���all_images���ýṹ��Ľṹ��ע�⣬����99��ͼƬ�ļ�����all_images�к���101����������Ϊ������"."��".."

cd('input_images\');
image_0 = imread(all_images(3).name);        %% ��ȡ��һ��ͼƬ��ע����Ŵ�"3"��ʼ��
cd('..\');

[row, col, channel] = size(image_0);         %% ��ȡͼƬ�Ĵ�С����ɫ��Ϣ
Y = zeros(row*col, length(all_images)-2);    %% ΪY����Ԥ���ڴ�ռ䡣
if (channel == 3)                            %% channel����3˵������ɫͼƬ�������ǻҶ�ͼƬ 
    is_color = 1;
else
    is_color = 0;
end
 
for k = 3:length(all_images)
    %% ��ȡ��k��ͼƬ
    file_name = all_images(k).name;
    cd('input_images\');    
    image = imread(file_name,'bmp');
    cd('..\');
    
    if (is_color)
        image = rgb2gray(image);             %% �������ɫͼƬ����Ҫת��Ϊ�Ҷ�ͼƬ
    end
            
    Y(:,k-2) = double(reshape(image,row*col,1));    %% ��ͼƬ�ľ�����ת��Ϊ����������һ��120*170�ľ���ת��Ϊһ��20400*1���о��󣬲���ΪY�ĵ�k-2�С�
    
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

% ����avi�ļ�
video = VideoWriter('result.avi');
video.FrameRate = 20;
open(video);

X = x0;
for k = 1:2000 
    X = Ahat * X + Bhat * randn(nv,1);
    I = Chat * X + Ymean;
    I = floor(I);
    syn_img = reshape(I,[row,col]);
    
    % ������
%     imshow(syn_img,[0,255]);
%     title(strcat('Frame ',num2str(k)));
%     pause(0.001);
    % ��syn_img���д���ʹ֮���Ա�д��writeVideo��
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
