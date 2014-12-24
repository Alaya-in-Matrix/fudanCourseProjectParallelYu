module learn;


reg [2:0]presentState;
reg [2:0]nextState;

always @(allInput) begin 
    case (presentState)
        MODIFIED:
            if(busWM)   begin end
            else if(busRH) begin end
            else if(cpuRH) begin end 
            else if(cpuWH) begin end
            else if(cpuRM) begin end
            else if(cpuWM) begin end
        SHARED:
            if(busWM)   begin end
            else if(busRH) begin end
            else if(cpuRH) begin end 
            else if(cpuWH) begin end
            else if(cpuRM) begin end
            else if(cpuWM) begin end
        INVALID:
            if(busWM)   begin end
            else if(busRH) begin end
            else if(cpuRH) begin end 
            else if(cpuWH) begin end
            else if(cpuRM) begin end
            else if(cpuWM) begin end
        WAITWB:
            if(busWM)   begin end
            else if(busRH) begin end
            else if(cpuRH) begin end 
            else if(cpuWH) begin end
            else if(cpuRM) begin end
            else if(cpuWM) begin end
        WAITINV:
            if(busWM)   begin end
            else if(busRH) begin end
            else if(cpuRH) begin end 
            else if(cpuWH) begin end
            else if(cpuRM) begin end
            else if(cpuWM) begin end
        WAITRD:
            if(busWM)   begin end
            else if(busRH) begin end
            else if(cpuRH) begin end 
            else if(cpuWH) begin end
            else if(cpuRM) begin end
            else if(cpuWM) begin end
        default: 
    end
end
always @(posedge clk) begin 
    newState     = nextState;
    presentState = nextState;
end
