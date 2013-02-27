%function to calculate E_res FWHM and Intensity in Maximum
function [E_res FWHM Int]=timeDataAnalysis(S,lambda);

[a b]=max(S);

temp=find(S>a/2);
FWHM_r=lambda(max(temp));
FWHM_l=lambda(min(temp));

FWHM=1240/FWHM_l-1240/FWHM_r;
E_res=1240/lambda(b);
Int=a;
