function [Q, R] = blendImagePoisson1(im1, im2, roi, targetPosition)

roi(:,[1,2])=roi(:,[2,1]);
targetPosition(:,[1,2])=targetPosition(:,[2,1]);

dh = round(targetPosition(1,1)-roi(1,1));
dw = round(targetPosition(1,2)-roi(1,2));

[h1, w1, ~] = size(im1);

num = 0;

% calculating the number of the points
% as well as constructing the indicating matrix(map) to fix the order of the
% points

map = zeros(h1, w1);
for i=1:h1
    for j=1:w1
        if(inPoly([i, j], targetPosition)==1)
            num = num+1;
            map(i,j) = num;
        end
    end
end


laplacian_mask = [0 1 0;1 -4 1;0 1 0];
lap = imfilter(im2, laplacian_mask);

A=zeros(num,num);
% construct B
B=zeros(num,3);
% construct A
cnt = 0;
for i=2:h1-1
    for j=2:w1-1
        if map(i,j)>0
            cnt = cnt+1;
            A(cnt,cnt) = 4;            
            if map(i-1,j)==0
                B(cnt,:) = reshape(im1(i-1,j,:),[],1);
            else
                A(cnt,map(i-1,j)) = -1;
            end
            
            if map(i+1,j)==0
                for k=1:3
                    B(cnt,k) = B(cnt,k)+im1(i+1,j,k);
                end
            else
                A(cnt,map(i+1,j)) = -1;
            end
              
            if map(i,j-1)==0
                for k=1:3
                    B(cnt,k) = B(cnt,k)+im1(i,j-1,k);
                end
            else
                A(cnt,map(i,j-1)) = -1;
            end
            
            if map(i,j+1)==0
                for k=1:3
                    B(cnt,k) = B(cnt,k)+im1(i,j+1,k);
                end
            else
                A(cnt,map(i,j+1)) = -1;
            end
            
            for k=1:3
                B(cnt,k)=B(cnt,k)-lap(i-dh,j-dw,k);
            end
        end
    end
end

[Q,R] = qr(A);

end

%% jundge a point is in the area or not
function flags = inPoly(p,poly)
% �жϵ��Ƿ��ڶ������
% flag(i)Ϊ��������function flags = inPoly(p,poly)
% �жϵ��Ƿ��ڶ������
% flag(i)Ϊ1����ô�ڣ�0Ϊ����

if ~(poly(1,1) == poly(end,1)&&poly(1,2) == poly(end,2))
    poly = [poly;poly(1,:)];
end

pn = size(p,1);
polyn = size(poly,1);
flags = zeros(1,pn);
for i=1:pn

    if ~isempty(find(poly(:,1)==p(i,1)& poly(:,2)==p(i,2), 1))%�ҵ�һ����ͬ�ĵ㼴��
        flags(i) = 1;
        continue;%%����pn=1������pn=2
    end
    for j=2:polyn
        if ((((poly(j,2)<=p(i,2)) && (p(i,2) < poly(j-1,2) )) ||...
                ((poly(j-1,2) <= p(i,2)) && (p(i,2) < poly(j,2)))) && ...
                (p(i,1) < (poly(j-1,1) - poly(j,1)) * (p(i,2) - poly(j,2))/(poly(j-1,2)-poly(j,2)) + poly(j,1)))
            flags(i) = flags(i) + 1;
        end
    end
end
flags = mod(flags,2);

end

