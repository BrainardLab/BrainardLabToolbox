function [lRate,mRate,sRate] = IsomerizationsInEyeFunction(spd,S_spd)
% IsomerizationsInEyeFunction(spd,S_spd)
%
% Modified version of IsomerizationsInEyeDemo that computes
% cone isomerization rates for passed spectra.
%
% Can uncomment plot and printout section if you want to see
% some detail each time it is called.
%
% 12/13/09  dhb  Wrote it, once again since original was lost.
% 05/24/14  dhb  Updated but did not test.  
% 06/19/17  dhb  This was broken, because there was no source for pupil
%                diameter.  This might be because the behavior of
%                DefaultPhotoreceptors changed.
%                Fixed by setting this field to what the comments below say
%                it should be.  Not 100% sure behavior is what it used to
%                be.  The peak isomerization probs are close to but not
%                exactly the same as those in the comments below.  (Now get
%                0.384, 0.353, and 0.084].)  The parameter sources do,
%                however, match up with the comments.

%% Set some photoreceptor properties.  Here are is the parameter
% info filled in:
% 		photoreceptors.OSlength.source = 'Rodieck';
%           Rodieck, First Steps of Seeing, Appendix B.
%           33 um for each L, M, and S.
% 		photoreceptors.ISdiameter.source = 'Rodieck';
%           Rodieck, First Steps of Seeing, Appendix B.
%           2.3 um for each L, M, and S.
% 		photoreceptors.specificDensity.source = 'Rodieck';
%           Rodieck, First Steps of Seeing, Appendix B.
%           0.5 as axial optical density for each L, M, and S.
%           Divide by OSlength to get axial specific density of 0.0152
% 		photoreceptors.lensDensity.source = 'StockmanSharpe';
%           Lens transmittance obtained from Stockman, Sharpe, & Fach (1999).
% 		photoreceptors.macularPigmentDensity.source = 'Bone';
%           Macular transmittance from Bone et al.  See CVRL database.
% 		photoreceptors.pupilDiameter.source = 'PokornySmith';
%           Pupil diameter estimated from luminance according to:
%           Eq. 1 from: Pokorny and Smith, "How much light
%			reaches the retina", Colour Vision Deficiences XIII (C.
%			Cavonius, ed.), pp. 491-511.
% 		photoreceptors.eyeLengthMM.source = 'Rodieck';
%           Rodieck, First Steps of Seeing, Appendix B.
%           Taken as 16.1 mm
% 		photoreceptors.nomogram.source = 'StockmanSharpe';
%           StockmanSharpe photopigment nomogram.
%           http://cvrl.ioo.ucl.ac.uk/database/text/pigments/sstemplate.htm.
%           Also Stockman and Sharpe, 2000.
%           Lambda max: 558.9, 530.3, 420.7 nm
% 		photoreceptors.quantalEfficiency.source = 'Generic';
%           From Rodiek, First Steps of Seeing, page 472.
%           Taken as 0.667 for each cone type.
% These numbers lead to peak isomerization probabilities of
%       0.388, 0.353, and 0.094 for the LMS cones respectively.
whatCalc = 'LivingHumanFovea';
photoreceptors = DefaultPhotoreceptors(whatCalc);
photoreceptors = FillInPhotoreceptors(photoreceptors);
photoreceptors.pupilDiameter.source = 'PokornySmith';
photoreceptors.pupilDiameter.value = [];

%% Define common wavelength sampling for this script.
S = photoreceptors.nomogram.S;

%% We're going from radiance
% The original units are watts/sr-m^2-wlinterval.
radianceWatts = SplineSpd(S_spd,spd,S);

%% Find pupil area, needed to get retinal irradiance.  We compute
% pupil area based on the luminance of stimulus.
load T_xyz1931
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
theXYZ = T_xyz*radianceWatts; theLuminance = theXYZ(2);
[nil,pupilAreaMM] = PupilDiameterFromLum(theLuminance,photoreceptors.pupilDiameter.source);

%% Convert radiance of source to retinal irradiance and convert to quantal units.
irradianceWatts = RadianceToRetIrradiance(radianceWatts,S, ...
    pupilAreaMM,photoreceptors.eyeLengthMM.value);
        
irradianceQuanta = EnergyToQuanta(S,irradianceWatts);

%% Do the work in toolbox function
[isoPerConeSec,absPerConeSec,photoreceptors] = ...
	RetIrradianceToIsoRecSec(irradianceWatts,S,photoreceptors);

