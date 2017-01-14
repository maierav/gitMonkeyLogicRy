classdef digitalio < dynamicprops
    properties
        Line;
        Name;
        Running;
    end
    properties (Constant)
        Type = 'Digital IO';
    end
    properties (Hidden)
        hwInfo;
    end
    properties (Hidden, Access = protected)
        AdaptorName;
        DeviceID;
        TaskID;
    end
    properties (Hidden, Constant, Access = protected)
        SubsystemType = 3;  % 1: AI, 2: AO, 3: DIO
    end
    
    methods (Static, Access = protected)
        function id = taskid()
            persistent counter;
            if isempty(counter), n = now; counter = floor((n - floor(n))*10^9); end
            counter = counter + 1;
            id = counter;
        end
    end
    
    methods
        function obj = digitalio(adaptor,DeviceID)
            hw = daqhwinfo;
            idx = strncmpi(hw.InstalledAdaptors,adaptor,length(adaptor));
            if ~any(idx), error('Failure to find requested data acquisition device: %s.',adaptor); end
            adaptor = hw.InstalledAdaptors{idx};
            hw = daqhwinfo(adaptor);
            if isscalar(DeviceID), DeviceID = num2str(DeviceID); end
            idx = strcmpi(hw.InstalledBoardIds,DeviceID);
            if ~any(idx), error('The specified device ID is invalid. Use DAQHWINFO(adaptorname) to determine valid device IDs.'); end
            if isempty(hw.ObjectConstructorName{idx,obj.SubsystemType}), error('This device does not support the subsystem requested.  Use DAQHWINFO(adaptorname) to determine valid constructors.'); end
            DeviceID = hw.InstalledBoardIds{idx};
            
            obj.AdaptorName = adaptor;
            obj.DeviceID = DeviceID;
            obj.TaskID = obj.taskid();
            daqmex(3,obj.AdaptorName,obj.DeviceID,obj.SubsystemType,obj.TaskID);
            obj.hwInfo = about(obj);
            
            obj.Line = dioline.empty;
            obj.Name = [adaptor DeviceID '-DIO'];
        end
        function delete(obj)
            for m=1:length(obj)
                daqmex(4,obj(m).AdaptorName,obj(m).DeviceID,obj(m).SubsystemType,obj(m).TaskID);
            end
        end
        function info = about(obj)
            info = daqmex(2,obj.AdaptorName,obj.DeviceID,obj.SubsystemType);
        end
        
        function lines = addline(obj,hwline,varargin)
            if 1 < length(obj), error('OBJ must be a 1-by-1 digital I/O object.'); end
            switch nargin
                case 1, error('Not enough input arguments. HWLINE and DIRECTION must be defined.');
                case 2, error('Not enough input arguments. DIRECTION must be defined.');
            end
            
            hwline = hwline(:)';
            nline = length(hwline);
            switch nargin
                case 3
                    port = zeros(1,nline);
                    direction = varargin{1};
                    names = cell(1,nline);
                case 4
                    if ischar(varargin{1})
                        port = zeros(1,nline);
                        direction = varargin{1};
                        names = varargin{2}; if ~iscell(names), names = {names}; end
                    else
                        port = varargin{1}; port = port(:)';
                        direction = varargin{2};
                        names = cell(1,nline);
                    end
                case 5
                    port = varargin{1}; port = port(:)';
                    direction = varargin{2};
                    names = varargin{3}; if ~iscell(names), names = {names}; end
                otherwise
                    error('Too many input arguments.');
            end
            nport = length(port);
            if 1==nline, hwline = repmat(hwline,1,nport); nline = nport; end
            if 1==nport, port = repmat(port,1,nline); nport = nline; end
            if 1==length(names), names(1,2:nline) = names(1); end
            if nline~=nport, error('The lengths of HWLINE and PORT must be equal or either of them must be a scalar.'); end
            if nline~=length(names), error('Invalid number of NAMES provided for the number of lines specified in HWLINE and/or PORT.'); end
            
            PortIDs = [obj.hwInfo.Port.ID];
            for m=1:nline
                idx = port(m) == PortIDs;
                if ~any(idx), error('Unable to set Port above maximum value of %d.',max(PortIDs)); end
                if ~any(hwline(m) == obj.hwInfo.Port(idx).LineIDs), error('The specified line could not be found on any port.'); end
            end
            if ~isempty(obj.Line)
                old = [obj.Line.HwLine obj.Line.Port];
                if iscell(old), old = cell2mat(old); end
                [a,b] = size(old);
                new = [hwline' port'];
                for m=1:nline
                    if any(b==sum(old==repmat(new(m,:),a,1),2)), error('Line %d on port %d already exists.',new(m,:)); end
                end
            end
            
            lines(nline,1) = dioline;
            for m=1:nline
                lines(m).Parent = obj;
                lines(m).Direction = direction;
                lines(m).HwLine = hwline(m);
                lines(m).Index = length(obj.Line) + 1;
                lines(m).LineName = names{m};
                lines(m).Port = port(m);
                
                obj.Line = [obj.Line; lines(m)];
                if ~isempty(lines(m).LineName)
                    if ~isprop(obj,lines(m).LineName), addprop(obj,lines(m).LineName); end
                    obj.(lines(m).LineName) = [obj.(lines(m).LineName); lines(m)];
                end
            end
            
            update_lines(obj);
        end
        function update_lines(obj)
            param = [obj.Line.Port obj.Line.HwLine];
            if iscell(param), param = cell2mat(param); end
            daqmex(10,obj.AdaptorName,obj.DeviceID,obj.SubsystemType,obj.TaskID,[param strcmpi(obj.Line.Direction,'Out')+1]);
        end
        
        function start(obj)
            for m=1:length(obj)
                if isempty(obj(m).Line), error('At least one line must be created before calling START.'); end
                daqmex(7,obj(m).AdaptorName,obj(m).DeviceID,obj(m).SubsystemType,obj(m).TaskID);
            end
        end
        function stop(obj)
            for m=1:length(obj)
                daqmex(8,obj(m).AdaptorName,obj(m).DeviceID,obj(m).SubsystemType,obj(m).TaskID);
            end
        end
        function tf = isrunning(obj)
            nobj = length(obj);
            tf = false(1,nobj);
            for m=1:nobj
                tf(m) = daqmex(9,obj(m).AdaptorName,obj(m).DeviceID,obj(m).SubsystemType,obj(m).TaskID);
            end
        end
        
        function putvalue(obj,val)
            if 1 < length(obj), error('OBJ must be a 1-by-1 digital I/O object or a digital I/O line array.'); end
            nline = length(obj.Line);
            if isscalar(val)
                bin = dec2binvec(val, nline);
                if nline < length(bin), error('DATA is too large to be represented by the number of lines in OBJ.'); end
            else
                if nline ~= length(val), error('The number of lines and binvec values must be the same.'); end
                bin = 0 < val(:)';
            end
            daqmex(18,obj.AdaptorName,obj.DeviceID,obj.TaskID,bin);
        end
        function val = getvalue(obj)
            if 1 < length(obj), error('OBJ must be a 1-by-1 digital I/O object or a digital I/O line array.'); end
            val = daqmex(19,obj.AdaptorName,obj.DeviceID,obj.TaskID);
        end
        
        function set.Running(obj,val) %#ok<*INUSD>
            error('Attempt to modify read-only property: ''Running''.');
        end
        function val = get.Running(obj)
            val = isrunning(obj);
        end
        
        function out = set(obj,varargin)
            switch nargin
                case 1
                    out = [];
                    fields = properties(obj(1));
                    for m=1:length(fields)
                        propset = [fields{m} 'Set'];
                        if isprop(obj(1),propset), out.(fields{m}) = obj(1).(propset); else out.(fields{m}) = {}; end
                    end
                    return;
                case 2
                    if ~isscalar(obj), error('Object array must be a scalar when using SET to retrieve information.'); end
                    fields = varargin(1);
                    vals = {{}};
                case 3
                    if iscell(varargin{1})
                        fields = varargin{1};
                        vals = varargin{2};
                        [a,b] = size(vals);
                        if length(obj) ~= a || length(fields) ~= b, error('Size mismatch in Param Cell / Value Cell pair.'); end
                    else
                        fields = varargin(1);
                        vals = varargin(2);
                    end
                otherwise
                    if 0~=mod(nargin-1,2), error('Invalid parameter/value pair arguments.'); end
                    fields = varargin(1:2:end);
                    vals = varargin(2:2:end);
            end
            for m=1:length(obj)
                proplist = properties(obj(m));
                for n=1:length(fields)
                    field = fields{n};
                    if ~ischar(field), error('Invalid input argument type to ''set''.  Type ''help set'' for options.'); end
                    if 1==size(vals,1), val = vals{1,n}; else val = vals{m,n}; end
                    
                    idx = strncmpi(proplist,field,length(field));
                    if 1~=sum(idx), error('The property, ''%s'', does not exist.',field); end
                    prop = proplist{idx};
                    
                    if ~isempty(val)
                        obj(m).(prop) = val;
                    else
                        propset = [prop 'Set'];
                        if isprop(obj(m),propset)
                            out = obj(m).(propset)(:);
                        else
                            fprintf('The ''%s'' property does not have a fixed set of property values.\n',prop);
                        end
                    end
                end
            end
        end
        function out = get(obj,fields)
            if ischar(fields), fields = {fields}; end
            out = cell(length(obj),length(fields));
            for m=1:length(obj)
                proplist = properties(obj(m));
                for n=1:length(fields)
                    field = fields{n};
                    idx = strncmpi(proplist,field,length(field));
                    if 1~=sum(idx), error('The property, ''%s'', does not exist.',field); end
                    prop = proplist{idx};
                    out{m,n} = obj(m).(prop);
                end
            end
            if isscalar(out), out = out{1}; end
        end
    end
end
