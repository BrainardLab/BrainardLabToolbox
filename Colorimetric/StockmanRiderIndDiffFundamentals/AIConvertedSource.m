%% Complete CMF MATLAB Functions - Converted from Python
% Color Matching Function calculations and templates
% Based on Stockman & Sharpe cone fundamentals

%% =================================================================
%% CMFcalc functions - Core calculation routines
%% =================================================================










f

%% =================================================================
%% CMFtemplates functions - Template generation
%% =================================================================

function y = LMSconelogcommon(nm, LMS_type, shift)
    % Best-fitting log-lin 8x2 Fourier Series Polynomial
    
    Lsercommonlmax = 557.5;
    Lalacommonlmax = 554.8;
    Mcommonlmax = 527.3;
    Scommonlmax = 418.5;
    
    % Log shifts in lmax from Lser with log 390 to log 850 scaled 0 to pi
    Soffset = -1.048690123;
    Moffset = -0.2036522967;
    Lalaoffset = -0.01775262143;
    Lseroffset = 0;
    
    x = (log10(nm)-2.556302500767287267)/0.1187666467581842301;
    
    switch LMS_type
        case 'Lser'
            x = x + Lseroffset + log10(Lsercommonlmax/(Lsercommonlmax+shift))/0.1187666467581842301;
        case 'Lala'
            x = x + Lalaoffset + log10(Lalacommonlmax/(Lalacommonlmax+shift))/0.1187666467581842301;
        case 'M'
            x = x + Moffset + log10(Mcommonlmax/(Mcommonlmax+shift))/0.1187666467581842301;
        case 'S'
            x = x + Soffset + log10(Scommonlmax/(Scommonlmax+shift))/0.1187666467581842301;
        otherwise
            error('Cone type not specified');
    end
    
    c = [-2.1256563197, 5.4677929400, 0.8960658918, -0.9530108239, -5.0377095815, ...
         -3.0039987529, -0.9508620342, -1.3670849620, 1.7702113766, 0.5165048525, ...
         1.1505501831, 0.6100416117, 0.0518211044, 0.1009282570, -0.1773573074, ...
         -0.0278798136, -0.0427736834, 0.0007050030];
    
    y = c(1) + c(2)*cos(x) + c(3)*sin(x) + c(4)*cos(2*x) + c(5)*sin(2*x) + ...
        c(6)*cos(3*x) + c(7)*sin(3*x) + c(8)*cos(4*x) + c(9)*sin(4*x) + ...
        c(10)*cos(5*x) + c(11)*sin(5*x) + c(12)*cos(6*x) + c(13)*sin(6*x) + ...
        c(14)*cos(7*x) + c(15)*sin(7*x) + c(16)*cos(8*x) + c(17)*sin(8*x) + c(18);
end

function y = Lserconelog(nm, Lshift)
    x = (log10(nm)-2.556302500767287267)/0.1187666467581842301;
    
    Lserlmax_template = 553.1;
    xshift = log10(Lserlmax_template/(Lserlmax_template+Lshift))/0.1187666467581842301;
    x = x + xshift;
    
    c = [-42.417608560, -2.656791612, 75.011093607, 56.477062776, 7.509397607, ...
         9.061442173, -38.068488495, -20.974610259, -6.642746250, -3.785039126, ...
         9.322071459, 3.134494745, 1.603799055, 0.439302358, -0.676958684, ...
         -0.072988371, -0.078857510, -0.004264105];
    
    y = c(1) + c(2)*cos(x) + c(3)*sin(x) + c(4)*cos(2*x) + c(5)*sin(2*x) + ...
        c(6)*cos(3*x) + c(7)*sin(3*x) + c(8)*cos(4*x) + c(9)*sin(4*x) + ...
        c(10)*cos(5*x) + c(11)*sin(5*x) + c(12)*cos(6*x) + c(13)*sin(6*x) + ...
        c(14)*cos(7*x) + c(15)*sin(7*x) + c(16)*cos(8*x) + c(17)*sin(8*x) + c(18);
end

