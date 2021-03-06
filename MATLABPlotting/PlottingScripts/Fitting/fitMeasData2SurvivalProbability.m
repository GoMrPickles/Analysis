function fitMeasData2SurvivalProbability(order, data)
%fitMeasData2SurvivalProbability(ORDER, DATA)  Fit randomized benchmarking
% data to a survival probability function.
%   fitMeasData2SurvivalProbability(ORDER, DATA) fits data  randomized
%   benchmarking data to a survival probability function, plots the data
%   and the fit. ORDER should be either 0 or 1, and detemines the fit order
%   of the sequence fidelity model.
%   
%   See also:
%   Magesan et al., PRL 109, 080505 (2012).

d = 2; % Dimension of the system.

if exist('order', 'var')
    if isnumeric(order) && order
        order = 1;
    elseif ischar(order)
        if strcmp(order(1:4), 'zero')
            order = 0;
        else
            order = 1;
        end
    else
        order = 0;
    end
else
    order = 0;
end
if ~order
    ordstr = 'Zeroth-Order';
else
    ordstr = 'First-Order';
end

if ~exist('data', 'var')
    % Select a file.
    data = loadMeasurementData;
end
if isempty(fields(data))
    return
end

[pathname, filename, ext] = fileparts(data.Filename);

% Create folder Plots if necessary.
plts_path = makeDirPlots(pathname);

probabilities = {'No_Interleaved_Probability',...
                 'Interleaved_Probability'};
