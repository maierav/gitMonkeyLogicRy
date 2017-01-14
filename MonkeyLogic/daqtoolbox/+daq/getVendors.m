function vendorInfo = getVendors()

hw = daqhwinfo;
[~,~,~,vendorInfo] = daqmex(1,hw.InstalledAdaptors{1}); %#ok<*AGROW>
vendorInfo.AdaptorVersion = hw.ToolboxVersion;