function y = Mconelog(nm, Mshift)
    x = (log10(nm)-2.556302500767287267)/0.1187666467581842301;
    
    Mlmax_template = 529.9;
    xshift = log10(Mlmax_template/(Mlmax_template+Mshift))/0.1187666467581842301;
    x = x + xshift;
    
    c = [-210.6568853069, -0.1458073553, 386.7319763250, 305.4710584670, 5.0218382813, ...
         6.8386224350, -208.2062335724, -118.4890200521, -5.7625866330, -3.7973553168, ...
         55.1803460639, 19.9728512548, 1.8990456325, 0.6913410864, -5.0891806213, ...
         -0.7070689492, -0.1419926703, 0.0005894876];
    
    y = c(1) + c(2)*cos(x) + c(3)*sin(x) + c(4)*cos(2*x) + c(5)*sin(2*x) + ...
        c(6)*cos(3*x) + c(7)*sin(3*x) + c(8)*cos(4*x) + c(9)*sin(4*x) + ...
        c(10)*cos(5*x) + c(11)*sin(5*x) + c(12)*cos(6*x) + c(13)*sin(6*x) + ...
        c(14)*cos(7*x) + c(15)*sin(7*x) + c(16)*cos(8*x) + c(17)*sin(8*x) + c(18);
end

function y = Sconelog(nm, Sshift)
    x = (log10(nm)-2.556302500767287267)/0.1187666467581842301;
    
    Slmax_template = 416.9;
    xshift = log10(Slmax_template/(Slmax_template+Sshift))/0.1187666467581842301;
    x = x + xshift;
    
    c = [207.3880950935, -6.3065623516, -393.7100478026, -315.6650602846, 19.2917535553, ...
         19.6414743488, 214.2211570447, 121.8584683485, -15.1820737886, -8.6774057156, ...
         -56.7596380441, -20.6318720369, 3.6934875040, 1.0483022480, 5.3656615075, ...
         0.7898783086, -0.1480357836, 0.0002358232];
    
    y = c(1) + c(2)*cos(x) + c(3)*sin(x) + c(4)*cos(2*x) + c(5)*sin(2*x) + ...
        c(6)*cos(3*x) + c(7)*sin(3*x) + c(8)*cos(4*x) + c(9)*sin(4*x) + ...
        c(10)*cos(5*x) + c(11)*sin(5*x) + c(12)*cos(6*x) + c(13)*sin(6*x) + ...
        c(14)*cos(7*x) + c(15)*sin(7*x) + c(16)*cos(8*x) + c(17)*sin(8*x) + c(18);
end

function LMSout = LMSconelog(nm, Lshift, Mshift, Sshift, loglin)
    % Calculate LMS abs from individual Fourier templates
    LMSout = zeros(length(nm), 4);
    
    LMSout(:,1) = nm(:); % Wavelength in column 1
    LMSout(:,2) = Lserconelog(nm, Lshift); % Log absorbances
    LMSout(:,3) = Mconelog(nm, Mshift);
    LMSout(:,4) = Sconelog(nm, Sshift);
    
    if strcmp(loglin, 'lin')
        for n = 2:4
            LMSout(:,n) = 10.^(LMSout(:,n)); % Lin absorbances
        end
    end
end