% Check that the data variable exists.
for k=1:length(probabilities)
    [data, probabilities{k}] = checkDataVar(data, probabilities{k});
    dep_rels = data.rels.(probabilities{k});
    if isempty(dep_rels)
        error(['Independent (sweep) variables for data variable ''',...
              strrep(data_variable, '_', ' '), ''' are not specified.'])
    elseif ~strcmp(dep_rels{1}, 'Number_of_Cliffords')
        error('Probabilities should depend on ''Number of Cliffords''.')
    end
end

phi_no = double(data.No_Interleaved_Probability);
phi_ig = double(data.Interleaved_Probability);

gate = strrep(data.RB_Interleaving_Gate(4:end-3), '''', '');

rb_reps = single(data.RB_Reps);

% Check that the errors are given.
error_flag = true;
for k=1:length(probabilities)
    if ~isfield(data.error, probabilities{k}) 
        error_flag = false;
    end
end
if error_flag
    phi_no_err = double(data.error.No_Interleaved_Probability);
    phi_ig_err = double(data.error.Interleaved_Probability);
end

if length(dep_rels) == 1
    indep_name = dep_rels{1};
    indep_vals = double(data.(indep_name));

    disp(['Fitting to the ', lower(ordstr), ' model...'])
    if ~order
        f_no = SurvivalProbabilityZerothOrderModel(indep_vals, phi_no);
    else
        f_no = SurvivalProbabilityFirstOrderModel(indep_vals, phi_no);
    end
    p_no = f_no.d;
    
    disp('No interleaving gate:')
    ci = confint(f_no);
    ae_no = max([abs(ci(1, 1) - f_no.a), abs(ci(2, 1) - f_no.a)]);
    astr_no = ['  a = ', num2str(f_no.a, '%.4f'), ' � ',...
                         num2str(ae_no, '%.4f')];
    disp(astr_no)
    
    be_no = max([abs(ci(1, 2) - f_no.b), abs(ci(2, 2) - f_no.b)]);
    bstr_no = ['  b = ', num2str(f_no.b, '%.4f'), ' � ',...
                         num2str(be_no, '%.4f')];
    disp(bstr_no)
    
    if order
        ce_no = max([abs(ci(1, 3) - f_no.c), abs(ci(2, 3) - f_no.c)]);
        cstr_no = ['  c = ', num2str(f_no.c, '%.4f'), ' � ',...
                             num2str(ce_no, '%.4f')];
        disp(cstr_no)
        pe_no = max([abs(ci(1, 4) - f_no.d), abs(ci(2, 4) - f_no.d)]);
    else
        pe_no = max([abs(ci(1, 3) - f_no.d), abs(ci(2, 3) - f_no.d)]);
    end
    pstr_no = ['  p = ', num2str(f_no.d, '%.4f'), ' � ',...
                         num2str(pe_no, '%.4f')];
    disp(pstr_no)
    
    % Compute the average error rate over all Clifford gates. 
    r_avg = (d - 1) * (1 - p_no) / d;
    r_avg_error = (d - 1) * pe_no / d;

    if ~order
        f_ig = SurvivalProbabilityZerothOrderModel(indep_vals, phi_ig);
    else
        f_ig = SurvivalProbabilityFirstOrderModel(indep_vals, phi_ig);
    end
    p_ig = f_ig.d;
    
    % Compute the gate error. 
    r_gate = (d - 1) * (1 - p_ig / p_no) / d;
    r_gate_error = ...
            min([(d - 1) * (abs(p_no - p_ig / p_no) + 1 - p_no) / d,...
                 2 * (d^2 - 1) * (1 - p_no) / (p_no * d^2) +...
                 4 * sqrt(1 - p_no) * sqrt(d^2 - 1) / p_no]);
    
    disp(['With interleaving ', gate, ' gate:'])
    ci = confint(f_ig);
    ae_ig = max([abs(ci(1, 1) - f_ig.a), abs(ci(2, 1) - f_ig.a)]);
    astr_ig = ['  a = ', num2str(f_ig.a, '%.4f'), ' � ',...
                         num2str(ae_ig, '%.4f')];
    disp(astr_ig)
    
    be_ig = max([abs(ci(1, 2) - f_ig.b), abs(ci(2, 2) - f_ig.b)]);
    bstr_ig = ['  b = ', num2str(f_ig.b, '%.4f'), ' � ',...
                         num2str(be_ig, '%.4f')];
    disp(bstr_ig)
    
    if order
        ce_ig = max([abs(ci(1, 3) - f_ig.c), abs(ci(2, 3) - f_ig.c)]);
        cstr_ig = ['  c = ', num2str(f_ig.c, '%.4f'), ' � ',...
                             num2str(ce_ig, '%.4f')];
        disp(cstr_ig)
        pe_ig = max([abs(ci(1, 4) - f_ig.d), abs(ci(2, 4) - f_ig.d)]);
    else
        pe_ig = max([abs(ci(1, 3) - f_ig.d), abs(ci(2, 3) - f_ig.d)]);
    end
    pstr_ig = ['  p = ', num2str(f_ig.d, '%.4f'), ' � ',...
                         num2str(pe_ig, '%.4f')];
    disp(pstr_ig)
    
    disp('Average error rate over all Cliffords:')
    disp(['  r(average) = ', num2str(r_avg, '%.4f'), ' � ',...
            num2str(r_avg_error, '%.4f')]);
    
    disp(['Gate ', gate, ' error:'])
    disp(['  r(', gate, ') = ', num2str(r_gate, '%.4f'), ' � ',...
            num2str(r_gate_error, '%.4f')]);

    full_title = {[strrep(filename, '_', '\_'), ext,...
            ' [', data.Timestamp, ']'],...
            ['Depolarizations (', ordstr, '): p_{', gate, '} = ',...
              pstr_ig(7:end),'; p_{no gate} = ', pstr_no(7:end)],...
            ['Gate Errors: r_{', gate, '} = ', num2str(r_gate,...
             '%.4f'), ' � ', num2str(r_gate_error, '%.4f'),...
             '; r_{average} = ', num2str(r_avg, '%.4f'), ' � ',...
             num2str(r_avg_error, '%.4f')]};

    legends = {'no interleaving gate, data',...
               'no interleaving gate, fit',...
               ['interleaving ', gate, ' gate, data'],...
               ['interleaving ', gate, ' gate, fit']};

    name = 'Fitted_No_Interleaving_Probability';
    data.units.(name) = '';
    data.rels.(name) = dep_rels;
    data.dep{length(data.dep) + 1} = name;
    data.plotting.(name).plot_title = full_title;
    data.(name) = f_no(indep_vals);
    
    name = 'Fitted_Interleaving_Probability';
    data.units.(name) = '';
    data.rels.(name) = dep_rels;
    data.dep{length(data.dep) + 1} = name;
    data.plotting.(name).plot_title = full_title;
    data.(name) = f_ig(indep_vals);

    indep_fits = min(indep_vals):max(indep_vals);
    % Plot an errorbar graph.
    if error_flag
        createFigure('right');
        plotErrorbar(indep_vals, phi_no, phi_no_err / sqrt(rb_reps - 1))
        hold on
        plot(indep_fits, f_no(indep_fits), 'b', 'Linewidth', 2)
        plotErrorbar(indep_vals, phi_ig, phi_ig_err / sqrt(rb_reps - 1))
        plot(indep_fits, f_ig(indep_fits), 'r', 'Linewidth', 2)
        hold off
        legend(legends, 'Location', 'Best')
        xlabel(strrep(indep_name, '_', ' '), 'FontSize', 14)
        ylabel('Survival Probability', 'FontSize', 14)
        title(full_title, 'FontSize', 12)
        savePlot(fullfile(plts_path, [filename, '_survprobfit_errorbar']));
    end

    % Plot a simple 1D graph.
    createFigure;
    plotSimple(indep_vals, phi_no, 'bo')
    hold on
    plot(indep_fits, f_no(indep_fits), 'b', 'Linewidth', 2)
    plotSimple(indep_vals, phi_ig, 'ro')
    plot(indep_fits, f_ig(indep_fits), 'r', 'Linewidth', 2)
    hold off
    legend(legends, 'Location', 'Best')
    xlabel(strrep(indep_name, '_', ' '), 'FontSize', 14)
    ylabel('Survival Probability', 'FontSize', 14)
    title(full_title, 'FontSize', 12)
    savePlot(fullfile(plts_path, [filename, '_survprobfit_simple']));
end
end

function f = SurvivalProbabilityZerothOrderModel(m, p)
    ft = fittype('a * d^m + b',...
        'independent', 'm', 'dependent', 'p' );
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.TolX = 1e-9;
    opts.TolFun = 1e-9;
    opts.Lower = [0 0  0];
    opts.StartPoint = [max(p) / 2 min(p) sqrt(max(p))];
    opts.Upper = [1 1 1];
    f = fit(m(:), p(:), ft, opts);
end

function f = SurvivalProbabilityFirstOrderModel(m, p)
    ft = fittype('a * d^m + c * (m - 1) * d^(m - 2) + b',...
        'independent', 'm', 'dependent', 'p' );
    opts = fitoptions('Method', 'NonlinearLeastSquares');
    opts.Display = 'Off';
    opts.TolX = 1e-9;
    opts.TolFun = 1e-9;
    opts.Lower = [0 0 0 0];
    opts.StartPoint = [max(p) / 2 min(p) 0 sqrt(max(p))];
    opts.Upper = [1 1 1 1];
    f = fit(m(:), p(:), ft, opts);
end