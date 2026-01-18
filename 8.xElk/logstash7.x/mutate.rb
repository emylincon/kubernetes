def process_usage_info (rawewUsageInfo)
    ew = rawewUsageInfo.split("/")
    eventHandler = {"-" => "No event handler was executed", "1" => "onClientRequest", "2" => "onOriginRequest", "3" => "onOriginResponse", "4" => "onClientResponse", "5" => "responseProvider"}
    off_reason = {"-" => "Metadata indicated EdgeWorkers should be on", "m" => "Metadata indicated EdgeWorkers should be off", "i" => "Request was internal and as such should not execute the EdgeWorkers function, such as =>
    SureRoute Test Object races, ESI Fragment requests, Intermediary Processing Agent requests, Request was not from End User (not CLIENT_REQ), Akamai Translate or Purge", "n" => "Request not on supported network", 
    "g" => "Akamai edge server failed EdgeWorkers", "s" => "Request was denied by a security product"}
    logic_executed = {"0" => "No", "1" => "Yes"}
    status = {
        "0" => "Unspecified error",
        "1" => "Successful execution",
        "2" => "Generic EdgeWorkers error",
        "3" => "Could not find the EdgeWorkers identifier",
        "4" => "Requested event handler was not implemented by the EdgeWorkers function",
        "5" => "A runtime or environment error prevented the EdgeWorkers execution",
        "6" => "Error during the EdgeWorkers execution, such as a JavaScript exception or error",
        "7" => "EdgeWorkers function timed out",
        "8" => "EdgeWorkers function hit preset resource limit",
        "9" => "Error receiving or sending data through the RingBuffer",
        "10" => "EdgeWorkers is blocked by the Akamai JavaScript execution engine",
        "11" => "EdgeWorkers code bundle not available for a particular version",
        "12" => "The amount of CPU time consumed by the event handler exceeded the limit",
        "13" => "The wall time consumed by the event handler exceeded the limit",
        "14" => "The amount of CPU time consumed during initialization by the event handler exceeded the limit",
        "15" => "The wall time consumed during initialization by the event handler exceeded the limit"
    }

    metrics = [nil, nil]
    if ew[8] != nil
        metrics = ew[8][1..-1].split(",")
    end

    ewUsage = {
        "edgeWorkerId" => ew[2], 
        "version" => ew[3], 
        "eventHandler" => eventHandler[ew[4]], 
        "offReason" => off_reason[ew[5]], 
        "logicExecuted" => logic_executed[ew[6]], 
        "status" => status[ew[7]], 
        "metrics" => {
            "CPUTime" => metrics[0].to_f, 
            "WallTime" => metrics[1].to_f
        }
    }

    return ewUsage
end

def process_execution_info (rawewExecutionInfo)
    ex = rawewExecutionInfo.split(":")

    stage_info = {
        "S" => "Sub-request",
        "c" => "onClientRequest",
        "o" => "onOriginRequest",
        "C" => "onClientResponse",
        "O" => "onOriginResponse",
        "R" => "responseProvider",
        "m" => "Missing stage"
    }

    akamai_edge_flow = {
        "n" => "Normal flow",
        "s" => "Akamai JavaScript execution engine not available",
        "r" => "Termination request",
        "T" => "Akamai edge server write timeout",
        "t" => "Akamai edge server read timeout",
        "e" => "EdgeWorkers returned error",
        "E" => "Bad input from EdgeWorkers",
        "u" => "Unexpected Termination Request for non-METHOD_GET method",
        "m" => "Error in applying EdgeWorkers commands",
        "c" => "EdgeWorkers result applied from cached results",
        "o" => "Other"
    }

    error_code = {
        "0" => "unspecified",
        "1" => "success - EdgeWorkers function executed successfully",
        "2" => "genericError - Unnamed or uncategorized error",
        "3" => "unknownEdgeWorker - Unknown EdgeWorker ID",
        "4" => "unimplementedHandler - Requested event handler not implemented by EdgeWorkers function",
        "5" => "runtimeError - Error at runtime or environment prevented EdgeWorkers execution",
        "6" => "executionError - Error during EdgeWorkers execution, such as JavaScript exception or error",
        "7" => "timeoutError - EdgeWorkers timed out",
        "8" => "resourceLimit - EdgeWorkers hit preset resource limit",
        "9" => "ringBufferError - Error receiving or sending data through RingBuffer",
        "10" => "blacklisted - EdgeWorkers function is blacklisted by Akamai JavaScript execution engine",
        "11" => "bundleVersionUnavailable - EdgeWorkers code bundle unavailable for a particular version",
        "12" => "cpuTimeoutError - JavaScript exec CPU timed out",
        "13" => "wallTimeoutError - JavaScript exec Wall timed out",
        "14" => "initCpuTimeoutError - Init CPU timed out",
        "15" => "initWallTimeoutError - Init Wall timed out",
        "16" => "responseProviderCancelled - RP cancelled",
        "17" => "unsupportedResponseProviderMethod - responseProvider is attempting to run a method other than GET.",
        "18" => "EdgeWorker deleted - EdgeWorkers function deleted by user",
        "19" => "softwareTooOld - Software too old",
        "20" => "erpDrop - Request dropped due to ERP",
        "21" => "Error discovered by the Akamai edge server"
    }

    tierID = {"100" => "Basic Compute", "200" => "Dynamic Compute"}

    ewExecution = {
        "stageInfo" => stage_info[ex[0]],
        "edgeWorkerId" => ex[1],
        "edgeWorkerProcessTime" => ex[2].to_f,
        "edgeWorkerTotalTime" => ex[3].to_f,
        "totalStageTime" => ex[4].to_f,
        "UsedMemory" => ex[5].to_f,
        "akamaiEdgeServerFlow" => akamai_edge_flow[ex[6]],
        "errorCode" => error_code[ex[7]],
        "httpStatusChange" => ex[8],
        "edgeWorkerCPUConsumed" => ex[9].to_f,
        "edgeWorkerResourceTier" => tierID[ex[10]]
    }

    return ewExecution
end


# the value of `params` is the value of the hash passed to `script_params`
# in the logstash configuration
def register(params)
	@check_variables = params["check_variables"]
end

# the filter method receives an event and must return a list of events.
# Dropping an event means not including it in the return array,
# while creating new ones only requires you to add a new instance of
# LogStash::Event to the returned array
def filter(event)
    event.to_hash.each do |key, value|
        if "#{key}".downcase.end_with?(*@check_variables)
            event.set(key,value.to_f)
        end
    end
    
    if event.to_hash.key?("ewExecutionInfo")
        item = process_execution_info event.to_hash["ewExecutionInfo"]
        event.set("ewExecutionInfoDict", item)
    end
    if event.to_hash.key?("ewUsageInfo")
        item = process_usage_info event.to_hash["ewUsageInfo"]
        event.set("ewUsageInfoDict", item)
    end
    return [event]
end