function y = macular(nm)
    % Macular best-fitting 11x2 Fourier Series Polynomial
    x = (nm-375)/55.70423008; % Rescales 375 to 550 nm 0 to pi
    
    y = zeros(size(nm));
    
    c = [3712.2037792986, 374.1811575175, -7007.6989637831, -5887.2857515364, -633.0475233043, ...
         -716.0429039473, 4386.8811254914, 2882.1092658881, 638.1347550701, 468.4980700497, ...
         -1653.7567388120, -817.1240899995, -286.4038978705, -144.7996457395, 340.3364828167, ...
         115.5652804221, 59.1650826447, 18.6678197694, -30.2344535413, -5.4683753172, ...
         -4.1335064207, -0.5043959566, 0.5094171266, 1.0050048550];
    
    for i = 1:length(x)
        if x(i) >= 0 && x(i) <= ((550-375)/55.70423008)
            y(i) = (c(1) + c(2)*cos(x(i)) + c(3)*sin(x(i)) + c(4)*cos(2*x(i)) + c(5)*sin(2*x(i)) + ...
                   c(6)*cos(3*x(i)) + c(7)*sin(3*x(i)) + c(8)*cos(4*x(i)) + c(9)*sin(4*x(i)) + ...
                   c(10)*cos(5*x(i)) + c(11)*sin(5*x(i)) + c(12)*cos(6*x(i)) + c(13)*sin(6*x(i)) + ...
                   c(14)*cos(7*x(i)) + c(15)*sin(7*x(i)) + c(16)*cos(8*x(i)) + c(17)*sin(8*x(i)) + ...
                   c(18)*cos(9*x(i)) + c(19)*sin(9*x(i)) + c(20)*cos(10*x(i)) + c(21)*sin(10*x(i)) + ...
                   c(22)*cos(11*x(i)) + c(23)*sin(11*x(i))) * c(24);
        else
            y(i) = 0;
        end
    end
end

function y = lens(nm)
    % Lens best-fitting 9x2 Fourier Series Polynomial
    x = (nm-360.0)/95.49296586; % Rescales 360 to 660 nm to 0 to pi
    
    y = zeros(size(nm));
    
    c = [-313.9508632762, -70.3216819666, 585.4719725809, 471.5395862431, 117.3539102044, ...
         127.0168222865, -324.4700544731, -188.1638078982, -104.5512488013, -68.3078486904, ...
         89.7815373733, 33.4498264952, 35.2723638870, 13.6524086627, -8.7568168893, ...
         -1.2825766708, -3.5126531075, -0.4477840959, 0.0428291365, 1.0091871745];
    
    for i = 1:length(x)
        if x(i) <= ((660-360)/95.49296586)
            y(i) = (c(1) + c(2)*cos(x(i)) + c(3)*sin(x(i)) + c(4)*cos(2*x(i)) + c(5)*sin(2*x(i)) + ...
                   c(6)*cos(3*x(i)) + c(7)*sin(3*x(i)) + c(8)*cos(4*x(i)) + c(9)*sin(4*x(i)) + ...
                   c(10)*cos(5*x(i)) + c(11)*sin(5*x(i)) + c(12)*cos(6*x(i)) + c(13)*sin(6*x(i)) + ...
                   c(14)*cos(7*x(i)) + c(15)*sin(7*x(i)) + c(16)*cos(8*x(i)) + c(17)*sin(8*x(i)) + ...
                   c(18)*cos(9*x(i)) + c(19)*sin(9*x(i))) * c(20);
        else
            y(i) = 0;
        end
    end
end

%% =================================================================
%% High-level functions for calculating CMFs
%% =================================================================

function [LMS_energy, LMS_quantal, RGBCMFs] = calculateCMFs(nm_step, Lshift, Mshift, Lod, Mod, Sod, mac_460, lens_400)
    % Main function to calculate color matching functions
    
    % Default parameters (Stockman & Sharpe 2-degree standard)
    if nargin < 1, nm_step = 1.0; end
    if nargin < 2, Lshift = 0.0; end
    if nargin < 3, Mshift = 0.0; end
    if nargin < 4, Lod = 0.50; end
    if nargin < 5, Mod = 0.50; end
    if nargin < 6, Sod = 0.40; end
    if nargin < 7, mac_460 = 0.350; end
    if nargin < 8, lens_400 = 1.7649; end
    
    % Set up wavelength array
    nm = (360:nm_step:850)';
    
    % Generate macular and lens templates
    mac = macular(nm);
    lens_template = lens(nm);
    
    % Calculate cone absorbance templates
    coneabs_template = LMSconelog(nm, Lshift, Mshift, 0, 'lin');
    
    % Retinal absorptances
    conenewq_retina = absorptancefromabsorbance(coneabs_template, Lod, Mod, Sod, 'lin');
    
    % Corneal quantal spectral sensitivities
    conenewq_cornea = corneafromlinabsorptance(conenewq_retina, mac, lens_template, mac_460, lens_400, 'lin');
    
    % Corneal energy spectral sensitivities
    conenewe_cornea = energyfromquantalin(conenewq_cornea, 'lin');
    
    LMS_energy = conenewe_cornea;
    LMS_quantal = conenewq_cornea;
    
    % Calculate RGB CMFs (Stiles & Burch primaries as default)
    RGBCMFs = calculateRGBCMFs(LMS_energy, [645.15, 526.32, 444.44], nm_step, Lshift, Mshift, Lod, Mod, Sod, mac_460, lens_400);
