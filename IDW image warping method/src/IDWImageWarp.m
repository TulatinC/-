function im2 = IDWImageWarp(im, psrc, pdst)

% input: im, psrc, pdst

%% basic image manipulations
% get image (matrix) size
[h, w, ~] = size(im);
[num, ~] = size(psrc);

im2 = im*0;

psrc(:,[1,2])=psrc(:,[2,1]);
pdst(:,[1,2])=pdst(:,[2,1]);

%% get the warpped image
% using the interpolation function given by the paper
for i=1:h
    for j=1:w
        weight = Weight_function([i,j],psrc);
        fi=zeros(num,2);
        for k = 1:num
            fi(k,:) = pdst(k,:)+([i,j]-psrc(k,:));
        end
        x = round(dot(weight,fi(:,1)));
        y = round(dot(weight,fi(:,2)));
        if(x>0 && x<h && y>0 && y<w)
            im2(x,y,:)=im(i,j,:);
        end
    end
end
end

%% the function to calculate the weights
% this subfunction sets miu = 1
function weight = Weight_function(p,psrc)
    [num,~] = size(psrc);
    weight = zeros(num,1);
    delta = zeros(num,1);
    u = 1;
    for k = 1:num
        delta(k) = 1/(norm(psrc(k,:)-p))^u;
    end
    for k = 1:num
        weight(k) = delta(k)/sum(delta);
    end
end
