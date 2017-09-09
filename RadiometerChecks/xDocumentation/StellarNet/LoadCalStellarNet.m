tmp = importdata('SL1CAL-15081402-ATPLANE.ICD')
wls_sl1 = tmp.data(:, 1);
spd_sl1 = tmp.data(:, 2);

tmp = importdata('SL3CAL-15081437-ATPLANE.ICD')
wls_sl3 = tmp.data(:, 1);
spd_sl3 = tmp.data(:, 2);