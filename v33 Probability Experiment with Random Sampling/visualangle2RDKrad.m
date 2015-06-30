function [aperture_rad_px] = visualangle2RDKrad(width_cm, height_cm, width_px, height_px, screen_dist) %screen_dist in cm
% Find the size of the RDK in pixels, given the screen size in cm and the
% screen resolution in px. Use a visual angle of 8.1 for consitency with
% earlier experiments. Calculation for this is under end.

visual_angle = 8.10; %we want the visual angle of the RDK to be 8.1 (in any direction) - the calculation for this is below
width_ppc = width_px/width_cm; %find screen res in pixels per cm
height_ppc = height_px/height_cm; %height in pixels per cm
if round(width_ppc) ~= round(height_ppc)
    error('Did you input the correct screen width and height?')
end
aperture_diam_cm = screen_dist*tand(visual_angle); %find RDK with in cm; tan visual angle = height/dist; units must be the same
aperture_rad_cm = aperture_diam_cm/2; %diameter to radius
aperture_rad_px = aperture_rad_cm*width_ppc; %use pixels per cm resolution to convert to RDK width in px
aperture_rad_px = round(aperture_rad_px);
end

% % Visual angle for SB3 screens (Width: 41cm; Height: 25.5cm; Stimulus
% % aperture radius: 200px; Screen resolution: 1440 x 900; Distance from screen: 80cm)
% %Inputs
% width_cm = 41;
% height_cm = 25.5;
% width_px = 1440;
% height_px = 900;
% aperture_rad_px = 200;
% screen_dist = 80;
% %Calculations
% width_ppc = width_px/width_cm; %find screen res in pixels per cm
% height_ppc = height_px/height_cm; %pixels per cm
% if round(width_ppc) ~= round(height_ppc)
%     error('Did you input the correct screen width and height?')
% end
% aperture_rad_cm = aperture_rad_px/width_ppc; %find RDK radius in cm using pix per cm resolution
% aperture_diam_cm = 2*aperture_rad_cm; %for diameter, double radius
% visual_angle = atand(aperture_diam_cm/screen_dist); %tan visual angle = height/dist; units must be the same