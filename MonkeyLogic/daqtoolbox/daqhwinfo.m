function hw = daqhwinfo(varargin)

switch nargin
    case 0
        [hw.ToolboxName,hw.ToolboxVersion] = daq.getToolboxInfo;
        v = ver('MATLAB');
        hw.MATLABVersion = [v.Version ' ' v.Release];
        hw.InstalledAdaptors = daqmex(0);
    case 1
        switch class(varargin{1})
            case 'char'
                InstalledAdaptors = daqmex(0);
                idx = strncmpi(InstalledAdaptors,varargin{1},length(varargin{1}));
                if ~any(idx), error('Failure to find requested data acquisition device: %s',varargin{1}); end
                AdaptorName = InstalledAdaptors{idx};
                
                hw.AdaptorName = AdaptorName;
                [hw.BoardNames,hw.InstalledBoardIds,Subsystem] = daqmex(1,AdaptorName);
                for m=1:length(hw.InstalledBoardIds)
                    for n=1:3
                        if isempty(Subsystem{m,n}), continue; end
                        Subsystem{m,n} = [Subsystem{m,n} '('''  hw.AdaptorName ''',''' hw.InstalledBoardIds{m} ''')'];
                    end
                end
                hw.ObjectConstructorName = Subsystem;
				
            case {'analoginput','analogoutput','digitalio'}
                hw = varargin{1}.about;
        end
end
