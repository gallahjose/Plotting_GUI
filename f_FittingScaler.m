function [x] = f_FittingScaler(y, Scaler, Direction)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%Direction = 1 then gives scalled values between -0.5, 0.5

if Direction
    x = (y - 0.5 * (Scaler(:,2) + Scaler(:, 1))) ./ (Scaler(:, 2) - Scaler(:, 1));
else
    x = y.*(Scaler(:,2) - Scaler(:,1)) + 0.5.*(Scaler(:,2) + Scaler(:,1));
end

end