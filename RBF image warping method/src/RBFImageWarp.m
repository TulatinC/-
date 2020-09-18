function im2 = RBFImageWarp(im, psrc, pdst)
% get image (matrix) size and other basic paramentors

[h, w, ~] = size(im);
[num, ~] = size(psrc);

miu = 0.5;
im2 = im*0;

psrc(:,[1,2])=psrc(:,[2,1]);
pdst(:,[1,2])=pdst(:,[2,1]);

%% Solve the linear equations to get the coefficent omega and build the interpolation function
% each coefficient should be a two-dimentional vector so we can calculate
% them by parts

omega1 = zeros(1,num);
omega2 = zeros(1,num);

% solve the linear equtions

b1 = zeros(1, num);
b2 = zeros(1, num);
for i=1:num
    b1(1,i)=pdst(i,1)-psrc(i,1);
    b2(1,i)=pdst(i,2)-psrc(i,2);
end


% calculate ri
r = zeros(1, num);
for i=1:num
    r(1,i) = Inf;
    for j=1:num
        if(r(1,i) > norm(psrc(i,:)-psrc(j,:)) && i ~= j)
            r(1,i) = norm(psrc(i,:)-psrc(j,:));
        end
    end
end

%plug in the radial basis function
fp = zeros(num, num);
for i=1:num
    for j=1:num
        fp(i,j) = (norm(psrc(i,:)-psrc(j,:))^2+r(1,i)^2)^miu;
    end
end

omega1 = b1/fp;
omega2 = b2/fp;

% start to warp the image
% using the coefficient

for i=1:h
    for j=1:w
        x=i;
        y=j;
        for k=1:num
            x=x+omega1(k)*(norm([i,j]-psrc(k,:))^2+r(1,k)^2)^miu;
            y=y+omega2(k)*(norm([i,j]-psrc(k,:))^2+r(1,k)^2)^miu;
        end
        x = round(x);
        y = round(y);
        if(x>0 && x<h && y>0 && y<w)
            im2(x,y,:) = im(i,j,:);
        end
    end
end

end
