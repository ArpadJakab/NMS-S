%get the spectra of a measurement, with a given position
function Spec = timeCalcSpec(img, x_pos, x_width, y_pos, y_width, white)

%returns a spectrum of a measurement, if the position is already known
%img: image (400*1340pixels) with spectra
%x_pos: starting x-pos of the roi
%x_width: x-size of the roi
%y_pos: y-position in the image, where one spectra is positioned
%y_width: y-size of the roi
%white: spectrum of the whitligth

S=img([x_pos:(x_pos+x_width-1)],[y_pos:(y_pos+y_width-1)]);
S1=sum(S,2);
try
    Backg1=sum(img([x_pos:(x_pos+x_width-1)],[(y_pos-round(y_width/2)):(y_pos-1)]),2);
catch
    error(lasterr);
end
    
Backg2=sum(img([x_pos:(x_pos+x_width-1)],[(y_pos+y_width):y_pos+floor(1.5*y_width)-1]),2);
%round macht bei ungerade zahler von y_width den größeren teil, floor nimmt
%den kleineren teil

%correct Background
S2=S1-Backg1-Backg2;

%correct Whitelight
S3=S2./white([x_pos:(x_pos+x_width-1)]);

%smooth Data
Spec=smooth(S3,50);
