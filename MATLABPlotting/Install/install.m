function install
%INSTALL Create a startup file that adds relevant pathes to the MATLAB
%path list.

pkg_path = mfilename('fullpath');
seps = strfind(pkg_path, filesep);
pkg_path = pkg_path(1:seps(end-1) - 1);

startup = fullfile(getenv('USERPROFILE'), 'Documents', 'MATLAB', 'startup.m');

[fid, msg] = fopen(startup, 'w+');
if fid == -1
    error(msg);
end

fprintf(fid, 'function startup\n\n');
pkg_path = strrep(pkg_path, filesep, [filesep, filesep]);
fprintf(fid, ['addpath(genpath(''', pkg_path, '''));\n\n']);
fprintf(fid, 'end');

fclose(fid);

% Add the path for the current session, otherwise, MATLAB has to be
% restarted.
addpath(genpath(pkg_path));

end