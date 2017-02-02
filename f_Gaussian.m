function [ y ] = f_Gaussian( x, FWHM, mu, scaler )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if nargin <= 2 , mu = 0; end
if nargin <= 3 , scaler = 1; end

if length(scaler) < length(FWHM)
    scalerNew = ones(length(FWHM),1);
    scalerNew(1:length(scaler)) = scaler;
    scaler = scalerNew;
end
if length(mu) < length(FWHM)
    muNew = ones(length(FWHM),1);
    muNew(1:length(mu)) = mu;
    mu = muNew;
end

c = FWHM./2.35482;

y = zeros(length(x), length(FWHM));

for n = 1 : length(FWHM)
y(:,n) = scaler(n).*exp(-(x-mu(n)).^2/(2*c(n).^2));
end

