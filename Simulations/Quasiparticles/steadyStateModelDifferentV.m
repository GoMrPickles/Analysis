function steadyStateModelDifferentV
%steadyStateModelDifferentCtr Explore the quasiparticle power budget
%at different injection voltages.

r_direct = 1e-05; % in units of 1/\tau_0, assuming n_{qp} in units of n_{cp}
r_phonon = 5e-2; % dimensionless
c = 0.01; % dimensionless
vol = 5.000e+03; % um^3
V = 1.1:.5:30; % in units of \delta

Tph = 0.051; % K
tspan = [-510, -10]; % in units of \tau_0

% Number of the energy bins.
N = 200;

Prec = nan(size(V));
Psct = nan(size(V));
Psct2D = nan(size(V));
Ptrp = nan(size(V));
Ptrp2D = nan(size(V));
parfor kV = 1:length(V)
    Vsim = V(kV);
    [~, ~, ~, ~, ~, ~, ~, ...
        Prec(kV), Psct(kV), Psct2D(kV), Ptrp(kV), Ptrp2D(kV)] =...
        twoRegionSteadyStateModel(Tph, tspan,...
        Vsim, r_direct, r_phonon, c, vol, N, false);
    fprintf('*')
end

fprintf('\n')
figure
hold on
plot(V, Prec, V, Psct, V, Psct2D, V, Ptrp, V, Ptrp2D,...
    V, Prec + Psct + Ptrp, V, Prec + Psct2D + Ptrp2D,...
    'MarkerSize', 10, 'LineWidth', 2)
xlabel('Injection Energy (\Delta)', 'FontSize', 14)
ylabel('Fraction of Total Power', 'FontSize', 14)
legend('recombination', 'scattering', 'scattering above 2\Delta',...
    'trapping', 'trapping above 2\Delta', 'total',...
    'total above 2\Delta', 'Location', 'SouthEast')
title(['r_{qp} = ', num2str(r_direct, '%.2e'), '/\tau_0', ', ',...
     'r_{ph} = ', num2str(r_phonon, '%.3f'), ', ',...
     'c = ', num2str(c, '%.3f'), ', ',...
     'v = ', num2str(vol, '%.2e'), ' \mu{m}^3'])
axis tight
grid on

saveas(gca, 'PowerBudget_c0p01.pdf', 'pdf')
end