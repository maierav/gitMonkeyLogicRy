s = [whos; whos('global')];
for m=1:length(s)
    switch s(m).class
        case {'analoginput','aichannel','analogoutput','aochannel','digitalio','dioline'}, clear(s(m).name);
    end
end

[~,loadedMex] = inmem;
if any(strcmpi(loadedMex,'daqmex'))
	builtin('clear','daqmex');
end
