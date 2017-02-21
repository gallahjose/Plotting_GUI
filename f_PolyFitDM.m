function [ designMatrix ] = f_PolyFitDM( X, degPoly, opt )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    if opt.poly
        designMatrix = ones(length(X),degPoly);
        designMatrix = bsxfun(@times,designMatrix,X);
        designMatrix = bsxfun(@power,designMatrix,1:degPoly);  
    else
        designMatrix = ones(length(X),1);
        designMatrix = bsxfun(@times,designMatrix,X);
        designMatrix = bsxfun(@power,designMatrix,degPoly);
    end
    
    if opt.fitConstant
        designMatrix = [ones(length(X),1),designMatrix,]; % adds constant term
    end
end

