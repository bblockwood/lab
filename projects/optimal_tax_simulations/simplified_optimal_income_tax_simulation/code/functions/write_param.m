function write_param(name,value)
% Write parameter to a text file, for use in slides and text.

global OUTPUT;
outFile = [OUTPUT '/NumbersForText/' name '.tex'];
fid = fopen(outFile,'wt');
fprintf(fid, num2str(value));
fclose(fid);
end
