function [ output_args ] = nmss_no_hardware( input_args )
% nmss_no_hardware - start script for nmss without trying to connect to
% hardware instruments thus saving time at start up when no hardware access
% is intended (like when the user only wants to analyze the results)

    output_args = nmss('NO_HARDWARE');