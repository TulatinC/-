function toolPasteCB(varargin)

hpolys = evalin('base', 'hpolys');

roi = hpolys(1).getPosition();
targetPosition = roi + ceil(hpolys(2).getPosition() - roi);

im1 = evalin('base', 'im1');
im2 = evalin('base', 'im2');
himg = evalin('base', 'himg');

[Q, R] = blendImagePoisson1(im1, im2, roi, targetPosition);
imdst = blendImagePoisson2(im1, im2, roi, targetPosition, Q, R);

set(himg, 'CData', imdst);