% Make a plot showing the effective photoreceptor sensitivities in quantal
% units, expressed as probability of isomerization.
% figure(2); clf; set(gcf,'Position',[100 400 700 300]);
% subplot(1,2,1); hold on
% set(plot(SToWls(S),irradianceQuanta,'r'),'LineWidth',2);
% set(title('Light Spectrum'),'FontSize',14);
% set(xlabel('Wavelength (nm)'),'FontSize',12);
% set(ylabel('Quanta/sec-um^2-wlinterval'),'FontSize',12);
% subplot(1,2,2); hold on
% set(plot(SToWls(S),photoreceptors.isomerizationAbsorptance(1,:),'r'),'LineWidth',2);
% set(plot(SToWls(S),photoreceptors.isomerizationAbsorptance(2,:),'g'),'LineWidth',2);
% set(plot(SToWls(S),photoreceptors.isomerizationAbsorptance(3,:),'b'),'LineWidth',2);
% set(title('Isomerization Absorptance'),'FontSize',14);
% set(xlabel('Wavelength (nm)'),'FontSize',12);
% set(ylabel('Probability'),'FontSize',12);
% axis([300 800 0 1]);

% Print out a table summarizing the calculation.
% fprintf('***********************************************\n');
% fprintf('Isomerization calculations for living human retina\n');
% fprintf('\n');
% fprintf('Calculations done using:\n');
% fprintf('\t%s estimates for photoreceptor IS diameter\n',photoreceptors.ISdiameter.source);
% fprintf('\t%s estimates for photoreceptor OS length\n',photoreceptors.OSlength.source);
% fprintf('\t%s estimates for receptor specific density\n',photoreceptors.specificDensity.source);
% fprintf('\t%s photopigment nomogram\n',photoreceptors.nomogram.source);
% fprintf('\t%s estimates for lens density\n',photoreceptors.lensDensity.source);
% fprintf('\t%s estimates for macular pigment density\n',photoreceptors.macularPigmentDensity.source);
% fprintf('\t%s method for pupil diameter calculation\n',photoreceptors.pupilDiameter.source);
% fprintf('\t%s estimate (%g mm) for axial length of eye\n',photoreceptors.eyeLengthMM.source,photoreceptors.eyeLengthMM.value);
% fprintf('\n');
% fprintf('Photoreceptor Type             |\t       L\t       M\t     S\n');
% fprintf('______________________________________________________________________________________\n');
% fprintf('\n');
% fprintf('Lambda max                     |\t%8.1f\t%8.1f\t%8.1f\t nm\n',photoreceptors.nomogram.lambdaMax);
% if (isfield(photoreceptors,'OSlength') & ~isempty(photoreceptors.OSlength.value))
%     fprintf('Outer Segment Length           |\t%8.1f\t%8.1f\t%8.1f\t um\n',photoreceptors.OSlength.value);
% end
% if (isfield(photoreceptors,'OSdiameter') & ~isempty(photoreceptors.OSdiameter.value))
%     fprintf('Outer Segment Diameter         |\t%8.1f\t%8.1f\t%8.1f\t um\n',photoreceptors.OSdiameter.value);
% end
% fprintf('Inner Segment Diameter         |\t%8.1f\t%8.1f\t%8.1f\t um\n',photoreceptors.ISdiameter.value);
% fprintf('\n');
% if (isfield(photoreceptors,'specificDensity') & ~isempty(photoreceptors.specificDensity.value))
%     fprintf('Axial Specific Density         |\t%8.3f\t%8.3f\t%8.3f\t /um\n',photoreceptors.specificDensity.value);
% end
% fprintf('Axial Optical Density          |\t%8.3f\t%8.3f\t%8.3f\n',photoreceptors.axialDensity.value);
% fprintf('Bleached Axial Optical Density |\t%8.3f\t%8.3f\t%8.3f\n',photoreceptors.axialDensity.bleachedValue);
% fprintf('Peak isomerization prob.       |\t%8.3f\t%8.3f\t%8.3f\n',max(photoreceptors.isomerizationAbsorptance,[],2));
% fprintf('______________________________________________________________________________________\n');
% fprintf('\n');
% fprintf('Absorption Rate                |\t%4.2e\t%4.2e\t%4.2e\t quanta/photoreceptor-sec\n',...
% 	absPerConeSec);
% fprintf('Isomerization Efficiency       |\t%8.3f\t%8.3f\t%8.3f\n',...
% 	photoreceptors.quantalEfficiency.value);
% fprintf('Isomerization Rate             |\t%4.2e\t%4.2e\t%4.2e\t iso/photoreceptor-sec\n',...
% 	 isoPerConeSec);
% fprintf('In log10 units                 |\t%8.2f\t%8.2f\t%8.2f\t log10(iso)/photoreceptor-sec\n',...
% 	 log10(isoPerConeSec));
% fprintf('______________________________________________________________________________________\n');

% Report isomerizations per cone/sec

%% Return values
lRate = isoPerConeSec(1);
mRate = isoPerConeSec(2);
sRate = isoPerConeSec(3);
