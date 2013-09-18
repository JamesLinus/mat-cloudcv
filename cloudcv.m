classdef cloudcv
    %Class for connecting to CloudCV
    properties
        params;
        upload_obj;
        socket_obj;
    end
    
    methods(Access = private)
        function obj = startUpload(obj)
            obj.upload_obj=javaObject('UploadData', obj.params);
            t = javaObject('java.lang.Thread', obj.upload_obj);
            javaMethod('start', t);
           
        end
    end
    
    methods
        function obj = cloudcv()
            obj.params=NaN;
            obj.upload_obj=NaN;
            obj.socket_obj=NaN;
        end
        
        function obj = init(obj, configFile, imageDir, resultDir, execName)
    
            if ~exist('imageDir','var') || isempty(imageDir)
                imageDir = '';
            end
            
            if ~exist('resultDir','var') || isempty(resultDir)
                resultDir = '';
            end
            
            if ~exist('execName','var') || isempty(execName)
                execName = '';
            end

            obj.params = javaObject('ConfigParser',configFile);
            javaMethod('readConfigFile', obj.params);
            val = javaMethod('parseArguments', obj.params, imageDir, resultDir, execName);
            
            if(val==1)
                javaMethod('getParams',obj.params);
            end
    
        end
    
        function obj = disconnect(obj)
            if(~isempty(obj.socket_obj))
                javaMethod('unsubscribe',obj.socket_obj);
            end
            if(~isempty(obj.upload_obj))
                javaMethod('disconnect',obj.upload_obj);
            end
        end
        
        
        function obj = run(obj)
            obj = startUpload(obj);
            
            if(isempty(obj.socket_obj))
                disp('Socket Server created');
                obj.socket_obj = javaObject('SocketConnection', obj.params.executable_name, obj.params.output_path);
                javaMethod('socketIOConnection',obj.socket_obj);
            
            else
                disp('Socket Connection is already established');
                javaMethod('updateParameters',obj.socket_obj, obj.params.executable_name, obj.params.output_path);
                javaMethod('startRedis', obj.socket_obj);
            
            end
        end
    end
end