end

function RGBCMFs = calculateRGBCMFs(LMS_energy, primaries, nm_step, Lshift, Mshift, Lod, Mod, Sod, mac_460, lens_400)
    % Calculate RGB color matching functions from LMS functions
    
    CMF_Rnm = primaries(1);
    CMF_Gnm = primaries(2);
    CMF_Bnm = primaries(3);
    
    % Calculate LMS values at primary wavelengths
    nm_primaries = [CMF_Rnm; CMF_Gnm; CMF_Bnm];
    
    % Generate templates for primary wavelengths
    mac_primaries = macular(nm_primaries);
    lens_primaries = lens(nm_primaries);
    coneabs_primaries = LMSconelog(nm_primaries, Lshift, Mshift, 0, 'lin');
    
    conenewq_retina_primaries = absorptancefromabsorbance(coneabs_primaries, Lod, Mod, Sod, 'lin');
    conenewq_cornea_primaries = corneafromlinabsorptance(conenewq_retina_primaries, mac_primaries, lens_primaries, mac_460, lens_400, 'lin');
    conenewe_cornea_primaries = energyfromquantalin(conenewq_cornea_primaries, 'lin');
    
    % RGB matrix (columns are LMS responses to R, G, B primaries)
    RGBLMS = conenewe_cornea_primaries(:, 2:4)'; % Transpose to get 3x3 matrix
    
    % LMS to RGB transformation matrix
    LMSRGB = inv(RGBLMS);
    
    % Transform LMS to RGB
    RGBCMFs = LMS_energy; % Copy structure
    RGBCMFs(:, 2:4) = LMS_energy(:, 2:4) * LMSRGB';
end

%% =================================================================
%% EXAMPLE USAGE
%% =================================================================

function run_examples()
    %% Example 1: Standard 2-degree color matching functions
    fprintf('Example 1: Standard 2-degree CMFs\n');
    fprintf('===================================\n');
    
    % Calculate standard CMFs with no shifts (normal observer)
    [LMS_energy, LMS_quantal, RGBCMFs] = calculateCMFs();
    
    % Display some key information
    fprintf('Wavelength range: %.0f - %.0f nm\n', min(LMS_energy(:,1)), max(LMS_energy(:,1)));
    fprintf('Number of data points: %d\n', size(LMS_energy, 1));
    fprintf('Peak L sensitivity at: %.1f nm\n', LMS_energy(find(LMS_energy(:,2) == max(LMS_energy(:,2)), 1), 1));
    fprintf('Peak M sensitivity at: %.1f nm\n', LMS_energy(find(LMS_energy(:,3) == max(LMS_energy(:,3)), 1), 1));
    fprintf('Peak S sensitivity at: %.1f nm\n', LMS_energy(find(LMS_energy(:,4) == max(LMS_energy(:,4)), 1), 1));
    
    % Plot the results
    figure(1);
    subplot(2,2,1);
    plot(LMS_energy(:,1), LMS_energy(:,2), 'r-', 'LineWidth', 2); hold on;
    plot(LMS_energy(:,1), LMS_energy(:,3), 'g-', 'LineWidth', 2);
    plot(LMS_energy(:,1), LMS_energy(:,4), 'b-', 'LineWidth', 2);
    xlabel('Wavelength (nm)');
    ylabel('Sensitivity');
    title('LMS Energy-based CMFs');
    legend('L', 'M', 'S', 'Location', 'best');
    grid on;
    
    subplot(2,2,2);
    plot(RGBCMFs(:,1), RGBCMFs(:,2), 'r-', 'LineWidth', 2); hold on;
    plot(RGBCMFs(:,1), RGBCMFs(:,3), 'g-', 'LineWidth', 2);
    plot(RGBCMFs(:,1), RGBCMFs(:,4), 'b-', 'LineWidth', 2);
    xlabel('Wavelength (nm)');
    ylabel('Tristimulus Value');
    title('RGB Color Matching Functions');
    legend('R', 'G', 'B', 'Location', 'best');
    grid on;
    
    %% Example 2: Shifted L and M cones (simulating genetic variation)
    fprintf('\nExample 2: Shifted L and M cone sensitivities\n');
    fprintf('=============================================\n');
    
    % Simulate individual with shifted cone sensitivities
    Lshift = 2.0;  % 2 nm shift in L cone
    Mshift = -1.0; % 1 nm shift in M cone (opposite direction)
    
    [LMS_shifted, ~, RGB_shifted] = calculateCMFs(1.0, Lshift, Mshift);
    
    % Compare with normal
    subplot(2,2,3);
    plot(LMS_energy(:,1), LMS_energy(:,2), 'r--', 'LineWidth', 1.5); hold on;
    plot(LMS_energy(:,1), LMS_energy(:,3), 'g--', 'LineWidth', 1.5);
    plot(LMS_shifted(:,1), LMS_shifted(:,2), 'r-', 'LineWidth', 2);
    plot(LMS_shifted(:,1), LMS_shifted(:,3), 'g-', 'LineWidth', 2);
    xlabel('Wavelength (nm)');
    ylabel('Sensitivity');
    title('Normal vs Shifted L&M Cones');
    legend('L normal', 'M normal', 'L shifted', 'M shifted', 'Location', 'best');
    grid on;
    
    fprintf('L cone shift: %.1f nm\n', Lshift);
    fprintf('M cone shift: %.1f nm\n', Mshift);
    
    %% Example 3: Different optical densities (simulating age effects)
    fprintf('\nExample 3: Age-related changes in optical densities\n');
    fprintf('==================================================\n');
    
    % Young observer (higher optical densities)
    Lod_young = 0.50;
    Mod_young = 0.50;
    Sod_young = 0.40;
    mac_young = 0.35;
    lens_young = 1.76;
    
    % Older observer (lower optical densities, more lens pigment)
    Lod_old = 0.35;
    Mod_old = 0.35;
    Sod_old = 0.28;
    mac_old = 0.25;
    lens_old = 2.5;
    
    [LMS_young, ~, ~] = calculateCMFs(1.0, 0, 0, Lod_young, Mod_young, Sod_young, mac_young, lens_young);
    [LMS_old, ~, ~] = calculateCMFs(1.0, 0, 0, Lod_old, Mod_old, Sod_old, mac_old, lens_old);
    
    subplot(2,2,4);
    plot(LMS_young(:,1), LMS_young(:,2), 'r-', 'LineWidth', 2); hold on;
    plot(LMS_young(:,1), LMS_young(:,3), 'g-', 'LineWidth', 2);
    plot(LMS_young(:,1), LMS_young(:,4), 'b-', 'LineWidth', 2);
    plot(LMS_old(:,1), LMS_old(:,2), 'r--', 'LineWidth', 1.5);
    plot(LMS_old(:,1), LMS_old(:,3), 'g--', 'LineWidth', 1.5);
    plot(LMS_old(:,1), LMS_old(:,4), 'b--', 'LineWidth', 1.5);
    xlabel('Wavelength (nm)');
    ylabel('Sensitivity');
    title('Young vs Older Observer');
    legend('L young', 'M young', 'S young', 'L old', 'M old', 'S old', 'Location', 'best');
    grid on;
    
    fprintf('Young observer ODs: L=%.2f, M=%.2f, S=%.2f\n', Lod_young, Mod_young, Sod_young);
    fprintf('Older observer ODs: L=%.2f, M